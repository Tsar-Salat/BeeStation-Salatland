//Programs that interact with other programs or nanites directly, or have other special purposes.
/datum/nanite_program/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters, also overriding or disabling their cloud sync."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/toxic)
	var/pulse_cooldown = 0

/datum/nanite_program/viral/register_extra_settings()
	extra_settings[NES_PROGRAM_OVERWRITE] = new /datum/nanite_extra_setting/type("Add To", list("Overwrite", "Add To", "Ignore"))
	extra_settings[NES_CLOUD_OVERWRITE] = new /datum/nanite_extra_setting/number(0, 0, 100)

/datum/nanite_program/viral/active_effect()
	if(world.time < pulse_cooldown)
		return
	var/datum/nanite_extra_setting/program = extra_settings[NES_PROGRAM_OVERWRITE]
	var/datum/nanite_extra_setting/cloud = extra_settings[NES_CLOUD_OVERWRITE]
	for(var/mob/M in orange(5, host_mob))
		if(SEND_SIGNAL(M, COMSIG_NANITE_IS_STEALTHY))
			continue
		switch(program.get_value())
			if("Overwrite")
				SEND_SIGNAL(M, COMSIG_NANITE_SYNC, nanites, TRUE)
			if("Add To")
				SEND_SIGNAL(M, COMSIG_NANITE_SYNC, nanites, FALSE)
		SEND_SIGNAL(M, COMSIG_NANITE_SET_CLOUD, cloud.get_value())
	pulse_cooldown = world.time + 75

/datum/nanite_program/monitoring
	name = "Monitoring"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/monitoring/enable_passive_effect()

	. = ..()

	if(!ishuman(host_mob))
		return

	ADD_TRAIT(host_mob, TRAIT_NANITE_SENSORS, TRACKED_SENSORS_TRAIT)
	if(!HAS_TRAIT(host_mob, TRAIT_SUIT_SENSORS))
		GLOB.suit_sensors_list += host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/monitoring/disable_passive_effect()

	. = ..()

	if(!ishuman(host_mob))
		return

	REMOVE_TRAIT(host_mob, TRAIT_NANITE_SENSORS, TRACKED_SENSORS_TRAIT)
	if(!HAS_TRAIT(host_mob, TRAIT_SUIT_SENSORS))
		GLOB.suit_sensors_list -= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/self_scan
	name = "Host Scan"
	desc = "The nanites display a detailed readout of a body scan to the host."
	unique = FALSE
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/self_scan/register_extra_settings()
	extra_settings[NES_SCAN_TYPE] = new /datum/nanite_extra_setting/type("Medical", list("Medical", "Chemical", "Nanite"))

/datum/nanite_program/self_scan/on_trigger(comm_message)
	if(host_mob.stat == DEAD)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_SCAN_TYPE]
	switch(NS.get_value())
		if("Medical")
			healthscan(host_mob, host_mob)
		if("Chemical")
			chemscan(host_mob, host_mob)
		if("Nanite")
			SEND_SIGNAL(host_mob, COMSIG_NANITE_SCAN, host_mob, TRUE)

/datum/nanite_program/stealth
	name = "Stealth"
	desc = "The nanites mask their activity from superficial scans, becoming undetectable by HUDs and non-specialized scanners."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = 0.2

/datum/nanite_program/stealth/enable_passive_effect()
	. = ..()
	nanites.stealth = TRUE

/datum/nanite_program/stealth/disable_passive_effect()
	. = ..()
	nanites.stealth = FALSE

/datum/nanite_program/reduced_diagnostics
	name = "Reduced Diagnostics"
	desc = "Disables some high-cost diagnostics in the nanites, making them unable to communicate their program list to portable scanners. \
	Doing so saves some power, slightly increasing their replication speed."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = -0.1

/datum/nanite_program/reduced_diagnostics/enable_passive_effect()
	. = ..()
	nanites.diagnostics = FALSE

/datum/nanite_program/reduced_diagnostics/disable_passive_effect()
	. = ..()
	nanites.diagnostics = TRUE

/datum/nanite_program/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/relay/register_extra_settings()
	extra_settings[NES_RELAY_CHANNEL] = new /datum/nanite_extra_setting/number(1, 1, 9999)

/datum/nanite_program/relay/enable_passive_effect()
	. = ..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	. = ..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, relay_code, source)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != NS.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, code, source)

/datum/nanite_program/relay/proc/relay_comm_signal(comm_code, relay_code, comm_message)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != NS.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_COMM_SIGNAL, comm_code, comm_message)

/datum/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel. Does not have a built-in safety limiter."
	use_rate = -0.5 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	if(host_mob.nutrition <= 0)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.adjust_nutrition(-min(0.5, host_mob.nutrition))

/datum/nanite_program/research
	name = "Distributed Computing"
	desc = "The nanites aid the research servers by performing a portion of its calculations, increasing research point generation."
	use_rate = 0.2
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/research/active_effect()
	if(!iscarbon(host_mob))
		return
	var/points = 1
	if(!host_mob.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/datum/nanite_program/researchplus
	name = "Neural Network"
	desc = "The nanites link the host's brains together forming a neural research network, that becomes more efficient with the amount of total hosts."
	use_rate = 0.3
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/researchplus/enable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count++
	else
		SSnanites.neural_network_count += 0.25

/datum/nanite_program/researchplus/disable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count--
	else
		SSnanites.neural_network_count -= 0.25

/datum/nanite_program/researchplus/active_effect()
	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	var/points = round(SSnanites.neural_network_count / 12, 0.1)
	if(!C.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/datum/nanite_program/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 30
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/nanite_access = list()

//Syncs the nanites with the cumulative current mob's access level. Can potentially wipe existing access.
/datum/nanite_program/access/on_trigger(comm_message)
	nanite_access = list() // resets access list
	var/obj/item/current_item
	current_item = host_mob.get_active_held_item()
	if(current_item)
		nanite_access |= current_item.GetAccess()
	current_item = host_mob.get_inactive_held_item()
	if(current_item)
		nanite_access |= current_item.GetAccess()
	current_item = host_mob.pulling
	if(isitem(current_item))
		nanite_access |= current_item.GetAccess()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		current_item = H.wear_id
		if(current_item)
			nanite_access |= current_item.GetAccess()
	else if(isanimal(host_mob))
		var/mob/living/simple_animal/A = host_mob
		current_item = A.access_card
		if(current_item)
			nanite_access |= current_item.GetAccess()

/datum/nanite_program/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	use_rate = 1.50
	rogue_types = list(/datum/nanite_program/aggressive_replication, /datum/nanite_program/necrotic)
	COOLDOWN_DECLARE(spread_cooldown)

/datum/nanite_program/spreading/active_effect()
	if(!COOLDOWN_FINISHED(src, spread_cooldown))
		return
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/target in ohearers(5, host_mob))
		if(prob(15 * max(get_dist(host_mob, target) - 1, 0)))
			continue
		if(!(MOB_ORGANIC in target.mob_biotypes) && !(MOB_UNDEAD in target.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE))
			continue
		target_hosts += target
	if(!target_hosts.len)
		COOLDOWN_START(src, spread_cooldown, 2 SECONDS)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(SEND_SIGNAL(infectee, COMSIG_HAS_NANITES))
		COOLDOWN_START(src, spread_cooldown, 2 SECONDS)
		return
	if(prob(100 - (infectee.getarmor(null, BIO))))
		COOLDOWN_START(src, spread_cooldown, 7.5 SECONDS)
		infectee.AddComponent(/datum/component/nanites, 10)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by spreading nanites by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)
	else
		COOLDOWN_START(src, spread_cooldown, 2 SECONDS)

/datum/nanite_program/nanite_sting
	name = "Nanite Sting"
	desc = "When triggered, projects a nearly invisible spike of nanites that attempts to infect a nearby non-host with a copy of the host's nanites cluster."
	can_trigger = TRUE
	trigger_cost = 5
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/glitch, /datum/nanite_program/toxic)

/datum/nanite_program/nanite_sting/on_trigger(comm_message)
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/L in oview(1, host_mob))
		if(!(MOB_ORGANIC in L.mob_biotypes) && !(MOB_UNDEAD in L.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE))
			continue
		if(!L.Adjacent(host_mob))
			continue
		target_hosts += L
	if(!target_hosts.len)
		consume_nanites(-5)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(prob(100 - (infectee.getarmor(null, BIO))))
		infectee.AddComponent(/datum/component/nanites, 5)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by a nanite cluster by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)
		to_chat(infectee, span_warning("You feel a tiny prick!"))

/datum/nanite_program/mitosis
	name = "Mitosis"
	desc = "The nanites gain the ability to self-replicate, using bluespace to power the process. Becomes more effective the more nanites are already in the host.\
			The replication has also a chance to corrupt the nanite programming due to copy faults - cloud sync is highly recommended."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/mitosis/active_effect()
	var/rep_rate = round(nanites.nanite_volume / 50, 1) //0.5 per 50 nanite volume
	rep_rate *= 0.5
	nanites.adjust_nanites(amount = rep_rate)
	if(prob(rep_rate))
		var/datum/nanite_program/fault = pick(nanites.programs)
		if(fault == src)
			return
		fault.software_error()

/datum/nanite_program/dermal_button
	name = "Dermal Button"
	desc = "Displays a button on the host's skin, which can be used to send a signal to the nanites."
	unique = FALSE
	var/datum/action/innate/nanite_button/button

/datum/nanite_program/dermal_button/register_extra_settings()
	extra_settings[NES_SENT_CODE] = new /datum/nanite_extra_setting/number(1, 1, 9999)
	extra_settings[NES_BUTTON_NAME] = new /datum/nanite_extra_setting/text("Button")
	extra_settings[NES_ICON] = new /datum/nanite_extra_setting/type("power", list("one", "two", "three", "four", "five", "plus", "minus", "power"))
	extra_settings[NES_COLOR] = new /datum/nanite_extra_setting/type("green", list("green", "red", "yellow", "blue"))

