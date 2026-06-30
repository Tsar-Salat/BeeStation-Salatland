/// Middleware for the intrinsic per-character language loadout.
/// Replaces the old "Bilingual" and "Common Second Language" quirks: every character can know a
/// few languages at a chosen fluency, on top of their species-required set. Stored as
/// preferences.alternate_languages (an undatumized list), applied at spawn by
/// /datum/preferences/proc/apply_character_languages.

/datum/preference_middleware/languages
	action_delegations = list(
		"add_language" = PROC_REF(add_language),
		"remove_language" = PROC_REF(remove_language),
		"set_fluency" = PROC_REF(set_fluency),
		"set_understand_only" = PROC_REF(set_understand_only),
		"set_native" = PROC_REF(set_native),
		"set_origin" = PROC_REF(set_origin),
	)

/// Global, player-independent: the selectable language pool + the chargen constants.
/datum/preference_middleware/languages/get_constant_data()
	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()

	var/list/pool = GLOB.uncommon_roundstart_languages.Copy()
	pool |= /datum/language/uncommon // Sertan is foreigner-only, but learnable here

	var/list/languages = list()
	for(var/datum/language/language_type as anything in pool)
		var/category = initial(language_type.chargen_category)
		if(isnull(category))
			continue // debug/internal language (e.g. metalanguage) - never offered
		languages["[language_type]"] = list(
			"path" = "[language_type]",
			"name" = initial(language_type.name),
			"desc" = initial(language_type.desc),
			"category" = category,
			"priority" = initial(language_type.chargen_priority),
		)

	return list(
		"languages" = languages,
		"max_languages" = MAX_KNOWN_LANGUAGES,
		"fluency_levels" = GLOB.language_fluency_levels,
		"category_order" = GLOB.language_chargen_category_order,
		"origins" = GLOB.language_origin_choices,
	)

/// Player-specific: the current loadout + the species-required set (so the panel can show
/// "(required)" rows and the remaining-slot count). Sent on every update - the data is tiny.
/datum/preference_middleware/languages/get_ui_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	return list(
		"alternate_languages" = preferences.alternate_languages,
		"required_languages" = get_required_languages(),
		"native_language" = effective_native(),
		"language_gates" = get_language_gates(),
		"origin" = preferences.read_character_preference(/datum/preference/choiced/origin),
		"origin_choices" = origins_for_species(preferences.read_character_preference(/datum/preference/choiced/species)),
		"origin_language" = get_origin_display(),
		"origin_fit" = get_origin_fit(),
	)

/// The language the character will *default to speaking* at spawn: an explicit origin pick wins,
/// otherwise the selected species' primary tongue. One source of truth, resolved the same way
/// grant_origin_language does at spawn. Returns a /datum/language typepath, or null.
/datum/preference_middleware/languages/proc/resolved_origin_language()
	var/chosen = preferences.read_character_preference(/datum/preference/choiced/origin)
	if(chosen && chosen != LANGUAGE_ORIGIN_AUTO)
		var/datum/language/explicit = GLOB.language_origin_languages[chosen]
		if(ispath(explicit, /datum/language))
			return explicit
	// AUTO: a tongue the player explicitly marked native in the loadout is their identity, else the
	// species primary. Mirrors grant_origin_language so chargen and spawn resolve the default the same way.
	var/datum/language/marked = character_marked_native_language(preferences)
	if(ispath(marked, /datum/language))
		return marked
	var/datum/species/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	if(ispath(species_type, /datum/species))
		return species_primary_language(initial(species_type.species_language_holder))
	return null

/// The heritage language the character defaults to speaking (free, not budget-counted), for display in
/// the origin section. Null if unresolved / silicon, or if it's already a species row (an AUTO character
/// defaults to their species primary, which is shown as a species row - the fit line carries the rest).
/datum/preference_middleware/languages/proc/get_origin_display()
	var/chosen = preferences.read_character_preference(/datum/preference/choiced/origin)
	var/from_background = (chosen && chosen != LANGUAGE_ORIGIN_AUTO)
	var/datum/language/origin = resolved_origin_language()
	if(!ispath(origin, /datum/language))
		return null
	if("[origin]" in required_paths()) // already shown as a species row - don't double-list
		return null
	return list(
		"path" = "[origin]",
		"name" = initial(origin.name),
		"desc" = initial(origin.desc),
		"from_background" = from_background,
		"source_label" = from_background ? chosen : "your species",
	)

