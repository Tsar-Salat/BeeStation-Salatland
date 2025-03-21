#define CAN_HEAR_MASTERS (1<<0)
#define CAN_HEAR_ACTIVE_HOLOCALLS (1<<1)
#define CAN_HEAR_RECORD_MODE (1<<2)
#define CAN_HEAR_ALL_FLAGS (CAN_HEAR_MASTERS|CAN_HEAR_ACTIVE_HOLOCALLS|CAN_HEAR_RECORD_MODE)

/* Holograms!
 * Contains:
 *		Holopad
 *		Hologram
 *		Other stuff
 */

/*
Revised. Original based on space ninja hologram code. Which is also mine. /N
How it works:
AI clicks on holopad in camera view. View centers on holopad.
AI clicks again on the holopad to display a hologram. Hologram stays as long as AI is looking at the pad and it (the hologram) is in range of the pad.
AI can use the directional keys to move the hologram around, provided the above conditions are met and the AI in question is the holopad's master.
Any number of AIs can use a holopad. /Lo6
AI may cancel the hologram at any time by clicking on the holopad once more.

Possible to do for anyone motivated enough:
	Give an AI variable for different hologram icons.
	Itegrate EMP effect to disable the unit.
*/


/*
 * Holopad
 */

#define HOLOPAD_PASSIVE_POWER_USAGE 1
#define HOLOGRAM_POWER_USAGE 2

/obj/machinery/holopad
	name = "holopad"
	desc = "It's a floor-mounted device for projecting holographic images."
	icon_state = "holopad0"
	layer = LOW_OBJ_LAYER
	plane = FLOOR_PLANE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 100
	max_integrity = 300
	armor_type = /datum/armor/machinery_holopad
	circuit = /obj/item/circuitboard/machine/holopad
	var/list/masters //List of living mobs that use the holopad
	var/list/holorays //Holoray-mob link.
	var/last_request = 0 //to prevent request spam. ~Carn
	var/holo_range = 5 // Change to change how far the AI can move away from the holopad before deactivating.
	var/temp = ""
	var/list/holo_calls	//array of /datum/holocalls
	var/datum/holocall/outgoing_call	//do not modify the datums only check and call the public procs
	var/obj/item/disk/holodisk/disk //Record disk
	var/replay_mode = FALSE //currently replaying a recording
	var/loop_mode = FALSE //currently looping a recording
	var/record_mode = FALSE //currently recording
	var/record_start = 0  	//recording start time
	var/record_user			//user that inititiated the recording
	var/obj/effect/overlay/holo_pad_hologram/replay_holo	//replay hologram
	var/static/force_answer_call = FALSE	//Calls will be automatically answered after a couple rings, here for debugging
	var/static/list/holopads = list()
	var/obj/effect/overlay/holoray/ray
	var/ringing = FALSE
	var/offset = FALSE
	var/on_network = TRUE
	///bitfield. used to turn on and off hearing sensitivity depending on if we can act on Hear() at all - meant for lowering the number of unessesary hearable atoms
	var/can_hear_flags = NONE


/datum/armor/machinery_holopad
	melee = 50
	bullet = 20
	laser = 20
	energy = 20
	fire = 50

/obj/machinery/holopad/tutorial
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODECONSTRUCT_1
	on_network = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor
	var/proximity_range = 1

/obj/machinery/holopad/tutorial/Initialize(mapload)
	. = ..()
	if(proximity_range)
		proximity_monitor = new(src, proximity_range)
	if(mapload)
		var/obj/item/disk/holodisk/new_disk = locate(/obj/item/disk/holodisk) in src.loc
		if(new_disk && !disk)
			new_disk.forceMove(src)
			disk = new_disk

/obj/machinery/holopad/tutorial/attack_hand(mob/user, list/modifiers)
	if(!istype(user))
		return
	if(user.incapacitated() || !is_operational)
		return
	if(replay_mode)
		replay_stop()
	else if(disk?.record)
		replay_start()

