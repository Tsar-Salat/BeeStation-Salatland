//Subtype of human
/datum/species/human/alclades
	name = "\improper Alclades"
	id = SPECIES_ALCLADES
	bodyflag = FLAG_ALCLADES
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("body_size" = "Normal", "cladia" = CLADIA_FELYSS)

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/human/alclades/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/cladia_feature = H.dna.features["cladia"]
		switch(cladia_feature)
			if(CLADIA_FELYSS)
				cladia = CLADIA_FELYSS
				mutantears = /obj/item/organ/ears/human/cat
				mutant_organs = list(/obj/item/organ/tail/human/cat)
				mutanttongue = /obj/item/organ/tongue/cat
				//swimming_component = /datum/component/swimming/felinid
				//inert_mutation = /datum/mutation/catclaws
			if(CLADIA_RENARI)
				cladia = CLADIA_RENARI
				mutantears = /obj/item/organ/ears/human/fox
				mutant_organs = list(/obj/item/organ/tail/human/fox)
				mutanttongue = /obj/item/organ/tongue
			/* Wolfdog race
			if("Lupos")
				mutantears = /obj/item/organ/ears/lupine
				mutant_organs = list(/obj/item/organ/tail/lupine)
				mutanttongue = /obj/item/organ/lupine
			*/

	return ..()

/datum/species/human/alclades/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Modern" // Good haircut, less MPDG than Hime
	human.hair_color = "fcc" // pink
	human.update_hair()

	var/obj/item/organ/ears/clad_ears = human.getorgan(/obj/item/organ/ears)
	if (clad_ears)
		clad_ears.color = human.hair_color
		human.update_body()

/datum/species/human/alclades/get_species_description()
	return "Alclades (Al-clay-des/All-cla-days) are an all-encompassing term covering the \
		modified offspring of humanity's bleeding-edge forays into genetic science. \
		\
		The term originates from the taxonomic term 'clade' meaning an organism and all its descendants. \
		Though, ironically the term's usage has become corrupted overtime to its current form to specifically refer to \
		those with striking phenotypical differences to standard Gaians & Terrans. \
		\
		To some, the term once made to unite all of humanity and it's children in the yesteryears is nothing but a perjorative, \
		but it remains the most common descriptor to this day."

/datum/species/human/alclades/get_species_lore()
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		var/cladia_feature = H.dna.features["cladia"]
		switch(cladia_feature)
			if(CLADIA_FELYSS)
				return list(
				"Bio-engineering at its felinest, Felyss are the peak example of humanity's mastery of genetic code. \
					One of many \"Alclade\" variants, Alclades are the most popular and common, as well as one of the \
					biggest points of contention in genetic-modification.",

				"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
					These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

				"Sadly for the Felyss, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felyss (and other Alclades) \
					sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
					As a result, outer Human space has a high Animalid population.",
				)
			if(CLADIA_RENARI)
				return list(
				"Renari lore",
				)
			/* Wolfdog race
			if("Lupos")
				return list(
				"Lupos lore",
				)
			*/


// Alclades are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/alclades/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Always Land On Your Feet",
			SPECIES_PERK_DESC = "Alclades always land on their feet, and take reduced damage from falling. Just so long as you keep that tail attached to your body...",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Laser Affinity",
			SPECIES_PERK_DESC = "Alclades can't resist the temptation of a good laser pointer, and might involuntarily chase a strong one.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "swimming-pool",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Alclades don't like water, and hate going in the pool.",
		),
	)

	return to_add
