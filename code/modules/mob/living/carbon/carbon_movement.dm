/mob/living/carbon/slip(knockdown_amount, obj/O, lube, paralyze, force_drop)
	if(movement_type & (FLYING | FLOATING))
		return FALSE
	if((lube & NO_SLIP_ON_CATWALK) && (locate(/obj/structure/lattice/catwalk) in get_turf(src)))
		return FALSE
	if(!(lube & SLIDE_ICE))
		log_combat(src, (O ? O : get_turf(src)), "slipped on the", null, ((lube & SLIDE) ? "(LUBE)" : null))
	return loc.handle_slip(src, knockdown_amount, O, lube, paralyze, force_drop)

/mob/living/carbon/Process_Spacemove(movement_dir = FALSE)
	if(..())
		return TRUE
	if(!isturf(loc))
		return FALSE

	// Do we have a jetpack implant (and is it on)?
	if(has_jetpack_power(movement_dir))
		return TRUE

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(. && !(movement_type & FLOATING)) //floating is easy
		if(HAS_TRAIT(src, TRAIT_NOHUNGER))
			set_nutrition(NUTRITION_LEVEL_FED - 1)	//just less than feeling vigorous
		else if(nutrition && stat != DEAD)
			adjust_nutrition(-(HUNGER_FACTOR/10))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(HUNGER_FACTOR/10))

/mob/living/carbon/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING | FLOATING) && !(old_movement_type & (FLYING | FLOATING)))
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_LIMBLESS, update=TRUE)
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

/mob/living/carbon/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING | FLOATING) && !(movement_type & (FLYING | FLOATING)))
		var/limbless_slowdown = 0
		if(get_num_legs() < default_num_legs)
			limbless_slowdown += (default_num_legs - get_num_legs()) * 3
			if(!get_num_legs())
				ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
				if(get_num_arms() < default_num_hands)
					limbless_slowdown += (default_num_hands - get_num_arms()) * 3
					if(!get_num_arms())
						ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(limbless_slowdown)
			add_movespeed_modifier(MOVESPEED_ID_LIVING_LIMBLESS, update=TRUE, priority=100, override=TRUE, multiplicative_slowdown = limbless_slowdown, movetypes=GROUND)
		else
			remove_movespeed_modifier(MOVESPEED_ID_LIVING_LIMBLESS, update=TRUE)
