/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	req_access = list(ACCESS_GENETICS) //for modifying records
	interaction_flags_click = ALLOW_SILICON_REACH

	var/clonepod_type = /obj/machinery/clonepod
	var/list/connected_pods //Linked cloning pods
	var/obj/machinery/dna_scannernew/connected_scanner //Linked scanner. For scanning.

	var/list/records = list()
	var/obj/item/disk/data/diskette //Incompatible format to genetics machine

	/// console status for cloning
	var/temp = "Inactive"
	/// console status for scanning
	var/scantemp = "Inactive"

	/// The computer is doing something and cannot do something else. Currently used in scanning
	var/busy = FALSE

	/// Used for experimental cloning. experimental clone pod also needs to have this
	var/experimental = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()
	update_modules(find_clonepod_first = TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(length(connected_pods))
		for(var/each_pod in connected_pods)
			detach_clonepod(each_pod)
		connected_pods = null
	return ..()

// --------------------------------------
// Manages a clone pod
/obj/machinery/computer/cloning/proc/find_clonepod()
	var/obj/machinery/clonepod/found_clonepod = null
	for(var/direction in GLOB.cardinals)
		found_clonepod = locate(clonepod_type, get_step(src, direction))
		if (!isnull(found_clonepod) && found_clonepod.is_operational)
			attach_clonepod(found_clonepod)
	// multiple clonepods can be attached to a single computer, so we don't do an early return

/obj/machinery/computer/cloning/proc/attach_clonepod(obj/machinery/clonepod/found_clonepod)
	if(!found_clonepod.connected)
		found_clonepod.connected = src
		LAZYADD(connected_pods, found_clonepod)

/obj/machinery/computer/cloning/proc/detach_clonepod(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(connected_pods, pod)

/obj/machinery/computer/cloning/proc/get_available_clonepod()
	if(!length(connected_pods))
		return
	for(var/obj/machinery/clonepod/each_pod as anything in connected_pods)
		if(each_pod.occupant || each_pod.attempting || each_pod.mess || !each_pod.is_operational)
			continue
		if(each_pod.connected != src)
			stack_trace("Clone pod is not connected to this cloning computer for an unknown reason.")
			continue
		return each_pod

// --------------------------------------
// Manages a scanner
/obj/machinery/computer/cloning/proc/find_scanner()
	var/obj/machinery/dna_scannernew/found_scanner
	for(var/direction in GLOB.cardinals)
		found_scanner = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		if(found_scanner?.is_operational)
			return found_scanner
	return null // no scanner found

/obj/machinery/computer/cloning/proc/connect_scanner(obj/machinery/dna_scannernew/new_scanner)
	if(connected_scanner)
		UnregisterSignal(connected_scanner, COMSIG_MACHINE_OPEN)
		UnregisterSignal(connected_scanner, COMSIG_MACHINE_CLOSE)

	connected_scanner = new_scanner
	if(new_scanner)
		RegisterSignal(new_scanner, COMSIG_MACHINE_OPEN, PROC_REF(on_scanner_opened))
		RegisterSignal(new_scanner, COMSIG_MACHINE_CLOSE, PROC_REF(on_scanner_closed))
		on_scanner_closed()

/// Returns the scanner occupant, or its brainmob for heads and brains
/obj/machinery/computer/cloning/proc/get_scanner_occupant()
	var/atom/movable/scanned = connected_scanner?.occupant
	return isliving(scanned) ? scanned : get_brainmob(scanned)

/obj/machinery/computer/cloning/proc/on_scanner_opened()
	SIGNAL_HANDLER
	scantemp = "Ready to Scan"
	ui_update()

/obj/machinery/computer/cloning/proc/on_scanner_closed()
	SIGNAL_HANDLER
	var/mob/living/scanner_occupant = get_scanner_occupant()
	scantemp = scanner_occupant ? "[scanner_occupant] => Ready to Scan" : "Ready to Scan"
	ui_update()

/obj/machinery/computer/cloning/proc/update_modules(find_clonepod_first)
	if(QDELETED(connected_scanner))
		connect_scanner(find_scanner())
	if(find_clonepod_first && !LAZYLEN(connected_pods))
		find_clonepod()

// --------------------------------------
// Other standard procs
/obj/machinery/computer/cloning/attackby(obj/item/used_item, mob/user, list/modifiers)
	if(istype(used_item, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if (!diskette)
			if (!user.transferItemToLoc(used_item,src))
				return
			diskette = used_item
			to_chat(user, span_notice("You insert [used_item]."))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else
		return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/cloning)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/cloning)
	if(istype(buffer, /obj/machinery/clonepod))
		if(get_area(buffer) != get_area(src))
			to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
			FLUSH_BUFFER(buffer_parent)
			return NONE
		to_chat(user, "<font color = #666633>-% Successfully linked [buffer] with [src] %-</font color>")
		var/obj/machinery/clonepod/pod = buffer
		if(pod.connected)
			pod.connected.detach_clonepod(pod)
		attach_clonepod(pod)
	else
		if (TRY_STORE_IN_BUFFER(buffer_parent, src))
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(src)] [name] in buffer %-</font color>")
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/computer/cloning/click_alt(mob/user)
	eject_disk(user)
	return CLICK_ACTION_SUCCESS

// --------------------------------------
// Manages record and disk
/obj/machinery/computer/cloning/proc/find_record(id)
	for(var/datum/record/cloning/each_record as anything in records)
		if(each_record.id == id)
			return each_record

/obj/machinery/computer/cloning/proc/scan_error(message, sound = 'sound/machines/terminal_prompt_deny.ogg')
	scantemp = message
	playsound(src, sound, 50, FALSE)

/obj/machinery/computer/cloning/proc/clone_error(message)
	temp = message
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)

