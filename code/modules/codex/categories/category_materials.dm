/datum/codex_category/materials
	name = "Materials"
	desc = "Various natural and artificial materials."

/datum/codex_category/materials/Initialize()
	// Iterate through all material datums in the subsystem
	for(var/mat_path in SSmaterials.materials)
		var/datum/material/mat = SSmaterials.materials[mat_path]

		if(mat.hidden_from_codex)
			continue

		// Create codex entry using material name
		var/datum/codex_entry/entry = new(_display_name = "[mat.name] (material)")

		// Use material description as lore text if available
		if(mat.desc)
			entry.lore_text = mat.desc

		// Build mechanics info from available properties
		var/list/material_info = list()

		// Structural properties
		if(mat.strength_modifier != 1)
			if(mat.strength_modifier > 1)
				material_info += "It increases structural strength by [round((mat.strength_modifier - 1) * 100)]%."
			else
				material_info += "It decreases structural strength by [round((1 - mat.strength_modifier) * 100)]%."

		if(mat.integrity_modifier != 1)
			if(mat.integrity_modifier > 1)
				material_info += "It increases structural integrity by [round((mat.integrity_modifier - 1) * 100)]%."
			else
				material_info += "It decreases structural integrity by [round((1 - mat.integrity_modifier) * 100)]%."

		// Visual properties
		if(mat.alpha < 255)
			material_info += "It is partially transparent."

		// Economic value
		if(mat.value_per_unit > 0)
			material_info += "It has an economic value of [mat.value_per_unit] credits per unit."

		// If we have any mechanics info, add it
		if(LAZYLEN(material_info))
			entry.mechanics_text = jointext(material_info, "<br>")
		else
			entry.mechanics_text = "A basic construction material."

		entry.update_links()
		SScodex.add_entry_by_string(entry.display_name, entry)
		items += entry.display_name
	..()
