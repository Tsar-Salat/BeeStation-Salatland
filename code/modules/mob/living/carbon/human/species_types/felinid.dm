//Subtype of human
/datum/species/human/felinid
	name = "\improper Felinid"
	id = SPECIES_FELINID
	bodyflag = FLAG_FELINID
	examine_limb_id = SPECIES_HUMAN

	mutant_bodyparts = list("tail_human" = "Cat", "ears" = "Cat", "wings" = "None", "body_size" = "Normal")
	forced_features = list("tail_human" = "Cat", "ears" = "Cat")

	mutantears = /obj/item/organ/ears/cat
	mutant_organs = list(/obj/item/organ/tail/cat)
	mutanttongue = /obj/item/organ/tongue/cat
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	swimming_component = /datum/component/swimming/felinid
	inert_mutation = /datum/mutation/catclaws

/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(!ishuman(C))
		return ..()
	var/mob/living/carbon/human/H = C
	if(H.dna.features["ears"] == "Cat")
		var/obj/item/organ/ears/cat/ears = new
		ears.Insert(H, drop_if_replaced = FALSE, pref_load = pref_load)
	else
		mutantears = /obj/item/organ/ears
	if(H.dna.features["tail_human"] == "Cat")
		var/obj/item/organ/tail/cat/tail = new
		tail.Insert(H, drop_if_replaced = FALSE, pref_load = pref_load)
	else
		mutant_organs = list()

/datum/species/human/felinid/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Hime Cut"
	human.hair_color = "fcc" // pink
	human.update_hair()

	var/obj/item/organ/ears/cat/cat_ears = human.getorgan(/obj/item/organ/ears/cat)
	if (cat_ears)
		cat_ears.color = human.hair_color
		human.update_body()

/datum/species/human/felinid/get_species_description()
	return "Felinids are one of the many types of bespoke genetic \
		modifications to come of humanity's mastery of genetic science, and are \
		also one of the most common. Meow?"

/datum/species/human/felinid/get_species_lore()
	return list(
		"Bio-engineering at its felinest, Felinids are the peak example of humanity's mastery of genetic code. \
			One of many \"Animalid\" variants, Felinids are the most popular and common, as well as one of the \
			biggest points of contention in genetic-modification.",

		"Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. \
			These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",

		"Sadly for the Felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, Felinids (and other Animalids) \
			sought their greener pastures out in the colonies, cloistering in communities of their own kind. \
			As a result, outer Human space has a high Animalid population.",
	)

// Felinids are subtypes of humans.
// This shouldn't call parent or we'll get a buncha human related perks (though it doesn't have a reason to).
/datum/species/human/felinid/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "angle-double-down",
			SPECIES_PERK_NAME = "Always Land On Your Feet",
			SPECIES_PERK_DESC = "Felinids always land on their feet, and take reduced damage from falling. Just so long as you keep that tail attached to your body...",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "shoe-prints",
			SPECIES_PERK_NAME = "Laser Affinity",
			SPECIES_PERK_DESC = "Felinids can't resist the temptation of a good laser pointer, and might involuntarily chase a strong one.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "swimming-pool",
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Felinids don't like water, and hate going in the pool.",
		),
	)

	return to_add
