/datum/quirk/item_quirk/addict
	name = "Addict"
	desc = "You are addicted to something that doesn't exist. Suffer."
	icon = "pills"
	quirk_value = -1
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	lose_text = span_notice("You feel like you should kick your drug habit.")
	medical_record_text = "Patient has a history of hard drugs."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(/obj/effect/spawner/random/contraband/narcotics)
	var/list/drug_list = list(/datum/reagent/drug/crank, /datum/reagent/drug/krokodil, /datum/reagent/medicine/morphine, /datum/reagent/drug/happiness, /datum/reagent/drug/methamphetamine, /datum/reagent/drug/ketamine) //List of possible IDs
	var/datum/reagent/reagent_type //!If this is defined, reagent_id will be unused and the defined reagent type will be instead.
	var/datum/reagent/reagent_instance //! actual instanced version of the reagent
	var/obj/item/drug_container_type //! If this is defined before pill generation, pill generation will be skipped. This is the type of the pill bottle.
	var/obj/item/accessory_type //! If this is null, an accessory won't be spawned.
	var/drug_flavour_text = "Better hope you don't run out... of what, exactly? You don't know."
	var/process_interval = 30 SECONDS //! how frequently the quirk processes
	COOLDOWN_DECLARE(next_process) //! ticker for processing

/datum/quirk/item_quirk/addict/add_unique(client/client_source)

	if (!reagent_type)
		reagent_type = pick(drug_list)

	reagent_instance = new reagent_type()

	for(var/addiction in reagent_instance.addiction_types)
		quirk_holder.add_addiction_points(addiction, 1000) ///Max that shit out

	var/current_turf = get_turf(quirk_target)

	if (!drug_container_type)
		drug_container_type = /obj/item/storage/pill_bottle

	var/obj/item/drug_instance = new drug_container_type(get_turf(H))
	if (istype(drug_instance, /obj/item/storage/pill_bottle))
		var/pill_state = pick(PILL_SHAPE_LIST)
		for(var/i in 1 to 7)
			var/obj/item/reagent_containers/pill/pill = new(drug_instance)
			pill.icon_state = pill_state
			pill.reagents.add_reagent(reagent_type, 1)

	give_item_to_holder(
		drug_instance,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		),
		flavour_text = drug_flavour_text,
	)

	if(accessory_type)
		give_item_to_holder(
		accessory_type,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		)
	)

/datum/quirk/item_quirk/addict/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, next_process))
		return
	COOLDOWN_START(src, next_process, process_interval)
	var/deleted = QDELETED(reagent_instance)
	var/missing_addiction = FALSE
	for(var/addiction_type in reagent_instance.addiction_types)
		if(!LAZYACCESS(quirk_holder.active_addictions, addiction_type))
			missing_addiction = TRUE
	if(deleted || missing_addiction)
		if(deleted)
			reagent_instance = new reagent_type()
		to_chat(quirk_target, span_danger("You thought you kicked it, but you feel like you're falling back onto bad habits.."))
		for(var/addiction in reagent_instance.addiction_types)
			quirk_holder.add_addiction_points(addiction, 1000) ///Max that shit out

/datum/quirk/item_quirk/addict/junkie
	name = "Junkie"
	desc = "You can't get enough of hard drugs."
	icon = "pills"
	gain_text = span_danger("You suddenly feel the craving for drugs.")
	medical_record_text = "Patient has a history of hard drugs."
	mail_goodies = list(/obj/effect/spawner/random/contraband/narcotics)
	drug_flavour_text = "Better hope you don't run out..."

/datum/quirk/item_quirk/addict/junkie/add_to_holder(mob/living/new_holder, quirk_transfer = FALSE, client/client_source, unique = TRUE, announce = TRUE)
	if(!quirk_transfer)
		var/addiction = reagent_type || read_choice_preference(/datum/preference/choiced/quirk/junkie_drug)
		if(addiction && (addiction != "Random"))
			reagent_type = GLOB.possible_junkie_addictions[addiction]
	return ..()

/datum/quirk/item_quirk/addict/remove()
	if(!QDELETED(quirk_target) && reagent_instance)
		for(var/addiction_type in subtypesof(/datum/addiction))
			quirk_holder.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS)

/datum/quirk/item_quirk/addict/smoker
	name = "Smoker"
	desc = "Sometimes you just really want a smoke. Probably not great for your lungs."
	icon = "smoking"
	quirk_value = -1
	gain_text = span_danger("You could really go for a smoke right about now.")
	lose_text = span_notice("You don't feel nearly as hooked to nicotine anymore.")
	medical_record_text = "Patient is a current smoker."
	reagent_type = /datum/reagent/drug/nicotine
	accessory_type = /obj/item/lighter/greyscale
	mob_trait = TRAIT_SMOKER
	drug_flavour_text = "Make sure you get your favorite brand when you run out."
	mail_goodies = list(
		/obj/effect/spawner/random/entertainment/cigarette_pack,
		/obj/effect/spawner/random/entertainment/cigar,
		/obj/effect/spawner/random/entertainment/lighter,
		/obj/item/cigarette/pipe,
	)

