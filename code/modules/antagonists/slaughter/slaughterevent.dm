/datum/round_event_control/slaughter
	name = "Spawn Slaughter Demon"
	typepath = /datum/round_event/ghost_role/slaughter
	weight = 1 //Very rare
	max_occurrences = 1
	earliest_start = 1 HOURS
	min_players = 20
	dynamic_should_hijack = TRUE



/datum/round_event/ghost_role/slaughter
	minimum_required = 1
	role_name = "slaughter demon"

/datum/round_event/ghost_role/slaughter/spawn_role()
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		role = /datum/role_preference/midround_ghost/slaughter_demon,
		check_jobban = ROLE_SLAUGHTER_DEMON,
		poll_time = 30 SECONDS,
		role_name_text = "slaughter demon",
		alert_pic = /mob/living/simple_animal/hostile/imp/slaughter,
	)
	if(!candidate)
		return NOT_ENOUGH_PLAYERS

	var/datum/mind/player_mind = new /datum/mind(candidate.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			spawn_locs += L.loc

	if(!spawn_locs)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/turf/chosen = pick(spawn_locs)
	var/mob/living/simple_animal/hostile/imp/slaughter/S = new(chosen)
	new /obj/effect/dummy/phased_mob(chosen, S)

	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = "Slaughter Demon"
	player_mind.add_antag_datum(/datum/antagonist/slaughter)
	to_chat(S, ("<span class='bold'>You are currently not currently in the same plane of existence as the station. \
		Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc.</span>"))
	SEND_SOUND(S, 'sound/magic/demon_dies.ogg')
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a slaughter demon by an event.")
	log_game("[key_name(S)] was spawned as a slaughter demon by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
