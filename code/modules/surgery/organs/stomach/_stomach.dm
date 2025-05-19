//The contant in the rate of reagent transfer on life ticks
#define STOMACH_METABOLISM_CONSTANT 0.5

/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb_continuous = list("gores", "squishes", "slaps", "digests")
	attack_verb_simple = list("gore", "squish", "slap", "digest")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = span_info("Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.")
	high_threshold_passed = span_warning("Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!")
	high_threshold_cleared = span_info("The pain in your stomach dies down for now, but food still seems unappealing.")
	low_threshold_cleared = span_info("The last bouts of pain in your stomach have died out.")

	//This is a reagent user and needs more then the 10u from edible component
	reagent_vol = 1000

	///The rate that disgust decays
	var/disgust_metabolism = 1

	///The rate that the stomach will transfer reagents to the body
	var/metabolism_efficiency = 0.1 // the lowest we should go is 0.05

/obj/item/organ/stomach/on_life(delta_time, times_fired)
	. = ..()

	//Manage species digestion
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/humi = owner
		if(!(organ_flags & ORGAN_FAILING))
			handle_hunger(humi, delta_time, times_fired)

	var/mob/living/carbon/body = owner

	// digest food, sent all reagents that can metabolize to the body
	for(var/chunk in reagents.reagent_list)
		var/datum/reagent/bit = chunk

		// If the reagent does not metabolize then it will sit in the stomach
		// This has an effect on items like plastic causing them to take up space in the stomach
		if(!(bit.metabolization_rate > 0))
			continue

		//Ensure that the the minimum is equal to the metabolization_rate of the reagent if it is higher then the STOMACH_METABOLISM_CONSTANT
		var/amount_min = max(bit.metabolization_rate, STOMACH_METABOLISM_CONSTANT)
		//Do not transfer over more then we have
		var/amount_max = bit.volume

		//If the reagent is part of the food reagents for the organ
		//prevent all the reagents form being used leaving the food reagents
		var/amount_food = food_reagents[bit.type]
		if(amount_food)
			amount_max = max(amount_max - amount_food, 0)

		// Transfer the amount of reagents based on volume with a min amount of 1u
		var/amount = min(round(metabolism_efficiency * bit.volume, 0.1) + amount_min, amount_max)

		if(!(amount > 0))
			continue

		// transfer the reagents over to the body at the rate of the stomach metabolim
		// this way the body is where all reagents that are processed and react
		// the stomach manages how fast they are feed in a drip style
		reagents.trans_id_to(body, bit.type, amount=amount)

	//Handle disgust
	if(body)
		handle_disgust(body)

	//If the stomach is not damage exit out
	if(damage < low_threshold)
		return

	//We are checking if we have nutriment in a damaged stomach.
	var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in reagents.reagent_list
	//No nutriment found lets exit out
	if(!nutri)
		return

	//The stomach is damage has nutriment but low on theshhold, low prob of vomit
	if(prob(damage * 0.025 * nutri.volume * nutri.volume))
		body.vomit(damage)
		to_chat(body, "<span class='warning'>Your stomach reels in pain as you're incapable of holding down all that food!</span>")
		return

	// the change of vomit is now high
	if(damage > high_threshold && prob(damage * 0.1 * nutri.volume * nutri.volume))
		body.vomit(damage)
		to_chat(body, "<span class='warning'>Your stomach reels in pain as you're incapable of holding down all that food!</span>")

