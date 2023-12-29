//Helper Modules


// Helper to repressurize the area in case it was run in space
/datum/mapGeneratorModule/bottom_layer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottom_layer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/open/T in map)
		if(T.air)
			if(T.initial_gas_mix)
				T.air.parse_gas_string(T.initial_gas_mix)
				T.set_temperature(T.air.return_temperature())
			else
				T.air.copy_from_turf(T)

/datum/mapGeneratorModule/bottom_layer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()
	var/deleteturfs = TRUE	//separate var for the empty type.
	var/list/ignore_typecache

/datum/mapGeneratorModule/bottom_layer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty(deleteturfs? null : T.type, null, ignore_typecache, CHANGETURF_FORCEOP)

/datum/mapGeneratorModule/bottom_layer/massdelete/no_delete_mobs/New()
	..()
	ignore_typecache = GLOB.typecache_mob

/datum/mapGeneratorModule/bottom_layer/massdelete/leave_turfs
	deleteturfs = FALSE

/datum/mapGeneratorModule/bottom_layer/massdelete/regeneration_delete
	deleteturfs = FALSE

/datum/mapGeneratorModule/bottom_layer/massdelete/regeneration_delete/New()
	..()
	ignore_typecache = GLOB.typecache_mob

//Only places atoms/turfs on area borders
/datum/mapGeneratorModule/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/mapGeneratorModule/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if (get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

/datum/mapGenerator/repressurize
	modules = list(/datum/mapGeneratorModule/bottom_layer/repressurize)
	buildmode_name = "Block: Restore Roundstart Air Contents"

/datum/mapGenerator/massdelete
	modules = list(/datum/mapGeneratorModule/bottom_layer/massdelete)
	buildmode_name = "Block: Full Mass Deletion"

/datum/mapGenerator/massdelete/nomob
	modules = list(/datum/mapGeneratorModule/bottom_layer/massdelete/no_delete_mobs)
	buildmode_name = "Block: Mass Deletion - Leave Mobs"

/datum/mapGenerator/massdelete/noturf
	modules = list(/datum/mapGeneratorModule/bottom_layer/massdelete/leave_turfs)
	buildmode_name = "Block: Mass Deletion - Leave Turfs"

/datum/mapGenerator/massdelete/regen
	modules = list(/datum/mapGeneratorModule/bottom_layer/massdelete/regeneration_delete)
	buildmode_name = "Block: Mass Deletion - Leave Mobs and Turfs"
