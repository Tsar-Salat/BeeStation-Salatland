/// bump this to throw out every cached timing
#define INIT_PROGRESS_CACHE_VERSION 2
#define INIT_PROGRESS_CACHE_FILE "data/init_progress_cache.json"
/// weight of the newest boot when averaging it into history
#define INIT_BLEND_NEW 0.25
/// how far a step ramps linearly before it starts easing off
#define INIT_STEP_KNEE 0.9
/// how many maps' worth of history to keep before the least recently booted get dropped
#define INIT_PROGRESS_CACHE_MAPS 32

/**
 * Works out how far through init we are, used by lobby bar
 *
 * Init steps are nowhere near unifor. SSmapping alone dwarfs dozens of subsystems,
 * so ticking the bar once per subsystem would crawl for most of the boot and then
 * sprint. We time each subsystem instead, cache that per map, and replay the curve.
 *
 * All stored as durations and accumulated, as opposed to absolutes. Should
 * prevent the bar walking backward if some dumbass renames a subsystem
 */
/datum/init_estimator
	/// subsystem type => duration in ds, averaged over previous boots
	var/list/cached_durations = list()
	/// subsystem type => duration in ds, this boot only
	var/list/measured_durations = list()
	/// subsystem types in the order they'll init
	var/list/step_order = list()
	/// how full the bar is once step N is done
	var/list/step_bounds = list()
	/// index into step_order, 0 between steps
	var/current_step = 0
	/// when the current step started
	var/step_started = 0
	/// how long we reckon the current step will take. never 0, divided by
	var/step_predicted = 1
	/// 0..1 within the current step if it bothers reporting, else null
	var/step_reported = null
	/// slice of the current step report() writes into. SSmapping is a special boy and loads several maps back
	/// to back and each one counts 0..1, so they get a slice each instead of fighting
	var/report_low = 0
	var/report_high = 1
	/// highest fraction we've handed out. the bar does not go backwards
	var/displayed = 0
	/// init's over, bar reads full
	var/finished = FALSE
	/// when this boot started
	var/run_started = 0
	/// what a step we've no history for is worth, in ds
	var/default_duration = 1

/datum/init_estimator/New(list/ordered_subsystems)
	run_started = REALTIMEOFDAY
	load_cache()
	default_duration = average_cached_duration()
	plan(ordered_subsystems)

/// how long this boot has been going, in ds
/datum/init_estimator/proc/elapsed()
	return REALTIMEOFDAY - run_started

/// Reads timing history for the current map. Fine to call this early, SSmapping sets
/// current_map in PreInit() and SUBSYSTEM_DEF calls that from New().
/datum/init_estimator/proc/load_cache()
	if(!fexists(INIT_PROGRESS_CACHE_FILE))
		return

	var/list/decoded
	try
		decoded = json_decode(file2text(INIT_PROGRESS_CACHE_FILE))
	catch
		// mangled cache, boot with flat weights and stomp it later :P
		return

	if(!islist(decoded) || decoded["_version"] != INIT_PROGRESS_CACHE_VERSION)
		return

	// maps live under their own key rather than at the top level, so a map that happens to be
	// called _version can't collide with the header
	var/list/maps = decoded["maps"]
	if(!islist(maps))
		return

	var/list/entry = maps[SSmapping.current_map?.map_name]
	if(!islist(entry))
		return

	var/list/steps = entry["steps"]
	if(!islist(steps))
		return

	for(var/key in steps)
		// paths come back out of json as text. anything that doesn't resolve any more was
		// renamed or deleted, so it drops itself here
		var/step_type = text2path(key)
		if(!ispath(step_type, /datum/controller/subsystem))
			continue
		cached_durations[step_type] = steps[key]

/// Mean of every duration we do have history for, or 1 with no history at all - which makes
/// a first boot weigh everything equally.
/datum/init_estimator/proc/average_cached_duration()
	if(!length(cached_durations))
		return 1

	var/total = 0
	for(var/step_type as anything in cached_durations)
		total += cached_durations[step_type]
	return max(total / length(cached_durations), 1)

/// Works out how much of the bar each subsystem is worth. No history means everything
/// weighs the same, which is wrong but harmless, and one boot fixes it.
/datum/init_estimator/proc/plan(list/ordered_subsystems)
	var/total = 0
	for(var/datum/controller/subsystem/subsystem as anything in ordered_subsystems)
		// never make it to the timed bit of init_subsystem(), so no width for them
		if(subsystem.ss_flags & SS_NO_INIT)
			continue
		step_order += subsystem.type
		total += predicted_duration(subsystem.type)

	if(total <= 0)
		total = 1

	var/running = 0
	for(var/step_type as anything in step_order)
		running += predicted_duration(step_type)
		step_bounds += running / total