/obj/machinery/holopad/tutorial/HasProximity(atom/movable/AM)
	if (!isliving(AM))
		return
	if(!replay_mode && (disk && disk.record))
		replay_start()

/obj/machinery/holopad/Initialize(mapload)
	. = ..()
	if(on_network)
		holopads += src

/obj/machinery/holopad/Destroy()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

	for(var/datum/holocall/holocall_to_disconnect as anything in holo_calls)
		holocall_to_disconnect.ConnectionFailure(src)

	for (var/I in masters)
		clear_holo(I)

	if(replay_mode)
		replay_stop()
	if(record_mode)
		record_stop()

	QDEL_NULL(disk)

	holopads -= src
	return ..()

/obj/machinery/holopad/power_change()
	. = ..()
	if (!powered())
		if(replay_mode)
			replay_stop()
		if(record_mode)
			record_stop()
		if(outgoing_call)
			outgoing_call.ConnectionFailure(src)

/obj/machinery/holopad/atom_break()
	. = ..()
	if(outgoing_call)
		outgoing_call.ConnectionFailure(src)

/obj/machinery/holopad/RefreshParts()
	var/holograph_range = 4
	for(var/obj/item/stock_parts/capacitor/B in component_parts)
		holograph_range += 1 * B.rating
	holo_range = holograph_range

/obj/machinery/holopad/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Current projection range: <b>[holo_range]</b> units.")

/obj/machinery/holopad/attackby(obj/item/P, mob/user, params)
	if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", P))
		return

	if(default_pry_open(P))
		return

	if(default_deconstruction_crowbar(P))
		return

	if(istype(P,/obj/item/disk/holodisk))
		if(disk)
			to_chat(user,span_notice("There's already a disk inside [src]"))
			return
		if (!user.transferItemToLoc(P,src))
			return
		to_chat(user,span_notice("You insert [P] into [src]"))
		disk = P
		updateDialog()
		return

	return ..()


/obj/machinery/holopad/ui_interact(mob/living/carbon/human/user) //Carn: Hologram requests.
	. = ..()
	if(!istype(user))
		return

	if(outgoing_call || user.incapacitated() || !is_operational)
		return

	user.set_machine(src)
	var/dat
	if(temp)
		dat = temp
	else
		if(on_network)
			dat += "<a href='byond://?src=[REF(src)];AIrequest=1'>Request an AI's presence</a><br>"
			dat += "<a href='byond://?src=[REF(src)];Holocall=1'>Call another holopad</a><br>"
		if(disk)
			if(disk.record)
				//Replay
				dat += "<a href='byond://?src=[REF(src)];replay_start=1'>Replay disk recording</a><br>"
				dat += "<a href='byond://?src=[REF(src)];loop_start=1'>Loop disk recording</a><br>"
				//Clear
				dat += "<a href='byond://?src=[REF(src)];record_clear=1'>Clear disk recording</a><br>"
			else
				//Record
				dat += "<a href='byond://?src=[REF(src)];record_start=1'>Start new recording</a><br>"
			//Eject
			dat += "<a href='byond://?src=[REF(src)];disk_eject=1'>Eject disk</a><br>"

		if(LAZYLEN(holo_calls))
			dat += "=====================================================<br>"

		if(on_network)
			var/one_answered_call = FALSE
			var/one_unanswered_call = FALSE
			for(var/I in holo_calls)
				var/datum/holocall/HC = I
				if(HC.connected_holopad != src)
					dat += "<a href='byond://?src=[REF(src)];connectcall=[REF(HC)]'>Answer call from [get_area(HC.calling_holopad)]</a><br>"
					one_unanswered_call = TRUE
				else
					one_answered_call = TRUE

			if(one_answered_call && one_unanswered_call)
				dat += "=====================================================<br>"
			//we loop twice for formatting
			for(var/I in holo_calls)
				var/datum/holocall/HC = I
				if(HC.connected_holopad == src)
					dat += "<a href='byond://?src=[REF(src)];disconnectcall=[REF(HC)]'>Disconnect call from [HC.user]</a><br>"


	var/datum/browser/popup = new(user, "holopad", name, 300, 175)
	popup.set_content(dat)
	popup.open()

