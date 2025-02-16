/*
 * Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */

/atom/proc/add_to_all_human_data_huds()
	for(var/datum/atom_hud/data/human/hud in GLOB.huds)
		hud.add_atom_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in GLOB.huds)
		hud.remove_atom_from_hud(src)

/datum/atom_hud/data

/datum/atom_hud/data/human/medical
	hud_icons = list(STATUS_HUD, HEALTH_HUD, NANITE_HUD)

/datum/atom_hud/data/human/medical/basic

/datum/atom_hud/data/human/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H) && !ismonkey(H))
		return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U))
		return 0
	if(U.sensor_mode <= SENSOR_VITALS)
		return 0
	return 1

/datum/atom_hud/data/human/medical/basic/add_atom_to_single_mob_hud(mob/M, mob/living/carbon/H)
	if(check_sensors(H))
		..()

/datum/atom_hud/data/human/medical/basic/proc/update_suit_sensors(mob/living/carbon/H)
	check_sensors(H) ? add_atom_to_hud(H) : remove_atom_from_hud(H)

/datum/atom_hud/data/human/medical/advanced

/datum/atom_hud/data/human/security

/datum/atom_hud/data/human/security/basic
	hud_icons = list(ID_HUD)

/datum/atom_hud/data/human/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD, WANTED_HUD, NANITE_HUD)

/datum/atom_hud/data/diagnostic

/datum/atom_hud/data/diagnostic/basic
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_CIRCUIT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_NANITE_FULL_HUD, DIAG_LAUNCHPAD_HUD, DIAG_WAKE_HUD)

/datum/atom_hud/data/diagnostic/advanced
	hud_icons = list(DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_CIRCUIT_HUD, DIAG_TRACK_HUD, DIAG_AIRLOCK_HUD, DIAG_NANITE_FULL_HUD, DIAG_LAUNCHPAD_HUD, DIAG_WAKE_HUD, DIAG_PATH_HUD)

/datum/atom_hud/data/bot_path
	uses_global_hud_category = FALSE
	hud_icons = list(DIAG_PATH_HUD)

/datum/atom_hud/abductor
	hud_icons = list(GLAND_HUD)

/datum/atom_hud/ai_detector
	hud_icons = list(AI_DETECT_HUD)

/datum/atom_hud/ai_detector/show_to(mob/M)
	..()
	if(!M || hud_users.len != 1)
		return

	for(var/mob/camera/ai_eye/eye as anything in GLOB.ai_eyes)
		eye.update_ai_detect_hud()

