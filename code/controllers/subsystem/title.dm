SUBSYSTEM_DEF(title)
	name = "Title Screen"
	// deliberately not SS_NO_FIRE. the bar is driven from fire() so it stops dead when DM
	// does - animate it clientside instead and a wedged server keeps sliding merrily
	// towards 100%, which is the one thing you actually want to notice
	//
	// not SS_BACKGROUND either. background subsystems draw from the leftover tick budget and
	// are the first thing dropped when the MC is overloaded, which is the steady state during
	// mapload - the bar would stall exactly when there's most to report. one maptext write and
	// one animate() a second is cheap enough to just run normally
	wait = 1 SECONDS
	runlevels = ALL
	init_stage = INITSTAGE_EARLY

	var/file_path
	var/lobby_screen_size = "15x15"
	var/icon/icon
	var/icon/previous_icon
	var/turf/newplayer_start_loc
	var/turf/closed/indestructible/splashscreen/splash_turf

	/// lobby image size in tiles, off the title screen filename
	var/screen_tiles_x = 15
	var/screen_tiles_y = 15

	/// everything else hangs off this, it's what goes in the turf's vis_contents
	var/obj/effect/splashscreen/master_object
	/// thin rim behind the bar so it doesn't look like a bare rectangle
	var/obj/effect/splashscreen/bar/bar_frame
	/// the empty part
	var/obj/effect/splashscreen/bar/bar_track
	/// the full part
	var/obj/effect/splashscreen/bar/bar_fill
	/// flash over whatever we just gained, fades as the fill catches up to it
	var/obj/effect/splashscreen/bar/bar_delta
	/// whichever subsystem is initializing
	var/obj/effect/splashscreen/text/status_label
	/// percentage and elapsed time. also the liveness tell - seconds stop counting, DM's dead
	var/obj/effect/splashscreen/text/readout_label

	/// bar geometry in pixels, worked out from the lobby image size
	var/bar_width = 288
	var/bar_height = 10
	var/bar_x = 0
	var/bar_y = 0
	/// status line as it currently reads
	var/current_status = "Starting up..."
	/// last fraction the bar was given. feeds the flash and the percentage
	var/last_fraction = 0

/datum/controller/subsystem/title/Initialize()
	if(file_path && icon)
		return SS_INIT_SUCCESS

	if(fexists("data/previous_title.dat"))
		var/previous_path = rustg_file_read("data/previous_title.dat")
		if(istext(previous_path))
			previous_icon = new(previous_icon)
	fdel("data/previous_title.dat")

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	LAZYREMOVE(provisional_title_screens, "exclude")
	if(length(provisional_title_screens))
		file_path = "[global.config.directory]/title_screens/images/[pick(provisional_title_screens)]"
	else
		file_path = "icons/runtime/default_title.dmi"

	ASSERT(fexists(file_path))

	icon = new(fcopy_rsc(file_path))

	//Calculate the screen size
	var/regex/size_regex = new("(\\d+)x(\\d+)\\.\\w*$")
	if (size_regex.Find(file_path))
		var/width = text2num(size_regex.group[1])
		var/height = text2num(size_regex.group[2])
		lobby_screen_size = "[width]x[height]"
		screen_tiles_x = width
		screen_tiles_y = height

		//Update the new player start (views are centered)
		var/new_player_x = splash_turf.x + floor(width / 2)
		var/new_player_y = splash_turf.y + floor(height / 2)
		newplayer_start_loc = locate(new_player_x, new_player_y, splash_turf.z)
		// Reset the newplayer start loc
		GLOB.newplayer_start.Cut()
		GLOB.newplayer_start += newplayer_start_loc

		//Update fast joiners
		for (var/mob/dead/new_player/fast_joiner in GLOB.player_list)
			if(isnull(fast_joiner.client?.view_size))
				fast_joiner.client?.change_view(getScreenSize(fast_joiner))
			else
				fast_joiner.client?.view_size.resetToDefault(getScreenSize(fast_joiner))
			// Execute this immediately, change_view runs through SStimer which doesn't execute until after
			// initialisation
			if (fast_joiner.client?.prefs?.read_player_preference(/datum/preference/toggle/auto_fit_viewport))
				fast_joiner.client?.fit_viewport()
			fast_joiner.forceMove(newplayer_start_loc)

	if(splash_turf)
		splash_turf.icon = icon
		setup_objects()

	return SS_INIT_SUCCESS

