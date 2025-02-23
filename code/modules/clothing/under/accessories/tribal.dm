// Tribal undershirt accessories, made from bone or sinew.
/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	armor_type = /datum/armor/accessory_talisman
	attachment_slot = null

/datum/armor/accessory_talisman
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	rad = 5
	acid = 25
	stamina = 25
	bleed = 10

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	above_suit = TRUE
	armor_type = /datum/armor/accessory_skullcodpiece
	attachment_slot = GROIN

/datum/armor/accessory_skullcodpiece
	melee = 5
	bullet = 5
	laser = 5
	energy = 5
	bomb = 20
	bio = 20
	rad = 5
	acid = 25
	stamina = 10
	bleed = 10
