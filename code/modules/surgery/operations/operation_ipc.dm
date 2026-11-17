#define OPERATION_UPGRADE "upgrade"

/datum/surgery_operation/limb/identity_recalibration
	name = "recalibrate identity"
	rnd_name = "Identity Recalibration"
	desc = "Overwrite a robotic patient's registered identity with the name on an ID card."
	implements = list(/obj/item/card/id = 1)
	time = 1 SECONDS
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/identity_recalibration/all_required_strings()
	return list("operate on chest (target chest)") + ..()

/datum/surgery_operation/limb/identity_recalibration/get_default_radial_image()
	return image(/obj/item/card/id)

/datum/surgery_operation/limb/identity_recalibration/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && ishuman(limb.owner)

/datum/surgery_operation/limb/identity_recalibration/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to swipe [tool] through [limb.owner]'s identity circuits..."),
		span_notice("[surgeon] begins to swipe [tool] through [limb.owner]'s identity circuits."),
		span_notice("[surgeon] begins to work on [limb.owner]'s [limb.plaintext_zone]."),
	)

/datum/surgery_operation/limb/identity_recalibration/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/card/id/tool, list/operation_args)
	var/mob/living/carbon/human/patient = limb.owner
	var/old_name = patient.real_name
	if(!tool.registered_name)
		patient.real_name = "????"
		to_chat(surgeon, span_warning("The lack of registered name on the card has lead to a glitch!"))
		log_combat(surgeon, patient, "renamed", addition = "changed [old_name] to ????")
		return
	patient.real_name = tool.registered_name
	display_results(
		surgeon,
		patient,
		span_notice("You successfully recalibrated [old_name]'s identity!"),
		span_notice("[surgeon] successfully recalibrated [old_name]'s identity with [tool]!"),
		span_notice("[surgeon] successfully recalibrated [old_name]'s identity!"),
	)
	log_combat(surgeon, patient, "renamed", addition = "changed [old_name]'s name to [tool.registered_name]")

/datum/surgery_operation/limb/install_upgrade
	name = "install upgrade"
	rnd_name = "Upgrade Installation"
	desc = "Install an upgrade module into a compatible robotic patient."
	implements = list(/obj/item/ipc_upgrade = 1)
	time = 1 SECONDS
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_operation/limb/install_upgrade/all_required_strings()
	return list("operate on chest (target chest)") + ..() + list("the patient must be upgrade compatible")

/datum/surgery_operation/limb/install_upgrade/get_default_radial_image()
	return image(/obj/item/ipc_upgrade)

/datum/surgery_operation/limb/install_upgrade/state_check(obj/item/bodypart/limb)
	return limb.body_zone == BODY_ZONE_CHEST && HAS_TRAIT(limb.owner, TRAIT_UPGRADE_COMPATIBLE)

/datum/surgery_operation/limb/install_upgrade/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/ipc_upgrade/tool, operated_zone)
	return ..() && !get_ipc_upgrade_by_slot(limb.owner.status_effects, tool.slot)

/datum/surgery_operation/limb/install_upgrade/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to install [tool] into [limb.owner]..."),
		span_notice("[surgeon] begins to install [tool] into [limb.owner]."),
		span_notice("[surgeon] begins to install something into [limb.owner]."),
	)

/datum/surgery_operation/limb/install_upgrade/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/ipc_upgrade/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You install [tool] into [limb.owner]."),
		span_notice("[surgeon] installs [tool] into [limb.owner]."),
		span_notice("[surgeon] installs something into [limb.owner]."),
	)
	tool.insert(limb.owner)

/datum/surgery_operation/limb/remove_upgrade
	name = "uninstall upgrade"
	rnd_name = "Upgrade Removal"
	desc = "Uninstall an upgrade module from a compatible robotic patient."
	implements = list(TOOL_CROWBAR = 1)
	time = 1 SECONDS
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_operation/limb/remove_upgrade/all_required_strings()
	return list("operate on chest (target chest)") + ..() + list("the patient must have an upgrade installed")

/datum/surgery_operation/limb/remove_upgrade/get_default_radial_image()
	return image(/obj/item/crowbar)

/datum/surgery_operation/limb/remove_upgrade/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return !!(locate(/datum/status_effect/ipc_upgrade) in limb.owner.status_effects)

/datum/surgery_operation/limb/remove_upgrade/pre_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/list/datum/status_effect/ipc_upgrade/choices = list()
	for(var/datum/status_effect/ipc_upgrade/upgrade in limb.owner.status_effects)
		choices += upgrade
	operation_args[OPERATION_UPGRADE] = tgui_input_list(surgeon, "Uninstall which Upgrade?", "Surgery", sort_list(choices))
	return !!operation_args[OPERATION_UPGRADE]

/datum/surgery_operation/limb/remove_upgrade/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/status_effect/ipc_upgrade/upgrade = operation_args[OPERATION_UPGRADE]
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to uninstall [upgrade.name] from [limb.owner]..."),
		span_notice("[surgeon] begins to uninstall [upgrade.name] from [limb.owner]."),
		span_notice("[surgeon] begins to uninstall something from [limb.owner]."),
	)

/datum/surgery_operation/limb/remove_upgrade/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/status_effect/ipc_upgrade/upgrade = operation_args[OPERATION_UPGRADE]
	if(QDELETED(upgrade))
		return
	display_results(
		surgeon,
		limb.owner,
		span_notice("You uninstall [upgrade.name] from [limb.owner]."),
		span_notice("[surgeon] uninstalls [upgrade.name] from [limb.owner]."),
		span_notice("[surgeon] uninstalls something from [limb.owner]."),
	)
	upgrade.extract()

#undef OPERATION_UPGRADE
