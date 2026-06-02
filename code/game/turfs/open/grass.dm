/turf/open/misc/grass
	name = "lush grass"
	desc = "Green and warm, makes you want to lay down."
	icon = 'icons/turf/floors/grass.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	baseturfs = /turf/open/misc/sandy_dirt
	bullet_bounce_sound = null
	layer = EDGED_TURF_LAYER
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_FLOOR_GRASS)
	tiled_dirt = FALSE
	transform = MAP_SWITCH(TRANSLATE_MATRIX(-9, -9), matrix())
	resistance_flags = INDESTRUCTIBLE
	planetary_atmos = TRUE
	init_air = FALSE //grass should act almost like space tiles as has the entire plannets atmos to cycle with
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/open/misc/grass/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
