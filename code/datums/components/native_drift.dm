/**
 * Native drift component.
 *
 * Re-homes the behaviour of the old "Common Second Language" quirk so it can apply to any character
 * whose *standard* tongue is a partially-understood second language (set in the chargen language
 * loadout). The standard tongue is whichever species-granted language the player downgraded - Aurin
 * for humans, but generalised so it isn't tied to one language:
 * - keeps the standard tongue partial across species changes (the new species holder would re-grant it
 *   in full)
 * - when rattled (low sanity) the speaker drifts back into their native tongue
 *
 * Attached at spawn by /datum/preferences/proc/apply_character_languages.
 */
/datum/component/native_drift
	/// Typepath of the language we drift toward under stress.
	var/native_language
	/// Typepath of the species' standard tongue that the character only partially understands.
	var/datum/language/standard_language = /datum/language/common
	/// How well the standard tongue is understood (the partial percentage to keep re-applying).
	var/standard_strength = 25

/datum/component/native_drift/Initialize(native_language, standard_strength = 25, standard_language = /datum/language/common)
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	src.standard_language = standard_language
	src.standard_strength = standard_strength
	src.native_language = native_language || get_native_language()

/datum/component/native_drift/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_SAY, PROC_REF(translate_parts))
	RegisterSignal(parent, COMSIG_SPECIES_GAIN, PROC_REF(reremove_standard))

/datum/component/native_drift/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_SAY, COMSIG_SPECIES_GAIN))

	var/mob/living/carbon/carbon_parent = parent
	if(QDELETED(carbon_parent))
		return
	carbon_parent.remove_partial_language(standard_language, LANGUAGE_MULTILINGUAL)
	// Give the standard tongue back in full if the (current) species is one that should speak it.
	if(istype(carbon_parent) && carbon_parent.dna?.species)
		var/datum/language_holder/species_holder = GLOB.prototype_language_holders[carbon_parent.dna.species.species_language_holder]
		if(LAZYACCESS(species_holder?.spoken_languages, standard_language))
			carbon_parent.grant_language(standard_language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	else
		carbon_parent.grant_language(standard_language, UNDERSTOOD_LANGUAGE, LANGUAGE_ATOM)

/// Gets our native language from our list of spoken languages, preferring the tongue's native ones.
/datum/component/native_drift/proc/get_native_language()
	var/mob/living/carbon/carbon_parent = parent
	var/list/language_pool = carbon_parent.get_language_holder()?.spoken_languages?.Copy()
	if(!length(language_pool))
		return // no languages to pick from at all?

	// We don't want to drift "into" the standard tongue - that's the whole point.
	language_pool -= standard_language

	var/list/prioritized_language_pool
	var/obj/item/organ/tongue/tongue = carbon_parent.get_organ_by_type(/obj/item/organ/tongue)
	if(length(tongue?.languages_native) > 0)
		prioritized_language_pool = language_pool & tongue.languages_native

	if(length(language_pool) < 1)
		return // guess we couldn't find one

	return length(prioritized_language_pool) > 0 ? prioritized_language_pool[1] : language_pool[1]

/// Every time we change species the new holder re-grants the standard tongue in full; strip it to partial.
/datum/component/native_drift/proc/reremove_standard(...)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_parent = parent
	carbon_parent.remove_language(standard_language, UNDERSTOOD_LANGUAGE, LANGUAGE_SPECIES)
	carbon_parent.grant_partial_language(standard_language, standard_strength, LANGUAGE_MULTILINGUAL)
	if(isnull(native_language) || !(native_language in carbon_parent.get_language_holder()?.spoken_languages))
		native_language = get_native_language()

/// At low sanity we slip everything we say back into our native language.
/datum/component/native_drift/proc/translate_parts(datum/source, list/say_args)
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_parent = parent
	var/datum/component/mood/mood = carbon_parent.GetComponent(/datum/component/mood)
	if(say_args[SPEECH_FORCED] || isnull(native_language) || mood?.sanity > 75)
		return
	// Never drift into a tongue we can't actually speak (e.g. a Basic / understand-only language the
	// player marked "native") - the forced language would just come out as gibberish.
	if(!(native_language in carbon_parent.get_language_holder()?.spoken_languages))
		return
	// init this list if nothing else has
	LAZYINITLIST(say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS])
	// force speak the native language, add mutual bonuses so everyone else can still understand
	say_args[SPEECH_LANGUAGE] = native_language
	say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS][native_language] = max(round(8 * sqrt(mood?.sanity), 5), say_args[SPEECH_MODS][LANGUAGE_MUTUAL_BONUS][native_language])
