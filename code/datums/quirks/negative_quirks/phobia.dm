/datum/quirk/phobia
	name = "Phobia"
	desc = "You are irrationally afraid of something."
	icon = "spider"
	quirk_value = -1
	medical_record_text = "Patient has an irrational fear of something."
	mail_goodies = list(/obj/item/clothing/glasses/blindfold, /obj/item/storage/pill_bottle/psicodine)

/datum/quirk_constant_data/phobia
	associated_typepath = /datum/quirk/phobia
	customization_options = list(/datum/preference/choiced/phobia)

// Phobia will follow you between transfers
/datum/quirk/phobia/add(client/client_source)
	var/phobia = read_choice_preference(/datum/preference/choiced/phobia)
	if(!phobia)
		return

	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.gain_trauma(new /datum/brain_trauma/mild/phobia(phobia), TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/human_holder = quirk_target
	human_holder.cure_trauma_type(/datum/brain_trauma/mild/phobia, TRAUMA_RESILIENCE_ABSOLUTE)
