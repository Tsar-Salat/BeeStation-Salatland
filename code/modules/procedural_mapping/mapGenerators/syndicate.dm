
// Modules

/datum/mapGeneratorModule/bottom_layer/syndie_floor
	spawnableTurfs = list(/turf/open/floor/plasteel/shuttle/red/syndicate = 100)

/datum/mapGeneratorModule/border/syndie_walls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall/r_wall = 100)


/datum/mapGeneratorModule/syndie_furniture
	clusterCheckFlags = CLUSTER_CHECK_ALL
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/table = 20,/obj/structure/chair = 15,/obj/structure/chair/stool = 10, \
		/obj/structure/frame/computer = 15, /obj/item/storage/toolbox/syndicate = 15 ,\
		/obj/structure/closet/syndicate = 25, /obj/machinery/suit_storage_unit/syndicate = 15)

/datum/mapGeneratorModule/splatter_layer/syndie_mobs
	spawnableAtoms = list(/mob/living/simple_animal/hostile/syndicate = 30, \
		/mob/living/simple_animal/hostile/syndicate/melee = 20, \
		/mob/living/simple_animal/hostile/syndicate/ranged = 20, \
		/mob/living/simple_animal/hostile/viscerator = 30)
	spawnableTurfs = list()

// Generators

/datum/mapGenerator/syndicate/empty //walls and floor only
	modules = list(/datum/mapGeneratorModule/bottom_layer/syndie_floor, \
		/datum/mapGeneratorModule/border/syndie_walls,\
		/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate"

/datum/mapGenerator/syndicate/mobsonly
	modules = list(/datum/mapGeneratorModule/bottom_layer/syndie_floor, \
		/datum/mapGeneratorModule/border/syndie_walls,\
		/datum/mapGeneratorModule/splatter_layer/syndie_mobs, \
		/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: Mobs"

/datum/mapGenerator/syndicate/furniture
	modules = list(/datum/mapGeneratorModule/bottom_layer/syndie_floor, \
		/datum/mapGeneratorModule/border/syndie_walls,\
		/datum/mapGeneratorModule/syndie_furniture, \
		/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: Furniture"

/datum/mapGenerator/syndicate/full
	modules = list(/datum/mapGeneratorModule/bottom_layer/syndie_floor, \
		/datum/mapGeneratorModule/border/syndie_walls,\
		/datum/mapGeneratorModule/syndie_furniture, \
		/datum/mapGeneratorModule/splatter_layer/syndie_mobs, \
		/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: All"
