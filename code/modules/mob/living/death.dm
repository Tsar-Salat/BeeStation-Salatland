/**
 * Blow up the mob into giblets
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Gibbed mob will drop a brain
 * * DROP_ORGANS - Gibbed mob will drop organs
 * * DROP_BODYPARTS - Gibbed mob will drop bodyparts (arms, legs, etc.)
 * * DROP_ITEMS - Gibbed mob will drop carried items (otherwise they get deleted)
 * * DROP_ALL_REMAINS - Gibbed mob will drop everything
**/
/mob/living/gib(drop_bitflags=NONE)
	var/prev_lying = lying_angle
	if(stat != DEAD)
		death(TRUE)

	if(!prev_lying)
		gib_animation()

	spill_organs(drop_bitflags)

	if(drop_bitflags & DROP_BODYPARTS)
		spread_bodyparts(drop_bitflags)

	spawn_gibs(drop_bitflags)
	SEND_SIGNAL(src, COMSIG_LIVING_GIBBED, drop_bitflags)
	qdel(src)

/mob/living/proc/gib_animation()
	return

/**
 * Spawn bloody gib mess on the floor
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BODYPARTS - Gibs will spawn with bodypart limbs present
**/
/mob/living/proc/spawn_gibs(drop_bitflags=NONE)
	new /obj/effect/gibspawner/generic(drop_location(), src, get_static_viruses())

/**
 * Drops a mob's organs on the floor
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Mob will drop a brain
 * * DROP_ORGANS - Mob will drop organs
 * * DROP_BODYPARTS - Mob will drop bodyparts (arms, legs, etc.)
 * * DROP_ALL_REMAINS - Mob will drop everything
**/
/mob/living/proc/spill_organs(drop_bitflags=NONE)
	return

/**
 * Launches all bodyparts away from the mob
 *
 * drop_bitflags: (see code/__DEFINES/blood.dm)
 * * DROP_BRAIN - Detaches the head from the mob and launches it away from the body
**/
/mob/living/proc/spread_bodyparts(drop_bitflags=NONE)
	return

/mob/living/dust(just_ash, drop_items, force)
	if(stat != DEAD)
		death(TRUE)

	if(drop_items)
		unequip_everything()

	if(buckled)
		buckled.unbuckle_mob(src, force = TRUE)

	dust_animation()
	spawn_dust(just_ash)
	QDEL_IN(src,5) // since this is sometimes called in the middle of movement, allow half a second for movement to finish, ghosting to happen and animation to play. Looks much nicer and doesn't cause multiple runtimes.

/mob/living/proc/dust_animation()
	return

/mob/living/proc/spawn_dust(just_ash = FALSE)
	new /obj/effect/decal/cleanable/ash(loc)


/mob/living/death(gibbed)
	var/was_dead_before = stat == DEAD
	set_stat(DEAD)
	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed, was_dead_before)
	unset_machine()
	timeofdeath = world.time
	tod = station_time_timestamp()
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		I.on_mob_death(src, gibbed)
	if(mind)
		if(mind.name && mind.active && !istype(T.loc, /area/ctf))
			var/rendered = span_deadsay("<b>[mind.name]</b> has died at <b>[get_area_name(T)]</b>.")
			deadchat_broadcast(rendered, follow_target = src, turf_target = T, message_type=DEADCHAT_DEATHRATTLE)
		mind.store_memory("Time of death: [tod]", 0)
	remove_from_alive_mob_list()
	if(playable)
		remove_from_spawner_menu()
	if(!gibbed && !was_dead_before)
		add_to_dead_mob_list()

	SetSleeping(0, 0)

	update_action_buttons_icon()
	update_health_hud()

	med_hud_set_health()
	med_hud_set_status()


	stop_pulling()

	. = ..()

	SEND_SIGNAL(src, COMSIG_LIVING_DEATH, gibbed)

	if (client)
		reset_perspective(null)
		reload_fullscreen()
		client.move_delay = initial(client.move_delay)
		client.player_details.time_of_death = timeofdeath
		//This first death of the game will not incur a ghost role cooldown
		client.next_ghost_role_tick = client.next_ghost_role_tick || suiciding ? world.time + CONFIG_GET(number/ghost_role_cooldown) : world.time

		INVOKE_ASYNC(client, TYPE_PROC_REF(/client, give_award), /datum/award/achievement/misc/ghosts, client.mob)

	if(mind?.current)
		client?.tgui_panel?.give_dead_popup()

	return TRUE

/mob/living/carbon/death(gibbed)
	. = ..()

	set_drugginess(0)
	set_disgust(0)
	update_damage_hud()

	if(!gibbed && !QDELETED(src))
		addtimer(CALLBACK(src, PROC_REF(med_hud_set_status)), (DEFIB_TIME_LIMIT * 10) + 10)
