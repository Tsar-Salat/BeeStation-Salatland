/datum/language/uncommon
	name = "Sertan"
	desc = "A naturally-evolved Old-Earth tongue that outlasted Solbind's standardisation on Tellune, and is still widely spoken across the homeworld."
	key = "!"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 50 // Old-Earth heritage; common on Tellune, rarer on the frontier station
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"ba", "be", "bo", "ca", "ce", "co", "da", "de", "do",
		"fa", "fe", "fo", "ga", "ge", "go", "ha", "he", "ho",
		"ja", "je", "jo", "ka", "ke", "ko", "la", "le", "lo",
		"ma", "me", "mo", "na", "ne", "no", "ra", "re", "ro",
		"sa", "se", "so", "ta", "te", "to", "va", "ve", "vo",
		"xa", "xe", "xo", "ya", "ye", "yo", "za", "ze", "zo"
	)
	icon_state = "galuncom"
	default_priority = 90

	mutual_understanding = list(
		/datum/language/common = 60,       // broadcast inbound: even heritage speakers follow Solbind broadcasts
		/datum/language/aurin = 15,        // foreign heritage: structural overlap only, no broadcast bonus (hence far below the Solbind 60, even though Aurin is ~85% Solbind)
		/datum/language/driftspeak = 25,   // catches the deliberately-regular spacer pidgin
		/datum/language/dredge = 20,       // foreign-heritage breadth
		/datum/language/indolic = 10,      // foreign heritage
	)
