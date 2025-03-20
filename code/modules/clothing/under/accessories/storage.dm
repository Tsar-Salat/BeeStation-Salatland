/obj/item/clothing/accessory/holster
	name = "shoulder holster"
	desc = "A holster to carry a handgun and ammo. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	var/storage_typepath = /datum/storage/pockets/holster

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	create_storage(storage_type = storage_typepath)

/obj/item/clothing/accessory/holster/detective
	name = "detective's shoulder holster"
	storage_typepath = /datum/storage/pockets/holster/detective

/obj/item/clothing/accessory/holster/detective/Initialize(mapload)
	. = ..()
	new /obj/item/gun/ballistic/revolver/detective(src)
