/datum/component/butchering
	/// Time in deciseconds taken to butcher something
	var/speed = 8 SECONDS
	/// Percentage effectiveness; numbers above 100 yield extra drops
	var/effectiveness = 100
	/// Percentage increase to bonus item chance
	var/bonus_modifier = 0
	/// Sound played when butchering
	var/butcher_sound = 'sound/weapons/slice.ogg'
	/// Whether or not this component can be used to butcher currently. Used to temporarily disable butchering
	var/butchering_enabled = TRUE
	/// Whether or not this component is compatible with blunt tools.
	var/can_be_blunt = FALSE

/datum/component/butchering/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(_speed)
		speed = _speed
	if(_effectiveness)
		effectiveness = _effectiveness
	if(_bonus_modifier)
		bonus_modifier = _bonus_modifier
	if(_butcher_sound)
		butcher_sound = _butcher_sound
	if(disabled)
		butchering_enabled = FALSE
	if(_can_be_blunt)
		can_be_blunt = _can_be_blunt
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))
		RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_item_interaction))

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user, list/modifiers)
	SIGNAL_HANDLER

	if(!user.combat_mode)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.get_sharpness()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && LAZYACCESS(modifiers, RIGHT_CLICK) && butchering_enabled && (can_be_blunt || source.get_sharpness()))
		INVOKE_ASYNC(src, PROC_REF(butcher_human), source, M, user)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && source.get_sharpness())
		var/mob/living/carbon/human/H = M
		var/neckslice_conditions = (H.health <= H.crit_threshold || user.grab_state >= GRAB_NECK || H.IsSleeping())
		if(neckslice_conditions && user.pulling == H && user.is_zone_selected(BODY_ZONE_HEAD) && user.grab_state >= GRAB_AGGRESSIVE) // Only sleeping, neck grabbed, or crit, can be sliced.
			if(HAS_TRAIT(user, TRAIT_PACIFISM))
				to_chat(user, span_warning("You don't want to harm other living beings!"))
				return COMPONENT_CANCEL_ATTACK_CHAIN

			if(H.has_status_effect(/datum/status_effect/neck_slice))
				user.show_message(span_danger("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), 1, span_danger("Their neck has already been already cut, you can't make the bleeding any worse!"))
				return

			INVOKE_ASYNC(src, PROC_REF(startNeckSlice), source, H, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/on_item_interaction(obj/item/source, mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER

	if(!source.get_sharpness() && !can_be_blunt)
		return NONE
	if(!user.combat_mode || !butchering_enabled || !isbodypart(target))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(butcher_limb), source, target, user)
	return ITEM_INTERACT_BLOCKING

/datum/component/butchering/proc/butcher_human(obj/item/source, mob/living/carbon/human/victim, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("You're already interacting with [victim]!"))
		return

	var/static/list/butcher_spots = typecacheof(list(
		/obj/structure/table,
		/obj/structure/bed,
		/obj/machinery/stasis,
		/obj/structure/kitchenspike,
	))

	var/found_spot = FALSE
	for(var/obj/thing in victim.loc)
		if(is_type_in_typecache(thing, butcher_spots))
			found_spot = TRUE
			break

	if(!found_spot)
		to_chat(user, span_warning("You need a better spot to butcher [victim]!"))
		return

	var/obj/item/bodypart/limb = victim.get_bodypart(user.get_combat_bodyzone(victim))
	if(!limb)
		to_chat(user, span_warning("[victim] doesn't have a [parse_zone(user.get_combat_bodyzone(victim))]!"))
		return

	butcher_limb(source, limb, user)

/datum/component/butchering/proc/butcher_limb(obj/item/source, obj/item/bodypart/target, mob/living/user)
	target.add_fingerprint(user)
	if(LIMB_HAS_SKIN(target) && !HAS_ANY_SURGERY_STATE(target.surgery_state, SURGERY_SKIN_CUT | SURGERY_SKIN_OPEN))
		to_chat(user, span_warning("[target]'s skin is still intact!"))
		return

	// We need to gut the limb before turning it into meat, otherwise just cut around the bone
	if(LIMB_HAS_BONES(target) && !HAS_ANY_SURGERY_STATE(target.surgery_state, SURGERY_BONE_DRILLED | SURGERY_BONE_SAWED) && length(target.contents))
		to_chat(user, span_warning("[target]'s bones are still intact!"))
		return

	var/speed_modifier = 1
	if(!target.owner)
		speed_modifier = 0.5
	else if(target.owner.stat < UNCONSCIOUS)
		speed_modifier = 1.5

	var/limb_descriptor = (target.owner ? "[target.owner]'s [target.plaintext_zone]" : target)
	if(target.body_zone == BODY_ZONE_CHEST && target.owner)
		limb_descriptor = target.owner

	if(target.owner)
		log_combat(user, target.owner, "attempted to butcher", source)

	if(length(target.contents))
		user.visible_message(span_warning("[user] begins to gut [limb_descriptor]!"), span_notice("You begin to gut [limb_descriptor]..."), ignored_mobs = target.owner)
		if(target.owner)
			to_chat(target.owner, span_warning("[user] begins to gut your [target.plaintext_zone]!"))

		playsound(target.loc, butcher_sound, 50, TRUE, -1)
		if(!do_after(user, speed * speed_modifier, target.owner || target))
			return
		target.drop_organs(user, TRUE)
		return

	if(!length(target.butcher_drops))
		to_chat(user, span_warning("There is nothing left inside [limb_descriptor]!"))
		return

	if(target.body_zone == BODY_ZONE_CHEST && target.owner)
		// Cannot butcher the chest until we hack off all the other limbs
		for(var/obj/item/bodypart/limb as anything in target.owner.bodyparts)
			if(limb != target && limb.butcher_drops && limb.butcher_replacement)
				to_chat(user, span_warning("You need to butcher all other limbs first!"))
				return

	user.visible_message(span_warning("[user] begins to cut [limb_descriptor] apart!"), span_notice("You begin to cut [limb_descriptor] apart..."), ignored_mobs = target.owner)
	if(target.owner)
		to_chat(target.owner, span_warning("[user] begins to cut your [target.plaintext_zone] apart!"))

	playsound(target.loc, butcher_sound, 50, TRUE, -1)
	if(!do_after(user, speed * speed_modifier, target.owner || target))
		return

	var/list/results = list()
	var/turf/drop_loc = target.owner?.drop_location() || target.drop_location()
	var/bonus_chance = max(0, (effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	var/list/failures = list()
	var/list/bonuses = list()

	for(var/obj/item/drop_type as anything in target.butcher_drops)
		var/amount = target.butcher_drops[drop_type] || 1
		var/is_stack = ispath(drop_type, /obj/item/stack)

		for(var/i in 1 to amount)
			if(!prob(effectiveness))
				failures |= drop_type::name
				amount -= 1
				continue

			if(prob(bonus_chance))
				if(!is_stack)
					results += new drop_type(drop_loc)
				amount += 1
				bonuses |= drop_type::name

			if(!is_stack)
				results += new drop_type(drop_loc)

		if(is_stack && amount)
			results += new drop_type(drop_loc, amount)

	if(length(failures))
		to_chat(user, span_warning("You fail to harvest some of the [english_list(failures)] from [limb_descriptor]."))
	if(length(bonuses))
		to_chat(user, span_info("You harvest some extra [english_list(bonuses)] from [limb_descriptor]!"))

	if(target.blood_dna_info)
		for(var/obj/item/result as anything in results)
			result.add_blood_DNA(target.blood_dna_info)

	if(target.reagents)
		var/meat_produced = 0
		for(var/obj/item/food/target_meat in results)
			meat_produced += 1

		for(var/obj/item/food/target_meat in results)
			target.reagents.trans_to(target_meat, target.reagents.total_volume / meat_produced, remove_blacklisted = TRUE)

	if(target.owner)
		var/reagents_in_produced = 0
		for(var/obj/item/result as anything in results)
			if(result.reagents)
				reagents_in_produced += 1

		var/list/diseases = target.owner.get_static_viruses()

		for(var/obj/item/result as anything in results)
			if(reagents_in_produced)
				if(target.owner.reagents)
					target.owner.reagents.trans_to(result, target.owner.reagents.total_volume / reagents_in_produced / length(target.owner.bodyparts), remove_blacklisted = TRUE)
				result.reagents?.add_reagent(/datum/reagent/consumable/nutriment, target.owner.nutrition / 15 / reagents_in_produced)

			if(LAZYLEN(diseases))
				var/list/datum/disease/diseases_to_add = list()
				for(var/datum/disease/disease as anything in diseases)
					// Admin or special viruses that should not be reproduced
					if(disease.spread_flags & (DISEASE_SPREAD_SPECIAL | DISEASE_SPREAD_NON_CONTAGIOUS))
						continue
					diseases_to_add += disease

				if(LAZYLEN(diseases_to_add))
					result.AddComponent(/datum/component/infective, diseases_to_add)

		for(var/obj/item/food/meat/meat in results)
			meat.name = "[target.owner.real_name] [meat.name]"
			meat.subjectname = target.owner.real_name
			meat.subjectjob = target.owner.job

	user.visible_message(span_warning("[user] butchers [limb_descriptor]!"), span_notice("You butcher [limb_descriptor]."), ignored_mobs = target.owner)
	if(!target.owner)
		target.drop_organs()
		if(target.butcher_replacement)
			create_replacement_limb(target, drop_loc)
		qdel(target)
		return

	to_chat(target.owner, span_userdanger("[user] hacks the meat off your [target.plaintext_zone]!"))
	var/mob/living/carbon/victim = target.owner

	if(!target.butcher_replacement)
		target.dismember(source.damtype)
		target.drop_organs()
		qdel(target)
		return

	var/obj/item/bodypart/replacement = create_replacement_limb(target, drop_loc)
	target.dismember(source.damtype)
	target.drop_organs()
	replacement.replace_limb(victim)
	replacement.update_limb(is_creating = TRUE)
	qdel(target)

/// Creates a replacement (usually skeleton) limb for the butchered one
/datum/component/butchering/proc/create_replacement_limb(obj/item/bodypart/target, drop_loc)
	var/drop_type = target.butcher_replacement
	var/obj/item/bodypart/replacement = new drop_type(drop_loc)
	replacement.bodyshape = target.bodyshape
	if(IS_ORGANIC_LIMB(replacement) && target.owner)
		replacement.blood_dna_info = target.owner.get_blood_dna_list()
	SEND_SIGNAL(target, COMSIG_BODYPART_BUTCHERED, replacement)
	return replacement

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, span_notice("You begin to butcher [M]..."))
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, speed, M) && M.Adjacent(source))
		Butcher(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)
	if(DOING_INTERACTION_WITH_TARGET(user, H))
		to_chat(user, span_warning("You're already interacting with [H]!"))
		return

	user.visible_message(span_danger("[user] is slitting [H]'s throat!"), \
					span_danger("You start slicing [H]'s throat!"), \
					span_hear("You hear a cutting noise!"))
	H.show_message(span_userdanger("Your throat is being slit by [user]!"), 1, \
					span_userdanger("Something is cutting into your neck!"), NONE)
	log_combat(user, H, "attempted throat slitting", source)

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	var/item_force = source.force
	if(!item_force) //Division by 0 protection
		item_force = 1
	if(do_after(user, clamp(500 / item_force, 30, 100), H) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message(span_danger("[H]'s neck has already been already cut, you can't make the bleeding any worse!"), 1, span_danger("Their neck has already been already cut, you can't make the bleeding any worse!"))
			return

		H.visible_message(span_danger("[user] slits [H]'s throat!"), \
					span_userdanger("[user] slits your throat..."))
		H.apply_damage(item_force, BRUTE, BODY_ZONE_HEAD)
		H.add_bleeding(BLEED_CRITICAL)
		H.apply_status_effect(/datum/status_effect/neck_slice)

/datum/component/butchering/proc/Butcher(mob/living/butcher, mob/living/meat)
	var/turf/T = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	for(var/V in meat.butcher_results)
		var/obj/bones = V
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, span_warning("You fail to harvest some of the [initial(bones.name)] from [meat]."))
			else if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, span_info("You harvest some extra [initial(bones.name)] from [meat]!"))
				for(var/i in 1 to 2)
					new bones (T)
			else
				new bones (T)
		meat.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib
	for(var/V in meat.guaranteed_butcher_results)
		var/obj/sinew = V
		var/amount = meat.guaranteed_butcher_results[sinew]
		for(var/i in 1 to amount)
			new sinew (T)
		meat.guaranteed_butcher_results.Remove(sinew)
	if(butcher)
		butcher.visible_message(span_notice("[butcher] butchers [meat]."), \
								span_notice("You butcher [meat]."))
	ButcherEffects(meat)
	meat.harvest(butcher)
	meat.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	meat.investigate_log("was gibbed via butchering", INVESTIGATE_DEATHS)
	meat.gib(FALSE, FALSE, TRUE)

/datum/component/butchering/proc/ButcherEffects(mob/living/meat) //extra effects called on butchering, override this via subtypes
	return

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler

/datum/component/butchering/recycler/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, loc_connections)

/datum/component/butchering/recycler/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/victim = arrived
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.machine_stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(victim.stat == DEAD && (victim.butcher_results || victim.guaranteed_butcher_results))
		Butcher(parent, victim)
