/mob/dead/new_player/authenticated/Logout()
	ready = 0
	..()
	if(!spawning)//Here so that if they are spawning and log out, the other procs can play out and they will have a mob to come back to.
		key = null//We null their key before deleting the mob, so they are properly kicked out.
		QDEL_NULL(mind) //Clean out mind, yes this fucking sucks
		qdel(src)
	return
