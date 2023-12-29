/datum/mapGeneratorModule/bottom_layer/shuttleFloor
	spawnableTurfs = list(/turf/open/floor/plasteel/shuttle = 100)

/datum/mapGeneratorModule/border/shuttleWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall/mineral/titanium = 100)
// Generators

/datum/mapGenerator/shuttle/full
	modules = list(/datum/mapGeneratorModule/bottom_layer/shuttleFloor, \
		/datum/mapGeneratorModule/border/shuttleWalls,\
		/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room"

/datum/mapGenerator/shuttle/floor
	modules = list(/datum/mapGeneratorModule/bottom_layer/shuttleFloor)
	buildmode_name = "Block: Shuttle Floor"
