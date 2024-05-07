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
	/// Callback for butchering
	var/datum/callback/butcher_callback

/datum/component/butchering/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	src.speed = speed
	src.effectiveness = effectiveness
	src.bonus_modifier = bonus_modifier
	src.butcher_sound = butcher_sound
	if(disabled)
		src.butchering_enabled = FALSE
	src.can_be_blunt = can_be_blunt
	src.butcher_callback = butcher_callback
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(onItemAttack))

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	if(user.a_intent == INTENT_HARM && M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.is_sharp()))
			INVOKE_ASYNC(src, PROC_REF(startButcher), source, M, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(M) && source.force && source.is_sharp())
		var/mob/living/carbon/human/H = M
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message("<span class='danger'>[H]'s neck has already been already cut, you can't make the bleeding any worse!", 1, \
							"<span class='danger'>Their neck has already been already cut, you can't make the bleeding any worse!")
			return COMPONENT_CANCEL_ATTACK_CHAIN
		if((H.health <= H.crit_threshold || (user.pulling == H && user.grab_state >= GRAB_NECK) || H.IsSleeping())) // Only sleeping, neck grabbed, or crit, can be sliced.
			INVOKE_ASYNC(src, PROC_REF(startNeckSlice), source, H, user)
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, "<span class='notice'>You begin to butcher [M]...</span>")
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_after(user, speed, M) && M.Adjacent(source))
		on_butchering(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)

	user.visible_message("<span class='danger'>[user] is slitting [H]'s throat!</span>", \
					"<span class='danger'>You start slicing [H]'s throat!</span>", \
					"<span class='hear'>You hear a cutting noise!</span>")
	H.show_message("<span class='userdanger'>Your throat is being slit by [user]!</span>", 1, \
					"<span class = 'userdanger'>Something is cutting into your neck!</span>", NONE)

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	var/item_force = source.force
	if(!item_force) //Division by 0 protection
		item_force = 1
	if(do_after(user, clamp(500 / item_force, 30, 100), H) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message("<span class='danger'>[H]'s neck has already been already cut, you can't make the bleeding any worse!", 1, \
							"<span class='danger'>Their neck has already been already cut, you can't make the bleeding any worse!")
			return

		H.visible_message("<span class='danger'>[user] slits [H]'s throat!</span>", \
					"<span class='userdanger'>[user] slits your throat...</span>")
		H.apply_damage(item_force, BRUTE, BODY_ZONE_HEAD)
		H.bleed_rate = clamp(H.bleed_rate + 20, 0, 30)
		H.apply_status_effect(/datum/status_effect/neck_slice)

/datum/component/butchering/proc/on_butchering(atom/butcher, mob/living/meat)
	var/turf/T = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	for(var/V in meat.butcher_results)
		var/obj/bones = V
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, "<span class='warning'>You fail to harvest some of the [initial(bones.name)] from [meat].</span>")
			else if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, "<span class='info'>You harvest some extra [initial(bones.name)] from [meat]!</span>")
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
		butcher.visible_message("<span class='notice'>[butcher] butchers [meat].</span>", \
								"<span class='notice'>You butcher [meat].</span>")
	butcher_callback?.Invoke(butcher, meat)
	meat.harvest(butcher)
	meat.log_message("has been butchered by [key_name(butcher)]", LOG_ATTACK)
	meat.investigate_log("was gibbed via butchering", INVESTIGATE_DEATHS)
	meat.gib(FALSE, FALSE, TRUE)

///Enables the butchering mechanic for the mob who has equipped us.
/datum/component/butchering/proc/enable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = TRUE

///Disables the butchering mechanic for the mob who has dropped us.
/datum/component/butchering/proc/disable_butchering(datum/source)
	SIGNAL_HANDLER
	butchering_enabled = FALSE

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler


/datum/component/butchering/recycler/Initialize(
	speed,
	effectiveness,
	bonus_modifier,
	butcher_sound,
	disabled,
	can_be_blunt,
	butcher_callback,
)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
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
		on_butchering(parent, victim)

/datum/component/butchering/mecha

/datum/component/butchering/mecha/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_ATTACHED, .proc/enable_butchering)
	RegisterSignal(parent, COMSIG_MECHA_EQUIPMENT_DETACHED, .proc/disable_butchering)
	RegisterSignal(parent, COMSIG_MECHA_DRILL_MOB, .proc/on_drill)

/datum/component/butchering/mecha/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MECHA_DRILL_MOB,
		COMSIG_MECHA_EQUIPMENT_ATTACHED,
		COMSIG_MECHA_EQUIPMENT_DETACHED,
	))

///When we are ready to drill through a mob
/datum/component/butchering/mecha/proc/on_drill(datum/source, obj/mecha/chassis, mob/living/meat)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/on_butchering, chassis, meat)

/datum/component/butchering/wearable

/datum/component/butchering/wearable/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/worn_enable_butchering)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/worn_disable_butchering)

/datum/component/butchering/wearable/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))

///Same as enable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_enable_butchering(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	//check if the item is being not worn
	if(!(slot & source.slot_flags))
		return
	butchering_enabled = TRUE
	RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/butcher_target)

///Same as disable_butchering but for worn items
/datum/component/butchering/wearable/proc/worn_disable_butchering(obj/item/source, mob/user)
	SIGNAL_HANDLER
	butchering_enabled = FALSE
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/datum/component/butchering/wearable/proc/butcher_target(mob/user, atom/target, proximity)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	onItemAttack(parent, target, user)
