/// Deals extra damage to mobs of a certain type, species, or biotype.
/// This doesn't directly modify the normal damage of the weapon, instead it applies it's own damage seperatedly ON TOP of normal damage
/// ie. a sword that does 10 damage with a bane elment attacthed that has a 0.5 damage_multiplier will do:
/// 10 damage from the swords normal attack + 5 damage (50%) from the bane element
/datum/element/bane
	element_flags = ELEMENT_DETACH|ELEMENT_BESPOKE
	id_arg_index = 2
	/// can be a mob or a species.
	var/target_type
	/// multiplier of the extra damage based on the force of the item.
	var/damage_multiplier
	/// Added after the above.
	var/added_damage
	/// If it requires harm intent to deal the extra damage or not.
	var/requires_harm_intent
	/// if we want it to only affect a certain mob biotype
	var/mob_biotypes

/datum/element/bane/Attach(datum/target, target_type = /mob/living, mob_biotypes = NONE, damage_multiplier=1, added_damage = 0, requires_harm_intent = TRUE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	if(ispath(target_type, /mob/living))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(mob_check))
	else if(ispath(target_type, /datum/species))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(species_check))
	else
		return ELEMENT_INCOMPATIBLE

	src.target_type = target_type
	src.damage_multiplier = damage_multiplier
	src.added_damage = added_damage
	src.requires_harm_intent = requires_harm_intent
	src.mob_biotypes = mob_biotypes

/datum/element/bane/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	return ..()

/datum/element/bane/proc/species_check(obj/item/source, mob/living/target,, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag || !istype(target) || !is_species(target, target_type))
		return

	var/is_correct_biotype = target.mob_biotypes & mob_biotypes
	if(mob_biotypes && !(is_correct_biotype))
		return

	activate(source, target, user)

/datum/element/bane/proc/mob_check(obj/item/source, mob/living/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag || !istype(target, target_type))
		return

	var/is_correct_biotype = target.mob_biotypes & mob_biotypes
	if(mob_biotypes && !(is_correct_biotype))
		return

	activate(source, target, user)

/datum/element/bane/proc/activate(obj/item/source, mob/living/target, mob/living/attacker)
	if(requires_harm_intent && !attacker.a_intent == INTENT_HARM)
		return

	var/extra_damage = max(0, (source.force * damage_multiplier) + added_damage)
	target.apply_damage(extra_damage, source.damtype, attacker.zone_selected)
	SEND_SIGNAL(target, COMSIG_LIVING_BANED, source, attacker) // for extra effects when baned.
