///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS
	layers = EXTERNAL_BEHIND | EXTERNAL_ADJACENT | EXTERNAL_FRONT
	flight_level = WINGS_COSMETIC
	var/basewings = "wings" //right now, this just determines whether the wings are normal wings or moth wings, for wingopening purposes
	var/canopen = TRUE
	var/wingsound = null

	///The flight action object
	var/datum/action/innate/flight/fly

	///The preference type for opened wings
	var/wings_open_preference = "wingsopen"
	///The preference type for closed wings
	var/wings_closed_preference = "wings"

	///Are our wings open or closed?
	var/wings_open = FALSE

	preference = "wings"

/obj/item/organ/external/wings/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!human.wear_suit)
		return TRUE
	if(human.wear_suit.flags_inv & ~HIDEJUMPSUIT)
		return TRUE
	if(human.wear_suit.species_exception && is_type_in_list(src, human.wear_suit.species_exception))
		return TRUE
	return FALSE

/obj/item/organ/external/wings/get_global_feature_list()
	if(wings_open)
		return GLOB.wings_open_list
	else
		return GLOB.wings_list

/obj/item/organ/external/wings/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()

	if(isnull(fly))
		fly = new
		fly.Grant(reciever)

/obj/item/organ/external/wings/Remove(mob/living/carbon/organ_owner, special)
	. = ..()

	fly.Remove(organ_owner)

/obj/item/organ/external/wings/on_life(delta_time, times_fired)
	. = ..()

	handle_flight(owner)

///Called on_life(). Handle flight code and check if we're still flying
/obj/item/organ/external/wings/proc/handle_flight(mob/living/carbon/human/human)
	if(human.movement_type & ~FLYING)
		return FALSE
	if(!can_fly(human))
		toggle_flight(human)
		return FALSE
	return TRUE


///Check if we're still eligible for flight (wings covered, atmosphere too thin, etc)
/obj/item/organ/external/wings/proc/can_fly(mob/living/carbon/human/human)
	if(human.stat || human.body_position == LYING_DOWN)
		return FALSE
	//Jumpsuits have tail holes, so it makes sense they have wing holes too
	if(human.wear_suit && ((human.wear_suit.flags_inv & HIDEJUMPSUIT) && (!human.wear_suit.species_exception || !is_type_in_list(src, human.wear_suit.species_exception))))
		to_chat(human, span_warning("Your suit blocks your wings from extending!"))
		return FALSE
	var/turf/location = get_turf(human)
	if(!location)
		return FALSE

	var/datum/gas_mixture/environment = location.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(human, span_warning("The atmosphere is too thin for you to fly!"))
		return FALSE
	else
		return TRUE

