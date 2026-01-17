/mob/living/carbon/death(gibbed)
	if(stat == DEAD)
		return

	silent = FALSE
	losebreath = 0

	if(!gibbed)
		INVOKE_ASYNC(src, PROC_REF(emote), "deathgasp")

	. = ..()

	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_death()

/mob/living/carbon/proc/inflate_gib() // Plays an animation that makes mobs appear to inflate before finally gibbing
	addtimer(CALLBACK(src, PROC_REF(gib), DROP_BRAIN|DROP_ORGANS|DROP_ITEMS), 25)
	var/matrix/M = matrix()
	M.Scale(1.8, 1.2)
	animate(src, time = 40, transform = M, easing = SINE_EASING)

/mob/living/carbon/gib(drop_bitflags=NONE)
	if(drop_bitflags & DROP_ITEMS)
		for(var/obj/item/W in src)
			dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
	var/atom/Tsec = drop_location()
	for(var/mob/M in src)
		M.forceMove(Tsec)
		visible_message(span_danger("[M] bursts out of [src]!"))
	return ..()

/mob/living/carbon/spill_organs(drop_bitflags=NONE)
	var/atom/Tsec = drop_location()

	for(var/obj/item/organ/organ as anything in internal_organs)
		if((drop_bitflags & DROP_BRAIN) && istype(organ, /obj/item/organ/brain))
			if(drop_bitflags & DROP_BODYPARTS)
				continue // the head will drop, so the brain should stay inside

			organ.Remove(src)
			organ.forceMove(Tsec)
			organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)
			continue

		if((drop_bitflags & DROP_ORGANS) && !istype(organ, /obj/item/organ/brain))
			if((drop_bitflags & DROP_BODYPARTS) && (check_zone(organ.zone) != BODY_ZONE_CHEST))
				continue // only chest & groin organs will be ejected

			organ.Remove(src)
			organ.forceMove(Tsec)
			organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)
			continue

		qdel(organ)

/mob/living/carbon/spread_bodyparts(drop_bitflags=NONE)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(!(drop_bitflags & DROP_BRAIN) && part.body_zone == BODY_ZONE_HEAD)
			continue
		else if(part.body_zone == BODY_ZONE_CHEST)
			continue
		part.drop_limb()
		part.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)
