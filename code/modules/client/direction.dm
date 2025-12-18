/client/New()
	..()
	dir = NORTH

/client/verb/spinleft()
	set name = "Spin View Counter-CW"
	set category = "OOC"
	dir = turn(dir, 90)
	to_chat(world, "Client used Spin View Counter-CW")
	update_smoothing_overlays()

/client/verb/spinright()
	set name = "Spin View CW"
	set category = "OOC"
	dir = turn(dir, -90)
	to_chat(world, "Client used Spin View CW")
	update_smoothing_overlays()

/client/proc/update_smoothing_overlays()
	// Update all visible smoothed atoms to show rotated versions
	var/rotation_angle = dir2angle(dir)
	to_chat(world, "<span class='boldnotice'>===== ROTATING VIEW TO [dir] (angle: [rotation_angle]) =====</span>")
	var/count = 0
	for(var/atom/A in view(mob))
		if(A.smoothing_flags & SMOOTH_BITMASK)
			A.update_client_smoothing(src, rotation_angle)
			count++
	to_chat(world, "<span class='boldnotice'>===== Updated [count] smoothed atoms =====</span>")
