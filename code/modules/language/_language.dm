/// Last 50 spoken (uncommon) words will be cached before we start cycling them out (re-randomizing them)
#define SCRAMBLE_CACHE_LEN 50
/// Last 20 spoken sentences will be cached before we start cycling them out (re-randomizing them)
#define SENTENCE_CACHE_LEN 20

/// Datum based languages. Easily editable and modular.
/datum/language
	abstract_type = /datum/language

	/// Fluff name of language if any.
	var/name = "an unknown language"
	/// Short description for 'Check Languages'.
	var/desc = "A language."
	/// Character used to speak in language
	/// If key is null, then the language isn't real or learnable.
	var/key
	/// Various language flags.
	var/flags = NONE
	/// Used when scrambling text for a non-speaker.
	var/list/syllables
	/// List of characters that will randomly be inserted between syllables.
	var/list/special_characters

	// These modify how syllables are combined.
	/// Likelihood of making a new sentence after each syllable.
	var/sentence_chance = 2
	/// Likelihood of making a new sentence after each word.
	var/between_word_sentence_chance = 0
	/// Likelihood of adding a space between syllables.
	var/space_chance = 20
	/// Likelyhood of adding a space between words.
	var/between_word_space_chance = 100
	/// Scramble word interprets the word as this much longer than it really is (low end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_low = -1
	/// Scramble word interprets the word as this much longer than it really is (high end)
	/// You can set this to an arbitarily large negative number to make all words only one syllable.
	var/additional_syllable_high = 3

	/// Spans to apply from this language
	var/list/spans
	/**
	 * Cache of recently scrambled text
	 * This allows commonly reused words to not require a full re-scramble every time.
	 * Is limited to the last SCRAMBLE_CACHE_LEN words spoken. After surpassing this limit,
	 * the oldest word will be removed from the cache and rescrambled if spoken again.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/scramble_cache = list()
	/**
	 * Scramble cache, but for the 1000 most common words in the English language.
	 * These are never rescrambled, so they will consistently be the same thing.
	 *
	 * Case insensitive, punctuation insensitive.
	 */
	VAR_PRIVATE/list/most_common_cache = list()
	/**
	 * Cache of recently spoken sentences
	 * So if one person speaks over the radio, everyone hears the same thing.
	 *
	 * This is an assoc list [sentence] = [key, scrambled_text]
	 * Where key is a string that is used to determine context about the listener (like what languages they know)
	 *
	 * Case sensitive, punctuation sensitive.
	 */
	VAR_PRIVATE/list/last_sentence_cache = list()

	/// The language that an atom knows with the highest "default_priority" is selected by default.
	var/default_priority = 0
	/// Family header this language is offered under in the chargen "learn a language" picker.
	/// A null category means it is never offered there (debug/internal languages like metalanguage).
	var/chargen_category = LANGUAGE_CATEGORY_OTHER
	/// Ordering within the chargen family: higher = more prevalent = nearer the top of the list.
	var/chargen_priority = 0

	/// Speech-gate axis: who can physically produce this language. See LANGUAGE_SPEECH_*.
	var/speech_req = LANGUAGE_SPEECH_OPEN
	/// Comprehension a SOFT language is produced at (0-100) when the speaker lacks the matching anatomy.
	var/soft_speech_quality = 40
	/// Comprehension-gate axis: who may understand this language. See LANGUAGE_COMPREHEND_*.
	var/comprehend_req = LANGUAGE_COMPREHEND_OPEN
	/// Chargen picker: the anatomy a SOFT/HARD language needs, as a bare noun phrase ("a slime tongue").
	/// The full limiter sentence is assembled centrally - keep this a noun phrase, not a sentence.
	var/chargen_speech_note
	/// Chargen picker: who a comprehension-gated language is limited to, as a bare noun phrase
	/// ("the blind", "monkeys"). The full sentence is assembled centrally.
	var/chargen_comprehend_audience
	/// Chargen picker: Font Awesome icon for the comprehension-restriction badge.
	var/chargen_comprehend_icon = "circle-info"

	/// If TRUE, when generating names, we will always use the default human namelist, even if we have syllables set.
	/// This is to be used for languages with very outlandish syllable lists (like pirates).
	var/always_use_default_namelist = FALSE
	/// Icon displayed in the chat window when speaking this language.
	/// if you are seeing someone speak popcorn language, then something is wrong.
	var/icon = 'icons/ui/chat/language.dmi'
	/// Icon state displayed in the chat window when speaking this language.
	var/icon_state = "unknown"

	/// By default, random names picks this many names
	var/default_name_count = 2
	/// By default, random names picks this many syllables (min)
	var/default_name_syllable_min = 2
	/// By default, random names picks this many syllables (max)
	var/default_name_syllable_max = 4
	/// What char to place in between randomly generated names
	var/random_name_spacer = " "

	// get_icon() proc will return a complete string rather than calling a proc every time.
	var/fast_icon_span

	/**
	 * Assoc Lazylist of other language types that would have a degree of mutual understanding with this language.
	 * For example, you could do `list(/datum/language/common = 50)` to say that this language has a 50% chance to understand common words
	 * And yeah if you give a 100% chance, they can basically just understand the language.
	 * Not sure why you would do that though.
	 */
	var/list/mutual_understanding

	/**
	 * How much of this language is carried by gesture/posture rather than the voice (0-100).
	 * 0 = a normal spoken language (heard fine, works over comms).
	 * The voice carries (100 - gestural_reliance)% of the meaning; the rest needs line of sight.
	 * So a high-reliance tongue is badly degraded over radio (no visual channel) and to anyone who
	 * can't see the speaker (blind / x-ray hearing). See /mob/living/proc/gesture_comprehension_cap.
	 */
	var/gestural_reliance = 0

	/// The say verb shown to a listener who receives this language by sight rather than by ear
	/// (deaf, or out of earshot e.g. across a vacuum) - reads 'gestures, "..."' instead of the
	/// speaker's spoken say_mod ('hisses, "..."'). Only used for languages with gestural_reliance > 0.
	var/visual_say_mod = "gestures"

	/// Whether this language has a written form (can be hand-written on paper, chosen in the paper
	/// writing-language selector). FALSE for gesture/tonal/psychic/innate tongues that can't be put to
	/// paper - e.g. Vraksh (half-posture), Machine/EAL (tonal), Sonus (psychic), Monkey, Noise.
	var/has_written_form = TRUE