/// Compares the character's spoken-default register against their highest-priority job's department
/// register, so chargen can show whether they'll sound native, passable, or foreign at work. Purely
/// informational - no mechanical effect (the friction is intrinsic to comprehension). Null for
/// silicon / no role / unresolved.
/datum/preference_middleware/languages/proc/get_origin_fit()
	var/datum/job/top_job = preferences.get_highest_priority_job()
	if(!istype(top_job) || (initial(top_job.departments) & DEPT_BITFLAG_SILICON))
		return null
	var/datum/language/dept = initial(top_job.origin_language)
	if(!ispath(dept, /datum/language))
		return null
	var/understanding = chargen_comprehension(dept, top_job)
	var/fit = "foreign"
	if(understanding >= LANGUAGE_FIT_NATIVE_THRESHOLD)
		fit = "native"
	else if(understanding >= LANGUAGE_FIT_PASSABLE_THRESHOLD)
		fit = "passable"
	return list(
		"fit" = fit,
		"understanding" = understanding,
		"dept_name" = initial(dept.name),
		"job_title" = top_job.title,
	)

/// Estimate (0-100) of how well this character will UNDERSTAND target_lang at spawn, across their full
/// chargen language set (species-required + resolved origin + learned tiers) plus the job-register
/// limp-through floor. Mutual intelligibility only cascades from fully-understood tongues (mirrors the
/// engine). A display estimate for the fit cue - not the authoritative runtime value.
/datum/preference_middleware/languages/proc/chargen_comprehension(datum/language/target_lang, datum/job/top_job)
	if(!ispath(target_lang, /datum/language))
		return 0
	// Tongues the character fully understands - these cascade their mutual intelligibility, and are a
	// direct 100 if they ARE the target.
	var/list/understood = list()
	for(var/list/req in get_required_languages())
		understood |= text2path(req["path"])
	var/datum/language/origin = resolved_origin_language()
	if(ispath(origin, /datum/language))
		understood |= origin
	for(var/list/entry in preferences.alternate_languages)
		if(islist(entry) && entry["fluency"] == LANGUAGE_FLUENCY_FLUENT)
			understood |= text2path(entry["language"])
	var/best = 0
	for(var/datum/language/known as anything in understood)
		if(!ispath(known, /datum/language))
			continue
		if(known == target_lang)
			return 100
		var/list/mu = initial(known.mutual_understanding)
		if(islist(mu) && mu[target_lang])
			best = max(best, mu[target_lang])
	// Direct partial knowledge of the target itself (a Working/Basic learned entry for it).
	for(var/list/entry in preferences.alternate_languages)
		if(!islist(entry) || text2path(entry["language"]) != target_lang)
			continue
		if(entry["fluency"] == LANGUAGE_FLUENCY_WORKING)
			best = max(best, LANGUAGE_FLUENCY_WORKING_AMOUNT)
		else if(entry["fluency"] == LANGUAGE_FLUENCY_BASIC)
			best = max(best, LANGUAGE_FLUENCY_BASIC_AMOUNT)
	// The assigned job grants a limp-through grasp of its OWN register (see grant_job_register).
	if(istype(top_job) && target_lang == initial(top_job.origin_language))
		best = max(best, LANGUAGE_JOB_REGISTER_PARTIAL)
	return best

/datum/preference_middleware/languages/proc/set_origin(list/params, mob/user)
	var/value = params["origin"]
	// Only accept an origin the current species is actually offered (so a human can't be set to a lizard
	// origin via a crafted action, and vice versa).
	if(!(value in origins_for_species(preferences.read_character_preference(/datum/preference/choiced/species))))
		return FALSE
	return preferences.update_preference(/datum/preference/choiced/origin, value, in_menu = TRUE)

/// Per-language speak/understand status for THIS character's body, as display-ready badges. Lets the
/// picker tell the player "you could learn this but couldn't speak it" on their currently-selected slot.
/datum/preference_middleware/languages/proc/get_language_gates()
	var/list/result = list()

	// The selected species' tongue is the character's anatomy: its languages_native is what it speaks.
	var/datum/species/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	var/tongue_path = ispath(species_type, /datum/species) ? initial(species_type.mutanttongue) : null
	if(!ispath(tongue_path, /obj/item/organ/tongue))
		tongue_path = /obj/item/organ/tongue
	var/obj/item/organ/tongue/species_tongue = tongue_path
	var/list/native = islist(initial(species_tongue.languages_native)) ? initial(species_tongue.languages_native) : list()

	// Describe every language the panel can show: the selectable pool + the species-required set.
	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()
	var/list/pool = GLOB.uncommon_roundstart_languages.Copy()
	pool |= /datum/language/uncommon
	for(var/list/req in get_required_languages())
		pool |= text2path(req["path"])
	var/list/origin_display = get_origin_display() // so the origin row gets a gate badge too
	if(origin_display)
		pool |= text2path(origin_display["path"])

	for(var/datum/language/lang as anything in pool)
		if(!ispath(lang, /datum/language))
			continue
		result["[lang]"] = describe_gate(lang, native)
	return result