/obj/machinery/computer/cloning/proc/delete_record(mob/user, target_record)
	var/obj/item/card/id/idcard_for_auth
	if(isliving(user))
		var/mob/living/living_user = user
		idcard_for_auth = living_user.get_idcard(hand_first = TRUE)
	if(!istype(idcard_for_auth) || !check_access(idcard_for_auth))
		scan_error("Cannot delete: Access Denied.")
		return

	var/datum/record/cloning/found_record = find_record(target_record)
	if(!found_record)
		scan_error("Cannot delete: Data Corrupted.")
		return

	scantemp = "[found_record.name] => Record deleted."
	records -= found_record
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	qdel(found_record)

/obj/machinery/computer/cloning/proc/save_to_disk(mob/user, target_record)
	if(!diskette)
		scan_error("Failed saving to disk: No disk.")
		return
	if(diskette.read_only)
		scan_error("Failed saving to disk: Disk refuses override attempt.")
		return

	var/datum/record/cloning/found_record = find_record(target_record)
	if(!found_record)
		scan_error("Failed saving to disk: Data Corrupted")
		return

	QDEL_NULL(diskette.data)
	diskette.data = found_record.copy()

	diskette.name = "data disk - '[diskette.data.name]'"
	scantemp = "Saved to disk successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/load_from_disk(mob/user)
	if(!diskette?.data?.name)
		scan_error("Failed loading: Load error.")
		return
	if(find_record(diskette.data.id))
		scan_error("Failed loading: Data already exists!")
		return

	records += diskette.data.copy()
	scantemp = "Loaded into internal storage successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/eject_disk(mob/user)
	if(!diskette)
		return
	scantemp = "Disk Ejected"
	diskette.forceMove(drop_location())
	user.put_in_active_hand(diskette)
	diskette = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/computer/cloning/proc/toggle_lock(mob/user)
	if(!connected_scanner?.is_operational)
		return
	if(!connected_scanner.locked && !connected_scanner.occupant) //I figured out that if you're fast enough, you can lock an open pod
		return
	connected_scanner.locked = !connected_scanner.locked
	playsound(src, connected_scanner.locked ? 'sound/machines/terminal_prompt_deny.ogg' : 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

// --------------------------------------
// Actual clone codes / 1.scan procs / 2.clone proc
/obj/machinery/computer/cloning/proc/start_scan(mob/user, body_only = FALSE)
	if(isnull(connected_scanner) || !connected_scanner.is_operational || !connected_scanner.occupant)
		return
	if(busy)
		scan_error("Error: Too busy for scanning.")
		return
	scantemp = "[get_scanner_occupant()] => Scanning..."
	busy = TRUE
	playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
	say("Initiating scan...")
	var/previous_lock_status = connected_scanner.locked
	connected_scanner.locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_scan), connected_scanner.occupant, user, previous_lock_status, body_only), 2 SECONDS)

