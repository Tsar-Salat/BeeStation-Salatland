/**********************Asteroid**************************/

/turf/open/misc/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	baseturfs = /turf/open/misc/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	resistance_flags = INDESTRUCTIBLE

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

	damage_deflection = 0
	/// Base turf type to be created by the tunnel
	var/turf_type = /turf/open/misc/asteroid
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	/// Whether the turf has been dug or not
	var/dug = FALSE
	/// Icon state to use when broken
	var/broken_state = "asteroid_dug"
	/// The states
	var/available_states = 12

/turf/open/misc/asteroid/break_tile()
	icon_state = broken_state

/turf/open/misc/asteroid/Initialize(mapload)
	auto_gen_variants(available_states)
	variants[icon_state] = 20
	return ..()

/turf/open/misc/asteroid/proc/getDug()
	dug = TRUE
	new digResult(src, 5)
	icon_state = "[base_icon_state]_dug"

/turf/open/misc/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, "<span class='notice'>Looks like someone has dug here already.</span>")

/turf/open/misc/asteroid/burn_tile()
	return
/turf/open/misc/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/misc/asteroid/MakeDry()
	return

/turf/open/misc/asteroid/ex_act(severity, target)
	return

/turf/open/misc/asteroid/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(W.tool_behaviour == TOOL_SHOVEL || W.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		to_chat(user, "<span class='notice'>You start digging...</span>")

		if(W.use_tool(src, user, 40, volume=50))
			if(!can_dig(user))
				return TRUE
			to_chat(user, "<span class='notice'>You dig a hole.</span>")
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, W.type)
			return TRUE
	else if(istype(W, /obj/item/storage/bag/ore))
		for(var/obj/item/stack/ore/O in src)
			SEND_SIGNAL(W, COMSIG_PARENT_ATTACKBY, O)

/turf/open/misc/asteroid/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()

/turf/open/misc/asteroid/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/open/misc/asteroid/planetary
	var/static/datum/gas_mixture/immutable/planetary/GM

/turf/open/misc/asteroid/planetary/Initialize(mapload)
	if(!GM)
		GM = new
	. = ..()
	air = GM
	update_air_ref(2)
	return

/turf/open/floor/plating/lavaland_baseturf
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface

/turf/open/misc/asteroid/dug //When you want one of these to be already dug.
	dug = TRUE
	base_icon_state = "asteroid_dug"
	icon_state = "asteroid_dug"

/// Used by ashstorms to replenish basalt tiles that have been dug up without going through all of them.
GLOBAL_LIST_EMPTY(dug_up_basalt)

/turf/open/misc/asteroid/basalt
	name = "volcanic floor"
	baseturfs = /turf/open/misc/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	available_states = 12
	digResult = /obj/item/stack/ore/glass/basalt
	broken_state = "basalt_dug"

/turf/open/misc/asteroid/basalt/getDug()
	set_light(0)
	GLOB.dug_up_basalt |= src
	return ..()

/turf/open/misc/asteroid/basalt/Destroy()
	GLOB.dug_up_basalt -= src
	return ..()

/turf/open/misc/asteroid/basalt/lava //lava underneath
	baseturfs = /turf/open/lava/smooth

/turf/open/misc/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/misc/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/proc/set_basalt_light(turf/open/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/turf/open/misc/asteroid/basalt/iceland_surface
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/cold

/turf/open/misc/asteroid/basalt/planetary
	resistance_flags = INDESTRUCTIBLE
	var/static/datum/gas_mixture/immutable/planetary/GM

/turf/open/misc/asteroid/basalt/planetary/Initialize(mapload)
	if(!GM)
		GM = new
	. = ..()
	air = GM
	update_air_ref(2)
	return

/turf/open/misc/asteroid/lowpressure
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	baseturfs = /turf/open/misc/asteroid/lowpressure
	turf_type = /turf/open/misc/asteroid/lowpressure

/turf/open/misc/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/misc/asteroid/airless
	turf_type = /turf/open/misc/asteroid/airless

/turf/open/misc/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturfs = /turf/open/misc/asteroid/snow
	icon_state = "snow"
	base_icon_state = "snow"
	broken_state = "snow_dug"
	initial_gas_mix = FROZEN_ATMOS
	flags_1 = NONE
	planetary_atmos = TRUE
	use_burnt_literal = TRUE
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	digResult = /obj/item/stack/sheet/snow

/turf/open/misc/asteroid/snow/burnt_states()
	return list("snow_dug")

/turf/open/misc/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message("<span class='danger'>[src] melts away!.</span>")
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/open/misc/asteroid/snow/ice
	name = "icy snow"
	desc = "Looks colder."
	baseturfs = /turf/open/misc/asteroid/snow/ice
	initial_gas_mix = "n2=82;plasma=24;TEMP=120"
	available_states = 0
	icon_state = "snow-ice"
	base_icon_state = "snow-ice"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/misc/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/misc/asteroid/snow/temperatre
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"

/turf/open/misc/asteroid/snow/atmosphere
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/asteroid/snow/standard_air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE
