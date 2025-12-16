/obj/item/gun/var/general_codex_key = "guns"

/obj/item/gun/ballistic/general_codex_key = "ballistic weapons"

/obj/item/gun/energy/general_codex_key = "energy weapons"

/obj/item/gun/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/gun/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	. = "[desc]<br>"
	if(general_entry && general_entry.lore_text)
		. += general_entry.lore_text

/obj/item/gun/get_mechanics_info()
	var/list/traits = list()

	var/list/entries = SScodex.retrieve_entries_for_string(general_codex_key)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		traits += general_entry.mechanics_text

	if(spread_unwielded)
		traits += "It's best fired with two-handed grip."

	if(!no_pin_required && pin)
		traits += "It's fitted with a firing pin. Remove or swap pins to change who can use it."

	if(zoomable)
		traits += "It has a magnifying optical scope. Toggle it to zoom."

	if(burst_size > 1)
		traits += "It has burst fire mode, firing [burst_size] rounds per trigger pull."

	return jointext(traits, "<br>")

/obj/item/gun/ballistic/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	if(LAZYLEN(caliber))
		traits += "<br>Caliber: [english_list(caliber)]"

	if(mag_type)
		var/obj/item/ammo_box/magazine/mag = new mag_type()
		traits += "Uses [mag.name] magazines holding up to [mag.max_ammo] rounds."
		qdel(mag)
	else if(direct_loading)
		traits += "Can be loaded directly with loose rounds."

	if(bolt_type)
		switch(bolt_type)
			if(BOLT_TYPE_STANDARD)
				traits += "Has a standard bolt mechanism."
			if(BOLT_TYPE_LOCKING)
				traits += "Bolt locks back when empty."
			if(BOLT_TYPE_OPEN)
				traits += "Has an open-bolt mechanism."

	. += jointext(traits, "<br>")

/obj/item/gun/energy/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	if(cell)
		var/shots = round(cell.maxcharge / 100) // Rough estimate
		traits += "<br>Its maximum capacity is approximately [shots] shots worth of power."

	if(selfcharge)
		traits += "It recharges itself over time."

	if(LAZYLEN(ammo_type) > 1 && can_select)
		traits += "It has multiple firing modes. Click it in hand to cycle them."

	. += jointext(traits, "<br>")

/obj/item/gun/ballistic/shotgun/get_mechanics_info()
	. = ..()
	if(bolt_type == BOLT_TYPE_PUMP)
		. += "<br>To pump it, click it in hand while wielding.<br>"

/obj/item/gun/energy/crossbow/get_antag_info()
	. = ..()
	. += "This is a stealthy weapon which fires poisoned bolts at your target. When it hits someone, they will suffer a stun effect, in \
	addition to toxins. The energy crossbow recharges itself slowly, and can be concealed in your pocket or bag.<br>"

/obj/item/gun/energy/chameleon/get_antag_info()
	. = ..()
	. += "This gun is actually a hologram projector that can alter its appearance to mimick other weapons. To change the appearance, use \
	the appropriate verb in the object tab. Any beams or projectiles fired from this gun are actually holograms and useless for actual combat. \
	Projecting these holograms over distance uses a little bit of charge.<br>"


/datum/codex_entry/energy_weapons
	display_name = "energy weapons"
	mechanics_text = "This weapon is an energy weapon; they run on battery charge rather than traditional ammunition. You can recharge \
		an energy weapon by placing it in a wall-mounted or table-mounted charger, such as those found in Security or around the \
		place. Additionally, most energy weapons can go straight through windows and hit whatever is on the other side, and are \
		hitscan, making them accurate and useful against distant targets. \
		<br><br>"

/datum/codex_entry/ballistic_weapons
	display_name = "ballistic weapons"
	mechanics_text = "This weapon is a ballistic weapon; it fires solid shots using a magazine or loaded rounds of ammunition. You can \
		unload it by holding it and clicking it with an empty hand, and reload it by clicking it with a magazine, or in the case of \
		shotguns or some rifles, by opening the breech and clicking it with individual rounds. \
		<br><br>"
	lore_text = "Ballistic weapons are still used even now due to the relative expense of decent laser \
		weapons, difficulties in maintaining them, and the sheer stopping and wounding power of solid slugs or \
		composite shot. Using a ballistic weapon on a spacebound habitat is usually considered a serious undertaking, \
		as a missed shot or careless use of automatic fire could rip open the hull or injure bystanders with ease."

