/proc/setup_junkie_addictions(list/possible_addictions)
	. = possible_addictions
	for(var/datum/reagent/addiction as anything in .)
		. -= addiction
		.[addiction::name] = addiction

/proc/setup_smoker_addictions(list/possible_addictions)
	. = possible_addictions
	for(var/obj/item/storage/addiction as anything in .)
		. -= addiction
		.[format_text(addiction::name)] = addiction // Format text to remove \improper used in cigarette packs

/datum/preference/choiced/junkie_drug
	db_key = "quirk_junkie_drug"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/junkie_drug/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_junkie_addictions)

/datum/preference/choiced/junkie/create_default_value()
	return "Random"

/datum/preference/choiced/junkie/is_accessible(datum/preferences/preferences, ignore_page)
	if (!..())
		return FALSE
	return "Junkie" in preferences.all_quirks

/datum/preference/choiced/junkie/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/junkie_drug/deserialize(input, datum/preferences/preferences)
	if(istext(input) && length(input) && input[1] == "/")
		var/path = text2path(input)
		if(path)
			for(var/name in GLOB.possible_junkie_addictions)
				if(GLOB.possible_junkie_addictions[name] == path)
					return name
	return ..()


/datum/preference/choiced/smoker_cigarettes
	db_key = "quirk_smoker_cigarettes"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/smoker_cigarettes/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_smoker_addictions)

/datum/preference/choiced/smoker/create_default_value()
	return "Random"

/datum/preference/choiced/smoker/is_accessible(datum/preferences/preferences, ignore_page)
	if (!..())
		return FALSE
	return "Smoker" in preferences.all_quirks

/datum/preference/choiced/smoker/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/smoker_cigarettes/deserialize(input, datum/preferences/preferences)
	if(istext(input) && length(input) && input[1] == "/")
		var/path = text2path(input)
		if(path)
			for(var/name in GLOB.possible_smoker_addictions)
				if(GLOB.possible_smoker_addictions[name] == path)
					return name
	return ..()


/datum/preference/choiced//alcohol_type
	db_key = "quirk_alcohol_type"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/alcohol_type/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_alcoholic_addictions)

/datum/preference/choiced/alcohol_type/create_default_value()
	return "Random"

/datum/preference/choiced/alcoholic/is_accessible(datum/preferences/preferences, ignore_page)
	if (!..())
		return FALSE
	return "Alcoholic" in preferences.all_quirks

/datum/preference/choiced/alcoholic/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/alcohol_type/deserialize(input, datum/preferences/preferences)
	if(istext(input) && length(input) && input[1] == "/")
		var/path = text2path(input)
		if(path)
			for(var/name in GLOB.possible_alcoholic_addictions)
				if(GLOB.possible_alcoholic_addictions[name]["bottlepath"] == path)
					return name
	return ..()
