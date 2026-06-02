
/**********************Asteroid**************************/

/turf/open/misc/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	baseturfs = /turf/open/misc/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	damage_deflection = 0
	variant_probability = 30
	variant_states = 12

	var/environment_type = "asteroid"
	/// Base turf type to be created by the tunnel
	var/turf_type = /turf/open/misc/asteroid
	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	/// Whether the turf has been dug or not
	var/dug = FALSE
	/// Icon state to use when broken
	var/broken_state = "asteroid_dug"

/turf/open/misc/asteroid/burn_tile()
	return

/turf/open/misc/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/misc/asteroid/MakeDry()
	return

/turf/open/misc/asteroid/ex_act(severity, target)
	return FALSE

/turf/open/misc/asteroid/attackby(obj/item/attack_item, mob/user, params)
	. = ..()
	if(.)
		return TRUE

	if(attack_item.tool_behaviour == TOOL_SHOVEL || attack_item.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		balloon_alert(user, "digging...")

		if(attack_item.use_tool(src, user, 4 SECONDS, volume = 50))
			if(!can_dig(user))
				return TRUE
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, attack_item.type)
			return TRUE
	else if(istype(attack_item, /obj/item/storage/bag/ore))
		for(var/obj/item/stack/ore/dropped_ore in src)
			SEND_SIGNAL(attack_item, COMSIG_ATOM_ATTACKBY, dropped_ore)

/// Drops itemstack when dug and changes icon
/turf/open/misc/asteroid/proc/getDug()
	if(dug || broken)
		return
	dug = TRUE
	broken = TRUE
	new dig_result(src, 5)
	update_appearance()

/// If the user can dig the turf
/turf/open/misc/asteroid/proc/can_dig(mob/user)
	if(!dug && !broken)
		return TRUE
	if(user)
		balloon_alert(user, "already excavated!")

///Refills the previously dug tile
/turf/open/misc/asteroid/proc/refill_dug()
	dug = FALSE
	broken = FALSE
	icon_state = base_icon_state
	if (variant_probability && prob(variant_probability))
		icon_state = "[base_icon_state][rand(1, variant_states)]"
	update_appearance()

/turf/open/misc/asteroid/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/open/misc/asteroid/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/open/misc/asteroid/planetary
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/lavaland_baseturf
	baseturfs = /turf/open/misc/asteroid/basalt/lava_land_surface

/turf/open/misc/asteroid/dug //When you want one of these to be already dug.
	variant_probability = 0
	dug = TRUE
	base_icon_state = "asteroid_dug"
	icon_state = "asteroid_dug"

/turf/open/misc/asteroid/lavaland_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/asteroid/lavaland_atmos

/// Used by ashstorms to replenish basalt tiles that have been dug up without going through all of them.
GLOBAL_LIST_EMPTY(dug_up_basalt)

/turf/open/misc/asteroid/basalt
	name = "volcanic floor"
	baseturfs = /turf/open/misc/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	environment_type = "basalt"
	variant_states = 12
	digResult = /obj/item/stack/ore/glass/basalt

/turf/open/misc/asteroid/basalt/getDug()
	set_light(0)
	GLOB.dug_up_basalt |= src
	return ..()

/turf/open/misc/asteroid/basalt/Destroy()
	GLOB.dug_up_basalt -= src
	return ..()

/turf/open/misc/asteroid/basalt/refill_dug()
	. = ..()
	GLOB.dug_up_basalt -= src
	set_basalt_light()

/turf/open/misc/asteroid/basalt/lava //lava underneath
	baseturfs = /turf/open/lava/smooth

/turf/open/misc/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/misc/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light()

/turf/open/misc/asteroid/basalt/proc/set_basalt_light()
	switch(icon_state)
		if("basalt1", "basalt2", "basalt3")
			set_light(BASALT_LIGHT_RANGE_BRIGHT, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			set_light(BASALT_LIGHT_RANGE_DIM, BASALT_LIGHT_POWER, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/misc/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/// Used for the lavaland icemoon ruin.
/turf/open/misc/asteroid/basalt/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/// A turf that can't we can't build openspace chasms on or spawn ruins in.
/turf/closed/mineral/volcanic/lava_land_surface/do_not_chasm
	turf_flags = NO_RUINS

/turf/open/misc/asteroid/basalt/iceland_surface
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/cold

/turf/open/misc/asteroid/basalt/planetary
	resistance_flags = INDESTRUCTIBLE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = TRUE

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
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	environment_type = "snow"
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
		visible_message(span_danger("[src] melts away!."))
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
	variant_states = 0
	variant_probability = 0
	icon_state = "snow-ice"
	base_icon_state = "snow-ice"
	environment_type = "snow_cavern"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/misc/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/misc/asteroid/snow/temperate
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/misc/asteroid/snow/atmosphere
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = FALSE

/turf/open/misc/asteroid/snow/planetary
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE

/turf/open/misc/asteroid/snow/standard_air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	planetary_atmos = FALSE
