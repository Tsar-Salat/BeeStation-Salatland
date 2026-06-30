// Dredge - a working cant from Ceti's old gas-rigs (Geminae core), carried to the Auri mines by migrant crews.
// Built off Solbind on the rigs and lower decks; broadly understood but class-marked.
// TODO: icon_state is a placeholder ("unknown") - needs a unique sprite in icons/ui/chat/language.dmi
/datum/language/dredge
	name = "Dredge"
	desc = "A rough working cant grown on the old gas-rigs of Ceti, in the Geminae core, and carried out to the Auri mines by migrant crews. Built off Solbind, so most can follow it - but speaking it marks you as a hand, not a suit."
	key = "5"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 70 // miners' cant; plenty of station hands carry it
	space_chance = 10
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = -1
	additional_syllable_high = 1
	syllables = list(
		"grok", "sk", "dreg", "ka", "tch", "ug", "rot", "sump", "gak", "kru",
		"scav", "nub", "oi", "grit", "muk", "haul", "slag", "rig", "pit", "drak",
		"vh", "bok", "crus", "hod", "guv", "nik", "rab"
	)
	icon_state = "unknown"
	default_priority = 20
	always_use_default_namelist = TRUE // human pidgin, uses human names

	mutual_understanding = list(
		/datum/language/common = 70,       // broadcast inbound
		/datum/language/aurin = 40,        // adjacent register (same frontier-labour stratum)
		/datum/language/uncommon = 25,     // pidgin breadth (Ceti drew labour from across Geminae)
		/datum/language/indolic = 25,      // pidgin breadth
		/datum/language/driftspeak = 35,   // sibling pidgin
	)
