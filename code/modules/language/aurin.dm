// Aurin - the working-class Auri frontier dialect of Solbind: the same language plus a thick layer of
// dock/station jargon (a lexical drift, not a structural one), so it stays ~85% mutual with Solbind. It
// is also the shared work-floor tongue where human and Vraksa crews meet - not because it is kin to any
// lizard tongue, but because the Vraksa learn it as a second language and speak it with a hiss.
// TODO: icon_state is a placeholder ("unknown") - needs a unique sprite in icons/ui/chat/language.dmi
/datum/language/aurin
	name = "Aurin"
	desc = "The working dialect of the Auri docks and work-floors - Solbind plus a thick layer of station and dock jargon, clipped and quick. It is the common ground where human and lizard crews actually talk: the Vraksa learn it as a second tongue and speak it with a hiss, so a Solbind speaker still follows the gist."
	key = "2"
	flags = TONGUELESS_SPEECH
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 90 // the local frontier dialect; the most prevalent learnable human tongue
	space_chance = 30
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	syllables = list(
		"sol", "dock", "vac", "tar", "grid", "loq", "sib", "ken", "vor", "tik",
		"clip", "re", "no", "ya", "sa", "to", "rin", "aur", "rim", "hab",
		"cyc", "fab", "lo", "ka", "mi", "se", "ta", "vo", "ne", "ro",
		// the Vraksa accent in Aurin: hisses and clipped sounds the work-floor picked up
		"ss", "sss", "hss", "ksss", "zka", "ssa", "isk", "zz", "rrk", "ssk"
	)
	icon_state = "unknown"
	default_priority = 90
	always_use_default_namelist = TRUE // human dialect, uses human names

	mutual_understanding = list(
		/datum/language/common = 85,       // dialect -> its parent standard
		/datum/language/dredge = 40,       // adjacent register (same frontier-labour stratum)
		/datum/language/driftspeak = 30,   // toward the spacer pidgin
		/datum/language/indolic = 20,      // distant register (frontier floor vs academy)
		// No Draconic: the lizard kin tongue is an isolated island; the Vraksa just learn Aurin as an L2.
	)