/// How long we think a step takes in ds. Anything we haven't seen before is worth an average
/// step rather than a flat 1 - against a warm cache a newly added subsystem would otherwise
/// get a rounding error's width next to SSmapping and stall the bar dead on itself.
/datum/init_estimator/proc/predicted_duration(step_type)
	var/duration = cached_durations[step_type]
	return isnull(duration) ? default_duration : duration

/datum/init_estimator/proc/begin_step(datum/controller/subsystem/subsystem)
	// Find() instead of just counting up, because subsystems can get skipped (already
	// initialized after a Recover, for one) and we'd rather jump the gap than desync
	current_step = step_order.Find(subsystem.type)
	step_started = REALTIMEOFDAY
	step_predicted = max(predicted_duration(subsystem.type), 1)
	step_reported = null
	report_low = 0
	report_high = 1

/datum/init_estimator/proc/end_step(datum/controller/subsystem/subsystem, duration)
	measured_durations[subsystem.type] = duration
	if(current_step)
		displayed = max(displayed, step_bounds[current_step])
	current_step = 0
	step_reported = null

/// pins following report() calls to a slice of the current step
/datum/init_estimator/proc/set_report_window(low, high)
	report_low = low
	report_high = high

/// for subsystems that know their own progress and can be bothered to say so
/datum/init_estimator/proc/report(fraction)
	if(!current_step)
		return
	step_reported = report_low + (clamp(fraction, 0, 1) * (report_high - report_low))

/// 0..1, never smaller than last time you asked
/datum/init_estimator/proc/get_fraction()
	if(finished)
		return 1

	if(current_step)
		var/lower = current_step > 1 ? step_bounds[current_step - 1] : 0
		var/upper = step_bounds[current_step]
		var/within

		if(!isnull(step_reported))
			within = step_reported
		else
			var/elapsed = REALTIMEOFDAY - step_started
			if(elapsed < step_predicted)
				within = INIT_STEP_KNEE * (elapsed / step_predicted)
			else
				// running long. ease towards the boundary instead of parking on it, a slow
				// step should still look like it's doing something
				var/overrun = (elapsed - step_predicted) / step_predicted
				within = INIT_STEP_KNEE + ((1 - INIT_STEP_KNEE) * (1 - (1 / (NUM_E ** overrun))))

		displayed = max(displayed, lower + min(within, 0.999) * (upper - lower))

	return displayed

/datum/init_estimator/proc/finish()
	finished = TRUE
	displayed = 1
	save_cache()

/**
 * Dumps this boot's timings, averaged against what was already there.
 *
 * Only writes subsystems that actually ran, so dead ones fall out of the file by
 * themselves. Note there's no separate total, it's always the sum of the steps, because
 * a total averaged on its own drifts off its own parts and the bar stops reaching full.
 */
/datum/init_estimator/proc/save_cache()
	var/map_name = SSmapping.current_map?.map_name
	if(!map_name || !length(measured_durations))
		return

	var/list/decoded
	if(fexists(INIT_PROGRESS_CACHE_FILE))
		try
			decoded = json_decode(file2text(INIT_PROGRESS_CACHE_FILE))
		catch
			decoded = null

	if(!islist(decoded) || decoded["_version"] != INIT_PROGRESS_CACHE_VERSION)
		decoded = list("_version" = INIT_PROGRESS_CACHE_VERSION)

	var/list/maps = decoded["maps"]
	if(!islist(maps))
		maps = list()
		decoded["maps"] = maps

	var/list/steps = list()
	for(var/step_type as anything in measured_durations)
		var/measured = measured_durations[step_type]
		var/previous = cached_durations[step_type]
		// lean towards the newest boot so this tracks the actual hardware after a few
		// restarts, without one weird boot wrecking it
		steps["[step_type]"] = isnull(previous) ? measured : ((1 - INIT_BLEND_NEW) * previous) + (INIT_BLEND_NEW * measured)

	maps[map_name] = list("steps" = steps, "last_used" = world.realtime)

	// a server that rotates maps would otherwise accumulate an entry per map it has ever
	// booted, so drop the least recently used until we're back under the cap
	while(length(maps) > INIT_PROGRESS_CACHE_MAPS)
		var/oldest_name
		var/oldest_time
		for(var/name in maps)
			var/list/candidate = maps[name]
			var/used = islist(candidate) ? candidate["last_used"] : 0
			if(isnull(oldest_time) || used < oldest_time)
				oldest_time = used
				oldest_name = name
		if(isnull(oldest_name))
			break
		maps -= oldest_name

	fdel(INIT_PROGRESS_CACHE_FILE)
	WRITE_FILE(file(INIT_PROGRESS_CACHE_FILE), json_encode(decoded))

#undef INIT_PROGRESS_CACHE_VERSION
#undef INIT_PROGRESS_CACHE_FILE
#undef INIT_BLEND_NEW
#undef INIT_STEP_KNEE
#undef INIT_PROGRESS_CACHE_MAPS
