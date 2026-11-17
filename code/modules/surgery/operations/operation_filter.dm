/datum/surgery_operation/limb/filter_blood
	name = "blood filtration"
	rnd_name = "Hemodialysis (Blood Filtration)"
	desc = "Remove unwanted chemicals from a patient's bloodstream."
	implements = list(/obj/item/blood_filter = 1)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	required_bodytype = ~BODYTYPE_ROBOTIC
	success_sound = 'sound/machines/ping.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED
	replaced_by = /datum/surgery_operation/limb/filter_blood/upgraded
	/// Fraction of each chemical removed per cycle
	var/chem_purge_factor = 0.2
	/// Fraction of toxin damage healed per cycle
	var/tox_heal_factor = 0
	/// Toxin damage is only healed above this amount
	var/limited_healing = 100

/datum/surgery_operation/limb/filter_blood/all_required_strings()
	. = list()
	. += "operate on chest (target chest)"
	. += ..()
	. += "the patient must not be husked"

/datum/surgery_operation/limb/filter_blood/get_default_radial_image()
	return image(/obj/item/blood_filter)

/datum/surgery_operation/limb/filter_blood/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && !HAS_TRAIT(limb.owner, TRAIT_HUSK)

/datum/surgery_operation/limb/filter_blood/can_loop(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	return ..() && has_filterable_chems(limb.owner, tool)

/datum/surgery_operation/limb/filter_blood/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_pain(limb.owner, "You feel a throbbing pain in your chest!")

/datum/surgery_operation/limb/filter_blood/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/mob/living/carbon/patient = limb.owner
	for(var/datum/reagent/chem as anything in patient.reagents?.reagent_list)
		patient.reagents.remove_reagent(chem.type, min(chem.volume * chem_purge_factor, 10))

	var/tox_loss = patient.getToxLoss()
	if(tox_heal_factor > 0 && tox_loss > limited_healing)
		if(tox_loss <= 2)
			patient.setToxLoss(0)
		else
			patient.adjustToxLoss(-(tox_loss * tox_heal_factor), forced = TRUE) //forced so this will actually heal oozelings too

	display_results(
		surgeon,
		patient,
		span_notice("[tool] completes a cycle filtering [patient]'s blood."),
		span_notice("[tool] whirrs as it filters [patient]'s blood."),
		span_notice("[tool] whirrs as it pumps."),
	)

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		chemscan(surgeon, patient)

/datum/surgery_operation/limb/filter_blood/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up!"),
	)
	limb.receive_damage(5, damage_source = tool)

/datum/surgery_operation/limb/filter_blood/proc/has_filterable_chems(mob/living/carbon/target, obj/item/blood_filter/bloodfilter)
	if(length(target.reagents?.reagent_list))
		return TRUE
	if(tox_heal_factor > 0 && target.getToxLoss() > limited_healing)
		return TRUE
	bloodfilter.audible_message(span_notice("[bloodfilter] pings as it reports no chemicals detected in [target]'s blood."))
	playsound(target, 'sound/machines/ping.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1)
	return FALSE

/datum/surgery_operation/limb/filter_blood/upgraded
	name = "advanced blood filtration"
	rnd_name = "Advanced Hemodialysis (Blood Filtration)"
	rnd_desc = "A blood filtration procedure which also undoes the damage toxins have done to the patient's system. \
		Heals considerably more when the patient is severely injured."
	operation_flags = parent_type::operation_flags | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/limb/filter_blood/upgraded/femto
	time = 1.85 SECONDS
	chem_purge_factor = 0.3
	tox_heal_factor = 0.075
	limited_healing = 0

/datum/surgery_operation/limb/filter_blood/upgraded/femto
	name = "experimental blood filtration"
	rnd_name = "Experimental Hemodialysis (Blood Filtration)"
	replaced_by = null
	time = 1 SECONDS
	chem_purge_factor = 0.4
	tox_heal_factor = 0.15

/datum/surgery_operation/limb/filter_blood/mechanic
	name = "purge hydraulics"
	rnd_name = "Hydraulics Purge (Blood Filtration)"
	required_bodytype = BODYTYPE_ROBOTIC
	replaced_by = null
	operation_flags = parent_type::operation_flags | OPERATION_MECHANIC