///Slipping but in the air?
/obj/item/organ/external/wings/proc/fly_slip(mob/living/carbon/human/human)
	var/obj/buckled_obj
	if(human.buckled)
		buckled_obj = human.buckled

	to_chat(human, span_notice("Your wings spazz out and launch you!"))

	playsound(human.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

	for(var/obj/item/choking_hazard in human.held_items)
		human.accident(choking_hazard)

	var/olddir = human.dir

	human.stop_pulling()
	if(buckled_obj)
		buckled_obj.unbuckle_mob(human)
		step(buckled_obj, olddir)
	else
		new /datum/forced_movement(human, get_ranged_target_turf(human, olddir, 4), 1, FALSE, CALLBACK(human, /mob/living/carbon/.proc/spin, 1, 1))
	return TRUE

///UNSAFE PROC, should only be called through the Activate or other sources that check for CanFly
/obj/item/organ/external/wings/proc/toggle_flight(mob/living/carbon/human/human)
	if(!HAS_TRAIT_FROM(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT))
		human.physiology.stun_mod *= 2
		ADD_TRAIT(human, TRAIT_NO_FLOATING_ANIM, SPECIES_FLIGHT_TRAIT)
		ADD_TRAIT(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		passtable_on(human, SPECIES_TRAIT)
		open_wings()
	else
		human.physiology.stun_mod *= 0.5
		REMOVE_TRAIT(human, TRAIT_NO_FLOATING_ANIM, SPECIES_FLIGHT_TRAIT)
		REMOVE_TRAIT(human, TRAIT_MOVE_FLYING, SPECIES_FLIGHT_TRAIT)
		passtable_off(human, SPECIES_TRAIT)
		close_wings()

///SPREAD OUR WINGS AND FLLLLLYYYYYY
/obj/item/organ/external/wings/proc/open_wings()
	preference = wings_open_preference
	wings_open = TRUE

	cache_key = generate_icon_cache() //we've changed preference to open, so we only need to update the key and ask for an update to change our sprite
	owner.update_body_parts()

///close our wings
/obj/item/organ/external/wings/proc/close_wings()
	preference = wings_closed_preference
	wings_open = FALSE

	cache_key = generate_icon_cache()
	owner.update_body_parts()
	if(isturf(owner?.loc))
		var/turf/location = loc
		location.Entered(src, NONE)

///hud action for starting and stopping flight
/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_IMMOBILE
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/human = owner
	var/obj/item/organ/external/wings/wings = human.getorganslot(ORGAN_SLOT_EXTERNAL_WINGS)
	if(wings && wings.can_fly(human))
		wings.toggle_flight(human)
		if(!(human.movement_type & FLYING))
			to_chat(human, span_notice("You settle gently back onto the ground..."))
		else
			to_chat(human, span_notice("You beat your wings and begin to hover gently above the ground..."))
			human.set_resting(FALSE, TRUE)

///Moth wings! They can flutter in low-grav and burn off in heat
/obj/item/organ/external/wings/moth
	preference = "moth_wings"
	layers = EXTERNAL_BEHIND | EXTERNAL_FRONT

	dna_block = DNA_MOTH_WINGS_BLOCK

	///Are we burned?
	var/burnt = FALSE
	///Store our old sprite here for if our burned wings are healed
	var/original_sprite = ""

/obj/item/organ/external/wings/moth/get_global_feature_list()
	return GLOB.moth_wings_list

/obj/item/organ/external/wings/moth/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()

	RegisterSignal(reciever, COMSIG_HUMAN_BURNING, .proc/try_burn_wings)
	RegisterSignal(reciever, COMSIG_LIVING_POST_FULLY_HEAL, .proc/heal_wings)
	RegisterSignal(reciever, COMSIG_MOVABLE_PRE_MOVE, .proc/update_float_move)

/obj/item/organ/external/wings/moth/Remove(mob/living/carbon/organ_owner, special)
	. = ..()

	UnregisterSignal(organ_owner, list(COMSIG_HUMAN_BURNING, COMSIG_LIVING_POST_FULLY_HEAL, COMSIG_MOVABLE_PRE_MOVE))
	REMOVE_TRAIT(organ_owner, TRAIT_FREE_FLOAT_MOVEMENT, src)

///For moth antennae and wings we make an exception. If their features are burnt, we only update our original sprite
/obj/item/organ/external/wings/moth/set_sprite(sprite)
	if(!burnt)
		return ..() //no one listens to the return value, I just need to call the parent proc and end the code

	original_sprite = sprite

///Check if we can flutter around
/obj/item/organ/external/wings/moth/proc/update_float_move()
	SIGNAL_HANDLER

	if(!isspaceturf(owner.loc) && !burnt)
		var/datum/gas_mixture/current = owner.loc.return_air()
		if(current && (current.return_pressure() >= ONE_ATMOSPHERE*0.85)) //as long as there's reasonable pressure and no gravity, flight is possible
			ADD_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, src)
			return

	REMOVE_TRAIT(owner, TRAIT_FREE_FLOAT_MOVEMENT, src)

///check if our wings can burn off ;_;
/obj/item/organ/external/wings/moth/proc/try_burn_wings(mob/living/carbon/human/human)
	SIGNAL_HANDLER

	if(!burnt && human.bodytemperature >= 800 && human.fire_stacks > 0) //do not go into the extremely hot light. you will not survive
		to_chat(human, span_danger("Your precious wings burn to a crisp!"))
		SEND_SIGNAL(human, COMSIG_ADD_MOOD_EVENT, "burnt_wings", /datum/mood_event/burnt_wings)

		burn_wings()
		human.update_body_parts()

///burn the wings off
/obj/item/organ/external/wings/moth/proc/burn_wings()
	burnt = TRUE

	original_sprite = sprite_datum.name
	set_sprite("Burnt Off")

///heal our wings back up!!
/obj/item/organ/external/wings/moth/proc/heal_wings()
	SIGNAL_HANDLER

	if(burnt)
		burnt = FALSE
		set_sprite(original_sprite)






























////////










































/obj/item/organ/wings/Initialize(mapload)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		Refresh(H)

/obj/item/organ/wings/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		Refresh(H)

/obj/item/organ/wings/proc/Refresh(mob/living/carbon/human/H)
	H.dna.species.mutant_bodyparts -= "[basewings]open"
	if(!(H.dna.species.mutant_bodyparts[basewings]))
		H.dna.species.mutant_bodyparts |= basewings
		H.dna.features[basewings] = wing_type
		H.update_body()
	if(flight_level >= WINGS_FLYING)
		fly = new
		fly.Grant(H)
	else if(fly)
		fly.Remove(H)
		QDEL_NULL(fly)
		if(H.movement_type & FLYING)
			H.dna.species.toggle_flight(H)

/obj/item/organ/wings/Remove(mob/living/carbon/human/H,  special = 0, pref_load = FALSE)
	..()
	

/obj/item/organ/wings/proc/toggleopen(mob/living/carbon/human/H) //opening and closing wings are purely cosmetic
	if(!canopen)
		return FALSE
	if(wingsound)
		playsound(H, wingsound, 100, 7)
	if(basewings == "wings" || basewings == "moth_wings")
		if(H.dna.species.mutant_bodyparts["wings"])
			H.dna.species.mutant_bodyparts -= "wings"
			H.dna.species.mutant_bodyparts |= "wingsopen"
		else if(H.dna.species.mutant_bodyparts["wingsopen"])
			H.dna.species.mutant_bodyparts -= "wingsopen"
			H.dna.species.mutant_bodyparts |= "wings"
		else if(H.dna.species.mutant_bodyparts["moth_wings"])
			H.dna.species.mutant_bodyparts |= "moth_wingsopen"
			H.dna.species.mutant_bodyparts -= "moth_wings"
		else if(H.dna.species.mutant_bodyparts["moth_wingsopen"])
			H.dna.species.mutant_bodyparts -= "moth_wingsopen"
			H.dna.species.mutant_bodyparts |= "moth_wings"
		else //it appears we don't actually have wing icons. apply them!!
			Refresh(H)
		H.update_body()
		return TRUE
	return FALSE

/obj/item/organ/wings/cybernetic
	name = "cybernetic wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	icon_state = "wingpack"
	flight_level = WINGS_FLYING
	wing_type = "Robot"
	wingsound = 'sound/items/change_jaws.ogg'
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/wings/cybernetic/emp_act(severity)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/species/S = H.dna.species
		var/outofcontrol = ((rand(1, 10)) * severity)
		to_chat(H, "<span_class = 'userdanger'>You lose control of your [src]!</span>")
		while(outofcontrol)
			if(S.CanFly(H))
				if(H.movement_type & FLYING)
					var/throw_dir = pick(GLOB.alldirs)
					var/atom/throw_target = get_edge_target_turf(H, throw_dir)
					H.throw_at(throw_target, 5, 4)
					if(prob(10))
						S.toggle_flight(H)
				else
					S.toggle_flight(H)
					if(prob(50))
						stoplag(5)
						S.toggle_flight(H)
			else
				H.Togglewings()
			outofcontrol --
			stoplag(5)

/obj/item/organ/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	flight_level = WINGS_MAGIC

/obj/item/organ/wings/moth
	name = "pair of moth wings"
	desc = "A pair of moth wings."
	icon_state = "mothwings"
	flight_level = WINGS_FLIGHTLESS
	basewings = "moth_wings"
	wing_type = "Plain"
	canopen = TRUE

/obj/item/organ/wings/moth/robust
	desc = "A pair of moth wings. They look robust enough to fly in an atmosphere"
	flight_level = WINGS_FLYING

/obj/item/organ/wings/moth/on_life()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(flight_level >= WINGS_FLIGHTLESS && H.bodytemperature >= 800 && H.fire_stacks > 0)
			flight_level = WINGS_COSMETIC
			if((H.movement_type & FLYING))//Closes wings if they're open and flying
				var/datum/species/S = H.dna.species
				S.toggle_flight(H)
			to_chat(H, "<span class='danger'>Your precious wings burn to a crisp!</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "burnt_wings", /datum/mood_event/burnt_wings)
			ADD_TRAIT(H, TRAIT_MOTH_BURNT, "fire")
			H.dna.species.handle_mutant_bodyparts(H)
			H.dna.species.handle_body(H)


/obj/item/organ/wings/angel
	name = "pair of feathered wings"
	desc = "A pair of feathered wings. They seem robust enough for flight"
	flight_level = WINGS_FLYING

/obj/item/organ/wings/dragon
	name = "pair of dragon wings"
	desc = "A pair of dragon wings. They seem robust enough for flight"
	icon_state = "dragonwings"
	flight_level = WINGS_FLYING
	wing_type = "Dragon"

/obj/item/organ/wings/dragon/fake
	desc = "A pair of fake dragon wings. They're useless"
	flight_level = WINGS_COSMETIC

/obj/item/organ/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown"
	icon_state = "beewings"
	flight_level = WINGS_COSMETIC
	actions_types = list(/datum/action/item_action/organ_action/use/bee_dash)
	wing_type = "Bee"
	var/jumpdist = 3

/obj/item/organ/wings/bee/Remove(mob/living/carbon/human/H, special, pref_load = FALSE)
	jumpdist = initial(jumpdist)
	return ..()

/datum/action/item_action/organ_action/use/bee_dash
	var/jumpspeed = 1
	var/recharging_rate = 100
	var/recharging_time = 0

/datum/action/item_action/organ_action/use/bee_dash/Trigger()
	var/mob/living/carbon/L = owner
	var/obj/item/organ/wings/bee/wings = locate(/obj/item/organ/wings/bee) in L.internal_organs
	var/jumpdistance = wings.jumpdist

	if(L.stat != CONSCIOUS || L.buckled) // Has to be conscious and unbuckled
		return
	if(recharging_time > world.time)
		to_chat(L, "<span class='warning'>The wings aren't ready to dash yet!</span>")
		return
	var/datum/gas_mixture/environment = L.loc.return_air()
	if(environment && !(environment.return_pressure() > 30))
		to_chat(L, "<span class='warning'>The atmosphere is too thin for you to dash!</span>")
		return

	var/turf/target = get_edge_target_turf(L, L.dir) //represents the user's direction
	var/hoppingtable = FALSE // Triggers the trip
	var/jumpdistancemoved = jumpdistance // temp jumpdistance
	var/turf/checkjump = get_turf(L)

	for(var/i in 1 to jumpdistance) //This is how hiero club find the tiles in front of it, tell me/fix it if there's a better way
		var/turf/T = get_step(checkjump, L.dir)
		if(T.density || !T.ClickCross(invertDir(L.dir), border_only = 1))
			break
		if(locate(/obj/structure/table) in T) // If there's a table, trip
			hoppingtable = TRUE
			jumpdistancemoved = i
			break
		if(!T.ClickCross(L.dir)) // Check for things other than tables that would block flight at the T turf
			break
		checkjump = get_step(checkjump, L.dir)

	var/datum/callback/crashcallback
	if(hoppingtable)
		crashcallback = CALLBACK(src, PROC_REF(crash_into_table), get_step(checkjump, L.dir))
	if(L.throw_at(target, jumpdistancemoved, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = crashcallback, force = MOVE_FORCE_WEAK))
		playsound(L, 'sound/creatures/bee.ogg', 50, 1, 1)
		L.visible_message("<span class='warning'>[usr] dashes forward into the air!</span>")
		recharging_time = world.time + recharging_rate
	else
		to_chat(L, "<span class='warning'>Something prevents you from dashing forward!</span>")

/datum/action/item_action/organ_action/use/bee_dash/proc/crash_into_table(turf/tableturf)
	if(owner.loc == tableturf)
		var/mob/living/carbon/L = owner
		L.take_bodypart_damage(10,check_armor = TRUE)
		L.Paralyze(40)
		L.visible_message("<span class='danger'>[L] crashes into a table, falling over!</span>",\
			"<span class='userdanger'>You violently crash into a table!</span>")
		playsound(src,'sound/weapons/punch1.ogg',50,1)

/datum/action/innate/flight
	name = "Toggle Flight"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "flight"

/datum/action/innate/flight/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/S = H.dna.species
	if(S.CanFly(H))
		S.toggle_flight(H)
		if(!(H.movement_type & FLYING))
			to_chat(H, "<span class='notice'>You settle gently back onto the ground...</span>")
		else
			to_chat(H, "<span class='notice'>You beat your wings and begin to hover gently above the ground...</span>")
			H.set_resting(FALSE, TRUE)
