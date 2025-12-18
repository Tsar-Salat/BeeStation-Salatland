/client
	var/list/smoothing_updated_atoms = list() // Track which atoms we've already updated
	var/last_smoothing_update = 0 // Last time we updated smoothing

/client/New()
	..()
	dir = NORTH

/client/Move(NewLoc, Dir)
	. = ..()
	if(. && dir != NORTH) // Only update if we're rotated and actually moved
		// Throttle updates - only every 5 deciseconds (0.5 seconds)
		if(world.time - last_smoothing_update > 5)
			update_smoothing_overlays_incremental()
			last_smoothing_update = world.time

/client/verb/spinleft()
	set name = "Spin View Counter-CW"
	set category = "OOC"
	dir = turn(dir, 90)
	smoothing_updated_atoms = list() // Clear cache when rotating
	update_smoothing_overlays()

/client/verb/spinright()
	set name = "Spin View CW"
	set category = "OOC"
	dir = turn(dir, -90)
	smoothing_updated_atoms = list() // Clear cache when rotating
	update_smoothing_overlays()

/client/proc/update_smoothing_overlays()
	set background = 1

	var/rotation_angle = dir2angle(dir)
	to_chat(src, "<span class='boldnotice'>Rotating view to [dir] ([rotation_angle]°)...</span>")

	if(!mob)
		return

	var/count = 0
	var/start_time = world.timeofday

	// Update everything in a large range
	for(var/atom/A in range(20, mob))
		if(A.smoothing_flags & SMOOTH_BITMASK)
			A.update_client_smoothing(src, rotation_angle)
			smoothing_updated_atoms[A] = TRUE
			count++

	var/elapsed = world.timeofday - start_time
	to_chat(src, "<span class='boldnotice'>Updated [count] smoothed atoms in [elapsed/10] seconds</span>")

/client/proc/update_smoothing_overlays_incremental()
	set background = 1

	if(!mob || dir == NORTH)
		return

	var/rotation_angle = dir2angle(dir)
	var/count = 0

	// Only update atoms we haven't seen before
	for(var/atom/A in range(20, mob))
		if((A.smoothing_flags & SMOOTH_BITMASK) && !smoothing_updated_atoms[A])
			A.update_client_smoothing(src, rotation_angle)
			smoothing_updated_atoms[A] = TRUE
			count++

	if(count > 0)
		to_chat(src, "<span class='notice'>Updated [count] new smoothed atoms</span>")
