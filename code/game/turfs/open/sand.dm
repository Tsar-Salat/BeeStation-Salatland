/turf/open/misc/beach
	name = "beach"
	desc = "Sandy."
	icon = 'icons/turf/sand.dmi'
	flags_1 = NONE
	planetary_atmos = TRUE
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/beach/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/misc/beach/sand/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "sand[rand(1,4)]"

/turf/open/misc/beach/sand
	gender = PLURAL
	name = "sand"
	desc = "Surf's up."
	icon_state = "Water-0"
	baseturfs = /turf/open/misc/beach/sand

/turf/open/misc/beach/sand/Initialize(mapload)
	. = ..()
	if(prob(15))
		icon_state = "sand[rand(1,4)]"

/turf/open/misc/beach/coast
	name = "coastline"
	desc = "Tide's high tonight. Charge your batons."
	icon = 'icons/turf/beach.dmi'
	icon_state = "beach"
	base_icon_state = "beach"
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/misc/beach/coast/break_tile()
	. = ..()
	icon_state = "beach"

/turf/open/misc/beach/coast/corner
	icon_state = "beach-corner"
	base_icon_state = "beach-corner"

/turf/open/misc/beach/coast/corner/break_tile()
	. = ..()
	icon_state = "beach-corner"

/turf/open/misc/beach/water
	name = "water"
	desc = "Ocean waves: Salty breeze, briny depths, endless blue expanse."
	icon = 'icons/misc/Beach/beach.dmi'
	icon_state = "Water-255"
	base_icon_state = "Water"
	baseturfs = /turf/open/misc/beach/water
	slowdown = 3
	bullet_sizzle = TRUE
	bullet_bounce_sound = 'sound/effects/splash.ogg'
	footstep = FOOTSTEP_WATER
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS, SMOOTH_GROUP_FLOOR_ICE, SMOOTH_GROUP_CLOSED_TURFS)

/turf/open/misc/sandy_dirt
	gender = PLURAL
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "sand"
	base_icon_state = "sand"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/misc/sandy_dirt/break_tile()
	. = ..()
	icon_state = "sand_damaged"

/turf/open/misc/sandy_dirt/broken_states()
	return list("sand_damaged")

/turf/open/misc/ironsand
	gender = PLURAL
	name = "iron sand"
	desc = "Like sand, but more <i>iron</i>."
	icon_state = "ironsand1"
	base_icon_state = "ironsand1"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ironsand/Initialize(mapload)
	. = ..()
	icon_state = "ironsand[rand(1,15)]"
