//There's already a mushroom language, but this is cooler and I might kill that one
/datum/language/sonus
	name = "Sonus"
	desc = "An assembly of clicks and innaudible whistles, spoken by extrasensory beings."
	key = "f"
	speech_req = LANGUAGE_SPEECH_HARD // only a psyphoza's fungal tongue produces it
	comprehend_req = LANGUAGE_COMPREHEND_REQUIRE // its meaning rides senses other than hearing
	has_written_form = FALSE // clicks and inaudible whistles - no written form
	chargen_speech_note = "a psyphoza's tongue"
	chargen_comprehend_audience = "the blind"
	chargen_comprehend_icon = "eye-slash"
	space_chance = 20
	syllables = list(
		"sa", "sá", "se", "sé", "si", "sí", "so", "só", "sö", "su", "sú", "sy", "sý", //whistles
		"ta", "tá", "te", "té", "ti", "tí", "to", "tó", "tö", "tu", "tú", "ty", "tý" //clicks
	)
	icon_state = "sonus"
	default_priority = 90

/// Only the blind (the extrasensory) can parse Sonus - it carries on senses other than hearing.
/datum/language/sonus/meets_comprehension_condition(mob/living/listener)
	return ismob(listener) && listener.is_blind()
