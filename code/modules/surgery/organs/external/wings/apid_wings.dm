//Yes you get your own file because you fucking SUCK

/obj/item/organ/external/wings/apid
	name = "apid wings"
	desc = "Spread your wings and FLOOOOAAAAAT!"

	preference = "feature_apid_wings"

	bodypart_overlay = /datum/bodypart_overlay/mutant/wings/apid

	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	var/jumpdist = 3


/obj/item/organ/external/wings/apid/on_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignal(receiver, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(update_float_move))

/obj/item/organ/external/wings/apid/on_remove(mob/living/carbon/organ_owner)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_MOVABLE_PRE_MOVE))
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))

/obj/item/organ/external/wings/apid/can_soften_fall()
	return TRUE

///Check if we can flutter around
/obj/item/organ/external/wings/apid/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc))
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, REF(src))


///Moth wing bodypart overlay, including burn functionality!
/datum/bodypart_overlay/mutant/wings/apid
	feature_key = "apid_wings"
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/wings/apid/get_global_feature_list()
	return GLOB.apid_wings_list

/datum/bodypart_overlay/mutant/wings/apid/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.wear_suit?.flags_inv & HIDEMUTWINGS))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/wings/apid/get_base_icon_state()
	return sprite_datum.icon_state

/datum/sprite_accessory/apid_wings
	icon = 'icons/mob/apid_accessories/apid_wings.dmi'
	color_src = null
	em_block = TRUE

/datum/sprite_accessory/apid_wings/normal
	name = "Normal"
	icon_state = "normal"




/datum/action/item_action/organ_action/use/bee_dash
	var/jumpspeed = 1
	var/recharging_rate = 100
	var/recharging_time = 0

/datum/action/item_action/organ_action/use/bee_dash/Trigger()
	var/mob/living/carbon/L = owner
	var/obj/item/organ/external/wings/bee/wings = locate(/obj/item/organ/external/wings/bee) in L.internal_organs
	var/jumpdistance = wings.jumpdist

	if(L.stat != CONSCIOUS || L.buckled) // Has to be conscious and unbuckled
		return
	if(recharging_time > world.time)
		to_chat(L, "<span class='warning'>The wings aren't ready to dash yet!</span>")
		return
	var/datum/gas_mixture/environment = L.loc.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(L, "<span class='warning'>The atmosphere is too thin for you to dash!</span>")
		return

	var/turf/target = get_edge_target_turf(L, L.dir) //represents the user's direction
	var/hoppingtable = FALSE // Triggers the trip
	var/jumpdistancemoved = jumpdistance // temp jumpdistance
	var/turf/checkjump = get_turf(L)

	for(var/i in 1 to jumpdistance) //This is how hiero club find the tiles in front of it, tell me/fix it if there's a better way
		var/turf/T = get_step(checkjump, L.dir)
		if(T.density || !T.ClickCross(invertDir(L.dir), border_only = 1))
			break
		if(locate(/obj/structure/table) in T) // If there's a table, trip
			hoppingtable = TRUE
			jumpdistancemoved = i
			break
		if(!T.ClickCross(L.dir)) // Check for things other than tables that would block flight at the T turf
			break
		checkjump = get_step(checkjump, L.dir)

	var/datum/callback/crashcallback
	if(hoppingtable)
		crashcallback = CALLBACK(src, PROC_REF(crash_into_table), get_step(checkjump, L.dir))
	if(L.throw_at(target, jumpdistancemoved, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = crashcallback, force = MOVE_FORCE_WEAK))
		playsound(L, 'sound/creatures/bee.ogg', 50, 1, 1)
		L.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(L, "<span class='warning'>Something prevents you from dashing forward!</span>")

/datum/action/item_action/organ_action/use/bee_dash/proc/crash_into_table(turf/tableturf)
	if(owner.loc == tableturf)
		var/mob/living/carbon/L = owner
		L.take_bodypart_damage(10,check_armor = TRUE)
		L.Paralyze(40)
		L.visible_message("<span class='danger'>[L] crashes into a table, falling over!</span>",\
			"<span class='userdanger'>You violently crash into a table!</span>")
		playsound(src,'sound/weapons/punch1.ogg',50,1)