/* MED/SEC/DIAG HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 * Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

//called when a carbon changes virus
/mob/living/carbon/proc/check_virus()
	var/threat
	var/danger
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(!(D.visibility_flags & HIDDEN_SCANNER))
			if(!threat || get_disease_danger_value(D.danger) > threat) //a buffing virus gets an icon
				threat = get_disease_danger_value(D.danger)
				danger = D.danger
	return danger

//helper for getting the appropriate health status
/proc/RoundHealth(mob/living/M)
	if(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_FAKEDEATH)))
		return "health-100" //what's our health? it doesn't matter, we're dead, or faking
	var/maxi_health = M.maxHealth
	if(iscarbon(M) && M.health < 0)
		maxi_health = 100 //so crit shows up right for aliens and other high-health carbon mobs; noncarbons don't have crit.
	var/resulthealth = (M.health / maxi_health) * 100
	switch(resulthealth)
		if(100 to INFINITY)
			return "health100"
		if(90.625 to 100)
			return "health93.75"
		if(84.375 to 90.625)
			return "health87.5"
		if(78.125 to 84.375)
			return "health81.25"
		if(71.875 to 78.125)
			return "health75"
		if(65.625 to 71.875)
			return "health68.75"
		if(59.375 to 65.625)
			return "health62.5"
		if(53.125 to 59.375)
			return "health56.25"
		if(46.875 to 53.125)
			return "health50"
		if(40.625 to 46.875)
			return "health43.75"
		if(34.375 to 40.625)
			return "health37.5"
		if(28.125 to 34.375)
			return "health31.25"
		if(21.875 to 28.125)
			return "health25"
		if(15.625 to 21.875)
			return "health18.75"
		if(9.375 to 15.625)
			return "health12.5"
		if(1 to 9.375)
			return "health6.25"
		if(-50 to 1)
			return "health0"
		if(-85 to -50)
			return "health-50"
		if(-99 to -85)
			return "health-85"
		else
			return "health-100"

//HOOKS

//called when a human changes suit sensors
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/human/medical/basic/B = GLOB.huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)

/// Updates both the Health and Status huds. ATOM HUDS, NOT SCREEN HUDS.
/mob/living/proc/update_med_hud()
	med_hud_set_health()
	med_hud_set_status()

//called when a living mob changes health
/mob/living/proc/med_hud_set_health()
	set_hud_image_vars(HEALTH_HUD, "hud[RoundHealth(src)]", get_hud_pixel_y())

/mob/living/carbon/med_hud_set_health()
	var/new_state = ""
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		new_state = "0"
	else if(undergoing_cardiac_arrest())
		new_state = "flatline"

	set_hud_image_vars(HEALTH_HUD, new_state, get_hud_pixel_y())

//called when a carbon changes stat, virus or XENO_HOST
/mob/living/proc/med_hud_set_status()
	SIGNAL_HANDLER
	var/new_state
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		new_state = "huddead"
	else
		new_state = "hudhealthy"

	set_hud_image_vars(STATUS_HUD, new_state, get_hud_pixel_y())

/mob/living/carbon/med_hud_set_status()
	var/new_state
	var/virus_threat = check_virus()

	if(HAS_TRAIT(src, TRAIT_XENO_HOST))
		new_state = "hudxeno"
	else if(stat == DEAD)
		if(!getorgan(/obj/item/organ/brain) || soul_departed() || ishellbound())
			new_state = "huddead-permanent"
			return
		if(tod)
			var/tdelta = round(world.time - timeofdeath)
			if(tdelta < (DEFIB_TIME_LIMIT * 10))
				if(!client && key)
					new_state = "huddefib-ssd"
					return
				new_state = "huddefib"
				return
		if(!client && key)
			new_state = "huddead-ssd"
			return
		new_state = "huddead"
	else if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		new_state = "huddefib"
	else
		switch(virus_threat)
			if(DISEASE_PANDEMIC)
				new_state = "hudill6"
			if(DISEASE_BIOHAZARD)
				new_state = "hudill5"
			if(DISEASE_DANGEROUS)
				new_state = "hudill4"
			if(DISEASE_HARMFUL)
				new_state = "hudill3"
			if(DISEASE_MEDIUM)
				new_state = "hudill2"
			if(DISEASE_MINOR)
				new_state = "hudill1"
			if(DISEASE_NONTHREAT)
				new_state = "hudill0"
			if(DISEASE_POSITIVE)
				new_state = "hudbuff"
			if(DISEASE_BENEFICIAL)
				new_state = "hudbuff2"
			if(null)
				new_state = "hudhealthy"

	set_hud_image_vars(STATUS_HUD, new_state, get_hud_pixel_y())

/***********************************************
 * Security HUDs! Basic mode shows only the job.
************************************************/

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/sechud_icon_state
	if(wear_id?.GetID())
		sechud_icon_state = "hud[ckey(wear_id.get_item_job_icon())]"
	if(HAS_TRAIT(src, TRAIT_UNKNOWN))
		sechud_icon_state = "hudno_id"
	sec_hud_set_security_status()
	set_hud_image_vars(ID_HUD, sechud_icon_state, get_hud_pixel_y())

/mob/living/proc/sec_hud_set_implants()
	for(var/i in list(IMPTRACK_HUD, IMPLOYAL_HUD, IMPCHEM_HUD))
		set_hud_image_vars(i, null)
		set_hud_image_inactive(i)

	var/hud_pixel_y = get_hud_pixel_y()
	for(var/obj/item/implant/I in implants)
		if(istype(I, /obj/item/implant/tracking))
			set_hud_image_vars(IMPTRACK_HUD, "hud_imp_tracking", hud_pixel_y)
			set_hud_image_active(IMPTRACK_HUD)

		else if(istype(I, /obj/item/implant/chem))
			set_hud_image_vars(IMPCHEM_HUD, "hud_imp_chem", hud_pixel_y)
			set_hud_image_active(IMPCHEM_HUD)
	if(has_mindshield_hud_icon())
		set_hud_image_vars(IMPLOYAL_HUD, "hud_imp_loyal", hud_pixel_y)
		set_hud_image_active(IMPLOYAL_HUD)

