/obj/item/clothing/suit/space/hunter
	name = "bounty hunting suit"
	desc = "A custom version of the MK.II SWAT suit, modified to look rugged and tough. Works as a space suit, if you can find a helmet."
	icon_state = "hunter"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/knife/combat)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, stamina = 70)
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hunter
	name = "bounty hunting helmet"
	desc = "A custom tactical space helmet with decals added."
	icon_state = "hunter"
	item_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 5,  BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 20)
