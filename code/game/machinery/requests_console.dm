GLOBAL_LIST_EMPTY(req_console_assistance)
GLOBAL_LIST_EMPTY(req_console_supplies)
GLOBAL_LIST_EMPTY(req_console_information)
GLOBAL_LIST_EMPTY(req_console_all)
GLOBAL_LIST_EMPTY(req_console_ckey_departments)

#define REQ_EMERGENCY_SECURITY "Security"
#define REQ_EMERGENCY_ENGINEERING "Engineering"
#define REQ_EMERGENCY_MEDICAL "Medical"

#define ANNOUNCEMENT_COOLDOWN_TIME (30 SECONDS)

/obj/machinery/requests_console
	name = "requests console"
	desc = "A console intended to send requests to different departments on the station."
	icon = 'icons/obj/terminals.dmi'
	icon_state = "req_comp0"
	max_integrity = 300
	armor = list(MELEE = 70,  BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 0, RAD = 0, FIRE = 90, ACID = 90, STAMINA = 0)
	layer = ABOVE_WINDOW_LAYER
	light_color = LIGHT_COLOR_GREEN
	light_power = 1.5
	//The list of all departments on the station (Determined from this variable on each unit) Set this to the same thing if you want several consoles in one department
	var/department = "Unknown"
	//List of all messages
	var/list/messages = list()
	//bitflag
	var/departmentType = 0
		// 0 = none (not listed, can only replied to)
		// assistance 	= 1
		// supplies 	= 2
		// info 		= 4
		// assistance + supplies 	= 3
		// assistance + info 		= 5
		// supplies + info 			= 6
		// assistance + supplies + info = 7
	var/silent = FALSE // set to 1 for it not to beep all the time
	var/hack_state = FALSE
	/// FALSE = This console cannot be used to send department announcements, TRUE = This console can send department announcements
	var/can_send_announcements = FALSE
	// TRUE if maintenance panel is open
	var/open = FALSE
	/// Will be set to TRUE when you authenticate yourself for announcements
	var/announcement_authenticated = FALSE
	/// Will contain the name of the person who verified it
	var/message_verified_by = ""
	/// If a message is stamped, this will contain the stamp name
	var/message_stamped_by = ""
	/// Reference to the internal radio
	var/obj/item/radio/radio
	///If an emergency has been called by this device. Acts as both a cooldown and lets the responder know where it the emergency was triggered from
	var/emergency
	/// If ore redemption machines will send an update when it receives new ores.
	var/receive_ore_updates = FALSE
	var/auth_id = "Unknown" //Will contain the name and and job of the person who verified it
	/// Did we error in the last mail?
	var/has_mail_send_error = FALSE
	/// Cooldown to prevent announcement spam
	COOLDOWN_DECLARE(announcement_cooldown)

/obj/machinery/requests_console/update_icon()
	if(machine_stat & NOPOWER)
		set_light(0)
	else
		set_light(1)//green light
	if(open)
		if(!hackState)
			icon_state="req_comp_open"
		else
			icon_state="req_comp_rewired"
	else if(machine_stat & NOPOWER)
		if(icon_state != "req_comp_off")
			icon_state = "req_comp_off"
	else
		if(emergency || (new_message_priority == REQ_EXTREME_MESSAGE_PRIORITY))
			icon_state = "req_comp3"
		else if(new_message_priority == REQ_HIGH_MESSAGE_PRIORITY)
			icon_state = "req_comp2"
		else if(new_message_priority == REQ_NORMAL_MESSAGE_PRIORITY)
			icon_state = "req_comp1"
		else
			icon_state = "req_comp0"

/obj/machinery/requests_console/Initialize(mapload)
	. = ..()
	if(department == "Unknown")
		var/area/AR = get_area(src)
		department = AR.name
	name = "\improper [department] requests console"
	GLOB.req_console_all += src

	if((assistance_requestable)) // adding to assistance list if not already present
		GLOB.req_console_assistance |= department

	if((supplies_requestable)) // supplier list
		GLOB.req_console_supplies |= department

	if((anon_tips_receiver)) // tips lists
		GLOB.req_console_information |= department

	GLOB.req_console_ckey_departments[ckey(department)] = department // and then we set ourselves a listed name

	radio = new /obj/item/radio(src)
	radio.listening = 0

/obj/machinery/requests_console/Destroy()
	QDEL_NULL(radio)
	QDEL_LIST(messages)
	GLOB.req_console_all -= src
	return ..()

