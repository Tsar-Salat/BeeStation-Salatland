/obj/item/clothing/under
	name = "under"
	icon = 'icons/obj/clothing/under/default.dmi'
	worn_icon = 'icons/mob/clothing/under/default.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slot_flags = ITEM_SLOT_ICLOTHING
	armor_type = /datum/armor/clothing_under
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	//limb_integrity = 30 //Wounds

	/// Has this undersuit been freshly laundered and, as such, imparts a mood bonus for wearing
	var/freshly_laundered = FALSE

	// Alt style handling
	/// Can this suit be adjusted up or down to an alt style
	var/can_adjust = TRUE
	/// If adjusted what style are we currently using?
	var/adjusted = NORMAL_STYLE
	/// For adjusted/rolled-down jumpsuits. FALSE = exposes chest and arms, TRUE = exposes arms only
	var/alt_covers_chest = FALSE

	/// The variable containing the flags for how the woman uniform cropping is supposed to interact with the sprite.
	var/female_sprite_flags = FEMALE_UNIFORM_FULL

	// Sensor handling
	/// Does this undersuit have suit sensors in general
	var/has_sensor = HAS_SENSORS
	/// Does this undersuit spawn with a random sensor value
	var/random_sensor = TRUE
	/// What is the active sensor mode of this undersuit
	var/sensor_mode = NO_SENSORS

	// Accessory handling (Can be componentized eventually)
	/// The max number of accessories we can have on this suit.
	var/max_number_of_accessories = 5
	/// A list of all accessories attached to us.
	var/list/obj/item/clothing/accessory/attached_accessories
	/// The overlay of the accessory we're demonstrating. Only index 1 will show up.
	/// This is the overlay on the MOB, not the item itself.
	var/mutable_appearance/accessory_overlay
	dying_key = DYE_REGISTRY_UNDER


/datum/armor/clothing_under
	bio = 10
	bleed = 10

/obj/item/clothing/under/Initialize(mapload)
	. = ..()
	var/new_sensor_mode = sensor_mode
	sensor_mode = SENSOR_NOT_SET
	if(random_sensor)
		//make the sensor mode favor higher levels, except coords.
		new_sensor_mode = pick(SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS, SENSOR_COORDS)
	update_sensors(new_sensor_mode)
	AddElement(/datum/element/update_icon_updates_onmob)

/* Screentips
/obj/item/clothing/under/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = NONE

	if(isnull(held_item) && has_sensor == HAS_SENSORS)
		context[SCREENTIP_CONTEXT_RMB] = "Toggle suit sensors"
		. = CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/clothing/accessory) && length(attached_accessories) < max_number_of_accessories)
		context[SCREENTIP_CONTEXT_LMB] = "Attach accessory"
		. = CONTEXTUAL_SCREENTIP_SET

	if(LAZYLEN(attached_accessories))
		context[SCREENTIP_CONTEXT_ALT_RMB] = "Remove accessory"
		. = CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/stack/cable_coil) && has_sensor == BROKEN_SENSORS)
		context[SCREENTIP_CONTEXT_LMB] = "Repair suit sensors"
		. = CONTEXTUAL_SCREENTIP_SET

	if(can_adjust && adjusted != DIGITIGRADE_STYLE)
		context[SCREENTIP_CONTEXT_ALT_LMB] =  "Wear [adjusted == ALT_STYLE ? "normally" : "casually"]"
		. = CONTEXTUAL_SCREENTIP_SET

	return .
*/

/obj/item/clothing/under/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = list()
	if(isinhands)
		return

	if(damaged_clothes)
		. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform", item_layer +  0.0002)
	if(HAS_BLOOD_DNA(src))
		. += mutable_appearance('icons/effects/blood.dmi', "uniformblood", item_layer +  0.0002)
	if(accessory_overlay)
		accessory_overlay.layer = item_layer +  0.0001
		. += accessory_overlay

