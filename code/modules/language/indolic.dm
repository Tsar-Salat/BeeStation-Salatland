// Indolic - the conservative dialect of Indol, humanity's oldest colony and the seat of its great
// universities and academies. It diverged early during Indol's long pioneer isolation and kept older,
// heavier forms - which made it the natural register of scholarship; the trained professions (research,
// medicine) carry it wherever they end up. This is the academic/credentialed "origin" tongue.
// TODO: icon_state is a placeholder ("unknown") - needs a unique sprite in icons/ui/chat/language.dmi
/datum/language/indolic
	name = "Indolic"
	desc = "The old, formal tongue of Indol - humanity's first off-world colony, and the seat of its great universities and academies. Conservative and weighty, it never bent back toward the modern standard; instead it endured as the language of scholarship, and the trained professions carry an Indolic turn of phrase wherever they practice."
	key = "3"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 60 // oldest-colony dialect; a sizeable speaker base
	space_chance = 15
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 2
	syllables = list(
		"in", "dol", "korv", "stadt", "grun", "vel", "tor", "berg", "hald", "mund",
		"ost", "vint", "kald", "fern", "old", "skol", "drav", "holm", "byg", "rast",
		"un", "der", "thal", "gard", "mor", "sten", "lund", "fjel", "vok"
	)
	icon_state = "unknown"
	default_priority = 80
	always_use_default_namelist = TRUE // human dialect, uses human names

	mutual_understanding = list(
		/datum/language/common = 70,       // broadcast inbound: the academy still follows Solbind
		/datum/language/aurin = 20,        // distant register (academy vs frontier floor)
		/datum/language/dredge = 20,       // distant register (academy vs mine)
		/datum/language/driftspeak = 25,   // catches the regular spacer pidgin
		/datum/language/uncommon = 10,     // foreign heritage
	)
