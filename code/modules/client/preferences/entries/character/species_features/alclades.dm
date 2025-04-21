/datum/preference/choiced/human_cladia
	db_key = "feature_human_cladia"
	preference_type = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	can_randomize = FALSE
	randomize_by_default = FALSE
	relevant_mutant_bodypart = "cladia_human"

/datum/preference/choiced/human_cladia/init_possible_values()
	return assoc_to_keys(GLOB.human_cladia_list)

/datum/preference/choiced/human_cladia/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["cladia"] = value

/datum/preference/choiced/human_cladia/create_default_value()
	var/datum/sprite_accessory/cladia/human/cladia = /datum/sprite_accessory/cladia/human
	return initial(cladia.name)
