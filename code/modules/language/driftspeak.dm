// Driftspeak - the spacer's fallback pidgin of Eclipse Express haulers and the
// transfer-lane crews who ride the 23-year windows. A deliberately tiny, regular
// vocabulary, learned as a last resort when no proper shared tongue exists.
// TODO: icon_state is a placeholder ("unknown") - needs a unique sprite in icons/ui/chat/language.dmi
/datum/language/driftspeak
	name = "Driftspeak"
	desc = "A bare-bones spacer pidgin used by long-haul freighter crews when there's no shared language and no autotranslator handy. Tiny and regular by design, it grants a little understanding to nearly anyone."
	key = "7"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 30 // niche spacer fallback; few speak it by choice
	space_chance = 25
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 90
	additional_syllable_low = -1
	additional_syllable_high = 0
	syllables = list(
		"ba", "de", "fo", "gi", "lu", "ma", "ne", "ro", "si", "ta",
		"vo", "ka", "mi", "se", "to", "na", "li", "do", "pe", "ru"
	)
	icon_state = "unknown"
	default_priority = 10
	always_use_default_namelist = TRUE // human pidgin, uses human names

	mutual_understanding = list(
		/datum/language/common = 55,       // pidgin bridges up to the broadcast standard
		/datum/language/aurin = 25,        // flat-bridge: a regular ~25 to every proper human tongue
		/datum/language/uncommon = 25,     // flat-bridge
		/datum/language/indolic = 25,      // flat-bridge
		/datum/language/dredge = 35,       // +10 to its sibling pidgin
	)
