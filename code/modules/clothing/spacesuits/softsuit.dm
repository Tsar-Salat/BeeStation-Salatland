	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "space"
	item_state = "eva_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 20, FIRE = 50, ACID = 65, STAMINA = 0)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "space"
	item_state = "eva_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = 0
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 20, FIRE = 50, ACID = 65, STAMINA = 0)

/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"
	armor = list(MELEE = 5,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 10, FIRE = 0, ACID = 0, STAMINA = 0)
	strip_delay = 65
	flash_protect = 0

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	slowdown = 2
	armor = list(MELEE = 5,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 10, FIRE = 0, ACID = 0, STAMINA = 0)
	strip_delay = 65
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, "<span class='warning'>\The [src] tears from the damage, breaking the air-tight seal!</span>")
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]"
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit
	name = "skinsuit helmet"
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "skinsuit_helmet"
	item_state = "skinsuit_helmet"
	max_integrity = 200
	desc = "An airtight helmet meant to protect the wearer during emergency situations."
	permeability_coefficient = 0.01
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 20, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = 0
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT | HEADINTERNALS
	max_heat_protection_temperature = 100
	actions_types = null

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/attack_self(mob/user)
	return

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/emp_act(severity)
	return

/obj/item/clothing/suit/space/hardsuit/skinsuit
	name = "skinsuit"
	desc = "A slim, compression-based spacesuit meant to protect the user during emergency situations. It's only a little warmer than your uniform."
	icon = 'icons/obj/clothing/suits/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "skinsuit"
	item_state = "s_suit"
	max_integrity = 200
	slowdown = 3 //Higher is slower
	clothing_flags = STOPSPRESSUREDAMAGE
	species_restricted = null
	gas_transfer_coefficient = 0.5
	permeability_coefficient = 0.5
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/skinsuit

/obj/item/clothing/suit/space/hardsuit/skinsuit/attackby(obj/item/I, mob/user, params)
	return