/obj/item/clothing/under/attackby(obj/item/attacking_item, mob/user, params)
	if(has_sensor == BROKEN_SENSORS && istype(attacking_item, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/cabling = attacking_item
		to_chat(user, span_notice("You repair the suit sensors on [src] with [cabling]."))
		cabling.use(1)
		has_sensor = HAS_SENSORS
		update_sensors(NO_SENSORS)
		return TRUE

	if(istype(attacking_item, /obj/item/clothing/accessory))
		return attach_accessory(attacking_item, user)

	return ..()

/obj/item/clothing/under/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	toggle()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/clothing/under/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	. = ..()
	if(damaged_state == CLOTHING_SHREDDED && has_sensor > NO_SENSORS)
		has_sensor = BROKEN_SENSORS
	else if(damaged_state == CLOTHING_PRISTINE && has_sensor == BROKEN_SENSORS)
		has_sensor = HAS_SENSORS
	update_sensors(NO_SENSORS)
	update_appearance()

/obj/item/clothing/under/Destroy()
	. = ..()
	if(ishuman(loc))
		update_sensors(SENSOR_OFF)

/obj/item/clothing/under/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(has_sensor == NO_SENSORS || has_sensor == BROKEN_SENSORS)
		return

	if(severity <= EMP_HEAVY)
		has_sensor = BROKEN_SENSORS
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,"<span class='warning'>[src]'s sensors short out!</span>")

	else
		var/new_sensor_mode = pick(SENSOR_OFF, SENSOR_OFF, SENSOR_OFF, SENSOR_LIVING, SENSOR_LIVING, SENSOR_VITALS, SENSOR_VITALS, SENSOR_COORDS)
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M,span_warning("The sensors on the [src] change rapidly!"))
		update_sensors(new_sensor_mode)

/obj/item/clothing/under/visual_equipped(mob/user, slot)
	. = ..()
	if(adjusted == ALT_STYLE)
		adjust_to_normal()

	if((supports_variations & DIGITIGRADE_VARIATION) && ishuman(user))
		var/mob/living/carbon/human/wearer = user
		if(wearer?.dna.species.bodytype & BODYTYPE_DIGITIGRADE)
			adjusted = DIGITIGRADE_STYLE
			update_appearance()

/obj/item/clothing/under/equipped(mob/living/user, slot)
	..()
	if((slot & ITEM_SLOT_ICLOTHING) && freshly_laundered)
		freshly_laundered = FALSE
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "fresh_laundry", /datum/mood_event/fresh_laundry)

