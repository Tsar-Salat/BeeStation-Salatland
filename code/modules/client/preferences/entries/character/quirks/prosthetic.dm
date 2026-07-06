/datum/preference/choiced/prosthetic
	db_key = "quirk_prosthetic_limb_location"
	preference_type = PREFERENCE_CHARACTER
	should_update_preview = FALSE

/datum/preference/choiced/prosthetic/create_default_value()
	return "Random"

/datum/preference/choiced/prosthetic/init_possible_values()
	return list("Random") + GLOB.prosthetic_limb_choice

/datum/preference/choiced/prosthetic/deserialize(input, datum/preferences/preferences)
	switch(input)
		if("l_arm")
			return "Left Arm"
		if("r_arm")
			return "Right Arm"
		if("l_leg")
			return "Left Leg"
		if("r_leg")
			return "Right Leg"
	return sanitize_inlist(input, get_choices(), create_default_value())

/datum/preference/choiced/prosthetic/serialize(input)
	switch(input)
		if("Left Arm")
			return "l_arm"
		if("Right Arm")
			return "r_arm"
		if("Left Leg")
			return "l_leg"
		if("Right Leg")
			return "r_leg"
	return input

/datum/preference/choiced/prosthetic/is_accessible(datum/preferences/preferences, ignore_page)
	. = ..()
	if (!.)
		return FALSE

	return "Prosthetic Limb" in preferences.all_quirks

/datum/preference/choiced/prosthetic/apply_to_human(mob/living/carbon/human/target, value)
	return
