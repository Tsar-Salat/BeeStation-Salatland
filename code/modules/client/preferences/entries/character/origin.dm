/// Character origin / heritage. A persistent background pick that sets the character's primary spoken
/// language (see GLOB.language_origin_languages). AUTO defers to the assigned role's origin_language.
/// Applied centrally in /datum/job/proc/grant_origin_language (it needs the job for the AUTO fallback),
/// so apply_to_human is intentionally a no-op here.
/datum/preference/choiced/origin
	db_key = "origin"
	preference_type = PREFERENCE_CHARACTER
	can_randomize = FALSE

/datum/preference/choiced/origin/create_default_value()
	return LANGUAGE_ORIGIN_AUTO

/datum/preference/choiced/origin/init_possible_values()
	return GLOB.language_origin_choices.Copy()

/datum/preference/choiced/origin/apply_to_human(mob/living/carbon/human/target, value)
	return

/// Per-character flag: has the player reviewed/acknowledged this character's language loadout? Set when
/// they click through the readyup / latejoin warning. Defaults FALSE so a player who never opened the
/// Languages tab is warned once per character - this is awareness, not a hard block (they may proceed).
/// See /mob/dead/new_player/proc/languages_reviewed_or_warn.
/datum/preference/toggle/languages_confirmed
	db_key = "languages_confirmed"
	preference_type = PREFERENCE_CHARACTER
	default_value = FALSE
	can_randomize = FALSE
