/obj/item/papercutter
	name = "paper cutter"
	desc = "Standard office equipment. Precisely cuts paper using a large blade."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "papercutter"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	var/obj/item/paper/storedpaper = null
	var/obj/item/hatchet/cutterblade/storedcutter = null
	var/cuttersecured = TRUE
	pass_flags = PASSTABLE


/obj/item/papercutter/Initialize(mapload)
	. = ..()
	storedcutter = new /obj/item/hatchet/cutterblade(src)
	update_icon()


/obj/item/papercutter/suicide_act(mob/living/user)
	if(storedcutter)
		user.visible_message(span_suicide("[user] is beheading [user.p_them()]self with [src.name]! It looks like [user.p_theyre()] trying to commit suicide!"))
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
			if(BP)
				BP.drop_limb()
				playsound(loc,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	else
		user.visible_message(span_suicide("[user] repeatedly bashes [src.name] against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/items/gavel.ogg', 50, 1, -1)
		return BRUTELOSS


/obj/item/papercutter/update_icon()
	..()
	cut_overlays()
	icon_state = (storedcutter ? "[initial(icon_state)]-cutter" : "[initial(icon_state)]")
	if(storedpaper)
		add_overlay("paper")


/obj/item/papercutter/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper) && !storedpaper)
		if(!user.transferItemToLoc(P, src))
			return
		playsound(loc, "pageturn", 60, 1)
		to_chat(user, span_notice("You place [P] in [src]."))
		storedpaper = P
		update_icon()
		return
	if(istype(P, /obj/item/hatchet/cutterblade) && !storedcutter)
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, span_notice("You replace [src]'s [P]."))
		P.forceMove(src)
		storedcutter = P
		update_icon()
		return
	if(P.tool_behaviour == TOOL_SCREWDRIVER && storedcutter)
		P.play_tool_sound(src)
		to_chat(user, span_notice("[storedcutter] has been [cuttersecured ? "unsecured" : "secured"]."))
		cuttersecured = !cuttersecured
		return
	..()

/obj/item/papercutter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(!storedcutter)
		to_chat(user, span_notice("The cutting blade is gone! You can't use [src] now."))
		return

	if(!cuttersecured)
		to_chat(user, span_notice("You remove [src]'s [storedcutter]."))
		user.put_in_hands(storedcutter)
		storedcutter = null
		update_icon()

	if(storedpaper)
		playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1)
		to_chat(user, span_notice("You neatly cut [storedpaper]."))
		storedpaper = null
		qdel(storedpaper)
		new /obj/item/paperslip(get_turf(src))
		new /obj/item/paperslip(get_turf(src))
		update_icon()

/obj/item/papercutter/MouseDrop(atom/over_object)
	. = ..()
	var/mob/M = usr
	if(M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over_object
		M.putItemFromInventoryInHandIfPossible(src, H.held_index)
	add_fingerprint(M)

/obj/item/paperslip
	name = "paper slip"
	desc = "A little slip of paper left over after a larger piece was cut. Whoa."
	icon_state = "paperslip"
	icon = 'icons/obj/bureaucracy.dmi'
	resistance_flags = FLAMMABLE
	max_integrity = 50

/obj/item/paperslip/attackby(obj/item/I, mob/living/user, params)
	if(burn_paper_product_attackby_check(I, user))
		return
	return ..()


/obj/item/paperslip/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)


/obj/item/hatchet/cutterblade
	name = "paper cutter"
	desc = "The blade of a paper cutter. Most likely removed for polishing or sharpening."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "cutterblade"
	item_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