/obj/item/organ/stomach/proc/handle_hunger(mob/living/carbon/human/human, delta_time, times_fired)
	if(HAS_TRAIT(human, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(human, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(human.overeatduration < (200 SECONDS))
			to_chat(human, span_notice("You feel fit again!"))
			REMOVE_TRAIT(human, TRAIT_FAT, OBESITY)
			human.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
			human.update_inv_w_uniform()
			human.update_inv_wear_suit()
	else
		if(human.overeatduration >= (200 SECONDS))
			to_chat(human, span_danger("You suddenly feel blubbery!"))
			ADD_TRAIT(human, TRAIT_FAT, OBESITY)
			human.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
			human.update_inv_w_uniform()
			human.update_inv_wear_suit()

	// nutrition decrease and satiety
	if (human.nutrition > 0 && human.stat != DEAD)
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = human.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(1 - 0.002 * mood.sanity, 0.5) //0.85 to 0.75
		// Whether we cap off our satiety or move it towards 0
		if(human.satiety > MAX_SATIETY)
			human.satiety = MAX_SATIETY
		else if(human.satiety > 0)
			human.satiety--
		else if(human.satiety < -MAX_SATIETY)
			human.satiety = -MAX_SATIETY
		else if(human.satiety < 0)
			human.satiety++
			if(DT_PROB(round(-human.satiety/77), delta_time))
				human.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= human.physiology.hunger_mod
		human.adjust_nutrition(-hunger_rate * delta_time)

	if(human.nutrition > NUTRITION_LEVEL_FULL)
		if(human.overeatduration < 20 MINUTES) //capped so people don't take forever to unfat
			human.overeatduration = min(human.overeatduration + (1 SECONDS * delta_time), 20 MINUTES)
	else
		if(human.overeatduration > 0)
			human.overeatduration = max(human.overeatduration - (2 SECONDS * delta_time), 0) //doubled the unfat rate

	//metabolism change
	if(human.nutrition > NUTRITION_LEVEL_FAT)
		human.metabolism_efficiency = 1
	else if(human.nutrition > NUTRITION_LEVEL_FED && human.satiety > 80)
		if(human.metabolism_efficiency != 1.25)
			to_chat(human, span_notice("You feel vigorous."))
			human.metabolism_efficiency = 1.25
	else if(human.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(human.metabolism_efficiency != 0.8)
			to_chat(human, span_notice("You feel sluggish."))
		human.metabolism_efficiency = 0.8
	else
		if(human.metabolism_efficiency == 1.25)
			to_chat(human, span_notice("You no longer feel vigorous."))
		human.metabolism_efficiency = 1

	//Hunger slowdown for if mood isn't enabled
	if(CONFIG_GET(flag/disable_human_mood))
		handle_hunger_slowdown(human)

	switch(human.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			human.throw_alert("nutrition", /atom/movable/screen/alert/fat)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FULL)
			human.clear_alert("nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			human.throw_alert("nutrition", /atom/movable/screen/alert/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			human.throw_alert("nutrition", /atom/movable/screen/alert/starving)

///for when mood is disabled and hunger should handle slowdowns
/obj/item/organ/stomach/proc/handle_hunger_slowdown(mob/living/carbon/human/human)
	var/hungry = (500 - human.nutrition) / 5 //So overeat would be 100 and default level would be 80
	if(hungry >= 70)
		human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (hungry / 50))
	else
		human.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)

/obj/item/organ/stomach/get_availability(datum/species/S)
	return !(NOSTOMACH in S.species_traits)

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/H, delta_time, times_fired)
	if(H.disgust)
		var/pukeprob = 2.5 + (0.025 * H.disgust)
		if(H.disgust >= DISGUST_LEVEL_GROSS)
			if(DT_PROB(5, delta_time))
				H.stuttering += 1
				H.confused += 2
			if(DT_PROB(5, delta_time) && !H.stat)
				to_chat(H, span_warning("You feel kind of iffy..."))
			H.jitteriness = max(H.jitteriness - 3, 0)
		if(H.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(DT_PROB(pukeprob, delta_time)) //iT hAndLeS mOrE ThaN PukInG
				H.confused += 2.5
				H.stuttering += 1
				H.vomit(10, 0, 1, 0, 1, 0)
			H.Dizzy(5)
		if(H.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(DT_PROB(13, delta_time))
				H.blur_eyes(3) //We need to add more shit down here

		H.adjust_disgust(-0.25 * disgust_metabolism * delta_time)
	switch(H.disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			H.clear_alert("disgust")
			SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			H.throw_alert("disgust", /atom/movable/screen/alert/gross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			H.throw_alert("disgust", /atom/movable/screen/alert/verygross)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			H.throw_alert("disgust", /atom/movable/screen/alert/disgusted)
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/stomach_owner, special = 0, pref_load = FALSE)
	if(ishuman(stomach_owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.clear_alert("disgust")
		SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "nutrition")

	return ..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/fly/on_life()
	if(locate(/datum/reagent/consumable) in reagents.reagent_list)
		var/mob/living/carbon/body = owner
		// we do not loss any nutrition as a fly when vomiting out food
		body.vomit(0, FALSE, FALSE, 2, TRUE, force=TRUE, purge=TRUE)
		playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
		body.visible_message("<span class='danger'>[body] vomits on the floor!</span>", \
					"<span class='userdanger'>You throw up on the floor!</span>")
	return ..()

/obj/item/organ/stomach/bone
	desc = "You have no idea what this strange ball of bones does."

/obj/item/organ/stomach/bone/on_life()
	var/datum/reagent/consumable/milk/milk = locate(/datum/reagent/consumable/milk) in reagents.reagent_list
	if(milk)
		var/mob/living/carbon/body = owner
		if(milk.volume > 10)
			reagents.remove_reagent(milk.type, milk.volume - 10)
			to_chat(owner, "<span class='warning'>The excess milk is dripping off your bones!</span>")
		body.heal_bodypart_damage(1.5,0, 0)
		reagents.remove_reagent(milk.type, milk.metabolization_rate)
	return ..()

/obj/item/organ/stomach/plasmaman
	name = "digestive crystal"
	icon_state = "stomach-p"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."
	metabolism_efficiency = 0.12

/obj/item/organ/stomach/plasmaman/on_life()
	var/datum/reagent/consumable/milk/milk = locate(/datum/reagent/consumable/milk) in reagents.reagent_list
	if(milk)
		var/mob/living/carbon/body = owner
		if(milk.volume > 10)
			reagents.remove_reagent(milk.type, milk.volume - 10)
			to_chat(owner, "<span class='warning'>The excess milk is dripping off your bones!</span>")
		body.heal_bodypart_damage(1.5,0, 0)
		reagents.remove_reagent(milk.type, milk.metabolization_rate)
	return ..()

/obj/item/organ/stomach/cybernetic
	name = "basic cybernetic stomach"
	icon_state = "stomach-c"
	desc = "A basic device designed to mimic the functions of a human stomach"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5
	metabolism_efficiency = 0.7 // not as good at digestion

/obj/item/organ/stomach/cybernetic/upgraded
	name = "cybernetic stomach"
	icon_state = "stomach-c-u"
	desc = "An electronic device designed to mimic the functions of a human stomach. Handles disgusting food a bit better."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 2
	metabolism_efficiency = 0.14

/obj/item/organ/stomach/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		owner.vomit(stun = FALSE)

/obj/item/organ/stomach/diona
	name = "nutrient vessel"
	desc = "A group of plant matter and vines, useful for digestion of light and radiation."
	icon_state = "diona_stomach"

#undef STOMACH_METABOLISM_CONSTANT