/obj/machinery/computer/cloning/proc/finish_scan(atom/movable/scanned, mob/user, previous_lock_status, body_only)
	busy = FALSE
	if(QDELETED(connected_scanner))
		return
	connected_scanner.locked = previous_lock_status
	if(QDELETED(scanned) || connected_scanner.occupant != scanned)
		scan_error("Error: Subject left the scanner.")
	else
		add_fingerprint(user)
		scan_occupant(scanned, user, body_only)
	SStgui.update_uis(src) // Immediate since it's not spammable

/obj/machinery/computer/cloning/proc/scan_occupant(atom/atom_occupant, mob/user, body_only)
	// Clone target variables
	var/mob/living/carbon/human/human_mob = ishuman(atom_occupant) ? atom_occupant : null
	var/mob/living/brain/brainmob = get_brainmob(atom_occupant)
	var/obj/item/organ/brain/brain_to_clone // Used when this code failed to find human_mob / brainmob (which means "atom_occupant" is an object and mindless)
	/* Note:
		Basically a minded mob can have 'brainmob' in their head or brain when they are beheaded
		but if a mob does not have any mind, they do not get brainmob.
		This is because letting ghosted players be able to find where their mind-holder exists.
		So, we should check when we clone mindless mobs
	*/
	var/datum/dna/dna
	var/datum/mind/occupant_mind
	var/datum/bank_account/has_bank_account

	// Scanning a mob; gets a human mob(likely not carbon) - We have a human body in the scanner (NOTE: carbon is not supported)
	if(human_mob)
		brain_to_clone = human_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
		dna = human_mob.has_dna()
		occupant_mind = human_mob.mind // Reminder : might not exist
		var/obj/item/card/id/human_id_card = human_mob.get_idcard(TRUE)
		if(human_id_card)
			has_bank_account = human_id_card.registered_account

	// Scanning an object; gets a brain mob - We do not have a human body. We have a brain(or head) that holds a mind datum
	else if(brainmob)
		brain_to_clone = brainmob.loc
		dna = brainmob.stored_dna
		occupant_mind = brainmob.mind // Reminder : likely exist
		if(!istype(brain_to_clone, /obj/item/organ/brain))
			stack_trace("var 'brain_to_clone' is not /organ/brain for some reason. From brainmob: [brainmob]")
			brain_to_clone = null
	// Note: This might look equivalant from below, but items return "brainmob" if things have a mind(player)
	// I mean, this attempts to detect the thing from head/brain(object), but it is not actually an object (ARgh I hate this weird description)

	// Scanning an object; gets a brain item - Try to find a brain that holds a DNA
	else if(istype(atom_occupant, /obj/item/bodypart/head)) // From head
		brain_to_clone = locate(/obj/item/organ/brain) in atom_occupant
		dna = brain_to_clone?.brain_dna
		// occupant_mind = null // Reminder: does not exist. This line exists for a hint.
	else if(istype(atom_occupant, /obj/item/organ/brain)) // From brain
		brain_to_clone = atom_occupant
		dna = brain_to_clone.brain_dna
		// occupant_mind = null // Reminder: does not exist. This line exists for a hint.

	if(!can_scan(dna, human_mob, occupant_mind, has_bank_account, body_only))
		return

	if(!dna.species)
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
		//Note: if you want to clone unusual species, you need to check 'carbon/human' rather than 'dna.species'

	var/datum/record/cloning/cloning_record = new(dna, human_mob, occupant_mind)
	cloning_record.last_death = experimental ? FALSE : (occupant_mind && occupant_mind.current.stat == DEAD) ? occupant_mind.last_death : -1
	cloning_record.body_only = experimental ? FALSE : body_only
	cloning_record.bank_account = has_bank_account

	//even if you have the same identity, this will give you different id based on your mind. body_only gets β at their id.
	var/name_hash = rustg_hash_string(RUSTG_HASH_MD5, cloning_record.name)
	if(experimental)
		cloning_record.id = copytext_char(name_hash, 3, 10)+"β+" //beta plus
	else if(body_only)
		cloning_record.id = copytext_char(name_hash, 3, 10)+"β" //beta
	else
		cloning_record.id = copytext_char(name_hash, 3, 7)+copytext_char(rustg_hash_string(RUSTG_HASH_MD5, FAST_REF(occupant_mind)), -4)

	//We'll detect the brain first because trauma is from the brain, not from the body.
	if(brainmob)
		cloning_record.traumas = brainmob.get_traumas()
	else if(human_mob)
		cloning_record.traumas = human_mob.get_traumas()
	else if(brain_to_clone)
		cloning_record.traumas = brain_to_clone.traumas.Copy()
	//Traumas will be overriden if the brain transplant is made because '/obj/item/organ/brain/Insert' does that thing. This should be done since we want a monkey yelling to people with 'God voice syndrome'

	if(human_mob && (!body_only || experimental && human_mob.stat != DEAD))
		//Add an implant if needed
		var/obj/item/implant/health/implant = locate() in human_mob.implants
		if(!implant)
			implant = new /obj/item/implant/health()
			implant.implant(human_mob)
		cloning_record.weakref_health_implant = WEAKREF(implant)

	var/datum/record/cloning/old_record = find_record(cloning_record.id)
	if(old_record)
		records -= old_record
		qdel(old_record)
		scantemp = "Record updated."
	else
		scantemp = "Subject successfully scanned."

	records += cloning_record

	var/record_kind = experimental ? "(experimental)" : body_only ? "(body-only)" : ""
	log_cloning("[key_name(user)] added the record[record_kind] of [key_name(human_mob || brainmob || atom_occupant)](DNA-name:[dna.real_name]) to [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50)

/obj/machinery/computer/cloning/proc/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/mind/mind, datum/bank_account/account, body_only)
	if(!istype(dna))
		scan_error("Unable to locate valid genetic data.")
		return FALSE
	if(!experimental && !body_only && !mind)
		scan_error("Mental interface failure.")
		return FALSE
	if(isliving(mob_occupant))
		if(HAS_TRAIT(mob_occupant, TRAIT_NO_DNA_COPY))
			scan_error("The DNA of this lifeform could not be read due to an unknown error!")
			return FALSE
		if((HAS_TRAIT(mob_occupant, TRAIT_HUSK)) && (connected_scanner.scan_level < 2))
			scan_error("Subject's body is too damaged to scan properly.", 'sound/machines/terminal_alert.ogg')
			return FALSE
		if(HAS_TRAIT(mob_occupant, TRAIT_BADDNA))
			scan_error("Subject's DNA is damaged beyond any hope of recovery.", 'sound/machines/terminal_alert.ogg')
			return FALSE
		if(!experimental && !body_only)
			if(mob_occupant.suiciding)
				scan_error("Subject's brain is not responding to scanning stimuli.")
				return FALSE
			if(SSeconomy.full_ancap && !account)
				scan_error("Subject is either missing an ID card with a bank account on it, or does not have an account to begin with. Please ensure the ID card is on the body before attempting to scan.")
				return FALSE
	return TRUE

