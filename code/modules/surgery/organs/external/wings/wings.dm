///Wing base type. doesn't really do anything
/obj/item/organ/external/wings
	name = "wings"
	desc = "Spread your wings and FLLLLLLLLYYYYY!"

	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_WINGS

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/wings

///Checks if the wings can soften short falls
/obj/item/organ/external/wings/proc/can_soften_fall()
	return TRUE

///Bodypart overlay of default wings. Does not have any wing functionality
/datum/bodypart_overlay/mutant/wings
	layers = ALL_EXTERNAL_OVERLAYS
	feature_key = "wings"

////////

/obj/item/organ/external/wings/cybernetic
	name = "cybernetic wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	icon_state = "wingpack"
	flight_level = WINGS_FLYING
	wing_type = "Robot"
	wingsound = 'sound/items/change_jaws.ogg'
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/external/wings/cybernetic/emp_act(severity)
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

/obj/item/organ/external/wings/cybernetic/ayy
	name = "advanced cybernetic wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	flight_level = WINGS_MAGIC

/obj/item/organ/external/wings/moth
	name = "pair of moth wings"
	desc = "A pair of moth wings."
	icon_state = "mothwings"
	flight_level = WINGS_FLIGHTLESS
	basewings = "moth_wings"
	wing_type = "Plain"
	canopen = TRUE

/obj/item/organ/external/wings/moth/Remove(mob/living/carbon/human/H, special, pref_load = FALSE)
	flight_level = initial(flight_level)
	return ..()

/obj/item/organ/external/wings/moth/robust
	desc = "A pair of moth wings. They look robust enough to fly in an atmosphere"
	flight_level = WINGS_FLYING

/obj/item/organ/external/wings/moth/on_life()
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


/obj/item/organ/external/wings/angel
	name = "pair of feathered wings"
	desc = "A pair of feathered wings. They seem robust enough for flight"
	flight_level = WINGS_FLYING

/obj/item/organ/external/wings/dragon
	name = "pair of dragon wings"
	desc = "A pair of dragon wings. They seem robust enough for flight"
	icon_state = "dragonwings"
	flight_level = WINGS_FLYING
	wing_type = "Dragon"

/obj/item/organ/external/wings/dragon/fake
	desc = "A pair of fake dragon wings. They're useless"
	flight_level = WINGS_COSMETIC

/obj/item/organ/external/wings/bee
	name = "pair of bee wings"
	desc = "A pair of bee wings. They seem tiny and undergrown"
	icon_state = "beewings"
	flight_level = WINGS_COSMETIC

	wing_type = "Bee"


/obj/item/organ/external/wings/bee/Remove(mob/living/carbon/human/H, special, pref_load = FALSE)
	jumpdist = initial(jumpdist)
	return ..()

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

*/
