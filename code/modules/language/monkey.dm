/datum/language/monkey
	name = "Chimpanzee"
	desc = "Ook ook ook."
	key = "1"
	space_chance = 0
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0
	space_chance = 100
	syllables = list("oop", "aak", "chee", "eek")
	default_priority = 80
	// Speech stays OPEN so a transformed crewmate can still speak it; only monkeys can understand it.
	comprehend_req = LANGUAGE_COMPREHEND_REQUIRE
	chargen_comprehend_audience = "monkeys"
	chargen_comprehend_icon = "paw"
	has_written_form = FALSE // ook ook ook - no written form

	icon_state = "animal"

/// Monkey chatter is private to monkeys - sentient species can't parse it even if they "know" it.
/datum/language/monkey/meets_comprehension_condition(mob/living/listener)
	return ismonkey(listener)

/datum/language/monkey/get_random_name(
	gender = NEUTER,
	name_count = 2,
	syllable_min = 2,
	syllable_max = 4,
	force_use_syllables = FALSE,
)
	return "monkey ([rand(1, 999)])"
