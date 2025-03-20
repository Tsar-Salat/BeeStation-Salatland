// Badges, pins, and other very small items that slot onto a shirt.
/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/interact(mob/user)
	. = ..()
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "[src]")
	user.visible_message(span_notice("[user] shows [user.p_their()] attorney's badge."), span_notice("You show your attorney's badge."))

/obj/item/clothing/accessory/lawyers_badge/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	RegisterSignal(user, COMSIG_LIVING_SLAM_TABLE, PROC_REF(table_slam))
	user.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	UnregisterSignal(user, COMSIG_LIVING_SLAM_TABLE)
	user.bubble_icon = initial(user.bubble_icon)

/obj/item/clothing/accessory/lawyers_badge/proc/table_slam(mob/living/source, obj/structure/table/the_table)
	SIGNAL_HANDLER

	ASYNC
		source.say("Objection!!", spans = list(SPAN_YELL), forced = "[src]")

////////////////
//HA HA! NERD!//
////////////////
/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"

/obj/item/clothing/accessory/pocketprotector/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/pocketprotector)

/obj/item/clothing/accessory/pocketprotector/can_attach_accessory(obj/item/clothing/under/attach_to, mob/living/user)
	. = ..()
	if(!.)
		return

	if(!isnull(attach_to.atom_storage))
		if(user)
			attach_to.balloon_alert(user, "not compatible!")
		return FALSE
	return TRUE

/obj/item/clothing/accessory/pocketprotector/full

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)

/obj/item/clothing/accessory/poppy_pin
	name = "poppy pin"
	desc = "A pin made from a poppy, worn to remember those who have fallen in war."
	icon_state = "poppy_pin"

/obj/item/clothing/accessory/poppy_pin/accessory_equipped(obj/item/clothing/under/clothes, mob/living/user)
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "poppy_pin", /datum/mood_event/poppy_pin)

/obj/item/clothing/accessory/poppy_pin/accessory_dropped(obj/item/clothing/under/clothes, mob/living/user)
	SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "poppy_pin")

//Security Badges
/obj/item/clothing/accessory/badge/officer
	name = "\improper Security badge"
	desc = "A badge of the Nanotrasen Security Division, made of silver and set on false black leather."
	icon_state = "officerbadge"
	worn_icon_state = "officerbadge"

/obj/item/clothing/accessory/badge/officer/det
	name = "\improper Detective's badge"
	desc = "A badge of the Nanotrasen Detective Agency, made of gold and set on false leather."
	icon_state = "detbadge"
	worn_icon_state = "detbadge"

/obj/item/clothing/accessory/badge/officer/hos
	name = "\improper Head of Security badge"
	desc = "A badge of the Nanotrasen Security Division, made of gold and set on false black leather."
	icon_state = "hosbadge"
	worn_icon_state = "hosbadge"

/obj/item/clothing/accessory/badge/officer/attack_self(mob/user)
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you \the: [icon2html(src, viewers(user))] [src.name]."), span_notice("You show \the [src.name]."))
	..()