// Primarily for debugging, allows for easy iteration and testing of languages.
/datum/language/vv_edit_var(var_name, var_value)
	. = ..()
	var/list/delete_cache = list(
		NAMEOF(src, additional_syllable_high),
		NAMEOF(src, additional_syllable_low),
		NAMEOF(src, between_word_sentence_chance),
		NAMEOF(src, between_word_space_chance),
		NAMEOF(src, sentence_chance),
		NAMEOF(src, space_chance),
		NAMEOF(src, special_characters),
		NAMEOF(src, syllables),
	)
	if(var_name in delete_cache)
		scramble_cache.Cut()
		most_common_cache.Cut()
		last_sentence_cache.Cut()

// --- Two-axis gates (speech / comprehension). Defaults are permissive; override per language. ---

/// 0-100 quality this speaker produces the language at. 0 means they physically cannot speak it
/// (HARD gate without the matching anatomy); <100 means degraded (SOFT gate without it).
/datum/language/proc/production_quality(mob/living/speaker)
	switch(speech_req)
		if(LANGUAGE_SPEECH_SOFT)
			return has_speech_anatomy(speaker) ? 100 : soft_speech_quality
		if(LANGUAGE_SPEECH_HARD)
			return has_speech_anatomy(speaker) ? 100 : 0
	return 100