//setters
/**
 * setter for can_hear_flags. handles adding or removing the given flag on can_hear_flags and then adding hearing sensitivity or removing it depending on the final state
 * this is necessary because holopads are a significant fraction of the hearable atoms on station which increases the cost of procs that iterate through hearables
 * so we need holopads to not be hearable until it is needed
 *
 * * flag - one of the can_hear_flags flag defines
 * * set_flag - boolean, if TRUE sets can_hear_flags to that flag and might add hearing sensitivity if can_hear_flags was NONE before,
 * if FALSE unsets the flag and possibly removes hearing sensitivity
 */
/obj/machinery/holopad/proc/set_can_hear_flags(flag, set_flag = TRUE)
	if(!(flag & CAN_HEAR_ALL_FLAGS))
		return FALSE //the given flag doesnt exist

	if(set_flag)
		if(can_hear_flags == NONE)//we couldnt hear before, so become hearing sensitive
			become_hearing_sensitive()

		can_hear_flags |= flag
		return TRUE

	else
		can_hear_flags &= ~flag
		if(can_hear_flags == NONE)
			lose_hearing_sensitivity()

		return TRUE

///setter for adding/removing holocalls to this holopad. used to update the holo_calls list and can_hear_flags
///adds the given holocall if add_holocall is TRUE, removes if FALSE
/obj/machinery/holopad/proc/set_holocall(datum/holocall/holocall_to_update, add_holocall = TRUE)
	if(!istype(holocall_to_update))
		return FALSE

	if(add_holocall)
		set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS)
		LAZYADD(holo_calls, holocall_to_update)

	else
		LAZYREMOVE(holo_calls, holocall_to_update)
		if(!LAZYLEN(holo_calls))
			set_can_hear_flags(CAN_HEAR_ACTIVE_HOLOCALLS, FALSE)

	return TRUE

//Stop ringing the AI!!
/obj/machinery/holopad/proc/hangup_all_calls()
	for(var/datum/holocall/holocall_to_disconnect as anything in holo_calls)
		holocall_to_disconnect.Disconnect(src)

/obj/machinery/holopad/Topic(href, href_list)
	if(..() || isAI(usr))
		return
	add_fingerprint(usr)
	if(!is_operational)
		return
	if (href_list["AIrequest"])
		if(last_request + 200 < world.time)
			last_request = world.time
			temp = "You requested an AI's presence.<BR>"
			temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
			var/area/area = get_area(src)
			for(var/mob/living/silicon/ai/AI as anything in GLOB.ai_list)
				if(!AI.client)
					continue
				to_chat(AI, span_info("Your presence is requested at <a href='byond://?src=[REF(AI)];jumptoholopad=[REF(src)]'>\the [area]</a>."))
		else
			temp = "A request for AI presence was already sent recently.<BR>"
			temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"

	else if(href_list["Holocall"])
		if(outgoing_call)
			return

		temp = "You must stand on the holopad to make a call!<br>"
		temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
		if(usr.loc == loc)
			var/list/callnames = list()
			for(var/I in holopads)
				var/area/A = get_area(I)
				if(A)
					LAZYADD(callnames[A], I)
			callnames -= get_area(src)

			var/result = input(usr, "Choose an area to call", "Holocall") as null|anything in sort_names(callnames)
			if(QDELETED(usr) || !result || outgoing_call)
				return

			if(usr.loc == loc)
				temp = "Dialing...<br>"
				temp += "<A href='byond://?src=[REF(src)];mainmenu=1'>Main Menu</A>"
				new /datum/holocall(usr, src, callnames[result])

	else if(href_list["connectcall"])
		var/datum/holocall/call_to_connect = locate(href_list["connectcall"]) in holo_calls
		if(!QDELETED(call_to_connect))
			call_to_connect.Answer(src)
		temp = ""

	else if(href_list["disconnectcall"])
		var/datum/holocall/call_to_disconnect = locate(href_list["disconnectcall"]) in holo_calls
		if(!QDELETED(call_to_disconnect))
			call_to_disconnect.Disconnect(src)
		temp = ""

	else if(href_list["mainmenu"])
		temp = ""
		if(outgoing_call)
			outgoing_call.Disconnect()

	else if(href_list["disk_eject"])
		if(disk && !replay_mode)
			disk.forceMove(drop_location())
			disk = null

	else if(href_list["replay_stop"])
		replay_stop()
	else if(href_list["replay_start"])
		replay_start()
	else if(href_list["loop_start"])
		loop_mode = TRUE
		replay_start()
	else if(href_list["record_start"])
		record_start(usr)
	else if(href_list["record_stop"])
		record_stop()
	else if(href_list["record_clear"])
		record_clear()
	else if(href_list["offset"])
		offset++
		if (offset > 4)
			offset = FALSE
		var/turf/new_turf
		if (!offset)
			new_turf = get_turf(src)
		else
			new_turf = get_step(src, GLOB.cardinals[offset])
		replay_holo.forceMove(new_turf)
	updateDialog()

