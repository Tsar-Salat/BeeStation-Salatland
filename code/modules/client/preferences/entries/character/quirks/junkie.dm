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

/datum/preference/choiced/quirk/junkie_drug
	db_key = "quirk_junkie_drug"
	required_quirk = /datum/quirk/item_quirk/addict/junkie

/datum/preference/choiced/quirk/junkie_drug/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_junkie_addictions)

/datum/preference/choiced/quirk/junkie_drug/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/name in GLOB.possible_junkie_addictions)
		clean_names[name] = name
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data

/datum/preference/choiced/quirk/smoker_cigarettes
	db_key = "quirk_smoker_cigarettes"
	required_quirk = /datum/quirk/item_quirk/addict/smoker

/datum/preference/choiced/quirk/smoker_cigarettes/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_smoker_addictions)

/datum/preference/choiced/quirk/smoker_cigarettes/create_default_value()
	return "Random"

/datum/preference/choiced/quirk/smoker_cigarettes/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/name in GLOB.possible_smoker_addictions)
		clean_names[name] = name
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data

/datum/preference/choiced/quirk/alcohol_type
	db_key = "quirk_alcohol_type"
	required_quirk = /datum/quirk/item_quirk/addict/alcoholic

/datum/preference/choiced/quirk/alcohol_type/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.possible_alcoholic_addictions)

/datum/preference/choiced/quirk/alcohol_type/create_default_value()
	return "Random"

/datum/preference/choiced/quirk/alcohol_type/compile_constant_data()
	var/list/data = ..()
	var/list/clean_names = list("Random" = "Random")
	for(var/name in GLOB.possible_alcoholic_addictions)
		clean_names[name] = name
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = clean_names
	return data
