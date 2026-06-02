/turf/open/misc/ice
	name = "ice sheet"
	desc = "A sheet of solid ice. Looks slippery."
	icon = 'icons/turf/floors/ice_turf.dmi'
	icon_state = "ice_turf-0"
	base_icon_state = "ice_turf-0"
	initial_gas_mix = FROZEN_ATMOS
	temperature = 180
	planetary_atmos = TRUE
	baseturfs = /turf/open/misc/ice
	slowdown = 1
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ice/Initialize(mapload)
	. = ..()
	MakeSlippery(TURF_WET_PERMAFROST, INFINITY, 0, INFINITY, TRUE)

/turf/open/misc/ice/break_tile()
	return

/turf/open/misc/ice/burn_tile()
	return

/turf/open/misc/ice/smooth
	icon_state = "ice-255"
	base_icon_state = "ice"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_ICE)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_ICE)

/turf/open/misc/ice/smooth/planetary
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	planetary_atmos = TRUE

/turf/open/misc/ice/smooth/red
	icon = 'icons/turf/floors/red_ice.dmi'
	icon_state = "red_ice-0"
	base_icon_state = "red_ice"

/turf/open/misc/ice/colder
	temperature = 140

/turf/open/misc/ice/temperate
	temperature = 255.37
