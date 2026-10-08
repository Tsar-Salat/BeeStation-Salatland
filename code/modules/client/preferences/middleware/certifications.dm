/// Handles picking a character's certifications
/datum/preference_middleware/certifications
	action_delegations = list(
		"give_certification" = PROC_REF(give_certification),
		"remove_certification" = PROC_REF(remove_certification),
	)

/datum/preference_middleware/certifications/get_ui_data(mob/user)
	return list(
		"certifications" = preferences.certifications,
		"valid_certifications" = preferences.get_valid_certifications(),
		"certification_slots" = get_certification_slots(preferences.read_character_preference(/datum/preference/numeric/age)),
	)

/datum/preference_middleware/certifications/get_constant_data()
	var/list/certifications = list()
	for(var/id in GLOB.certifications)
		var/datum/certification/certification = GLOB.certifications[id]
		certifications += list(list(
			"id" = id,
			"name" = certification.name,
			"description" = certification.desc,
			"minimum_age" = certification.minimum_age,
		))
	return list(
		"certifications" = certifications,
		"second_slot_age" = CERTIFICATION_SECOND_SLOT_AGE,
		"third_slot_age" = CERTIFICATION_THIRD_SLOT_AGE,
	)

/datum/preference_middleware/certifications/proc/give_certification(list/params, mob/user)
	var/datum/certification/certification = GLOB.certifications[params["certification"]]
	if(!certification || (certification.id in preferences.certifications))
		return FALSE
	var/age = preferences.read_character_preference(/datum/preference/numeric/age)
	if(age < certification.minimum_age)
		return FALSE
	// Picks the character is too young for are dropped here, so they can't come back over the limit later
	var/list/held = preferences.get_valid_certifications()
	if(length(held) >= get_certification_slots(age))
		return FALSE
	preferences.certifications = held + certification.id
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/certifications/proc/remove_certification(list/params, mob/user)
	var/id = params["certification"]
	if(!(id in preferences.certifications))
		return FALSE
	preferences.certifications -= id
	preferences.mark_undatumized_dirty_character()
	return TRUE