/// Builds the lobby progress display. Call it as often as you like, it'll reattach and
/// relay what's already there rather than making a second set.
/datum/controller/subsystem/title/proc/setup_objects()
	if(!splash_turf)
		return

	// measure the image instead of trusting the WxH on the filename. screens named
	// without it fall back to 15x15 and the bar ends up somewhere silly on anything
	// that isn't actually 480x480
	var/screen_px = screen_tiles_x * ICON_SIZE_X
	var/screen_py = screen_tiles_y * ICON_SIZE_Y
	if(icon)
		screen_px = icon.Width() || screen_px
		screen_py = icon.Height() || screen_py

	bar_width = round(screen_px * 0.6)
	bar_x = round((screen_px - bar_width) * 0.5)
	bar_y = round(screen_py * 0.14)

	if(!master_object)
		master_object = new(null)
		master_object.name = "Lobby Screen"

		// cool and washed out on purpose. this sits on top of whatever title art a server
		// happens to have installed, so it needs to stay readable over anything rather
		// than match any one image
		bar_frame = new(null)
		bar_frame.name = "Progress Bar Frame"
		bar_frame.color = "#7fb4c9"
		bar_frame.alpha = 90
		master_object.vis_contents += bar_frame

		bar_track = new(null)
		bar_track.name = "Progress Bar Track"
		bar_track.color = "#0a1218"
		bar_track.alpha = 220
		bar_track.layer = master_object.layer + 0.05
		master_object.vis_contents += bar_track

		bar_fill = new(null)
		bar_fill.name = "Progress Bar Fill"
		bar_fill.color = "#4fc3e8"
		bar_fill.layer = master_object.layer + 0.1
		master_object.vis_contents += bar_fill

		bar_delta = new(null)
		bar_delta.name = "Progress Bar Highlight"
		bar_delta.color = "#eafcff"
		bar_delta.alpha = 0
		bar_delta.layer = master_object.layer + 0.15
		master_object.vis_contents += bar_delta

		status_label = new(null)
		status_label.name = "Status Text"
		master_object.vis_contents += status_label

		readout_label = new(null)
		readout_label.name = "Readout Text"
		master_object.vis_contents += readout_label

	// laid out again every call, so swapping in a different sized title screen at runtime
	// moves the bar with it instead of leaving it stranded
	bar_frame.set_size(bar_width + 2, bar_height + 2)
	bar_frame.pixel_x = bar_x - 1
	bar_frame.pixel_y = bar_y - 1

	bar_track.set_size(bar_width, bar_height)
	bar_track.pixel_x = bar_x
	bar_track.pixel_y = bar_y

	bar_fill.set_size(bar_width * last_fraction, bar_height)
	bar_fill.pixel_x = bar_x
	bar_fill.pixel_y = bar_y

	bar_delta.pixel_y = bar_y

	// maptext fills its box from the top down, so keep the boxes about one line tall.
	// any taller and the text drifts off up away from where you put it
	status_label.maptext_width = bar_width
	status_label.maptext_height = 14
	status_label.pixel_x = bar_x
	status_label.pixel_y = bar_y + bar_height + 4

	readout_label.maptext_width = bar_width
	readout_label.maptext_height = 10
	readout_label.pixel_x = bar_x
	readout_label.pixel_y = bar_y - 14

	refresh_text()

	splash_turf.vis_contents |= master_object

/// the line above the bar. MC pokes this as each subsystem starts
/datum/controller/subsystem/title/proc/set_status(text)
	current_status = text
	refresh_text()

/datum/controller/subsystem/title/proc/refresh_text()
	// MAPTEXT() gets us the font and the 1px black outline off the skin stylesheet, which
	// is the only reason this stays readable on top of a bright title screen. inner span
	// is just size and colour
	if(status_label)
		status_label.maptext = MAPTEXT("<span class='center extremelybig' style='color: #e8f4fa'>[current_status]</span>")

	if(readout_label)
		var/elapsed = Master.init_estimator ? Master.init_estimator.elapsed() : 0
		readout_label.maptext = MAPTEXT("<span class='center' style='color: #8fa6b3'>[round(last_fraction * 100)]%   [round(elapsed / 10)]s elapsed</span>")

/datum/controller/subsystem/title/fire(resumed)
	var/datum/init_estimator/estimator = Master.init_estimator
	if(!estimator || !bar_fill)
		// nothing to drive the bar with and nothing that'll bring one back. stop rather than
		// waking up every second for the rest of the round to do nothing
		can_fire = FALSE
		return

	var/fraction = estimator.get_fraction()
	var/previous = last_fraction
	last_fraction = fraction

	// animate across exactly one fire interval. keeps the motion smooth without ever
	// letting the bar get ahead of something DM has actually confirmed
	bar_fill.set_size(bar_width * fraction, bar_height, wait)

	// flash whatever we just gained and fade it out as the fill catches up. pinched from
	// nova's nested sub-progress bar, it makes each step read as a thing that happened
	// rather than the bar just drifting along
	if(fraction - previous > 0.002)
		bar_delta.pixel_x = bar_x + round(bar_width * previous)
		bar_delta.set_size(bar_width * (fraction - previous), bar_height)
		bar_delta.alpha = 200
		animate(bar_delta, alpha = 0, time = wait, easing = SINE_EASING)

	refresh_text()

	// nothing left to say until the round starts and hide_progress() clears it. leaving
	// the timer frozen where it is conveniently shows the total boot time
	if(estimator.finished)
		can_fire = FALSE

/// fades the whole lot out once it's got nothing left to report
/datum/controller/subsystem/title/proc/hide_progress()
	can_fire = FALSE
	for(var/obj/effect/splashscreen/element in list(bar_frame, bar_track, bar_fill, bar_delta, status_label, readout_label))
		animate(element, alpha = 0, time = 1 SECONDS)

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				if(splash_turf)
					splash_turf.icon = icon
					// new screen might be a different size, shove the bar back where it goes
					setup_objects()

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		var/F = file("data/previous_title.dat")
		WRITE_FILE(F, file_path)

	for(var/thing in GLOB.clients_unsafe)
		if(!thing)
			continue
		var/atom/movable/screen/splash/S = new(null, thing, FALSE)
		S.fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon

	screen_tiles_x = SStitle.screen_tiles_x
	screen_tiles_y = SStitle.screen_tiles_y
	master_object = SStitle.master_object
	bar_frame = SStitle.bar_frame
	bar_track = SStitle.bar_track
	bar_fill = SStitle.bar_fill
	bar_delta = SStitle.bar_delta
	status_label = SStitle.status_label
	readout_label = SStitle.readout_label
	bar_width = SStitle.bar_width
	bar_height = SStitle.bar_height
	bar_x = SStitle.bar_x
	bar_y = SStitle.bar_y
	current_status = SStitle.current_status
	last_fraction = SStitle.last_fraction