/obj/machinery/requests_console/ui_interact(mob/user, datum/tgui/ui)
	if(open)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RequestsConsole")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/requests_console/ui_interact(mob/user)
	. = ..()
	var/dat = ""
	if(!open)
		switch(screen)
			if(REQ_SCREEN_MAIN)
				announceAuth = FALSE
				if (new_message_priority == REQ_NORMAL_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new messages</div><BR>"
				else if (new_message_priority == REQ_HIGH_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>PRIORITY</b> messages</div><BR>"
				else if (new_message_priority == REQ_EXTREME_MESSAGE_PRIORITY)
					dat += "<div class='notice'>There are new <b>EXTREME PRIORITY</b> messages</div><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_VIEW_MSGS]'>View Messages</A><BR><BR>"

				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_REQ_ASSISTANCE]'>Request Assistance</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_REQ_SUPPLIES]'>Request Supplies</A><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_RELAY]'>Relay Anonymous Information</A><BR><BR>"

				if(!emergency)
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_SECURITY]'>Emergency: Security</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_ENGINEERING]'>Emergency: Engineering</A><BR>"
					dat += "<A href='?src=[REF(src)];emergency=[REQ_EMERGENCY_MEDICAL]'>Emergency: Medical</A><BR><BR>"
				else
					dat += "<B><font color='red'>[emergency] has been dispatched to this location.</font></B><BR><BR>"

				if(announcementConsole)
					dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_ANNOUNCE]'>Send Station-wide Announcement</A><BR><BR>"
				if (silent)
					dat += "Speaker <A href='?src=[REF(src)];setSilent=0'>OFF</A>"
				else
					dat += "Speaker <A href='?src=[REF(src)];setSilent=1'>ON</A>"
			if(REQ_SCREEN_REQ_ASSISTANCE)
				dat += "Which department do you need assistance from?<BR><BR>"
				dat += departments_table(GLOB.req_console_assistance)

			if(REQ_SCREEN_REQ_SUPPLIES)
				dat += "Which department do you need supplies from?<BR><BR>"
				dat += departments_table(GLOB.req_console_supplies)

			if(REQ_SCREEN_RELAY)
				dat += "Which department would you like to send information to?<BR><BR>"
				dat += departments_table(GLOB.req_console_information)

			if(REQ_SCREEN_SENT)
				dat += "<span class='good'>Message sent.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

			if(REQ_SCREEN_ERR)
				dat += "<span class='bad'>An error occurred.</span><BR><BR>"
				dat += "<A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

			if(REQ_SCREEN_VIEW_MSGS)
				for (var/obj/machinery/requests_console/Console in GLOB.allConsoles)
					if (Console.department == department)
						Console.new_message_priority = REQ_NO_NEW_MESSAGE
						Console.update_icon()

				new_message_priority = REQ_NO_NEW_MESSAGE
				update_icon()
				var/messageComposite = ""
				for(var/msg in messages) // This puts more recent messages at the *top*, where they belong.
					messageComposite = "<div class='block'>[msg]</div>" + messageComposite
				dat += messageComposite
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back to Main Menu</A><BR>"

			if(REQ_SCREEN_AUTHENTICATE)
				dat += "<B>Message Authentication</B><BR><BR>"
				dat += "<b>Message for [to_department]: </b>[message]<BR><BR>"
				dat += "<div class='notice'>You may authenticate your message now by scanning your ID or your stamp</div><BR>"
				dat += "<b>Validated by:</b> [msgVerified ? msgVerified : "<i>Not Validated</i>"]<br>"
				dat += "<b>Stamped by:</b> [msgStamped ? msgStamped : "<i>Not Stamped</i>"]<br><br>"
				dat += "<A href='?src=[REF(src)];send=[TRUE]'>Send Message</A><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Discard Message</A><BR>"

			if(REQ_SCREEN_ANNOUNCE)
				dat += "<h3>Station-wide Announcement</h3>"
				if(announceAuth)
					dat += "<div class='notice'>Authentication accepted</div><BR>"
				else
					dat += "<div class='notice'>Swipe your card to authenticate yourself</div><BR>"
				dat += "<b>Message: </b>[message ? message : "<i>No Message</i>"]<BR>"
				dat += "<A href='?src=[REF(src)];writeAnnouncement=1'>[message ? "Edit" : "Write"] Message</A><BR><BR>"
				if ((announceAuth || IsAdminGhost(user)) && message)
					dat += "<A href='?src=[REF(src)];sendAnnouncement=1'>Announce Message</A><BR>"
				else
					dat += "<span class='linkOff'>Announce Message</span><BR>"
				dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"

		if(!dat)
			CRASH("No UI for src. Screen var is: [screen]")
		var/datum/browser/popup = new(user, "req_console", "[department] Requests Console", 450, 440)
		popup.set_content(dat)
		popup.open()
	return