//do not allow AIs to answer calls or people will use it to meta the AI sattelite
/obj/machinery/holopad/attack_ai(mob/living/silicon/ai/user)
	if (!istype(user))
		return
	if (!on_network)
		return
	/*There are pretty much only three ways to interact here.
	I don't need to check for client since they're clicking on an object.
	This may change in the future but for now will suffice.*/
	if(user.eyeobj.loc != src.loc)//Set client eye on the object if it's not already.
		user.eyeobj.setLoc(get_turf(src))
	else if(!LAZYLEN(masters) || !masters[user])//If there is no hologram, possibly make one.
		activate_holo(user)
	else//If there is a hologram, remove it.
		clear_holo(user)

//this really should not be processing by default with how common holopads are
//everything in here can start processing if need be once first set and stop processing after being unset
/obj/machinery/holopad/process()
	if(LAZYLEN(masters)) //As someone in the original PR commented, the original code was indeed depressing
		for(var/mob/living/master as anything in masters)
			if(!is_operational || !validate_user(master))
				clear_holo(master)

	if(outgoing_call)
		outgoing_call.Check()

	ringing = FALSE

	for(var/datum/holocall/holocall as anything in holo_calls)
		if(holocall.connected_holopad == src)
			continue

		if(force_answer_call && world.time > (holocall.call_start_time + (HOLOPAD_MAX_DIAL_TIME / 2)))
			holocall.Answer(src)
			break
		/*
		if(holocall.head_call && !secure)
			holocall.Answer(src)
			break
		*/
		if(outgoing_call)
			holocall.Disconnect(src)//can't answer calls while calling
		else
			playsound(src, 'sound/machines/twobeep.ogg', 100) //bring, bring!
			ringing = TRUE

	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/holopad/proc/activate_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(!istype(AI))
		AI = null

	if(is_operational && (!AI || AI.eyeobj.loc == loc))//If the projector has power and client eye is on it
		if (AI && istype(AI.current_holopad, /obj/machinery/holopad))
			to_chat(user, "[span_danger("ERROR:")] \black Image feed in progress.")
			return

		var/obj/effect/overlay/holo_pad_hologram/Hologram = new(loc)//Spawn a blank effect at the location.
		if(AI)
			Hologram.icon = AI.holo_icon
			Hologram.verb_say = AI.verb_say
			Hologram.verb_ask = AI.verb_ask
			Hologram.verb_exclaim = AI.verb_exclaim
			Hologram.verb_yell = AI.verb_yell
			Hologram.speech_span = AI.speech_span
		else	//make it like real life
			Hologram.icon = user.icon
			Hologram.icon_state = user.icon_state
			Hologram.copy_overlays(user, TRUE)
			//codersprite some holo effects here
			Hologram.alpha = 100
			Hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
			Hologram.Impersonation = user

		Hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
		Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
		Hologram.set_anchored(TRUE)//So space wind cannot drag it.
		Hologram.name = "[user.name] (Hologram)"//If someone decides to right click.
		Hologram.set_light(2)	//hologram lighting
		move_hologram()

		set_holo(user, Hologram)
		visible_message(span_notice("A holographic image of [user] flickers to life before your eyes!"))

		return Hologram
	else
		to_chat(user, "[span_danger("ERROR:")] Unable to project hologram.")