/// Builds the speakability + badges for one language against the character's anatomy (native_langs).
/datum/preference_middleware/languages/proc/describe_gate(datum/language/lang, list/native_langs)
	var/has_anatomy = (lang in native_langs)
	var/list/badges = list()
	var/speakable = "fine"

	// Standardized tooltip phrasing: speech badges read "<effect> without <anatomy>", comprehension
	// badges read "Only <audience> can understand it." - only the noun phrase varies per language.
	var/anatomy = initial(lang.chargen_speech_note) || "the right anatomy"
	switch(initial(lang.speech_req))
		if(LANGUAGE_SPEECH_SOFT)
			if(!has_anatomy)
				speakable = "degraded"
				badges += list(list(
					"icon" = "comment-dots",
					"color" = "average",
					"tooltip" = "Spoken unclearly without [anatomy].",
				))
		if(LANGUAGE_SPEECH_HARD)
			if(!has_anatomy)
				speakable = "unspeakable"
				badges += list(list(
					"icon" = "comment-slash",
					"color" = "bad",
					"tooltip" = "Can't be spoken without [anatomy] - understood only.",
				))

	var/audience = initial(lang.chargen_comprehend_audience) || "certain listeners"
	switch(initial(lang.comprehend_req))
		if(LANGUAGE_COMPREHEND_REQUIRE)
			badges += list(list(
				"icon" = initial(lang.chargen_comprehend_icon) || "circle-info",
				"color" = "label",
				"tooltip" = "Only [audience] can understand it.",
			))
		if(LANGUAGE_COMPREHEND_FORBID)
			badges += list(list(
				"icon" = initial(lang.chargen_comprehend_icon) || "circle-info",
				"color" = "label",
				"tooltip" = "[audience] can't understand it.",
			))

	return list("speakable" = speakable, "badges" = badges)

/// The languages the selected species grants for free (shown as "(required)", count against the cap).
/datum/preference_middleware/languages/proc/get_required_languages()
	var/list/result = list()
	var/datum/species/species_type = preferences.read_character_preference(/datum/preference/choiced/species)
	if(!ispath(species_type, /datum/species))
		return result
	var/holder_path = initial(species_type.species_language_holder)
	var/datum/language_holder/holder = GLOB.prototype_language_holders[holder_path]
	if(!istype(holder))
		return result

	var/species_name = initial(species_type.name)
	var/list/seen = list()
	for(var/datum/language/lang as anything in holder.spoken_languages)
		if(lang == /datum/language/metalanguage || (lang in seen))
			continue
		seen += lang
		result += list(list("path" = "[lang]", "name" = initial(lang.name), "desc" = initial(lang.desc), "spoken" = TRUE, "source" = "species", "source_label" = species_name))
	for(var/datum/language/lang as anything in holder.understood_languages)
		if(lang == /datum/language/metalanguage || (lang in seen))
			continue
		seen += lang
		result += list(list("path" = "[lang]", "name" = initial(lang.name), "desc" = initial(lang.desc), "spoken" = FALSE, "source" = "species", "source_label" = species_name))
	return result

/// The language that is effectively the character's native tongue right now: a player-marked one if
/// any, else the species' first spoken required language. Authoritative so the panel needn't guess.
/datum/preference_middleware/languages/proc/effective_native()
	for(var/list/entry in preferences.alternate_languages)
		if(entry["native"])
			return entry["language"]
	for(var/list/req in get_required_languages())
		if(req["spoken"])
			return req["path"]
	return null

/// Typepath-text set of the species-required languages.
/datum/preference_middleware/languages/proc/required_paths()
	var/list/paths = list()
	for(var/list/req in get_required_languages())
		paths += req["path"]
	return paths

/// The loadout entry (assoc list) for a language typepath text, or null.
/datum/preference_middleware/languages/proc/find_entry(language)
	for(var/list/entry in preferences.alternate_languages)
		if(entry["language"] == language)
			return entry
	return null

