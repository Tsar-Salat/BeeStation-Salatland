//HAUL Gauntlets go here :3

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	inhand_icon_state = "rapid"
	worn_icon_state = "rapid"
	transfer_prints = TRUE
	item_flags = ISWEAPON
	var/warcry = "AT"

/obj/item/clothing/gloves/rapid/Touch(atom/A, proximity)
	var/mob/living/M = loc
	if(get_dist(A, M) <= 1)
		if(isliving(A) && M.a_intent == INTENT_HARM)
			M.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				M.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")

	else if(M.a_intent == INTENT_HARM)
		for(var/mob/living/L in oview(1, M))
			L.attack_hand(M)
			M.changeNext_move(CLICK_CD_RAPID)
			if(warcry)
				M.say("[warcry]", ignore_spam = TRUE, forced = "north star warcry")
			break
	.= FALSE

/obj/item/clothing/gloves/rapid/attack_self(mob/user)
	var/input = stripped_input(user,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input == "*me") //If they try to do a *me emote it will stop the attack to prompt them for an emote then they can walk away and enter the emote for a punch from far away
		to_chat(user, "<span class='warning'>Invalid battlecry, please use another. Battlecry cannot contain *me.</span>")
	else if(CHAT_FILTER_CHECK(input))
		to_chat(user, "<span class='warning'>Invalid battlecry, please use another. Battlecry contains prohibited word(s).</span>")
	else if(input)
		warcry = input

/obj/item/clothing/gloves/color/white/magic
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	inhand_icon_state = "wgloves"
	var/range = 3

/obj/item/clothing/gloves/color/white/magic/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = W
		if(!wand.used && range == initial(range))
			wand.used = TRUE
			range = 6
			to_chat(user, "<span_class='notice'>You upgrade the [src] with the [wand].</span>")
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/clothing/gloves/color/white/magic/Touch(atom/A, proximity)
	var/mob/living/user = loc
	if(get_dist(A, user) <= 1 )
		return FALSE
	if(user in viewers(range, A))
		user.visible_message("<span class='danger'>[user] waves their hands at [A]</span>", "<span class='notice'>You begin manipulating [A].</span>")
		new	/obj/effect/temp_visual/telegloves(A.loc)
		user.changeNext_move(CLICK_CD_MELEE)
		if(do_after(user, 0.8 SECONDS, A))
			new /obj/effect/temp_visual/telekinesis(user.loc)
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)
			A.attack_hand(user)
			return TRUE

/obj/item/clothing/gloves/artifact_pinchers
	name = "anti-tactile pinchers"
	desc = "Used for the fine manipulation and examination of artifacts."
	icon_state = "pincher"
	inhand_icon_state = "pincher"
	worn_icon_state = "pincher"
	transfer_prints = FALSE
	actions_types = list(/datum/action/item_action/artifact_pincher_mode)
	var/safety = FALSE

/datum/action/item_action/artifact_pincher_mode
	name = "Toggle Safety"

/datum/action/item_action/artifact_pincher_mode/Trigger()
	var/obj/item/clothing/gloves/artifact_pinchers/pinchy = target
	if(istype(pinchy))
		pinchy.safety = !pinchy.safety
		button.icon_state = (pinchy.safety ? "template_active" : "template")

/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	inhand_icon_state = "egloves"
	worn_icon_state = "egloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 70, ACID = 50, STAMINA = 0)

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex. Transfers minor paramedic knowledge to the user via budget nanochips."
	icon_state = "latex"
	inhand_icon_state = "latex"
	worn_icon_state = "latex"
	siemens_coefficient = 0.3
	permeability_coefficient = 0.01
	transfer_prints = TRUE
	resistance_flags = NONE
	var/carrytrait = TRAIT_QUICKER_CARRY

/obj/item/clothing/gloves/color/latex/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_GLOVES)
		ADD_TRAIT(user, carrytrait, CLOTHING_TRAIT)

/obj/item/clothing/gloves/color/latex/dropped(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves != src)
			return
		else
			REMOVE_TRAIT(user, carrytrait, CLOTHING_TRAIT)

/obj/item/clothing/gloves/color/latex/obj_break()
	..()
	if(ishuman(loc))
		REMOVE_TRAIT(loc, carrytrait, CLOTHING_TRAIT)

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are stronger than latex. Transfers intimate paramedic knowledge into the user via nanochips."
	icon_state = "nitrile"
	inhand_icon_state = "nitrilegloves"
	worn_icon_state = "nitrilegloves"
	transfer_prints = FALSE
	carrytrait = TRAIT_QUICKER_CARRY