/*This is the proc for special two-way communication between AI and holopad/people talking near holopad.
For the other part of the code, check silicon say.dm. Particularly robot talk.*/
/obj/machinery/holopad/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(speaker && LAZYLEN(masters) && !radio_freq)//Master is mostly a safety in case lag hits or something. Radio_freq so AIs dont hear holopad stuff through radios.
		for(var/mob/living/silicon/ai/master in masters)
			if(master == speaker || master.ai_hologram == speaker) // AI will not hear talks that are spoken from themselves
				continue
			master.hear_holocall(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)

	for(var/I in holo_calls)
		var/datum/holocall/HC = I
		if(HC.connected_holopad == src && speaker != HC.hologram)
			HC.user.Hear(message, speaker, message_language, raw_message, radio_freq, spans, message_mods)
			if(HC.user.should_show_chat_message(speaker, message_language, FALSE, is_heard = TRUE))
				create_chat_message(speaker, message_language, list(HC.user), raw_message, spans, message_mods)

	if(outgoing_call && speaker == outgoing_call.user)
		outgoing_call.hologram.say(raw_message)

	if(record_mode && speaker == record_user)
		record_message(speaker,raw_message,message_language)

/obj/machinery/holopad/proc/SetLightsAndPower()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	update_use_power(total_users > 0 ? ACTIVE_POWER_USE : IDLE_POWER_USE)
	update_mode_power_usage(ACTIVE_POWER_USE, HOLOPAD_PASSIVE_POWER_USAGE + (HOLOGRAM_POWER_USAGE * total_users))
	if(total_users || replay_mode)
		set_light(2)
	else
		set_light(0)
	update_icon()

/obj/machinery/holopad/update_icon()
	var/total_users = LAZYLEN(masters) + LAZYLEN(holo_calls)
	if(ringing)
		icon_state = "holopad_ringing"
	else if(total_users || replay_mode)
		icon_state = "holopad1"
	else
		icon_state = "holopad0"

/obj/machinery/holopad/proc/set_holo(mob/living/user, var/obj/effect/overlay/holo_pad_hologram/h)
	LAZYSET(masters, user, h)
	LAZYSET(holorays, user, new /obj/effect/overlay/holoray(loc))
	set_can_hear_flags(CAN_HEAR_MASTERS)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI))
		AI.current_holopad = src
		AI.ai_hologram = h
	SetLightsAndPower()
	update_holoray(user, get_turf(loc))
	return TRUE

/obj/machinery/holopad/proc/clear_holo(mob/living/user)
	qdel(masters[user]) // Get rid of user's hologram
	unset_holo(user)
	return TRUE

/obj/machinery/holopad/proc/unset_holo(mob/living/user)
	var/mob/living/silicon/ai/AI = user
	if(istype(AI) && AI.current_holopad == src)
		AI.current_holopad = null
		AI.ai_hologram = null
	LAZYREMOVE(masters, user) // Discard AI from the list of those who use holopad
	if(!LAZYLEN(masters))
		set_can_hear_flags(CAN_HEAR_MASTERS, set_flag = FALSE)
	qdel(holorays[user])
	LAZYREMOVE(holorays, user)
	SetLightsAndPower()
	return TRUE

