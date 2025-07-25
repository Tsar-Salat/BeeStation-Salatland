//open shell
/datum/surgery_step/mechanic_open
	name = "unscrew shell (screwdriver)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75, // med borgs could try to unskrew shell with scalpel
		/obj/item/knife = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_open/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)]."),
	)

/datum/surgery_step/mechanic_incise/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

//close shell
/datum/surgery_step/mechanic_close
	name = "screw shell (screwdriver)"
	implements = list(
		TOOL_SCREWDRIVER = 100,
		TOOL_SCALPEL = 75,
		/obj/item/knife/ = 50,
		/obj/item = 10) // 10% success with any sharp item.
	time = 24
	preop_sound = 'sound/items/screwdriver.ogg'
	success_sound = 'sound/items/screwdriver2.ogg'

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to screw the shell of [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to screw the shell of [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to screw the shell of [target]'s [parse_zone(target_zone)]."),
	)

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool)
	if(implement_type == /obj/item && !tool.is_sharp())
		return FALSE
	if(tool.usesound)
		preop_sound = tool.usesound

	return TRUE

/datum/surgery_step/mechanic_close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	target.cauterise_wounds()
	return ..()

//prepare electronics
/datum/surgery_step/prepare_electronics
	name = "prepare electronics (multitool)"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 10) // try to reboot internal controllers via short circuit with some conductor
	time = 24
	preop_sound = 'sound/surgery/tape_flip.ogg'
	success_sound = 'sound/surgery/taperecorder_close.ogg'

/datum/surgery_step/prepare_electronics/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to prepare electronics in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)]."),
	)

//unwrench
/datum/surgery_step/mechanic_unwrench
	name = "unwrench bolts (wrench)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_unwrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)]."),
	)

//wrench
/datum/surgery_step/mechanic_wrench
	name = "wrench bolts (wrench)"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	time = 24
	preop_sound = 'sound/items/ratchet.ogg'

/datum/surgery_step/mechanic_wrench/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to wrench some bolts in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to wrench some bolts in [target]'s [parse_zone(target_zone)]."),
	)

//open hatch
/datum/surgery_step/open_hatch
	name = "open the hatch (hand)"
	accept_hand = 1
	time = 10
	preop_sound = 'sound/items/ratchet.ogg'
	preop_sound = 'sound/machines/doorclick.ogg'

/datum/surgery_step/open_hatch/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to open the hatch holders in [target]'s [parse_zone(target_zone)]..."),
		span_notice("[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)]."),
		span_notice("[user] begins to open the hatch holders in [target]'s [parse_zone(target_zone)]."),
	)
