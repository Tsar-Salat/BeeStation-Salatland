/// Validates the mutual-intelligibility web on every learnable language:
/// - each mutual_understanding key is a real, learnable (keyed) language
/// - no language lists itself
/// - every value is a percentage in the 0-100 range
/datum/unit_test/language_web/Run()
	for(var/datum/language/language_type as anything in GLOB.language_datum_instances)
		var/datum/language/prototype = GLOB.language_datum_instances[language_type]
		var/list/web = prototype.mutual_understanding
		if(!length(web))
			continue
		for(var/datum/language/target as anything in web)
			TEST_ASSERT(ispath(target, /datum/language), "[language_type] mutual_understanding key [target] is not a /datum/language path")
			TEST_ASSERT(GLOB.language_datum_instances[target], "[language_type] partially understands [target], which is not a learnable language (no key / not instantiated)")
			TEST_ASSERT(target != language_type, "[language_type] lists itself in its own mutual_understanding")
			var/value = web[target]
			TEST_ASSERT(isnum(value), "[language_type] -> [target] mutual_understanding value is not a number ([value])")
			TEST_ASSERT(value >= 0 && value <= 100, "[language_type] -> [target] mutual_understanding value out of range 0-100 ([value])")

/// Validates the *design model* of the human intelligibility web (the band system documented in the
/// anchor comment above /datum/language/common's mutual_understanding):
/// - no value exceeds the dialect ceiling (nothing becomes near-fluent through partial understanding)
/// - every human-category register understands the Solbind broadcast standard at/above the floor
/// - broadcast asymmetry: a register understands Solbind at least as well as Solbind understands it back
/// - the lizard tongues are an isolated kin island: a reciprocal in-band kin pair, no bridge to any human tongue
/datum/unit_test/language_web_model/Run()
	var/datum/language/solbind = GLOB.language_datum_instances[/datum/language/common]
	var/list/solbind_web = solbind.mutual_understanding

	for(var/datum/language/language_type as anything in GLOB.language_datum_instances)
		var/datum/language/prototype = GLOB.language_datum_instances[language_type]
		var/list/web = prototype.mutual_understanding

		// Global ceiling: partial understanding can't make any tongue near-fluent in another.
		for(var/datum/language/target as anything in web)
			TEST_ASSERT(web[target] <= LANGUAGE_WEB_MAX, "[language_type] -> [target] = [web[target]] exceeds the dialect ceiling LANGUAGE_WEB_MAX ([LANGUAGE_WEB_MAX])")

		switch(prototype.chargen_category)
			if(LANGUAGE_CATEGORY_HUMAN)
				if(language_type == /datum/language/common)
					continue
				// Every human register follows the broadcast standard, and is understood by Solbind no
				// better than it understands Solbind (the deliberate broadcast asymmetry).
				var/to_solbind = web[/datum/language/common] || 0
				TEST_ASSERT(to_solbind >= LANGUAGE_WEB_BROADCAST_FLOOR, "human register [language_type] understands Solbind at [to_solbind], below the broadcast floor ([LANGUAGE_WEB_BROADCAST_FLOOR])")
				if(solbind_web[language_type])
					TEST_ASSERT(to_solbind >= solbind_web[language_type], "broadcast asymmetry violated: [language_type]->Solbind ([to_solbind]) < Solbind->[language_type] ([solbind_web[language_type]])")
			if(LANGUAGE_CATEGORY_LIZARD)
				// The lizard tongues stay an isolated kin island - no bridge to any human tongue.
				for(var/datum/language/target as anything in web)
					var/datum/language/target_proto = GLOB.language_datum_instances[target]
					if(!target_proto)
						continue // missing-instance validity is the basic language_web test's job
					TEST_ASSERT(target_proto.chargen_category != LANGUAGE_CATEGORY_HUMAN, "lizard tongue [language_type] partially understands human tongue [target] - the lizard web must stay an isolated kin island")

	// The lizard kin pair is reciprocal and in-band (the Draconic/Vraksh diglossia).
	var/datum/language/draconic = GLOB.language_datum_instances[/datum/language/draconic]
	var/datum/language/vraksh = GLOB.language_datum_instances[/datum/language/ashic]
	var/dra_to_vra = draconic.mutual_understanding[/datum/language/ashic]
	var/vra_to_dra = vraksh.mutual_understanding[/datum/language/draconic]
	TEST_ASSERT(dra_to_vra >= 30 && dra_to_vra <= 60, "Draconic->Vraksh kin value [dra_to_vra] is outside the 30-60 kin band")
	TEST_ASSERT(vra_to_dra >= 30 && vra_to_dra <= 60, "Vraksh->Draconic kin value [vra_to_dra] is outside the 30-60 kin band")

/// Locks the species-intelligibility invariant from the Aurin-primary rework: every roundstart-playable
/// species must comprehend the crew's contact dialect (Aurin) at least at the "native fit" threshold, so
/// no playable species is left half-deaf to the Aurin-speaking majority (the gap the Solbind->Aurin switch
/// opened for non-human species). A species satisfies this by knowing Aurin outright (the chosen fix,
/// mirroring lizards/humans) or via high mutual intelligibility. Their *own* default tongue need NOT be
/// understood by the crew - that one-way "switch to Aurin to be heard" friction is intended (lizard parity).
/datum/unit_test/species_crew_intelligibility/Run()
	for(var/species_type in subtypesof(/datum/species))
		var/datum/species/species = GLOB.species_prototypes[species_type]
		if(!species || !species.check_roundstart_eligible())
			continue
		var/datum/language_holder/proto = GLOB.prototype_language_holders[species.species_language_holder]
		if(!proto)
			continue
		var/understands_aurin = proto.has_language(/datum/language/aurin, UNDERSTOOD_LANGUAGE) ? 100 : (proto.best_mutual_languages?[/datum/language/aurin] || 0)
		TEST_ASSERT(understands_aurin >= LANGUAGE_FIT_NATIVE_THRESHOLD, "roundstart species [species_type] ([species.species_language_holder]) understands the crew dialect Aurin at only [understands_aurin]% - it would be half-deaf to the Aurin-speaking crew. Grant /datum/language/aurin in its language holder (see the lizard/moth/etc. holders).")