/// Slots used = species-required languages + player-learned (non-required) entries.
/datum/preference_middleware/languages/proc/slots_used()
	var/list/required = required_paths()
	var/learned = 0
	for(var/list/entry in preferences.alternate_languages)
		if(!(entry["language"] in required))
			learned++
	return length(required) + learned

/// Is this a language the player is allowed to put in their loadout?
/datum/preference_middleware/languages/proc/is_selectable(language)
	var/datum/language/path = text2path(language)
	if(!ispath(path, /datum/language))
		return FALSE
	if(isnull(initial(path.chargen_category)))
		return FALSE // debug/internal language - never selectable, even via a crafted request
	if(language in required_paths()) // required languages may be referenced to downgrade / mark native
		return TRUE
	if(path == /datum/language/uncommon)
		return TRUE
	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()
	return (path in GLOB.uncommon_roundstart_languages)

/// Mark dirty and request a UI refresh.
/datum/preference_middleware/languages/proc/persist()
	preferences.mark_undatumized_dirty_character()
	return TRUE

/datum/preference_middleware/languages/proc/add_language(list/params, mob/user)
	var/language = params["language"]
	if(!is_selectable(language))
		return FALSE
	if(language in required_paths()) // already free; use set_fluency to downgrade it
		return FALSE
	if(find_entry(language))
		return FALSE
	if(slots_used() >= MAX_KNOWN_LANGUAGES)
		return FALSE
	preferences.alternate_languages += list(list(
		"language" = language,
		"fluency" = LANGUAGE_FLUENCY_BASIC,
		"understand_only" = FALSE,
		"native" = FALSE,
	))
	return persist()

/datum/preference_middleware/languages/proc/remove_language(list/params, mob/user)
	var/language = params["language"]
	var/list/entry = find_entry(language)
	if(!entry || (language in required_paths())) // can't remove a required language
		return FALSE
	preferences.alternate_languages -= list(entry)
	return persist()

/datum/preference_middleware/languages/proc/set_fluency(list/params, mob/user)
	var/language = params["language"]
	var/fluency = params["fluency"]
	if(!(fluency in GLOB.language_fluency_levels))
		return FALSE
	var/list/entry = find_entry(language)
	if(entry)
		entry["fluency"] = fluency
		return persist()
	// Allow creating a downgrade entry for a required language (the "Common Second Language" case).
	if(!(language in required_paths()))
		return FALSE
	preferences.alternate_languages += list(list(
		"language" = language,
		"fluency" = fluency,
		"understand_only" = FALSE,
		"native" = FALSE,
	))
	return persist()

/datum/preference_middleware/languages/proc/set_understand_only(list/params, mob/user)
	var/list/entry = find_entry(params["language"])
	if(!entry)
		return FALSE
	entry["understand_only"] = !!params["understand_only"]
	return persist()

/datum/preference_middleware/languages/proc/set_native(list/params, mob/user)
	var/language = params["language"]
	for(var/list/other in preferences.alternate_languages)
		other["native"] = FALSE
	if(!language) // clearing native back to the species default
		return persist()
	var/list/entry = find_entry(language)
	if(entry)
		entry["native"] = TRUE
		return persist()
	if(!(language in required_paths()))
		return FALSE
	preferences.alternate_languages += list(list(
		"language" = language,
		"fluency" = LANGUAGE_FLUENCY_FLUENT,
		"understand_only" = FALSE,
		"native" = TRUE,
	))
	return persist()

/**
 * Applies the character's intrinsic language loadout to the spawned human.
 * Called at spawn (roundstart + latejoin), ungated by the quirk config flags - languages are
 * intrinsic, not traits. Runs after the species holder has granted the species/required set.
 */
