/datum/map_generator_module/bottom_layer/cult_floor
	spawnableTurfs = list(/turf/open/floor/engine/cult = 100)

/datum/map_generator_module/border/cult_walls
	spawnableTurfs = list(/turf/closed/wall/mineral/cult = 100)

/datum/map_generator_module/bottom_layer/clock_floor
	spawnableTurfs = list(/turf/open/floor/clockwork = 100)

/datum/map_generator_module/border/clock_walls
	spawnableTurfs = list(/turf/closed/wall/clockwork = 100)

/datum/mapGenerator/cult //walls and floor only
	modules = list(/datum/map_generator_module/bottom_layer/cult_floor, \
		/datum/map_generator_module/border/cult_walls, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Cult Room"

/datum/mapGenerator/clock //walls and floor only
	modules = list(/datum/map_generator_module/bottom_layer/clock_floor, \
		/datum/map_generator_module/border/clock_walls, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Clockwork Room"

/datum/mapGenerator/cult/floor //floors only
	modules = list(/datum/map_generator_module/bottom_layer/cult_floor, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Block: Cult Floor"

/datum/mapGenerator/clock/floor //floor only
	modules = list(/datum/map_generator_module/bottom_layer/clock_floor, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Block: Clockwork Floor"