/obj/machinery/computer/cloning/proc/start_clone(mob/user, target_record)
	var/datum/record/cloning/found_record = find_record(target_record)
	if(!found_record)
		clone_error("Failed to clone: No Data corrupted.")
		return

	var/obj/machinery/clonepod/pod = get_available_clonepod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(connected_pods))
		clone_error("Error: No Clonepods detected.")
		return
	if(!pod)
		clone_error("Error: No Clonepods available.")
		return
	if((!found_record.body_only || !experimental) && !CONFIG_GET(flag/revival_cloning))
		clone_error("Error: Unable to initiate cloning cycle.")
		return

	var/result = pod.growclone(found_record, experimental)
	if(result == CLONING_SUCCESS)
		temp = "Notice: [found_record.name] => Cloning cycle in progress..."
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		if(!found_record.body_only)
			records -= found_record
		return
	if(result == CLONING_SUCCESS_EXPERIMENTAL)
		temp = "Notice: [found_record.name] => Experimental cloning cycle in progress..."
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		return

	var/message
	switch(result)
		if(ERROR_NO_SYNTHFLESH)
			message = "Out of synthflesh."
		if(ERROR_PANEL_OPENED)
			message = "Panel opened."
		if(ERROR_MESS_OR_ATTEMPTING)
			message = "Pod is already occupied."
		if(ERROR_MISSING_EXPERIMENTAL_POD)
			message = "Experimental pod is not detected."
		if(ERROR_NOT_MIND)
			message = "[found_record.name]'s lack of their mind."
		if(ERROR_PRESAVED_CLONE)
			message = "[found_record.name]'s clone record is presaved."
		if(ERROR_OUTDATED_CLONE)
			message = "[found_record.name]'s clone record is outdated."
		if(ERROR_ALREADY_ALIVE)
			message = "[found_record.name] already alive."
		if(ERROR_COMMITED_SUICIDE)
			message = "[found_record.name] commited a suicide."
		if(ERROR_SOUL_DEPARTED)
			message = "[found_record.name]'s soul had departed."
		if(ERROR_SUICIDED_BODY)
			message = "Failed to capture [found_record.name]'s mind from a suicided body."
	if(message)
		clone_error("Error [result]: [message]")
	else
		clone_error("Error unknown => Initialisation failure.")

