/datum/surgery_operation/limb/embedded_removal
	name = "remove embedded objects"
	desc = "Remove objects embedded in a patient's limb."
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_HEMOSTAT = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/embedded_removal/all_required_strings()
	return ..() + list("the limb must have an object embedded in it")

/datum/surgery_operation/limb/embedded_removal/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/embedded_removal/state_check(obj/item/bodypart/limb)
	return length(limb.embedded_objects)

/datum/surgery_operation/limb/embedded_removal/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You look for objects embedded in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] looks for objects embedded in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] looks for something in [limb.owner]'s [limb.plaintext_zone]."),
	)

/datum/surgery_operation/limb/embedded_removal/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	var/objects = length(limb.embedded_objects)
	for(var/obj/item/embedded as anything in limb.embedded_objects)
		limb.owner.remove_embedded_object(embedded)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully remove [objects] object\s from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully removes [objects] object\s from [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] successfully removes [objects] object\s from [limb.owner]'s [limb.plaintext_zone]!"),
	)
