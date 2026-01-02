/datum/computer_file/program/borg_self_monitor
	filename = "borg_self_monitor"
	filedesc = "Cyborg Self-Monitoring"
	extended_desc = "A built-in app for cyborg self-management and diagnostics."
	ui_header = "borg_self_monitor.gif" //DEBUG -- new icon before PR
	program_icon_state = "command"
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	unsendable = TRUE
	undeletable = TRUE
	size = 5
	tgui_id = "NtosCyborgSelfMonitor"
	power_consumption = 0
	///A typed reference to the computer, specifying the borg tablet type
	var/obj/item/modular_computer/tablet/integrated/tablet

/datum/computer_file/program/borg_self_monitor/Destroy()
	tablet = null
	return ..()

/datum/computer_file/program/borg_self_monitor/on_start(mob/living/user)
	if(!istype(computer, /obj/item/modular_computer/tablet/integrated))
		to_chat(user, span_warning("A warning flashes across \the [computer]: Device Incompatible."))
		return FALSE
	. = ..()
	if(.)
		tablet = computer
		if(tablet.device_theme == THEME_SYNDICATE)
			program_icon_state = "command-syndicate"
		return TRUE
	return FALSE

/datum/computer_file/program/borg_self_monitor/ui_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/cyborg = tablet.silicon_owner

	data["name"] = cyborg.name
	data["designation"] = cyborg.model //Borgo module type
	data["masterAI"] = cyborg.connected_ai //Master AI
	var/charge = 0
	var/maxcharge = 1
	if(cyborg.cell)
		charge = cyborg.cell.charge
		maxcharge = cyborg.cell.maxcharge
	data["charge"] = charge //Current cell charge
	data["maxcharge"] = maxcharge //Cell max charge
	data["integrity"] = (cyborg.health / cyborg.maxHealth) * 100 //Borgo health, as percentage
	data["lampIntensity"] = cyborg.lamp_intensity //Borgo lamp power setting
	data["sensors"] = "[cyborg.sensors_on?"ACTIVE":"DISABLED"]"
	data["printerPictures"] = cyborg.connected_ai ? length(cyborg.connected_ai.aicamera?.stored) : length(cyborg.aicamera?.stored) //Number of pictures taken, synced to AI if available
	data["printerToner"] = cyborg.toner //amount of toner
	data["printerTonerMax"] = cyborg.tonermax //It's a variable, might as well use it
	data["cameraRadius"] = isnull(cyborg.aicamera) ? 1 : cyborg.aicamera.picture_size_x // picture_size_x and picture_size_y should always be the same.
	data["thrustersInstalled"] = cyborg.ionpulse //If we have a thruster uprade
	data["thrustersStatus"] = "[cyborg.ionpulse_on?"ACTIVE":"DISABLED"]" //Feedback for thruster status
	data["selfDestructAble"] = (cyborg.emagged || istype(cyborg, /mob/living/silicon/robot/model/syndicate))

	//Cover, TRUE for locked
	data["cover"] = "[cyborg.locked? "LOCKED":"UNLOCKED"]"
	//Ability to move. FAULT if lockdown wire is cut, DISABLED if borg locked, ENABLED otherwise
	data["locomotion"] = "[cyborg.wires.is_cut(WIRE_LOCKDOWN)?"FAULT":"[cyborg.lockcharge?"DISABLED":"ENABLED"]"]"
	//Model wire. FAULT if cut, NOMINAL otherwise
	data["wireModule"] = "[cyborg.wires.is_cut(WIRE_RESET_MODEL)?"FAULT":"NOMINAL"]"
	//DEBUG -- Camera(net) wire. FAULT if cut (or no cameranet camera), DISABLED if pulse-disabled, NOMINAL otherwise
	data["wireCamera"] = "[!cyborg.builtInCamera || cyborg.wires.is_cut(WIRE_CAMERA)?"FAULT":"[cyborg.builtInCamera.can_use()?"NOMINAL":"DISABLED"]"]"
	//AI wire. FAULT if wire is cut, CONNECTED if connected to AI, READY otherwise
	data["wireAI"] = "[cyborg.wires.is_cut(WIRE_AI)?"FAULT":"[cyborg.connected_ai?"CONNECTED":"READY"]"]"
	//Law sync wire. FAULT if cut, NOMINAL otherwise
	data["wireLaw"] = "[cyborg.wires.is_cut(WIRE_LAWSYNC)?"FAULT":"NOMINAL"]"

	return data