/// Whether this speaker has the anatomy to produce the language cleanly. Default rule: the language
/// is native to the speaker's tongue (slime tongue -> Slimic, lizard tongue -> Draconic, etc.).
/// Override for non-tongue requirements (wings, a synthetic body...). Only consulted for SOFT/HARD.
/datum/language/proc/has_speech_anatomy(mob/living/speaker)
	var/mob/living/carbon/carbon_speaker = speaker
	if(!istype(carbon_speaker))
		return TRUE // non-carbons (silicons, simple mobs) aren't tongue-gated here
	var/obj/item/organ/tongue/tongue = carbon_speaker.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		return FALSE // no tongue -> no specialised anatomy
	return (type in tongue.languages_native)

/// Whether this listener may comprehend the language at all, on top of actually knowing it.
/// Resolves the comprehension axis against meets_comprehension_condition().
/datum/language/proc/listener_can_comprehend(mob/living/listener)
	switch(comprehend_req)
		if(LANGUAGE_COMPREHEND_REQUIRE)
			return meets_comprehension_condition(listener)
		if(LANGUAGE_COMPREHEND_FORBID)
			return !meets_comprehension_condition(listener)
	return TRUE

/// The REQUIRE/FORBID condition tested against a listener (blindness for Sonus, sentience for Monkey...).
/// Only consulted for non-OPEN comprehension languages. Default: FALSE (no one meets an unspecified condition).
/datum/language/proc/meets_comprehension_condition(mob/living/listener)
	return FALSE

/// Returns TRUE/FALSE based on seeing a language icon is validated to a given hearer in the parameter.
/datum/language/proc/display_icon(atom/movable/hearer)
	// ghosts want to know how it is going.
	if((flags & LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS) && \
			(isobserver(hearer) || (HAS_TRAIT(hearer, TRAIT_METALANGUAGE_KEY_ALLOWED) && istype(src, /datum/language/metalanguage))))
		return TRUE

	var/understands = hearer.has_language(src.type)
	if(understands)
		// It's something common so that you don't have to see a language icon
		// or, it's not a valid language that should show a language icon
		if((flags & LANGUAGE_HIDE_ICON_IF_UNDERSTOOD) || (flags & LANGUAGE_HIDE_ICON_TO_YOURSELF))
			return FALSE

	else
		// Standard to Galatic Common
		if(flags & LANGUAGE_ALWAYS_SHOW_ICON_IF_NOT_UNDERSTOOD)
			return TRUE

		// You'll typically end here - not being able to see a language icon
		if(!HAS_TRAIT(hearer, TRAIT_LINGUIST))
			return FALSE
		else if(flags & LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY) // don't merge with the if above. it's different check.
			return FALSE

	// If you reach here, you'd be a linguist quirk holder, and will be eligible to see a lang icon
	return TRUE

/datum/language/proc/get_icon()
	if(!fast_icon_span)
		var/datum/asset/spritesheet_batched/sheet = get_asset_datum(/datum/asset/spritesheet_batched/chat)
		fast_icon_span = sheet.icon_tag("language-[icon_state]")
	return fast_icon_span

/// Simple helper for getting a default firstname lastname
/datum/language/proc/default_name(gender = NEUTER)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(gender == FEMALE)
		return capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
	return capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

/**
 * Generates a random name this language would use.
 *
 * * gender: What gender to generate from, if neuter / plural coin flips between male and female
 * * name_count: How many names to generate in, by default 2, for firstname lastname
 * * syllable_count: How many syllables to generate in each name, min
 * * syllable_max: How many syllables to generate in each name, max
 * * force_use_syllables: If the name should be generated from the syllables list.
 * Only used for subtypes which implement custom name lists. Also requires the language has syllables set.
 */
/datum/language/proc/get_random_name(
	gender = NEUTER,
	name_count = default_name_count,
	syllable_min = default_name_syllable_min,
	syllable_max = default_name_syllable_max,
	force_use_syllables = FALSE,
)
	if(gender != MALE && gender != FEMALE)
		gender = pick(MALE, FEMALE)
	if(!length(syllables) || always_use_default_namelist)
		return default_name(gender)

	var/list/full_name = list()
	for(var/i in 1 to name_count)
		var/new_name = ""
		for(var/j in 1 to rand(default_name_syllable_min, default_name_syllable_max))
			new_name += pick_weight_recursive(syllables)
		full_name += capitalize(LOWER_TEXT(new_name))

	return jointext(full_name, random_name_spacer)