/obj/item/clothing/under/dropped(mob/user)
	..()
	var/mob/living/carbon/human/H = user
	if(ishuman(H) || ismonkey(H))
		if(H.w_uniform == src)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS))
				return
			REMOVE_TRAIT(user, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
			if(!HAS_TRAIT(user, TRAIT_SUIT_SENSORS) && !HAS_TRAIT(user, TRAIT_NANITE_SENSORS))
				GLOB.suit_sensors_list -= user

// End suit sensor handling

/// Attach the passed accessory to the clothing item
/obj/item/clothing/under/proc/attach_accessory(obj/item/clothing/accessory/accessory, mob/living/user, attach_message = TRUE)
	if(!istype(accessory))
		return
	if(length(attached_accessories) >= max_number_of_accessories)
		if(user)
			balloon_alert(user, "too many accessories!")
		return

	if(!accessory.can_attach_accessory(src, user))
		return
	if(user && !user.temporarilyRemoveItemFromInventory(accessory))
		return
	if(!accessory.attach(src, user))
		return

	LAZYADD(attached_accessories, accessory)
	accessory.forceMove(src)
	// Allow for accessories to react to the acccessory list now
	accessory.successful_attach(src)

	if(user && attach_message)
		balloon_alert(user, "accessory attached")

	if(isnull(accessory_overlay))
		create_accessory_overlay()

	update_appearance()
	return TRUE

/// Removes (pops) the topmost accessory from the accessories list and puts it in the user's hands if supplied
/obj/item/clothing/under/proc/pop_accessory(mob/living/user, attach_message = TRUE)
	var/obj/item/clothing/accessory/popped_accessory = attached_accessories[1]
	remove_accessory(popped_accessory)

	if(!user)
		return

	user.put_in_hands(popped_accessory)
	if(attach_message)
		popped_accessory.balloon_alert(user, "accessory removed")

/// Removes the passed accesory from our accessories list
/obj/item/clothing/under/proc/remove_accessory(obj/item/clothing/accessory/removed)
	if(removed == attached_accessories[1])
		accessory_overlay = null

	// Remove it from the list before detaching
	LAZYREMOVE(attached_accessories, removed)
	removed.detach(src)

	if(isnull(accessory_overlay) && LAZYLEN(attached_accessories))
		create_accessory_overlay()

	update_appearance()

/// Handles creating the worn overlay mutable appearance
/// Only the first accessory attached is displayed (currently)
/obj/item/clothing/under/proc/create_accessory_overlay()
	var/obj/item/clothing/accessory/prime_accessory = attached_accessories[1]
	accessory_overlay = mutable_appearance(prime_accessory.worn_icon, prime_accessory.icon_state)
	accessory_overlay.alpha = prime_accessory.alpha
	accessory_overlay.color = prime_accessory.color

/obj/item/clothing/under/Exited(atom/movable/gone, direction)
	. = ..()
	// If one of our accessories was moved out, handle it
	if(gone in attached_accessories)
		remove_accessory(gone)

/// Helper to remove all attachments to the passed location
/obj/item/clothing/under/proc/dump_attachments(atom/drop_to = drop_location())
	for(var/obj/item/clothing/accessory/worn_accessory as anything in attached_accessories)
		remove_accessory(worn_accessory)
		worn_accessory.forceMove(drop_to)

/obj/item/clothing/under/atom_destruction(damage_flag)
	dump_attachments()
	return ..()

/obj/item/clothing/under/Destroy()
	QDEL_LAZYLIST(attached_accessories)
	return ..()

//Adds or removes mob from suit sensor global list
/obj/item/clothing/under/proc/update_sensors(new_mode, forced = FALSE)
	var/old_mode = sensor_mode
	sensor_mode = new_mode
	if(!forced && (old_mode == new_mode || (old_mode != SENSOR_OFF && new_mode != SENSOR_OFF)))
		return
	if(!ishuman(loc) || istype(loc, /mob/living/carbon/human/dummy))
		return

	if(has_sensor >= HAS_SENSORS && sensor_mode > SENSOR_OFF)
		if(HAS_TRAIT(loc, TRAIT_SUIT_SENSORS))
			return
		ADD_TRAIT(loc, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
		if(!HAS_TRAIT(loc, TRAIT_NANITE_SENSORS))
			GLOB.suit_sensors_list += loc
	else
		if(!HAS_TRAIT(loc, TRAIT_SUIT_SENSORS))
			return
		REMOVE_TRAIT(loc, TRAIT_SUIT_SENSORS, TRACKED_SENSORS_TRAIT)
		if(!HAS_TRAIT(loc, TRAIT_NANITE_SENSORS))
			GLOB.suit_sensors_list -= loc


/obj/item/clothing/under/examine(mob/user)
	. = ..()
	if(can_adjust)
		. += "Alt-click on [src] to wear it [adjusted == ALT_STYLE ? "normally" : "casually"]."
	if(has_sensor == BROKEN_SENSORS)
		. += "Its sensors appear to be shorted out. You could repair it with some cabling."
	else if(has_sensor > NO_SENSORS)
		switch(sensor_mode)
			if(SENSOR_OFF)
				. += "Its sensors appear to be disabled."
			if(SENSOR_LIVING)
				. += "Its binary life sensors appear to be enabled."
			if(SENSOR_VITALS)
				. += "Its vital tracker appears to be enabled."
			if(SENSOR_COORDS)
				. += "Its vital tracker and tracking beacon appear to be enabled."
	if(LAZYLEN(attached_accessories))
		var/list/accessories = list_accessories_with_icon(user)
		. += "It has [english_list(accessories)] attached."
		. += "Alt-Right-Click to remove [attached_accessories[1]]."

/// Helper to list out all accessories with an icon besides it, for use in examine
/obj/item/clothing/under/proc/list_accessories_with_icon(mob/user)
	var/list/all_accessories = list()
	for(var/obj/item/clothing/accessory/attached as anything in attached_accessories)
		all_accessories += attached.get_examine_string(user)

	return all_accessories

/obj/item/clothing/under/verb/toggle()
	set name = "Adjust Suit Sensors"
	set category = "Object"
	set src in usr
	set_sensors(usr)

/obj/item/clothing/under/proc/set_sensors(mob/user_mob)
	if(!can_toggle_sensors(user_mob))
		return

	var/list/modes = list("Off", "Binary vitals", "Exact vitals", "Tracking beacon")
	var/switchMode = tgui_input_list(user_mob, "Select a sensor mode", "Suit Sensors", modes, modes[sensor_mode + 1])
	if(isnull(switchMode))
		return
	if(!can_toggle_sensors(user_mob))
		return

	var/sensor_selection = modes.Find(switchMode) - 1

	update_sensors(sensor_selection)
	if(istype(src.loc, /mob))
		var/mob/living/carbon/human/wearer = src.loc
		wearer.visible_message(span_notice("[user_mob] tries to set [wearer]'s sensors."), \
						span_warning("[user_mob] is trying to set your sensors."), null, COMBAT_MESSAGE_RANGE)
		if(do_after(user_mob, SENSOR_CHANGE_DELAY, wearer))
			switch(sensor_selection)
				if(SENSOR_OFF)
					wearer.visible_message(span_warning("[user_mob] disables [wearer]'s remote sensing equipment."), \
						span_warning("[user_mob] disables your remote sensing equipment."), null, COMBAT_MESSAGE_RANGE)
				if(SENSOR_LIVING)
					wearer.visible_message(span_notice("[user_mob] turns [wearer]'s remote sensors to binary."), \
						span_notice("[user_mob] turns your remote sensors to binary."), null, COMBAT_MESSAGE_RANGE)
				if(SENSOR_VITALS)
					wearer.visible_message(span_notice("[user_mob] turns [wearer]'s remote sensors to track vitals."), \
						span_notice("[user_mob] turns your remote sensors to track vitals."), null, COMBAT_MESSAGE_RANGE)
				if(SENSOR_COORDS)
					wearer.visible_message(span_notice("[user_mob] turns [wearer]'s remote sensors to maximum."), \
						span_notice("[user_mob] turns your remote sensors to maximum."), null, COMBAT_MESSAGE_RANGE)
			update_sensors(sensor_selection)
			log_combat(user_mob, wearer, "changed sensors to [switchMode]")

	if(ishuman(loc) || ismonkey(loc))
		var/mob/living/carbon/human/H = loc
		if(H.w_uniform == src)
			H.update_suit_sensors()

/// Checks if the toggler is allowed to toggle suit sensors currently
/obj/item/clothing/under/proc/can_toggle_sensors(mob/toggler)
	if(!can_use(toggler) || toggler.stat == DEAD) //make sure they didn't hold the window open.
		return FALSE
	if(get_dist(toggler, src) > 1)
		balloon_alert(toggler, "too far!")
		return FALSE

	switch(has_sensor)
		if(LOCKED_SENSORS)
			balloon_alert(toggler, "sensor controls locked!")
			return FALSE
		if(BROKEN_SENSORS)
			balloon_alert(toggler, "sensors shorted!")
			return FALSE
		if(NO_SENSORS)
			balloon_alert(toggler, "no sensors to ajdust!")
			return FALSE

	return TRUE

/obj/item/clothing/under/AltClick(mob/user)
	. = ..()
	if(.)
		return

	if(!can_adjust)
		balloon_alert(user, "can't be adjusted!")
		return
	if(!can_use(user))
		return
	rolldown()

/obj/item/clothing/under/alt_click_secondary(mob/user)
	. = ..()
	if(.)
		return

	if(!LAZYLEN(attached_accessories))
		balloon_alert(user, "no accessories to remove!")
		return
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return

	pop_accessory(user)

/obj/item/clothing/under/verb/jumpsuit_adjust()
	set name = "Adjust Jumpsuit Style"
	set category = null
	set src in usr

	if(!can_adjust)
		balloon_alert(usr, "can't be adjusted!")
		return
	if(!can_use(usr))
		return
	rolldown()

/obj/item/clothing/under/proc/rolldown()
	if(toggle_jumpsuit_adjust())
		to_chat(usr, span_notice("You adjust the suit to wear it more casually."))
	else
		to_chat(usr, span_notice("You adjust the suit back to normal."))

	update_appearance()

/// Helper to toggle the jumpsuit style, if possible
/// Returns the new state
/obj/item/clothing/under/proc/toggle_jumpsuit_adjust()
	switch(adjusted)
		if(DIGITIGRADE_STYLE)
			return

		if(NORMAL_STYLE)
			adjust_to_alt()

		if(ALT_STYLE)
			adjust_to_normal()

	SEND_SIGNAL(src, COMSIG_CLOTHING_UNDER_ADJUSTED)
	return adjusted

/// Helper to reset to normal jumpsuit state
/obj/item/clothing/under/proc/adjust_to_normal()
	adjusted = NORMAL_STYLE
	female_sprite_flags = initial(female_sprite_flags)
	if(!alt_covers_chest)
		body_parts_covered |= CHEST
		body_parts_covered |= ARMS
	if(LAZYLEN(damage_by_parts))
		// ugly check to make sure we don't reenable protection on a disabled part
		for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			if(damage_by_parts[zone] > limb_integrity)
				body_parts_covered &= body_zone2cover_flags(zone)

/// Helper to adjust to alt jumpsuit state
/obj/item/clothing/under/proc/adjust_to_alt()
	adjusted = ALT_STYLE
	if(!(female_sprite_flags & FEMALE_UNIFORM_TOP_ONLY))
		female_sprite_flags = NO_FEMALE_UNIFORM
	if(!alt_covers_chest) // for the special snowflake suits that expose the chest when adjusted (and also the arms, realistically)
		body_parts_covered &= ~CHEST
		body_parts_covered &= ~ARMS

/obj/item/clothing/under/can_use(mob/user)
	if(ismob(user) && !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, NO_TK))
		return FALSE
	return ..()

/obj/item/clothing/under/rank
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/compile_monkey_icon()
	var/identity = "[type]_[icon_state]" //Allows using multiple icon states for piece of clothing
	//If the icon, for this type of clothing, is already made by something else, don't make it again
	if(GLOB.monkey_icon_cache[identity])
		monkey_icon = GLOB.monkey_icon_cache[identity]
		return

	//Start with a base and align it with the mask
	var/icon/base = icon('icons/mob/clothing/under/default.dmi', icon_state, SOUTH) //This takes the icon and uses the worn version of the icon
	var/icon/back = icon('icons/mob/clothing/under/default.dmi', icon_state, NORTH) //Awkard but, we have to manually insert the back
	back.Shift(SOUTH, 2) //Allign with masks
	base.Shift(SOUTH, 2)

	//Break the base down into two parts and lay it on-top of the original. This helps with clothing being too small for monkeys
	var/icon/left = new(base)
	var/icon/mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	left.AddAlphaMask(mask)

	var/icon/right = new(base)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_right")
	right.AddAlphaMask(mask)
	right.Shift(EAST, 1)

	var/icon/middle = new(base) //This part is used to correct a line of pixels
	mask = new('icons/mob/monkey.dmi', "monkey_mask_middle")
	middle.AddAlphaMask(mask)
	middle.Shift(EAST, 1)

	left.Blend(right, ICON_OVERLAY)
	left.Blend(middle, ICON_OVERLAY)
	base.Blend(left, ICON_OVERLAY)

	//Again for the back
	left = new(back)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_left")
	left.AddAlphaMask(mask)

	right = new(back)
	right.Shift(EAST, 1)
	mask = new('icons/mob/monkey.dmi', "monkey_mask_right")
	right.AddAlphaMask(mask)

	left.Blend(right, ICON_OVERLAY)
	back.Blend(left, ICON_OVERLAY) //blend the outcome into the current to avoid a bald stripe

	//Now modify the left & right facing icons to better emphasize direction / volume
	left = new(base)
	left.Shift(WEST, 3)
	base.Insert(left, dir = WEST)

	right = new(left)
	right.Flip(EAST)
	base.Insert(right, dir = EAST)

	//Apply masking
	mask = new('icons/mob/monkey.dmi', "monkey_mask_cloth")//Roughly monkey shaped clothing
	base.AddAlphaMask(mask)
	back.AddAlphaMask(mask)
	base.Insert(back, dir = NORTH)//Insert faces into the base

	//Mix in GAG color
	if(greyscale_colors)
		base.Blend(greyscale_colors, ICON_MULTIPLY)

	//Finished!
	monkey_icon = base
	GLOB.monkey_icon_cache[identity] = icon(monkey_icon) //Don't create a reference to monkey icon
