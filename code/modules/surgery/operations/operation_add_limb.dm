#define OPERATION_REJECTION_DAMAGE "tox_damage"

// This surgery is so snowflake that it doesn't use any of the operation subtypes, it forges its own path
/datum/surgery_operation/prosthetic_replacement
	name = "prosthetic replacement"
	desc = "Replace a missing limb with a prosthetic (or arbitrary) item."
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_STANDING_ALLOWED | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NOTABLE | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_SKIN_OPEN | SURGERY_VESSELS_CLAMPED
	/// Items that can replace an arm, and what they get mounted as. Most specific types first.
	var/static/list/arm_prosthetics = list(
		/obj/item/chainsaw/energy/doom = /obj/item/mounted_chainsaw/super,
		/obj/item/chainsaw/energy = /obj/item/mounted_chainsaw/energy,
		/obj/item/chainsaw = /obj/item/mounted_chainsaw/normal,
		/obj/item/melee/synthetic_arm_blade = /obj/item/melee/arm_blade,
	)
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_prosthetic_options

/datum/surgery_operation/prosthetic_replacement/get_default_radial_image()
	return image(/obj/item/bodypart/chest)

/datum/surgery_operation/prosthetic_replacement/get_recommended_tool()
	return "any limb / any item"

/datum/surgery_operation/prosthetic_replacement/get_any_tool()
	return "Any suitable arm replacement"

/datum/surgery_operation/prosthetic_replacement/all_required_strings()
	. = list()
	. += "operate on chest (target chest)"
	. += ..()
	. += "when the chest is prepared, target the zone of the limb you are attaching"

/datum/surgery_operation/prosthetic_replacement/any_required_strings()
	return list("arms may receive a chainsaw or synthetic arm blade in lieu of a replacement limb") + ..()

/datum/surgery_operation/prosthetic_replacement/get_radial_options(obj/item/bodypart/chest/chest, obj/item/tool, operating_zone)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_prosthetic_options, tool.type)
	if(!option)
		option = new()
		option.name = "attach [initial(tool.name)]"
		option.info = "Replace the patient's missing limb with [initial(tool.name)]."
		option.image = image(tool.type)
		LAZYSET(cached_prosthetic_options, tool.type, option)

	return option

/datum/surgery_operation/prosthetic_replacement/get_operation_target(mob/living/patient, body_zone)
	// We always operate on the chest even if we're targeting left leg or w/e
	return patient.get_bodypart(BODY_ZONE_CHEST)

/datum/surgery_operation/prosthetic_replacement/has_surgery_state(obj/item/bodypart/chest/chest, state)
	return LIMB_HAS_SURGERY_STATE(chest, state)

/datum/surgery_operation/prosthetic_replacement/has_any_surgery_state(obj/item/bodypart/chest/chest, state)
	return LIMB_HAS_ANY_SURGERY_STATE(chest, state)

/datum/surgery_operation/prosthetic_replacement/get_patient(obj/item/bodypart/chest/chest)
	return chest.owner

/datum/surgery_operation/prosthetic_replacement/is_available(obj/item/bodypart/chest/chest, operated_zone)
	var/real_operated_zone = deprecise_zone(operated_zone)
	// Operate on the chest but target another zone
	if(!HAS_TRAIT(chest, TRAIT_READY_TO_OPERATE) || real_operated_zone == BODY_ZONE_CHEST)
		return FALSE
	if(chest.owner.get_bodypart(real_operated_zone))
		return FALSE
	return ..()