/// Generates a random name, and attempts to ensure it is unique (IE, no other mob in the world has it)
/datum/language/proc/get_random_unique_name(...)
	var/result = get_random_name(arglist(args))
	for(var/i in 1 to 10)
		if(!findname(result))
			break
		result = get_random_name(arglist(args))

	return result

// Checks the word cache for a word
/datum/language/proc/read_word_cache(input)
	SHOULD_NOT_OVERRIDE(TRUE)
	// we generally want "The" and "the" to translate to the same thing.
	// so we lowercase everything, making it case insensitive.
	var/lowertext_input = LOWER_TEXT(input)
	if(most_common_cache[lowertext_input])
		return most_common_cache[lowertext_input]

	. = scramble_cache[lowertext_input]
	if(. && scramble_cache[1] != lowertext_input)
		// bumps it to the top of the cache
		scramble_cache -= lowertext_input
		scramble_cache[lowertext_input] = .
	return .

/// Adds a word to the cache
/datum/language/proc/write_word_cache(input, scrambled_text)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/lowertext_input = LOWER_TEXT(input)
	// The most common words are always cached
	if(GLOB.most_common_words_frequency[lowertext_input])
		most_common_cache[lowertext_input] = scrambled_text
		return
	// Add it to cache, cutting old entries if the list is too long
	scramble_cache[lowertext_input] = scrambled_text
	if(length(scramble_cache) > SCRAMBLE_CACHE_LEN)
		scramble_cache.Cut(1, scramble_cache.len - SCRAMBLE_CACHE_LEN + 1)

/// Checks the sentence cache for a sentence
/datum/language/proc/read_sentence_cache(input)
	SHOULD_NOT_OVERRIDE(TRUE)
	// the only handling we do is capitalizing the first word, as say auto-capitalizes the first word anyway
	// the actual structure of the sentence is otherwise case sensitive so it's preserved
	var/input_capitalized = capitalize(input)
	. = last_sentence_cache[input_capitalized]
	if(. && last_sentence_cache[1] != input_capitalized)
		// bumps it to the top of the cache (don't anticipate this happening often)
		last_sentence_cache -= input_capitalized
		last_sentence_cache[input_capitalized] = .
	return .

/// Adds a sentence to the cache, though the sentence should be modified with a key
/datum/language/proc/write_sentence_cache(input, key, result_scramble)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/input_capitalized = capitalize(input)
	// Add to the cache (the cache being an assoc list of assoc lists), cutting old entries if the list is too long
	LAZYSET(last_sentence_cache[input_capitalized], key, result_scramble)
	if(length(last_sentence_cache) > SENTENCE_CACHE_LEN)
		last_sentence_cache.Cut(1, last_sentence_cache.len - SENTENCE_CACHE_LEN + 1)

/**
 * Scramble a paragraph in this language.
 *
 * Takes into account any languages the hearer knows that has mutual understanding with this language.
 */
/datum/language/proc/scramble_paragraph(input, list/mutual_languages)
	// perfect understanding, no need to scramble
	if(mutual_languages?[type] >= 100)
		return input

	var/static/regex/first_sentence = regex(@"(.+?(?:[\.!\?]|$))", "g")
	var/list/new_paragraph = list()
	while(first_sentence.Find(input))
		new_paragraph += scramble_sentence(trim(first_sentence.group[1]), mutual_languages)
	return jointext(new_paragraph, " ")

/**
 * Scrambles a sentence in this language.
 *
 * Takes into account any languages the hearer knows that has mutual understanding with this language.
 */