/datum/nanite_program/dermal_button/enable_passive_effect()
	. = ..()
	var/datum/nanite_extra_setting/bn_name = extra_settings[NES_BUTTON_NAME]
	var/datum/nanite_extra_setting/bn_icon = extra_settings[NES_ICON]
	if(!button)
		button = new(src, bn_name.get_value(), bn_icon.get_value(), "red")
	button.Grant(host_mob)

/datum/nanite_program/dermal_button/disable_passive_effect()
	. = ..()
	if(button)
		button.Remove(host_mob)

/datum/nanite_program/dermal_button/on_mob_remove()
	. = ..()
	QDEL_NULL(button)

/datum/nanite_program/dermal_button/proc/press()
	if(activated)
		host_mob.visible_message(span_notice("[host_mob] presses a button on [host_mob.p_their()] forearm."),
								span_notice("You press the nanite button on your forearm."), null, 2)
		var/datum/nanite_extra_setting/sent_code = extra_settings[NES_SENT_CODE]
		SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code.get_value(), "a [name] program")

/datum/action/innate/nanite_button
	name = "Button"
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_CONSCIOUS
	button_icon_state = "power_green"
	var/datum/nanite_program/dermal_button/program

/datum/action/innate/nanite_button/New(datum/nanite_program/dermal_button/_program, _name, _icon, _color)
	..()
	program = _program
	name = _name
	button_icon_state = "[_icon]_[_color]"

/datum/action/innate/nanite_button/on_activate()
	program.press()

/datum/action/innate/nanite_button/proc/update_icon(icon, color)
	button_icon_state = "[icon]_[color]"
	update_buttons()

/datum/nanite_program/dermal_button/toggle
	name = "Dermal Toggle"
	desc = "Displays a switch on the host's skin, which can be used to send an activation and deactivation signal to the nanites."
	var/active = FALSE

/datum/nanite_program/dermal_button/toggle/register_extra_settings()
	extra_settings[NES_ACTIVATION_CODE] = new /datum/nanite_extra_setting/number(1, 1, 9999)
	extra_settings[NES_DEACTIVATION_CODE] = new /datum/nanite_extra_setting/number(1, 1, 9999)
	extra_settings[NES_BUTTON_NAME] = new /datum/nanite_extra_setting/text("Toggle")
	extra_settings[NES_ICON] = new /datum/nanite_extra_setting/type("power", list("one", "two", "three", "four", "five", "plus", "minus", "power"))

/datum/nanite_program/dermal_button/toggle/press()
	if(!activated)
		return

	var/datum/nanite_extra_setting/icon = extra_settings[NES_ICON]
	var/datum/nanite_extra_setting/sent_code = extra_settings[active ? NES_DEACTIVATION_CODE : NES_ACTIVATION_CODE]
	button.update_icon(icon.get_value(), active ? "red" : "green")
	host_mob.visible_message(span_notice("[host_mob] flicks a switch on [host_mob.p_their()] forearm."),
								span_notice("You flick the nanite button on your forearm [active ? "off" : "on"]."), null, 2)
	active = !active
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code.get_value(), "a [name] program")

/datum/nanite_program/signaler
	name = "Remote Signaler"
	desc = "The nanites send a pulse to all remote signalers on a given frequency and code."
	can_trigger = TRUE
	trigger_cost = 10
	trigger_cooldown = 5
	var/datum/radio_frequency/radio_connection

/datum/nanite_program/signaler/register_extra_settings()
	extra_settings[NES_SIGNAL_FREQUENCY] = new /datum/nanite_extra_setting/number(FREQ_SIGNALER, MIN_FREQ, MAX_FREQ)
	extra_settings[NES_SIGNAL_CODE] = new /datum/nanite_extra_setting/number(DEFAULT_SIGNALER_CODE, 1, 99)

/datum/nanite_program/signaler/enable_passive_effect()
	. = ..()
	var/datum/nanite_extra_setting/frequency = extra_settings[NES_SIGNAL_FREQUENCY]
	radio_connection = SSradio.return_frequency(frequency.get_value())

/datum/nanite_program/signaler/on_trigger()
	if(!radio_connection)
		return
	var/datum/nanite_extra_setting/code = extra_settings[NES_SIGNAL_CODE]
	radio_connection.post_signal(src, new /datum/signal(list("code" = code.get_value())), filter = RADIO_SIGNALER)

/datum/nanite_program/vampire
	name = "Vampiric Synthesis"
	desc = "The nanites can consume the host's blood in order to replicate much faster. Does not have a built-in safety limiter."
	use_rate = -0.75

/datum/nanite_program/vampire/check_conditions()
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(host_mob))
		return FALSE
	if(host_mob.blood_volume <= 0)
		return FALSE
	if(ishuman(host_mob))
		var/mob/living/carbon/human/host_human = host_mob
		if(HAS_TRAIT(host_human, TRAIT_NOBLOOD))
			return FALSE

/datum/nanite_program/vampire/active_effect()
	host_mob.blood_volume = max(host_mob.blood_volume - 1.5, 0)