/obj/machinery/requests_console/proc/departments_table(list/req_consoles)
	var/dat = ""
	dat += "<table width='100%'>"
	for(var/req_dpt in req_consoles)
		if (req_dpt != department)
			dat += "<tr>"
			dat += "<td width='55%'>[req_dpt]</td>"
			dat += "<td width='45%'><A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_NORMAL_MESSAGE_PRIORITY]'>Normal</A> <A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_HIGH_MESSAGE_PRIORITY]'>High</A>"
			if(hack_state)
				dat += "<A href='?src=[REF(src)];write=[ckey(req_dpt)];priority=[REQ_EXTREME_MESSAGE_PRIORITY]'>EXTREME</A>"
			dat += "</td>"
			dat += "</tr>"
	dat += "</table>"
	dat += "<BR><A href='?src=[REF(src)];setScreen=[REQ_SCREEN_MAIN]'><< Back</A><BR>"
	return dat

/obj/machinery/requests_console/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("clear_message_status")
			has_mail_send_error = FALSE
			for (var/obj/machinery/requests_console/console in GLOB.req_console_all)
				if (console.department == department)
					console.new_message_priority = REQ_NO_NEW_MESSAGE
					console.update_appearance()
			return TRUE
		if("clear_authentication")
			message_stamped_by = ""
			message_verified_by = ""
			announcement_authenticated = FALSE
			return TRUE
		if("toggle_silent")
			silent = !silent
			return TRUE
		if("set_emergency")
			if(emergency)
				return
			var/radio_freq
			switch(params["emergency"])
				if(REQ_EMERGENCY_SECURITY) //Security
					radio_freq = FREQ_SECURITY
				if(REQ_EMERGENCY_ENGINEERING) //Engineering
					radio_freq = FREQ_ENGINEERING
				if(REQ_EMERGENCY_MEDICAL) //Medical
					radio_freq = FREQ_MEDICAL
			if(radio_freq)
				emergency = params["emergency"]
				radio.set_frequency(radio_freq)
				radio.talk_into(src,"[emergency] emergency in [department]!!",radio_freq)
				update_appearance()
				addtimer(CALLBACK(src, PROC_REF(clear_emergency)), 5 MINUTES)
			return TRUE
		if("send_announcement")
			if(!COOLDOWN_FINISHED(src, announcement_cooldown))
				to_chat(usr, span_alert("Intercomms recharging. Please stand by."))
				return
			if(!can_send_announcements)
				return
			if(!(announcement_authenticated || isAdminGhostAI(usr)))
				return

			var/message = reject_bad_text(params["message"])
			if(!message)
				to_chat(usr, span_alert("Invalid message."))
				return
			if(isliving(usr))
				var/mob/living/L = usr
				message = L.treat_message(message)
			minor_announce(message, "[department] Announcement:", html_encode = FALSE)
			GLOB.news_network.submit_article(message, department, "Station Announcements", null)
			usr.log_talk(message, LOG_SAY, tag="station announcement from [src]")
			message_admins("[ADMIN_LOOKUPFLW(usr)] has made a station announcement from [src] at [AREACOORD(usr)].")
			deadchat_broadcast(" made a station announcement from [span_name("[get_area_name(usr, TRUE)]")].", span_name("[usr.real_name]"), usr, message_type=DEADCHAT_ANNOUNCEMENT)

			COOLDOWN_START(src, announcement_cooldown, ANNOUNCEMENT_COOLDOWN_TIME)
			announcement_authenticated = FALSE
			return TRUE
		if("quick_reply")
			var/recipient = params["reply_recipient"]

			var/reply_message = reject_bad_text(tgui_input_text(usr, "Write a quick reply to [recipient]", "Awaiting Input"))

			if(!reply_message)
				has_mail_send_error = TRUE
				playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
				return TRUE

			send_message(recipient, reply_message, REQ_NORMAL_MESSAGE_PRIORITY, REPLY_REQUEST)
			return TRUE
		if("send_message")
			var/recipient = params["recipient"]
			if(!recipient)
				return
			var/priority = params["priority"]
			if(!priority)
				return
			var/message = reject_bad_text(params["message"])
			if(!message)
				to_chat(usr, span_alert("Invalid message."))
				has_mail_send_error = TRUE
				return TRUE
			var/request_type = params["request_type"]
			if(!request_type)
				return
			send_message(recipient, message, priority, request_type)
			return TRUE

