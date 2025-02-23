/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/holster

/obj/item/clothing/accessory/holster/detective
	name = "detective's shoulder holster"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/holster/detective

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	new /obj/item/gun/ballistic/revolver/detective(src)
