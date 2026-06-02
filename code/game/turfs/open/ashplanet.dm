/turf/open/misc/ashplanet
	icon = MAP_SWITCH('icons/turf/floors/ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "ash"
	base_icon_state = "ash"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	// This is static
	// Done like this to avoid needing to make it dynamic and save cpu time
	// 4 to the left, 4 down
	transform = MAP_SWITCH(TRANSLATE_MATRIX(MINERAL_WALL_OFFSET, MINERAL_WALL_OFFSET), matrix())
	gender = PLURAL
	name = "ash"
	desc = "The ground is covered in volcanic ash."
	baseturfs = /turf/open/misc/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	var/smooth_icon = 'icons/turf/floors/ash.dmi'

/turf/open/misc/ashplanet/break_tile()
	return

/turf/open/misc/ashplanet/burn_tile()
	return

/turf/open/misc/ashplanet/ash
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH, SMOOTH_GROUP_CLOSED_TURFS)
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/misc/ashplanet/rocky
	gender = PLURAL
	name = "rocky ground"
	icon = MAP_SWITCH('icons/turf/floors/rocky_ash.dmi', 'icons/turf/mining.dmi')
	icon_state = "rockyash"
	base_icon_state = "rocky_ash"
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	layer = MID_TURF_LAYER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ASH_ROCKY)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ASH_ROCKY, SMOOTH_GROUP_CLOSED_TURFS)
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ashplanet/wateryrock
	gender = PLURAL
	name = "wet rocky ground"
	smoothing_flags = NONE
	icon_state = "wateryrock"
	base_icon_state = "wateryrock"
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ashplanet/wateryrock/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()

// pool.dm copy paste

/turf/open/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //If you're swimming around, you don't really want to stop swimming just like that do you?
	if(S)
		return FALSE //If you're swimming, you can't swim into a regular turf, y'dig?
	. = ..()

/turf/open/misc/beach/water/CanPass(atom/movable/mover, turf/target)
	var/datum/component/swimming/S = mover.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
	return (isliving(mover)) ? S : ..() //So you can do stuff like throw beach balls around the pool!

/turf/open/misc/beach/water/Entered(atom/movable/AM)
	. = ..()
	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT)
	if(isliving(AM))
		var/datum/component/swimming/S = AM.GetComponent(/datum/component/swimming) //You can't get in the pool unless you're swimming.
		if(!S)
			var/mob/living/carbon/C = AM
			var/component_type = /datum/component/swimming
			if(istype(C) && C?.dna?.species)
				component_type = C.dna.species.swimming_component
			AM.AddComponent(component_type)

/turf/open/misc/beach/water/Exited(atom/movable/Obj, atom/newloc)
	. = ..()
	if(!istype(newloc, /turf/open/indestructible/sound/pool))
		var/datum/component/swimming/S = Obj.GetComponent(/datum/component/swimming) //Handling admin TPs here.
		S?.ClearFromParent()

/turf/open/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/atom/movable/AM = dropping
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming)
	if(S)
		if(do_after(user, 1 SECONDS, target = dropping))
			S.ClearFromParent()
			visible_message(span_notice("[dropping] climbs out of the pool."))
			AM.forceMove(src)
	else
		. = ..()

/turf/open/misc/beach/water/MouseDrop_T(atom/dropping, mob/user)
	if(!isliving(user) || !isliving(dropping)) //No I don't want ghosts to be able to dunk people into the pool.
		return
	var/datum/component/swimming/S = dropping.GetComponent(/datum/component/swimming) //If they're already swimming, don't let them start swimming again.
	if(S)
		return FALSE
	. = ..()
	if(user != dropping)
		dropping.visible_message(span_notice("[user] starts to lower [dropping] down into [src]."), \
			span_notice("You start to lower [dropping] down into [src]."))
	else
		to_chat(user, span_notice("You start climbing down into [src]..."))
	if(do_after(user, 4 SECONDS, target = dropping))
		splash(dropping)


/turf/open/misc/beach/water/proc/splash(mob/user)
	user.forceMove(src)
	playsound(src, 'sound/effects/splosh.ogg', 100, 1) //Credit to hippiestation for this sound file!
	user.visible_message(span_boldwarning("SPLASH!"))
	var/zap = 0
	if(issilicon(user)) //Do not throw brick in a pool. Brick begs.
		zap = 1 //Sorry borgs! Swimming will come at a cost.
	if(ishuman(user))
		var/mob/living/carbon/human/F = user
		var/datum/species/SS = F.dna.species
		if(SS.inherent_biotypes & MOB_ROBOTIC)  //ZAP goes the IPC!
			zap = 2 //You can protect yourself from water damage with thick clothing.
		if(F.head && isclothing(F.head))
			var/obj/item/clothing/CH = F.head
			if (CH.clothing_flags & THICKMATERIAL) //Skinsuit should suffice! But IPCs are robots and probably not water-sealed.
				zap --
		if(F.wear_suit && isclothing(F.wear_suit))
			var/obj/item/clothing/CS = F.wear_suit
			if (CS.clothing_flags & THICKMATERIAL)
				zap --
	if(zap > 0)
		user.emp_act(zap)
		user.emote("scream") //Chad coders use M.say("*scream")
		do_sparks(zap, TRUE, user)
		to_chat(user, span_userdanger("WARNING: WATER DAMAGE DETECTED!"))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "robotpool", /datum/mood_event/robotpool)
	else
		if(!check_clothes(user))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolparty)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "pool", /datum/mood_event/poolwet)

//Largely a copypaste from shower.dm. Checks if the mob was stupid enough to enter a pool fully clothed. We allow masks as to not discriminate against clown and mime players.
/turf/open/misc/beach/water/proc/check_clothes(mob/living/carbon/human/H)
	if(!istype(H) || iscatperson(H)) //Don't care about non humans.
		return FALSE
	if(H.wear_suit && (H.wear_suit.clothing_flags))
		// Do not check underclothing if the over-suit is suitable.
		// This stops people feeling dumb if they're showering
		// with a radiation suit on.
		return FALSE

	. = FALSE
	if(!(H.wear_suit?.clothing_flags))
		return TRUE
	if(!(H.w_uniform?.clothing_flags))
		return TRUE
	if(!(H.head?.clothing_flags))
		return TRUE

/turf/open/misc/beach/deep_water
	desc = "Deep water. What if there's sharks?"
	icon_state = "water_deep"
	name = "deep water"
	density = 1 //no swimming
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)
