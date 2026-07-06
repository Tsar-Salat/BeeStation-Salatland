/datum/preference/choiced/language
	db_key = "quirk_multilingual_language"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/language/deserialize(input, datum/preferences/preferences)
	var/datum/language/path = text2path(input)
	if(ispath(path, /datum/language))
		input = initial(path.name)
	return sanitize_inlist(input, get_choices(), create_default_value())

/datum/preference/choiced/language/serialize(input)
	// Convert display names back to type path strings for legacy system compat on rollback
	var/path = GLOB.language_types_by_name[input]
	if(ispath(path, /datum/language))
		return "[path]"
	return input

/datum/preference/choiced/language/create_default_value()
	return "Random"

/datum/preference/choiced/language/is_accessible(datum/preferences/preferences, ignore_page)
	if (!..(preferences))
		return FALSE

	return "Bilingual" in preferences.all_quirks

/datum/preference/choiced/language/init_possible_values()
	var/list/values = list()

	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()

	values += "Random"

	//we add uncommon as it's foreigner-only.
	var/datum/language/uncommon/uncommon_language = /datum/language/uncommon
	values += initial(uncommon_language.name)

	for(var/datum/language/language_type as anything in GLOB.uncommon_roundstart_languages)
		if(initial(language_type.name) in values)
			continue
		values += initial(language_type.name)

	return values

/datum/preference/choiced/language/apply_to_human(mob/living/carbon/human/target, value)
	return