/mob/living/proc/has_mindshield_hud_icon()
	if(istype(get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
		return FALSE
	return HAS_TRAIT(src, TRAIT_MINDSHIELD) || HAS_TRAIT(src, TRAIT_FAKE_MINDSHIELD)

/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/perp_name = get_face_name(get_id_name(""))
	var/new_state

	if(!perp_name || isnull(GLOB.manifest))
		new_state = null
		return

	var/datum/record/crew/target = find_record(perp_name, GLOB.manifest.general)
	if(isnull(target))
		new_state = null
		return

	var/has_criminal_entry = TRUE
	switch(target.wanted_status)
		if(WANTED_ARREST)
			new_state = "hudwanted"
		if(WANTED_PRISONER)
			new_state = "hudincarcerated"
		if(WANTED_SUSPECT)
			new_state = "hudsuspected"
		if(WANTED_PAROLE)
			new_state = "hudparolled"
		if(WANTED_DISCHARGED)
			new_state = "huddischarged"
		if(WANTED_NONE)
			new_state = null
			has_criminal_entry = FALSE

	if(has_criminal_entry)
		set_hud_image_vars(WANTED_HUD, new_state, get_hud_pixel_y())
		set_hud_image_active(WANTED_HUD)
		return

	set_hud_image_vars(WANTED_HUD, null)
	set_hud_image_inactive(WANTED_HUD)

//Utility functions

/**
 * Updates the visual security huds on all mobs in GLOB.human_list that match the name passed to it.
 */
/proc/update_matching_security_huds(perp_name)
	for (var/mob/living/carbon/human/h as anything in GLOB.human_list)
		if (h.get_face_name(h.get_id_name()) == perp_name)
			h.sec_hud_set_security_status()

/**
 * Updates the visual security huds on all mobs in GLOB.human_list
 */
/proc/update_all_security_huds()
	for(var/mob/living/carbon/human/security_hud_person as anything in GLOB.human_list)
		security_hud_person.sec_hud_set_security_status()

/***********************************************
 * Diagnostic HUDs!
************************************************/

/mob/living/proc/hud_set_nanite_indicator()
	var/image/holder = hud_list[NANITE_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = null
	if(HAS_TRAIT(src, TRAIT_NANITE_SENSORS))
		holder.icon_state = "nanite_ping"

//For Diag health and cell bars!
/proc/RoundDiagBar(value)
	switch(value * 100)
		if(95 to INFINITY)
			return "max"
		if(80 to 100)
			return "good"
		if(60 to 80)
			return "high"
		if(40 to 60)
			return "med"
		if(20 to 40)
			return "low"
		if(1 to 20)
			return "crit"
		else
			return "dead"

/// Returns a pixel_y value to use for hud code
/atom/proc/get_hud_pixel_y()
	SHOULD_NOT_OVERRIDE(TRUE)
	var/static/hud_icon_height_cache = list()
	if(isnull(icon))
		return 0

	. = hud_icon_height_cache[icon]

	if(!isnull(.)) // 0 is valid
		return .

	var/icon/I
	I = icon(icon, icon_state, dir)
	. = I.Height() - world.icon_size

	if(isfile(icon) && length("[icon]")) // Do NOT cache icon instances, only filepaths
		hud_icon_height_cache[icon] = .

//Sillycone hooks
/mob/living/silicon/proc/diag_hud_set_health()
	var/new_state
	if(stat == DEAD)
		new_state = "huddiagdead"
	else
		new_state = "huddiag[RoundDiagBar(health/maxHealth)]"

	set_hud_image_vars(DIAG_HUD, new_state, get_hud_pixel_y())

/mob/living/silicon/proc/diag_hud_set_status()
	var/new_state
	switch(stat)
		if(CONSCIOUS)
			new_state = "hudstat"
		if(UNCONSCIOUS)
			new_state = "hudoffline"
		else
			new_state = "huddead2"

	set_hud_image_vars(DIAG_STAT_HUD, new_state, get_hud_pixel_y())

//Borgie battery tracking!
/mob/living/silicon/robot/proc/diag_hud_set_borgcell()
	var/new_state
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		new_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		new_state = "hudnobatt"

	set_hud_image_vars(DIAG_BATT_HUD, new_state, get_hud_pixel_y())

//borg-AI shell tracking
/mob/living/silicon/robot/proc/diag_hud_set_aishell() //Shows tracking beacons on the mech
	if(!shell) //Not an AI shell
		set_hud_image_vars(DIAG_TRACK_HUD, null)
		set_hud_image_inactive(DIAG_TRACK_HUD)
		return

	var/new_state
	if(deployed) //AI shell in use by an AI
		new_state = "hudtrackingai"
	else //Empty AI shell
		new_state = "hudtracking"

	set_hud_image_active(DIAG_TRACK_HUD)
	set_hud_image_vars(DIAG_TRACK_HUD, new_state, get_hud_pixel_y())

//AI side tracking of AI shell control
/mob/living/silicon/ai/proc/diag_hud_set_deployed() //Shows tracking beacons on the mech
	if(!deployed_shell)
		set_hud_image_vars(DIAG_TRACK_HUD, null)
		set_hud_image_inactive(DIAG_TRACK_HUD)

	else //AI is currently controlling a shell
		set_hud_image_vars(DIAG_TRACK_HUD, "hudtrackingai", get_hud_pixel_y())
		set_hud_image_active(DIAG_TRACK_HUD)

/*~~~~~~~~~~~~~~~~~~~~
	BIG STOMPY MECHS
~~~~~~~~~~~~~~~~~~~~~*/
/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechhealth()
	set_hud_image_vars(DIAG_MECH_HUD, "huddiag[RoundDiagBar(atom_integrity/max_integrity)]", get_hud_pixel_y())

/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechcell()
	var/new_state
	if(cell)
		var/chargelvl = cell.maxcharge ? cell.charge/cell.maxcharge : 0 //Division by 0 protection
		new_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		new_state = "hudnobatt"

	set_hud_image_vars(DIAG_BATT_HUD, new_state, get_hud_pixel_y())


/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechstat()
	if(internal_damage)
		set_hud_image_vars(DIAG_STAT_HUD, "hudwarn", get_hud_pixel_y())
		set_hud_image_active(DIAG_STAT_HUD)
		return

	set_hud_image_vars(DIAG_STAT_HUD, null)
	set_hud_image_inactive(DIAG_STAT_HUD)

///Shows tracking beacons on the mech
/obj/vehicle/sealed/mecha/proc/diag_hud_set_mechtracking()
	var/new_icon_state //This var exists so that the holder's icon state is set only once in the event of multiple mech beacons.
	for(var/obj/item/mecha_parts/mecha_tracking/T in trackers)
		if(T.ai_beacon) //Beacon with AI uplink
			new_icon_state = "hudtrackingai"
			break //Immediately terminate upon finding an AI beacon to ensure it is always shown over the normal one, as mechs can have several trackers.
		else
			new_icon_state = "hudtracking"

	set_hud_image_vars(DIAG_TRACK_HUD, new_icon_state, get_hud_pixel_y())

/*~~~~~~~~~
	Bots!
~~~~~~~~~~*/
/mob/living/simple_animal/bot/proc/diag_hud_set_bothealth()
	set_hud_image_vars(DIAG_HUD, "huddiag[RoundDiagBar(health/maxHealth)]", get_hud_pixel_y())

/mob/living/simple_animal/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/new_state
	if(on)
		new_state = "hudstat"
	else if(stat) //Generally EMP causes this
		new_state = "hudoffline"
	else //Bot is off
		new_state = "huddead2"

	set_hud_image_vars(DIAG_STAT_HUD, new_state, get_hud_pixel_y())

/mob/living/simple_animal/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	if(client) //If the bot is player controlled, it will not be following mode logic!
		set_hud_image_vars(DIAG_BOT_HUD, "hudsentient", get_hud_pixel_y())
		return

	var/new_state
	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			new_state = "hudcalled"
		if(BOT_CLEANING, BOT_REPAIRING, BOT_HEALING) //Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			new_state = "hudworking"
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			new_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT) //STOP RIGHT THERE, CRIMINAL SCUM!
			new_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			new_state = "hudmove"
		else
			new_state = ""

	set_hud_image_vars(DIAG_BOT_HUD, new_state, get_hud_pixel_y())

/mob/living/simple_animal/bot/mulebot/proc/diag_hud_set_mulebotcell()
	var/new_state
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		new_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		new_state = "hudnobatt"

	set_hud_image_vars(DIAG_BATT_HUD, new_state, get_hud_pixel_y())

/*~~~~~~~~~~~~
	Airlocks!
~~~~~~~~~~~~~*/
/obj/machinery/door/airlock/proc/diag_hud_set_electrified()
	if(secondsElectrified == MACHINE_NOT_ELECTRIFIED)
		set_hud_image_inactive(DIAG_AIRLOCK_HUD)
		return

	set_hud_image_vars(DIAG_AIRLOCK_HUD, "electrified")
	set_hud_image_active(DIAG_AIRLOCK_HUD)
