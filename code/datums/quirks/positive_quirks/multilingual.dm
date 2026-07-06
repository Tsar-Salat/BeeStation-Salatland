/datum/quirk/multilingual
	name = "Multilingual"
	desc = "You spent a portion of your life learning to understand an additional language. You may or may not be able to speak it based on your anatomy."
	icon = "comments"
	quirk_value = 1
	mob_trait = TRAIT_MULTILINGUAL
	gain_text = span_notice("You have learned to understand an additional language.")
	lose_text = span_danger("You have forgotten how to understand a language.")
	medical_record_text = "Patient knows more than one language."

/datum/quirk_constant_data/multilingual
	associated_typepath = /datum/quirk/multilingual
	customization_options = list(/datum/preference/choiced/language)

/datum/quirk/multilingual/add(client/client_source)
	var/wanted_language = read_choice_preference(/datum/preference/choiced/language)
	var/datum/language/language_type
	if(wanted_language == "Random")
		language_type = pick(GLOB.uncommon_roundstart_languages)
	else
		language_type = GLOB.language_types_by_name[wanted_language]
	if(quirk_target.has_language(language_type))
		language_type = /datum/language/uncommon
		if(quirk_target.has_language(language_type))
			to_chat(quirk_target, span_boldnotice("You are already familiar with the quirk in your preferences, so you did not learn one."))
			return
		to_chat(quirk_target, span_boldnotice("You are already familiar with the quirk in your preferences, so you learned Galactic Uncommon instead."))
	quirk_target.grant_language(language_type, source = LANGUAGE_QUIRK)

/datum/quirk/multilingual/remove()
	if(QDELING(quirk_target))
		return
	quirk_target.remove_all_languages(source = LANGUAGE_QUIRK)