/datum/preferences/proc/apply_character_languages(mob/living/carbon/human/target)
	if(!istype(target))
		return

	var/native_path
	var/standard_partial = 0 // > 0 means a species/standard tongue is only a partial second language
	var/standard_path // the species tongue that got downgraded (Aurin for humans), for the drift anchor
	var/learned_count = 0 // non-required tongues granted so far, to re-enforce the cap at apply time

	if(!GLOB.uncommon_roundstart_languages.len)
		generate_selectable_species_and_languages()

	for(var/list/entry as anything in alternate_languages)
		if(!islist(entry))
			continue
		var/datum/language/language_type = text2path(entry["language"])
		if(!ispath(language_type, /datum/language))
			continue
		var/already_known = target.has_language(language_type, UNDERSTOOD_LANGUAGE) || target.has_language(language_type, SPOKEN_LANGUAGE)
		// Re-validate at apply time - the edit-time is_selectable() guard isn't authoritative once the
		// loadout is stored (stale or hand-edited saves). Only chargen-offered languages, or ones already
		// on the body (required downgrade entries), may be granted, and never more learned than the cap.
		if(isnull(initial(language_type.chargen_category)))
			continue
		if(!already_known && language_type != /datum/language/uncommon && !(language_type in GLOB.uncommon_roundstart_languages))
			continue
		if(!already_known)
			if(learned_count >= MAX_KNOWN_LANGUAGES)
				continue
			learned_count++

		var/fluency = entry["fluency"] || LANGUAGE_FLUENCY_BASIC
		var/understand_only = entry["understand_only"]
		if(entry["native"])
			native_path = language_type

		// A language the species already grants, set below Native, is a downgrade
		// (the "Common Second Language" case): keep it speakable but only partially understood.
		if(already_known && fluency != LANGUAGE_FLUENCY_FLUENT)
			var/amount = (fluency == LANGUAGE_FLUENCY_WORKING) ? LANGUAGE_FLUENCY_WORKING_AMOUNT : LANGUAGE_FLUENCY_BASIC_AMOUNT
			// Strip the *understood* grant across every source (species/atom AND the LANGUAGE_JOB grant that
			// grant_origin_language adds for an AUTO character whose species primary == this tongue) - else
			// the downgrade is silently defeated by the surviving JOB source. SPOKEN is left intact (the
			// downgraded tongue stays speakable; you just understand it only partially).
			target.remove_language(language_type, UNDERSTOOD_LANGUAGE, LANGUAGE_ALL)
			target.grant_partial_language(language_type, amount, LANGUAGE_MULTILINGUAL)
			standard_partial = amount // a downgraded standard tongue → drift back to native under stress
			standard_path = language_type
			continue

		// A freshly-learned language (or a required one kept at Native): grant at the chosen tier.
		switch(fluency)
			if(LANGUAGE_FLUENCY_FLUENT)
				target.grant_language(language_type, understand_only ? UNDERSTOOD_LANGUAGE : (SPOKEN_LANGUAGE | UNDERSTOOD_LANGUAGE), LANGUAGE_MULTILINGUAL)
			if(LANGUAGE_FLUENCY_WORKING)
				if(!understand_only)
					target.grant_language(language_type, SPOKEN_LANGUAGE, LANGUAGE_MULTILINGUAL)
				target.grant_partial_language(language_type, LANGUAGE_FLUENCY_WORKING_AMOUNT, LANGUAGE_MULTILINGUAL)
			if(LANGUAGE_FLUENCY_BASIC)
				target.grant_partial_language(language_type, LANGUAGE_FLUENCY_BASIC_AMOUNT, LANGUAGE_MULTILINGUAL)

	// A standard tongue kept as a partial second language → drift back to the native tongue under stress.
	if(standard_partial > 0)
		target.AddComponent(/datum/component/native_drift, native_path, standard_partial, standard_path)

/// The language the player explicitly marked as this character's native tongue in the loadout, if any
/// (a /datum/language typepath, else null). Shared by the spawn path (grant_origin_language) and the
/// chargen origin display (resolved_origin_language) so they resolve the spoken default identically.
/proc/character_marked_native_language(datum/preferences/prefs)
	if(!istype(prefs))
		return null
	for(var/list/entry in prefs.alternate_languages)
		if(islist(entry) && entry["native"])
			var/datum/language/path = text2path(entry["language"])
			if(ispath(path, /datum/language))
				return path
	return null

/// The origin/background choices offered to a given species in chargen - the picker is species-aware, so
/// a lizard isn't offered "Tellune Core" and a human isn't offered "Ashwalker." The origin pref still
/// validates against the full union (GLOB.language_origin_choices), so old saves never break; this only
/// filters what is shown and settable.
/proc/origins_for_species(datum/species/species_type)
	var/holder = ispath(species_type, /datum/species) ? initial(species_type.species_language_holder) : null
	// Check the more specific Ashwalker holder first - it is a subtype of the lizard holder, and only it
	// unlocks the holdout hearth-tongue (Ashwalker -> Vraksh) origin.
	if(ispath(holder, /datum/language_holder/lizard/ash))
		return GLOB.language_origin_choices_lizard_ash
	if(ispath(holder, /datum/language_holder/lizard))
		return GLOB.language_origin_choices_lizard
	return GLOB.language_origin_choices_human
