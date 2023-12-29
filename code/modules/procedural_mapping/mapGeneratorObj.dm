/obj/effect/landmark/map_generator
	var/startTurfX = 0
	var/startTurfY = 0
	var/startTurfZ = -1
	var/endTurfX = 0
	var/endTurfY = 0
	var/endTurfZ = -1
	var/map_generator_type = /datum/mapGenerator/nature
	var/datum/mapGenerator/map_generator

/obj/effect/landmark/map_generator/New()
	..()
	if(startTurfZ < 0)
		startTurfZ = z
	if(endTurfZ < 0)
		endTurfZ = z
	map_generator = new map_generator_type()
	map_generator.define_region(locate(startTurfX,startTurfY,startTurfZ), locate(endTurfX,endTurfY,endTurfZ))
	map_generator.generate()
