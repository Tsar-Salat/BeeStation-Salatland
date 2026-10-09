/datum/preference_middleware/qualifications
	action_delegations = list(
		"give_qualification" = PROC_REF(give_qualification),
		"remove_qualification" = PROC_REF(remove_qualification),
		"move_qualification" = PROC_REF(move_qualification),
	)

/datum/preference_middleware/qualifications/get_ui_data(mob/user)
	return list(
		"career" = preferences.get_career(),
	)

/datum/preference_middleware/qualifications/get_constant_data()
	var/list/qualifications = list()
	for(var/id in GLOB.qualifications)
		var/datum/qualification/qualification = GLOB.qualifications[id]
		qualifications += list(list(
			"id" = id,
			"name" = qualification.name,
			"description" = qualification.desc,
			"training" = qualification.training,
			"practitioner" = qualification.practitioner,
			"training_years" = qualification.training_years,
			"department" = qualification.department,
		))
	return list(
		"qualifications" = qualifications,
		"max_qualifications" = MAX_QUALIFICATIONS,
		"career_start_age" = AGE_MIN,
		"max_age" = AGE_MAX,
	)

/datum/preference_middleware/qualifications/proc/give_qualification(list/params, mob/user)
	var/datum/qualification/qualification = GLOB.qualifications[params["qualification"]]
	if(!qualification || (qualification.id in preferences.qualifications))
		return FALSE
	if(length(preferences.qualifications) >= MAX_QUALIFICATIONS)
		return FALSE
	var/list/career = preferences.get_career()
	var/starts = length(career) ? career[length(career)]["earned"] : AGE_MIN
	if(starts + qualification.training_years > preferences.read_character_preference(/datum/preference/numeric/age))
		return FALSE
	preferences.qualifications += qualification.id
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/qualifications/proc/move_qualification(list/params, mob/user)
	var/id = params["qualification"]
	var/position = params["position"]
	if(!(id in preferences.qualifications) || !isnum(position))
		return FALSE
	preferences.qualifications -= id
	preferences.qualifications.Insert(clamp(round(position), 1, length(preferences.qualifications) + 1), id)
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/qualifications/proc/remove_qualification(list/params, mob/user)
	var/id = params["qualification"]
	if(!(id in preferences.qualifications))
		return FALSE
	preferences.qualifications -= id
	preferences.mark_undatumized_dirty_character()
	return TRUE
