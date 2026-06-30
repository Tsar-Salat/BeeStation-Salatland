/datum/language/draconic
	name = "Draconic"
	desc = "The living in-group tongue of the colony Vraksa - spoken kin-to-kin and across the work-floor, warm and quick and thick with clan-feeling. It is not a tongue for outsiders: lizards keep it among their own and switch to worker's Aurin when dealing with anyone else. A mostly-vocal descendant of the old Cinis speech, lighter and more expressive than the holdouts' Vraksh."
	key = "o"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_LIZARD
	chargen_priority = 90 // the colony Vraksa's everyday in-group tongue; the most spoken non-human language
	speech_req = LANGUAGE_SPEECH_SOFT // a lizard tongue forms it cleanly; others slur the vocal half (the gestural half is gated separately by gestural_reliance)
	chargen_speech_note = "a lizard's tongue"
	space_chance = 12
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 3
	syllables = list(
		"za", "az", "ze", "ez", "zi", "iz", "zo", "oz", "zu", "uz", "zs", "sz",
		"ha", "ah", "he", "eh", "hi", "ih", "ho", "oh", "hu", "uh", "hs", "sh",
		"la", "al", "le", "el", "li", "il", "lo", "ol", "lu", "ul", "ls", "sl",
		"ka", "ak", "ke", "ek", "ki", "ik", "ko", "ok", "ku", "uk", "ks", "sk",
		"sa", "as", "se", "es", "si", "is", "so", "os", "su", "us", "ss", "ss",
		"ra", "ar", "re", "er", "ri", "ir", "ro", "or", "ru", "ur", "rs", "sr",
		"a",  "a",  "e",  "e",  "i",  "i",  "o",  "o",  "u",  "u",  "s",  "s"
	)
	special_characters = list("-")
	icon_state = "lizard"
	default_priority = 90
	default_name_syllable_min = 3
	default_name_syllable_max = 5
	random_name_spacer = "-"
	// The colony tongue shed most of the gestures, so it's mostly vocal - it only "sort of" degrades
	// over comms / when you can't see the speaker.
	gestural_reliance = 25

	// A distinct lizard-family tongue, sister to the holdouts' Vraksh - it understands no human language
	// (the Vraksa reach the crew through Aurin, learned as a separate L2), only its own kin tongue.
	mutual_understanding = list(
		/datum/language/ashic = 45, // lizard kin (the Draconic/Vraksh diglossia pair)
	)

/datum/language/draconic/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(force_use_syllables)
		return ..()
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)

	if(gender == MALE)
		return "[pick(GLOB.lizard_names_male)][random_name_spacer][pick(GLOB.lizard_names_male)]"
	return "[pick(GLOB.lizard_names_female)][random_name_spacer][pick(GLOB.lizard_names_female)]"
