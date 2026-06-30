// Vraksh - the archaic, body-based hearth-tongue of the wary Vraksa clans (the "Ashwalkers") still holding Cinis (Lavaland).
// It preserves the old grammar and the gestural component of the original Cinis tongue: speaking it
// correctly takes lizard anatomy (frill, tail, posture) on top of the vocalizations, so it is
// anatomy-gated to lizard tongues in /obj/item/organ/tongue/lizard/get_possible_languages().
// "Vraksh" is the holdouts' own name for it (from vraksa, "ash-crosser"); the company files them as
// "Ashwalkers". The typepath stays /datum/language/ashic (the old file-name) to avoid a wide rename.
// TODO: icon_state is a placeholder ("unknown") - needs a unique sprite in icons/ui/chat/language.dmi
// TODO (engine): the gestural/line-of-sight component is only approximated by anatomy gating;
//   Bee has no NONVERBAL/SIGNLANG concept yet (see language_system_overview comparison).
/datum/language/ashic
	name = "Vraksh"
	desc = "The unbroken hearth-tongue of the holdout Vraksa - the 'Ashwalkers' who refused the colony and still hold the Cinis ashfields. They call it Vraksh: honorific-laden and half-gesture, every word carrying clan-standing in particle and posture at once, so it cannot be spoken without the body."
	key = "c"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_LIZARD
	chargen_priority = 20 // isolated holdouts' hearth-tongue; rarely heard on-station
	space_chance = 14
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 3
	syllables = list(
		"za", "az", "zha", "ezh", "skra", "ka", "ssa", "iss", "akh", "kha",
		"rh", "thar", "ash", "esh", "uzh", "kra", "tza", "vekh", "or", "ul",
		"ssur", "hak", "rusk", "kesh", "vra", "zhul", "skar", "hss"
	)
	special_characters = list("'", "-")
	icon_state = "unknown"
	default_priority = 60
	default_name_syllable_min = 3
	default_name_syllable_max = 5
	random_name_spacer = "-"
	// Half hiss, half posture: most of Vraksh rides on gesture/clan-stance. Barely survives over
	// comms (no visual channel) - which suits the isolated Ashwalkers, who don't use radios anyway.
	gestural_reliance = 70
	has_written_form = FALSE // half-posture hearth-tongue - never committed to paper

	mutual_understanding = list(
		/datum/language/draconic = 40, // lizard kin (the Vraksh/Draconic diglossia pair); understands no human tongue
	)