/datum/surgery_operation/prosthetic_replacement/snowflake_check_availability(obj/item/bodypart/chest, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	var/real_operated_zone = deprecise_zone(operated_zone)
	// check bodyshape compatibility for real bodyparts
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(real_operated_zone != new_limb.body_zone)
			return FALSE
		if(!new_limb.can_attach_limb(chest.owner))
			return FALSE
	// arbitrary prosthetics can only be used on arms (for now)
	else if(!(real_operated_zone in GLOB.arm_zones))
		return FALSE
	return TRUE

/datum/surgery_operation/prosthetic_replacement/tool_check(obj/item/tool)
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(isbodypart(tool))
		return TRUE
	return is_type_in_list(tool, arm_prosthetics)

/datum/surgery_operation/prosthetic_replacement/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	// always operate on absolute body zones
	operation_args[OPERATION_TARGET_ZONE] = deprecise_zone(operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/prosthetic_replacement/on_preop(obj/item/bodypart/chest/chest, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/target_zone_readable = parse_zone(operation_args[OPERATION_TARGET_ZONE])
	display_results(
		surgeon,
		chest.owner,
		span_notice("You begin to replace [chest.owner]'s missing [target_zone_readable] with [tool]..."),
		span_notice("[surgeon] begins to replace [chest.owner]'s missing [target_zone_readable] with [tool]."),
		span_notice("[surgeon] begins to replace [chest.owner]'s missing [target_zone_readable]."),
	)
	display_pain(chest.owner, "You feel an uncomfortable sensation where your [target_zone_readable] should be!")

	operation_args[OPERATION_REJECTION_DAMAGE] = 10
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(IS_ROBOTIC_LIMB(new_limb))
			operation_args[OPERATION_REJECTION_DAMAGE] = 0
		else if(new_limb.check_for_frankenstein(chest.owner))
			operation_args[OPERATION_REJECTION_DAMAGE] = 30

/datum/surgery_operation/prosthetic_replacement/on_success(obj/item/bodypart/chest/chest, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen
	if(operation_args[OPERATION_REJECTION_DAMAGE] > 0)
		chest.owner.apply_damage(operation_args[OPERATION_REJECTION_DAMAGE], TOX)
	if(isbodypart(tool))
		handle_bodypart(chest.owner, surgeon, tool)
		return
	handle_arbitrary_prosthetic(chest.owner, surgeon, tool, operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/prosthetic_replacement/proc/handle_bodypart(mob/living/carbon/patient, mob/living/surgeon, obj/item/bodypart/bodypart_to_attach)
	bodypart_to_attach.try_attach_limb(patient)
	if(bodypart_to_attach.check_for_frankenstein(patient))
		bodypart_to_attach.bodypart_flags |= BODYPART_IMPLANTED
	display_results(
		surgeon, patient,
		span_notice("You succeed in replacing [patient]'s [bodypart_to_attach.plaintext_zone]."),
		span_notice("[surgeon] successfully replaces [patient]'s [bodypart_to_attach.plaintext_zone] with [bodypart_to_attach]!"),
		span_notice("[surgeon] successfully replaces [patient]'s [bodypart_to_attach.plaintext_zone]!"),
	)
	display_pain(patient, "You feel synthetic sensation wash from your [bodypart_to_attach.plaintext_zone], which you can feel again!", TRUE)

/datum/surgery_operation/prosthetic_replacement/proc/handle_arbitrary_prosthetic(mob/living/carbon/patient, mob/living/surgeon, obj/item/thing_to_attach, target_zone)
	SSblackbox.record_feedback("tally", "arbitrary_prosthetic", 1, initial(thing_to_attach.name))
	var/obj/item/bodypart/new_limb = patient.newBodyPart(target_zone)
	new_limb.try_attach_limb(patient)
	new_limb.bodypart_flags |= BODYPART_PSEUDOPART | BODYPART_IMPLANTED
	var/mount_type = is_type_in_list(thing_to_attach, arm_prosthetics, zebra = TRUE)
	var/obj/item/new_arm = new mount_type(patient, TRUE, TRUE)
	if(target_zone == BODY_ZONE_R_ARM)
		patient.put_in_r_hand(new_arm)
	else
		patient.put_in_l_hand(new_arm)
	display_results(
		surgeon, patient,
		span_notice("You attach [thing_to_attach]."),
		span_notice("[surgeon] finishes attaching [thing_to_attach]!"),
		span_notice("[surgeon] finishes the attachment procedure!"),
	)
	display_pain(patient, "You feel a strange sensation as [thing_to_attach] takes the place of your arm!", TRUE)
	qdel(thing_to_attach)

#undef OPERATION_REJECTION_DAMAGE
