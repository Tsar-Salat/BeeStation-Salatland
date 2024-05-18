/obj/item/clothing/gloves/color
	greyscale_colors = null

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut

/obj/item/clothing/gloves/color/black/equipped(mob/user, slot)
	. = ..()
	if((slot == ITEM_SLOT_GLOVES) && (user.mind?.assigned_role in GLOB.security_positions))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "sec_black_gloves", /datum/mood_event/sec_black_gloves)

/obj/item/clothing/gloves/color/black/dropped(mob/living/carbon/user)
	..()
	if(user.gloves != src)
		return
	if(user.mind?.assigned_role in GLOB.security_positions)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "sec_black_gloves")

/obj/item/clothing/gloves/color/yellow/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		if(user.mind?.assigned_role == JOB_NAME_ASSISTANT)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "assistant_insulated_gloves", /datum/mood_event/assistant_insulated_gloves)
		if(user.mind?.assigned_role in GLOB.security_positions)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "sec_insulated_gloves", /datum/mood_event/sec_insulated_gloves)

/obj/item/clothing/gloves/color/yellow/dropped(mob/living/carbon/user)
	..()
	if(user.gloves != src)
		return
	if(user.mind?.assigned_role == JOB_NAME_ASSISTANT)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "assistant_insulated_gloves")
	if(user.mind?.assigned_role in GLOB.security_positions)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "sec_insulated_gloves")


/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in Initialize()
	permeability_coefficient = 0.05
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/cut
	desc = "These gloves would protect the wearer from electric shock... if the fingers were covered."
	name = "fingerless insulated gloves"
	icon_state = "yellowcut"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	transfer_prints = TRUE

/obj/item/clothing/gloves/cut/heirloom
	desc = "The old gloves your great grandfather stole from Engineering, many moons ago. They've seen some tough times recently."
