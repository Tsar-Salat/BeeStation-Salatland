
// Clothing armour values.
/obj/item/clothing/get_lore_info()
	return desc

/obj/item/clothing/get_mechanics_info()
	var/list/armor_strings = list()

	// BeeStation uses /datum/armor instead of a list
	var/datum/armor/arm = get_armor()
	if(arm)
		// Define armor type descriptions
		var/static/list/armour_to_descriptive_term = list(
			"melee" = "blunt force",
			"bullet" = "ballistics",
			"laser" = "lasers",
			"energy" = "energy",
			"bomb" = "explosions",
			"bio" = "biohazards",
			"rad" = "radiation"
		)

		for(var/armor_type in armour_to_descriptive_term)
			var/armor_value = arm.vars[armor_type]
			if(armor_value)
				switch(armor_value)
					if(1 to 20)
						armor_strings += "It barely protects against [armour_to_descriptive_term[armor_type]]."
					if(21 to 30)
						armor_strings += "It provides a very small defense against [armour_to_descriptive_term[armor_type]]."
					if(31 to 40)
						armor_strings += "It offers a small amount of protection against [armour_to_descriptive_term[armor_type]]."
					if(41 to 50)
						armor_strings += "It offers a moderate defense against [armour_to_descriptive_term[armor_type]]."
					if(51 to 60)
						armor_strings += "It provides a strong defense against [armour_to_descriptive_term[armor_type]]."
					if(61 to 70)
						armor_strings += "It is very strong against [armour_to_descriptive_term[armor_type]]."
					if(71 to 80)
						armor_strings += "This gives a very robust defense against [armour_to_descriptive_term[armor_type]]."
					if(81 to 100)
						armor_strings += "Wearing this would make you nigh-invulerable against [armour_to_descriptive_term[armor_type]]."

	// BeeStation uses clothing_flags & STOPSPRESSUREDAMAGE instead of item_flags & ITEM_FLAG_AIRTIGHT
	if(clothing_flags & STOPSPRESSUREDAMAGE)
		armor_strings += "It protects you from pressure damage."

	if(min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT)
		armor_strings += "Wearing this will protect you from the vacuum of space."
	else if(min_cold_protection_temperature)
		armor_strings += "Wearing this will protect you from low temperatures, but not the vacuum of space."

	if(max_heat_protection_temperature)
		if(max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			armor_strings += "You could probably safely skydive into the Sun wearing this."
		else if(max_heat_protection_temperature >= SPACE_SUIT_MAX_TEMP_PROTECT)
			armor_strings += "It provides good protection against fire and heat."

	// BeeStation uses obj_flags & THICKMATERIAL instead of item_flags & ITEM_FLAG_THICKMATERIAL
	if(obj_flags & THICKMATERIAL)
		armor_strings += "The material is exceptionally thick."

	// Body part coverage
	var/list/covers = list()
	var/static/list/part_flags = list(
		"head" = HEAD,
		"chest" = CHEST,
		"groin" = GROIN,
		"left leg" = LEG_LEFT,
		"right leg" = LEG_RIGHT,
		"left foot" = FOOT_LEFT,
		"right foot" = FOOT_RIGHT,
		"left arm" = ARM_LEFT,
		"right arm" = ARM_RIGHT,
		"left hand" = HAND_LEFT,
		"right hand" = HAND_RIGHT,
		"neck" = NECK
	)

	for(var/name in part_flags)
		if(body_parts_covered & part_flags[name])
			covers += name

	// Slot flags
	var/list/slots = list()
	var/static/list/slot_names = list(
		"exosuit slot" = ITEM_SLOT_OCLOTHING,
		"jumpsuit slot" = ITEM_SLOT_ICLOTHING,
		"glove slot" = ITEM_SLOT_GLOVES,
		"glasses slot" = ITEM_SLOT_EYES,
		"ear slot" = ITEM_SLOT_EARS,
		"mask slot" = ITEM_SLOT_MASK,
		"head slot" = ITEM_SLOT_HEAD,
		"shoe slot" = ITEM_SLOT_FEET,
		"ID slot" = ITEM_SLOT_ID,
		"belt slot" = ITEM_SLOT_BELT,
		"back slot" = ITEM_SLOT_BACK,
		"neck slot" = ITEM_SLOT_NECK
	)

	for(var/name in slot_names)
		if(slot_flags & slot_names[name])
			slots += name

	if(length(covers))
		armor_strings += "It covers the [english_list(covers)]."

	if(length(slots))
		armor_strings += "It can be worn on your [english_list(slots)]."

	return jointext(armor_strings, "<br>")

/*
/obj/item/clothing/suit/armor/vest/alt/get_mechanics_info()
	. = ..()
	. += "<br>Its protection is provided by the plate inside, examine it for details on armor.<br>"
*/
