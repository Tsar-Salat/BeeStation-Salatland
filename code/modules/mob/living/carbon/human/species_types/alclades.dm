//Subtype of human
/datum/species/human/alclades
	name = "\improper Alclades"
	id = SPECIES_ALCLADES
	bodyflag = FLAG_ALCLADES
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("body_size" = "Normal", "cladia" = "Felyss")

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

/datum/species/human/alclades/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/cladia_feature = H.dna.features["cladia"]
		switch(cladia_feature)
			if("Felyss")
				mutantears = /obj/item/organ/ears/human/cat
				mutant_organs = list(/obj/item/organ/tail/human/cat)
				mutanttongue = /obj/item/organ/tongue/cat
				//swimming_component = /datum/component/swimming/felinid
				//inert_mutation = /datum/mutation/catclaws
			if("Renari")
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
	return "Alclades are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common."

/datum/species/human/alclades/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Alclades are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Alclades are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Alclades, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

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