/datum/computer_file/program/borg_self_monitor/ui_static_data(mob/user)
	var/list/data = list()
	if(!iscyborg(user))
		return data
	var/mob/living/silicon/robot/cyborg = user

	data["Laws"] = cyborg.laws.get_law_list(TRUE, TRUE, FALSE)
	data["borgLog"] = tablet.borglog
	data["borgUpgrades"] = cyborg.upgrades
	return data

/datum/computer_file/program/borg_self_monitor/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/mob/living/silicon/robot/cyborg = tablet.silicon_owner

	switch(action)
		if("coverunlock")
			if(cyborg.locked)
				cyborg.locked = FALSE
				cyborg.update_icons()
				if(cyborg.emagged)
					cyborg.logevent("ChÃ¥vÃis cover lock has been [cyborg.locked ? "engaged" : "released"]") //"The cover interface glitches out for a split second"
				else
					cyborg.logevent("Chassis cover lock has been [cyborg.locked ? "engaged" : "released"]")

		if("lawchannel")
			cyborg.set_autosay()

		if("lawstate")
			cyborg.checklaws()

		if("alertPower")
			if(cyborg.stat == CONSCIOUS)
				if(!cyborg.cell || !cyborg.cell.charge)
					cyborg.visible_message(span_notice("The power warning light on [span_name("[cyborg]")] flashes urgently."), \
						"You announce you are operating in low power mode.")
					playsound(cyborg, 'sound/machines/buzz-two.ogg', 50, FALSE)

		if("toggleSensors")
			cyborg.toggle_sensors()

		if("viewImage")
			if(cyborg.connected_ai)
				cyborg.connected_ai.aicamera?.viewpictures(usr)
			else
				cyborg.aicamera?.viewpictures(usr)

		if("printImage")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = cyborg.aicamera
			borgcam?.borgprint(usr)

		if("toggleThrusters")
			cyborg.toggle_ionpulse()

		if("lampIntensity")
			cyborg.lamp_intensity = clamp(text2num(params["ref"]), 1, 5)
			cyborg.toggle_headlamp(FALSE, TRUE)

		if("cameraRadius")
			var/obj/item/camera/siliconcam/robot_camera/borgcam = cyborg.aicamera
			if(isnull(borgcam))
				CRASH("Cyborg embedded AI camera is null somehow, was it qdeleted?")
			var/desired_radius = text2num(params["ref"])
			if(isnull(desired_radius))
				return
			// respect the limits
			if(desired_radius > borgcam.picture_size_x_max || desired_radius < borgcam.picture_size_x_min)
				log_href_exploit(usr, " attempted to select an invalid borg camera size '[desired_radius]'.")
				return
			borgcam.picture_size_x = desired_radius
			borgcam.picture_size_y = desired_radius

		if("selfDestruct")
			if(cyborg.stat || cyborg.lockcharge) //No detonation while stunned or locked down
				return
			if(cyborg.emagged || istype(cyborg, /mob/living/silicon/robot/model/syndicate)) //This option shouldn't even be showing otherwise
				cyborg.self_destruct(cyborg)

/**
  * Forces a full update of the UI, if currently open.
  *
  * Forces an update that includes refreshing ui_static_data. Called by
  * law changes and borg log additions.
  */
/datum/computer_file/program/borg_self_monitor/proc/force_full_update()
	if(tablet)
		var/datum/tgui/active_ui = SStgui.get_open_ui(tablet.borgo, src)
		if(active_ui)
			active_ui.send_full_update(bypass_cooldown = TRUE)