// --------------------------------------
// TGUI parts
/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()
	data["records"] = list()
	for(var/datum/record/cloning/each_record in records)
		var/list/record_entry = list()
		record_entry["name"] = "[each_record.name]"
		record_entry["id"] = "[each_record.id]"
		var/obj/item/implant/health/health_imp = each_record.weakref_health_implant?.resolve()
		if(health_imp)
			record_entry["damages"] = health_imp.sensehealth(TRUE)
		else
			record_entry["damages"] = FALSE
		record_entry["UI"] = "[each_record.unique_identity]"
		record_entry["UE"] = "[each_record.unique_enzymes]"
		record_entry["blood_type"] = "[each_record.blood_type]"
		record_entry["last_death"] = each_record.last_death
		record_entry["body_only"] = each_record.body_only

		data["records"] += list(record_entry)
	if(diskette && diskette.data)
		var/list/disk_data = list()
		disk_data["name"] = "[diskette.data.name]"
		disk_data["id"] = "[diskette.data.id]"
		disk_data["UI"] = "[diskette.data.unique_identity]"
		disk_data["UE"] = "[diskette.data.unique_enzymes]"
		disk_data["blood_type"] = "[diskette.data.blood_type]"
		disk_data["last_death"] = diskette.data.last_death
		disk_data["body_only"] = diskette.data.body_only
		data["diskData"] = disk_data
	else
		data["diskData"] = list()
	var/list/lack_machine = list()
	if(isnull(connected_scanner))
		lack_machine += "ERROR: No Scanner Detected!"
	if(!LAZYLEN(connected_pods))
		lack_machine += "ERROR: No Pod Detected!"
	data["lacksMachine"] = lack_machine
	data["temp"] = temp
	data["scanTemp"] = scantemp
	data["scannerLocked"] = connected_scanner?.locked
	data["hasOccupant"] = !!connected_scanner?.occupant
	data["experimental"] = experimental
	data["diskette"] = !!diskette
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return

	// Return TRUE on almost every operation, since operations write to temp and scantemp to display failure messages
	switch(action)
		if("scan")
			start_scan(usr, FALSE)
			return TRUE
		if("scan_body_only")
			start_scan(usr, TRUE)
			return TRUE
		if("clone")
			start_clone(usr, target_record = params["target"])
			return TRUE
		if("delrecord")
			delete_record(usr, target_record = params["target"])
			return TRUE
		if("save")
			save_to_disk(usr, target_record = params["target"])
			return TRUE
		if("load")
			load_from_disk(usr)
			return TRUE
		if("eject")
			eject_disk(usr)
			return TRUE
		if("toggle_lock")
			toggle_lock(usr)
			return TRUE

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	update_modules(find_clonepod_first = TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning System Control")
		ui.open()
		ui.set_autoupdate(TRUE)

//Prototype cloning console, that cannot clone a person as how they really are - experimental clone, individual identities
/obj/machinery/computer/cloning/prototype
	name = "prototype cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning/prototype
	clonepod_type = /obj/machinery/clonepod/experimental
	experimental = TRUE