/datum/language/proc/scramble_sentence(input, list/mutual_languages)
	var/cache_key = "[mutual_languages?[type] || 0]-understanding"
	var/list/cache = read_sentence_cache(input)
	if(cache?[cache_key])
		return cache[cache_key]

	// List of words that will be recombined into a sentence
	var/list/scrambled_words = list()
	// List which indexes correspond to words in scrambled_words, records whether the word was translated
	// Can't be a single assoc list because duplicates are expected
	var/list/translated_index = list()
	var/understanding = mutual_languages?[type] || 0
	for(var/word in splittext(input, " "))
		var/base_word = strip_outer_punctuation(word)
		var/lower_word = LOWER_TEXT(base_word)
		var/translate_prob = understanding
		if(understanding > 0 && GLOB.language_survival_words[lower_word])
			// CEFR "A1 survival" floor: anyone with a foothold in the language always catches
			// these (yes/no/run/danger/medbay/...) - "I get the panic, not the plan".
			translate_prob = 100
		else if(understanding < LANGUAGE_TACTICAL_UNDERSTANDING_THRESHOLD && GLOB.language_tactical_words[lower_word])
			// CEFR no-leak ceiling: plot/antag words (kill/bomb/traitor/...) don't come through
			// to a partial listener, so the floor/frequency roll can't out an antag for free.
			translate_prob = 0
		else if(translate_prob > 0)
			// the probability of managing to understand a word is based on how common it is (+10%, -15%)
			// 1000 words in the list, so words outside the list are just treated as "the 1250th most common word"
			var/commonness = GLOB.most_common_words_frequency[lower_word] || 1250
			translate_prob += (10 * (1 - (min(commonness, 1250) / 500)))

		if(translate_prob > 0 && prob(translate_prob))
			scrambled_words += word
			translated_index += FALSE
			continue

		var/scrambled_word = scramble_word(base_word)
		scrambled_words += scrambled_word
		translated_index += (scrambled_word != base_word)

	// start building the new sentence. first word is capitalized and otherwise untouched
	var/sentence = capitalize(scrambled_words[1])
	for(var/i in 2 to length(scrambled_words))
		var/word = scrambled_words[i]
		// this was not translated so just throw it in
		if(!translated_index[i])
			sentence += " [word]"
			continue
		// if the last word was scrambled, always include a space
		if(translated_index[i - 1] || prob(between_word_space_chance))
			sentence += " "
		// lastly try inserting a new sentence
		else if(prob(between_word_sentence_chance))
			sentence += ". "
			word = capitalize(word)

		sentence += word

	// scrambling the word will drop punctuation, so we need to re-add it at the end
	// (however we don't need to do anything if the last word was not translated)
	if(translated_index[length(scrambled_words)])
		sentence += find_last_punctuation(input)

	write_sentence_cache(input, cache_key, sentence)

	return sentence

/**
 * Scrambles a single word in this language.
 */
/datum/language/proc/scramble_word(input)
	// If the input is cached already, move it to the end of the cache and return it
	var/word = read_word_cache(input)
	if(word)
		return (is_uppercase(input) && length_char(input) >= 2) ? uppertext(word) : word

	if(!length(syllables))
		word = stars(input)

	else
		var/input_size = max(length_char(input) + rand(additional_syllable_low, additional_syllable_high), 1)
		var/add_space = FALSE
		var/add_period = FALSE
		word = ""
		while(length_char(word) < input_size)
			// add in the last syllable's period or space first
			if(add_period)
				word += ". "
			else if(add_space)
				word += " "
			// insert special chars if we're not at the start of the word
			else if(word && prob(1) && length(special_characters))
				word += pick(special_characters)
			// generate the next syllable (capitalize if we just added a period)
			var/next = pick_weight_recursive(syllables)
			word += add_period ? capitalize(next) : next
			// determine if the next syllable gets a period or space
			add_period = prob(sentence_chance)
			add_space = prob(space_chance)

	write_word_cache(input, word)

	// If they're shouting, we're shouting
	return (is_uppercase(input) && length_char(input) >= 2) ? uppertext(word) : word

#undef SCRAMBLE_CACHE_LEN