//Try to transfer hologram to another pad that can project on T
/obj/machinery/holopad/proc/transfer_to_nearby_pad(turf/T,mob/holo_owner)
	var/obj/effect/overlay/holo_pad_hologram/h = masters[holo_owner]
	if(!h || h.HC) //Holocalls can't change source.
		return FALSE
	for(var/pad in holopads)
		var/obj/machinery/holopad/another = pad
		if(another == src)
			continue
		if(another.validate_location(T))
			unset_holo(holo_owner)
			if(another.masters && another.masters[holo_owner])
				another.clear_holo(holo_owner)
			another.set_holo(holo_owner, h)
			return TRUE
	return FALSE

/obj/machinery/holopad/proc/validate_user(mob/living/user)
	if(QDELETED(user) || user.incapacitated() || !user.client)
		return FALSE
	return TRUE

//Can we display holos there
//Area check instead of line of sight check because this is a called a lot if AI wants to move around.
/obj/machinery/holopad/proc/validate_location(turf/T,check_los = FALSE)
	if(T.get_virtual_z_level() == get_virtual_z_level() && get_dist(T, src) <= holo_range && T.loc == get_area(src))
		return TRUE
	else
		return FALSE

/obj/machinery/holopad/proc/move_hologram(mob/living/user, turf/new_turf)
	if(LAZYLEN(masters) && masters[user])
		var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
		var/transfered = FALSE
		if(!validate_location(new_turf))
			if(!transfer_to_nearby_pad(new_turf,user))
				clear_holo(user)
				return FALSE
			else
				transfered = TRUE
		//All is good.
		holo.abstract_move(new_turf)
		if(!transfered)
			update_holoray(user,new_turf)
	return TRUE


/obj/machinery/holopad/proc/update_holoray(mob/living/user, turf/new_turf)
	var/obj/effect/overlay/holo_pad_hologram/holo = masters[user]
	var/obj/effect/overlay/holoray/ray = holorays[user]
	var/disty = holo.y - ray.y
	var/distx = holo.x - ray.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M = matrix()
	if (get_dist(get_turf(holo),new_turf) <= 1)
		animate(ray, transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle),time = 1)
	else
		ray.transform = turn(M.Scale(1,sqrt(distx*distx+disty*disty)),newangle)

// RECORDED MESSAGES

/obj/machinery/holopad/proc/setup_replay_holo(datum/holorecord/record)
	var/obj/effect/overlay/holo_pad_hologram/Hologram = new(loc)//Spawn a blank effect at the location.
	Hologram.add_overlay(record.caller_image)
	Hologram.alpha = 170
	Hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	Hologram.dir = SOUTH //for now
	var/datum/language_holder/holder = Hologram.get_language_holder()
	holder.selected_language = record.language
	Hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	Hologram.set_anchored(TRUE)//So space wind cannot drag it.
	Hologram.name = "[record.caller_name] (Hologram)"//If someone decides to right click.
	Hologram.set_light(2)	//hologram lighting
	visible_message(span_notice("A holographic image of [record.caller_name] flickers to life before your eyes!"))
	return Hologram

/obj/machinery/holopad/proc/replay_start()
	if(!replay_mode)
		replay_mode = TRUE
		replay_holo = setup_replay_holo(disk.record)
		temp = "Replaying...<br>"
		temp += "<A href='byond://?src=[REF(src)];offset=1'>Change offset</A><br>"
		temp += "<A href='byond://?src=[REF(src)];replay_stop=1'>End replay</A>"
		SetLightsAndPower()
		replay_entry(1)
	return

/obj/machinery/holopad/proc/replay_stop()
	if(replay_mode)
		replay_mode = FALSE
		loop_mode = FALSE
		offset = FALSE
		temp = null
		QDEL_NULL(replay_holo)
		SetLightsAndPower()
		updateDialog()

/obj/machinery/holopad/proc/record_start(mob/living/user)
	if(!user || !disk || disk.record)
		return
	disk.record = new
	record_mode = TRUE
	set_can_hear_flags(CAN_HEAR_RECORD_MODE)
	record_start = world.time
	record_user = user
	disk.record.set_caller_image(user)
	temp = "Recording...<br>"
	temp += "<A href='byond://?src=[REF(src)];record_stop=1'>End recording.</A>"