///Sends the message from the request console
/obj/machinery/requests_console/proc/send_message(recipient, message, priority, request_type)
	var/radio_freq
	switch(ckey(recipient))
		if("bridge")
			radio_freq = FREQ_COMMAND
		if("medbay")
			radio_freq = FREQ_MEDICAL
		if("science")
			radio_freq = FREQ_SCIENCE
		if("engineering")
			radio_freq = FREQ_ENGINEERING
		if("security")
			radio_freq = FREQ_SECURITY
		if("cargobay", "mining")
			radio_freq = FREQ_SUPPLY

	var/datum/signal/subspace/messaging/rc/signal = new(src, list(
		"sender_department" = department,
		"recipient_department" = recipient,
		"message" = message,
		"verified" = message_verified_by,
		"stamped" = message_stamped_by,
		"priority" = priority,
		"notify_freq" = radio_freq,
		"request_type" = request_type,
	))
	signal.send_to_receivers()

	has_mail_send_error = !signal.data["done"]

	if(!silent)
		if(has_mail_send_error)
			playsound(src, 'sound/machines/buzz-two.ogg', 50, TRUE)
		else
			playsound(src, 'sound/machines/twobeep.ogg', 50, TRUE)

	message_stamped_by = ""
	message_verified_by = ""

/obj/machinery/requests_console/ui_data(mob/user)
	var/list/data = list()
	data["is_admin_ghost_ai"] = isAdminGhostAI()
	data["can_send_announcements"] = can_send_announcements
	data["department"] = department
	data["emergency"] = emergency
	data["hack_state"] = hack_state
	data["new_message_priority"] = new_message_priority
	data["silent"] = silent
	data["has_mail_send_error"] = has_mail_send_error
	data["authentication_data"] = list(
		"message_verified_by" = message_verified_by,
		"message_stamped_by" = message_stamped_by,
		"announcement_authenticated" = announcement_authenticated,
	)
	data["messages"] = list()
	for (var/datum/request_message/message in messages)
		data["messages"] += list(message.message_ui_data())
	return data


/obj/machinery/requests_console/ui_static_data(mob/user)
	var/list/data = list()

	data["assistance_consoles"] = GLOB.req_console_assistance - department
	data["supply_consoles"] = GLOB.req_console_supplies - department
	data["information_consoles"] = GLOB.req_console_information - department

	return data

/obj/machinery/requests_console/say_mod(input, list/message_mods = list())
	if(spantext_char(input, "!", -3))
		return "blares"
	else
		. = ..()

/obj/machinery/requests_console/proc/clear_emergency()
	emergency = null
	update_appearance()

/// From message_server.dm: Console.create_message(data)
/obj/machinery/requests_console/proc/create_message(data)

	var/datum/request_message/new_message = new(data)

	switch(new_message.priority)
		if(REQ_NORMAL_MESSAGE_PRIORITY)
			if(new_message_priority < REQ_NORMAL_MESSAGE_PRIORITY)
				new_message_priority = REQ_NORMAL_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_HIGH_MESSAGE_PRIORITY)
			if(new_message_priority < REQ_HIGH_MESSAGE_PRIORITY)
				new_message_priority = REQ_HIGH_MESSAGE_PRIORITY
				update_appearance()

		if(REQ_EXTREME_MESSAGE_PRIORITY)
			silent = FALSE
			if(new_message_priority < REQ_EXTREME_MESSAGE_PRIORITY)
				new_message_priority = REQ_EXTREME_MESSAGE_PRIORITY
				update_appearance()

	messages.Insert(1, new_message) //reverse order

	SStgui.update_uis(src)

	var/alert = new_message.get_alert()

	if(!silent)
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
		say(alert)

	if(new_message.radio_freq)
		radio.set_frequency(new_message.radio_freq)
		radio.talk_into(src, "[alert]: <i>[new_message.content]</i>", new_message.radio_freq)

/obj/machinery/requests_console/attackby(obj/item/attacking_item, mob/user, params)
	var/obj/item/card/id/ID = attacking_item.GetID()
	if(ID)
		message_verified_by = "[ID.registered_name] ([ID.assignment])"
		announcement_authenticated = (ACCESS_RC_ANNOUNCE in ID.access)
		SStgui.update_uis(src)
		return
	if (istype(attacking_item, /obj/item/stamp))
		var/obj/item/stamp/attacking_stamp = attacking_item
		message_stamped_by = attacking_stamp.name
		SStgui.update_uis(src)
		return
	return ..()

#undef REQ_EMERGENCY_SECURITY
#undef REQ_EMERGENCY_ENGINEERING
#undef REQ_EMERGENCY_MEDICAL

#undef ANNOUNCEMENT_COOLDOWN_TIME
