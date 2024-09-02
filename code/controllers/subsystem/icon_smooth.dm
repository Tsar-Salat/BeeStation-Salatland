SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIOTITY_SMOOTHING
	flags = SS_TICKER

	var/list/blueprint_queue = list()
	var/list/smooth_queue = list()
	var/list/deferred = list()
	/// An associative list matching atom types to their typecaches of connector exceptions. Their no_connector_typecache var is overridden to the
	/// element in this list associated with their type; if no such element exists, and their no_connector_typecache is nonempty, the typecache is created
	/// according to the type's default value for no_connector_typecache, that typecache is added to this list, and the variable is set to that typecache.
	var/list/type_no_connector_typecaches = list()


/datum/controller/subsystem/icon_smooth/fire()
	var/list/smooth_queue_cache = smooth_queue
	while(length(smooth_queue_cache))
		var/atom/smoothing_atom = smooth_queue_cache[length(smooth_queue_cache)]
		smooth_queue_cache.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTH_QUEUED))
			continue
		if(smoothing_atom.flags_1 & INITIALIZED_1)
			smoothing_atom.smooth_icon()
		else
			deferred += smoothing_atom
		if (MC_TICK_CHECK)
			return

	if (!length(smooth_queue_cache))
		if (deferred.len)
			smooth_queue = deferred
			deferred = smooth_queue_cache
		else
			can_fire = FALSE


/datum/controller/subsystem/icon_smooth/Initialize()
	var/list/queue = smooth_queue
	smooth_queue = list()

	while(length(queue))
		var/atom/smoothing_atom = queue[length(queue)]
		queue.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTH_QUEUED) || !smoothing_atom.z)
			continue
		smoothing_atom.smooth_icon()
		CHECK_TICK

	queue = blueprint_queue
	blueprint_queue = null

	for(var/atom/movable/movable_item as anything in queue)
		if(!isturf(movable_item.loc))
			continue
		var/turf/item_loc = movable_item.loc
		item_loc.add_blueprints(movable_item)

	return SS_INIT_SUCCESS

/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/thing)
	if(thing.smoothing_flags & SMOOTH_QUEUED)
		return
	thing.smoothing_flags |= SMOOTH_QUEUED
	smooth_queue += thing
	if(!can_fire)
		can_fire = TRUE

/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/thing)
	thing.smoothing_flags &= ~SMOOTH_QUEUED
	smooth_queue -= thing
	if(blueprint_queue)
		blueprint_queue -= thing
	deferred -= thing

/datum/controller/subsystem/icon_smooth/proc/get_no_connector_typecache(cache_key, list/no_connector_types, connector_strict_typing)
	var/list/cached_typecache = type_no_connector_typecaches[cache_key]
	if(cached_typecache)
		return cached_typecache

	var/list/new_typecache = typecacheof(no_connector_types, only_root_path = connector_strict_typing)
	type_no_connector_typecaches[cache_key] = new_typecache
	return new_typecache