/obj/machinery/holopad/proc/record_message(mob/living/speaker,message,language)
	if(!record_mode)
		return
	//make this command so you can have multiple languages in single record
	if((!disk.record.caller_name || disk.record.caller_name == "Unknown") && istype(speaker))
		disk.record.caller_name = speaker.name
	if(!disk.record.language)
		disk.record.language = language
	else if(language != disk.record.language)
		disk.record.entries += list(list(HOLORECORD_LANGUAGE,language))

	var/current_delay = 0
	for(var/E in disk.record.entries)
		var/list/entry = E
		if(entry[1] != HOLORECORD_DELAY)
			continue
		current_delay += entry[2]

	var/time_delta = world.time - record_start - current_delay

	if(time_delta >= 1)
		disk.record.entries += list(list(HOLORECORD_DELAY,time_delta))
	disk.record.entries += list(list(HOLORECORD_SAY,message))
	if(disk.record.entries.len >= HOLORECORD_MAX_LENGTH)
		record_stop()

/obj/machinery/holopad/proc/replay_entry(entry_number)
	if(!replay_mode)
		return
	if(!anchored || (machine_stat & NOPOWER))
		record_stop()
		replay_stop()
		return
	if (!disk.record.entries.len) // check for zero entries such as photographs and no text recordings
		return // and pretty much just display them statically until manually stopped
	if(disk.record.entries.len < entry_number)
		if(loop_mode)
			entry_number = 1
		else
			replay_stop()
			return
	var/list/entry = disk.record.entries[entry_number]
	var/command = entry[1]
	switch(command)
		if(HOLORECORD_SAY)
			var/message = entry[2]
			if(replay_holo)
				replay_holo.say(message)
		if(HOLORECORD_SOUND)
			playsound(src,entry[2],50,1)
		if(HOLORECORD_DELAY)
			addtimer(CALLBACK(src,PROC_REF(replay_entry),entry_number+1),entry[2])
			return
		if(HOLORECORD_LANGUAGE)
			var/datum/language_holder/holder = replay_holo.get_language_holder()
			holder.selected_language = entry[2]
		if(HOLORECORD_PRESET)
			var/preset_type = entry[2]
			var/datum/preset_holoimage/H = new preset_type
			replay_holo.cut_overlays()
			replay_holo.add_overlay(H.build_image())
		if(HOLORECORD_RENAME)
			replay_holo.name = entry[2] + " (Hologram)"
	.(entry_number+1)

/obj/machinery/holopad/proc/record_stop()
	if(record_mode)
		record_mode = FALSE
		temp = null
		record_user = null
		updateDialog()
		set_can_hear_flags(CAN_HEAR_RECORD_MODE, FALSE)

/obj/machinery/holopad/proc/record_clear()
	if(disk && disk.record)
		QDEL_NULL(disk.record)
	updateDialog()

/obj/effect/overlay/holo_pad_hologram
	initial_language_holder = /datum/language_holder/universal
	var/mob/living/Impersonation
	var/datum/holocall/HC

/obj/effect/overlay/holo_pad_hologram/Destroy()
	Impersonation = null
	if(!QDELETED(HC))
		HC.Disconnect(HC.calling_holopad)
	HC = null
	return ..()

/obj/effect/overlay/holo_pad_hologram/Process_Spacemove(movement_dir = 0)
	return TRUE

/obj/effect/overlay/holo_pad_hologram/examine(mob/user)
	if(Impersonation)
		return Impersonation.examine(user)
	return ..()

/obj/effect/overlay/holoray
	name = "holoray"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "holoray"
	layer = FLY_LAYER
	density = FALSE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32
	alpha = 100

#undef HOLOPAD_PASSIVE_POWER_USAGE
#undef HOLOGRAM_POWER_USAGE
#undef CAN_HEAR_MASTERS
#undef CAN_HEAR_ACTIVE_HOLOCALLS
#undef CAN_HEAR_RECORD_MODE
#undef CAN_HEAR_ALL_FLAGS
