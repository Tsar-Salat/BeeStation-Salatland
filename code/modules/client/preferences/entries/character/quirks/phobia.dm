/datum/preference/choiced/phobia
	db_key = "quirk_phobia"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/phobia/init_possible_values()
	return GLOB.phobia_types

/datum/preference/choiced/phobia/deserialize(input, datum/preferences/preferences)
	if(input == "Random")
		return create_default_value()
	return sanitize_inlist(input, get_choices(), create_default_value())

/datum/preference/choiced/phobia/serialize(input)
	if(!(input in GLOB.available_random_trauma_list))
		return "Random"
	return input

/datum/preference/choiced/phobia/is_accessible(datum/preferences/preferences, ignore_page)
	if (!..(preferences))
		return FALSE

	return /datum/brain_trauma/mild/phobia::name in preferences.all_quirks

/datum/preference/choiced/phobia/apply_to_human(mob/living/carbon/human/target, value)
	return
