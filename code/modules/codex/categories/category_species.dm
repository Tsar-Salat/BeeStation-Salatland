/datum/codex_category/species
	name = "Species"
	desc = "Sapient species encountered in known space."

/datum/codex_category/species/Initialize()
	// BeeStation uses GLOB.species_list which is id -> type path, not name -> instance
	for(var/species_id in GLOB.species_list)
		var/species_type = GLOB.species_list[species_id]
		var/datum/species/species = new species_type()

		if(species.hidden_from_codex)
			qdel(species)
			continue

		// Create entry using species name
		var/datum/codex_entry/entry = new(_display_name = "[species.name] (species)")

		// BeeStation species don't have codex_description, use generic description
		// You can add lore text here or leave it blank for now
		entry.lore_text = "A playable species in this sector of space."

		// Add mechanics info about the species
		var/list/mechanics = list()

		if(species.speedmod != 0)
			if(species.speedmod > 0)
				mechanics += "Moves slower than baseline humans."
			else
				mechanics += "Moves faster than baseline humans."

		if(species.brutemod != 1)
			mechanics += "Takes [round(species.brutemod * 100)]% brute damage."

		if(species.burnmod != 1)
			mechanics += "Takes [round(species.burnmod * 100)]% burn damage."

		if(species.coldmod != 1)
			mechanics += "Takes [round(species.coldmod * 100)]% cold damage."

		if(species.heatmod != 1)
			mechanics += "Takes [round(species.heatmod * 100)]% heat damage."

		if(LAZYLEN(mechanics))
			entry.mechanics_text = jointext(mechanics, "<br>")

		entry.update_links()
		SScodex.add_entry_by_string(entry.display_name, entry)
		SScodex.add_entry_by_string(species.name, entry)
		items += entry.display_name

		qdel(species) // Clean up the temporary instance
	..()