/datum/quirk/item_quirk/addict/smoker/New()
	drug_container_type = GLOB.possible_smoker_addictions[pick(GLOB.possible_smoker_addictions)]
	return ..()

/datum/quirk/item_quirk/addict/smoker/add_unique(client/client_source)
	var/addiction = read_choice_preference(/datum/preference/choiced/quirk/smoker_cigarettes)
	if(addiction && (addiction != "Random"))
		drug_container_type = GLOB.possible_smoker_addictions[addiction]
	. = ..()

/datum/quirk/item_quirk/addict/smoker/post_add()
	..()
	// smoker lungs have 25% less health and healing
	var/mob/living/carbon/carbon_holder = quirk_target
	var/obj/item/organ/lungs/smoker_lungs = null
	var/obj/item/organ/lungs/old_lungs = carbon_holder.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(old_lungs && IS_ORGANIC_ORGAN(old_lungs))
		if(isplasmaman(carbon_holder))
			smoker_lungs = /obj/item/organ/lungs/plasmaman/plasmaman_smoker
		else
			smoker_lungs = /obj/item/organ/lungs/smoker_lungs
	if(!isnull(smoker_lungs))
		smoker_lungs = new smoker_lungs
		smoker_lungs.Insert(carbon_holder, special = TRUE, drop_if_replaced = FALSE)


/datum/quirk/item_quirk/addict/smoker/process()
	. = ..()
	var/mob/living/carbon/human/H = quirk_target
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_MASK)
	if (istype(I, /obj/item/cigarette))
		var/obj/item/storage/fancy/cigarettes/C = drug_container_type
		if(istype(I, initial(C.spawn_type)))
			SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "wrong_cigs")
			return
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "wrong_cigs", /datum/mood_event/wrong_brand)

/datum/quirk/item_quirk/addict/alcoholic
	name = "Alcoholic"
	desc = "You can't stand being sober."
	icon = "angry"
	quirk_value = -1
	gain_text = span_danger("You really need a drink.")
	lose_text = span_notice("Alcohol doesn't seem nearly as enticing anymore.")
	medical_record_text = "Patient is an alcoholic."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_PROCESSES
	mail_goodies = list(
		/obj/effect/spawner/random/food_or_drink/booze,
		/obj/item/book/bible/booze,
	)
	/// Cached typepath of the owner's favorite alcohol reagent
	var/datum/reagent/consumable/ethanol/favorite_alcohol

/datum/quirk/item_quirk/addict/alcoholic/New()
	var/random_alcohol = pick(GLOB.possible_alcoholic_addictions)
	drug_container_type = GLOB.possible_alcoholic_addictions[random_alcohol]["bottlepath"]
	favorite_alcohol = GLOB.possible_alcoholic_addictions[random_alcohol]["reagent"]
	return ..()

/datum/quirk/item_quirk/addict/alcoholic/add_unique(client/client_source)
	var/addiction = read_choice_preference(/datum/preference/choiced/quirk/alcohol_type)
	if(addiction && (addiction != "Random"))
		drug_container_type = GLOB.possible_alcoholic_addictions[addiction]["bottlepath"]
		favorite_alcohol = GLOB.possible_alcoholic_addictions[addiction]["reagent"]
	return ..()

/datum/quirk/item_quirk/addict/alcoholic/post_add()
	. = ..()
	RegisterSignal(quirk_target, COMSIG_MOB_REAGENT_TICK, PROC_REF(check_brandy))
	var/obj/item/reagent_containers/brandy_container = drug_container_type
	if(isnull(brandy_container))
		stack_trace("Alcoholic quirk added while the GLOB.possible_alcoholic_addictions is (somehow) not initialized!")
		brandy_container = new drug_container_type
		qdel(brandy_container)

	//quirk_target.add_mob_memory(/datum/memory/key/quirk_alcoholic, protagonist = quirk_target, preferred_brandy = initial(favorite_alcohol.name))
	// alcoholic livers have 25% less health and healing
	var/obj/item/organ/liver/alcohol_liver = quirk_target.get_organ_slot(ORGAN_SLOT_LIVER)
	if(alcohol_liver && IS_ORGANIC_ORGAN(alcohol_liver)) // robotic livers aren't affected
		alcohol_liver.maxHealth = alcohol_liver.maxHealth * 0.75
		alcohol_liver.healing_factor = alcohol_liver.healing_factor * 0.75

/datum/quirk/item_quirk/addict/alcoholic/remove()
	UnregisterSignal(quirk_target, COMSIG_MOB_REAGENT_TICK)

/datum/quirk/item_quirk/addict/alcoholic/proc/check_brandy(mob/source, datum/reagent/booze)
	SIGNAL_HANDLER

	//we don't care if it is not alcohol
	if(!istype(booze, /datum/reagent/consumable/ethanol))
		return


	if(istype(booze, favorite_alcohol))
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "wrong_alcohol")
	else
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "wrong_alcohol", /datum/mood_event/wrong_brandy)
