/datum/codex_category/gases
	name = "Gases"
	desc = "Information on gas types found in game."

/datum/codex_category/gases/Populate()
	for(var/datum/gas/gas_path as anything in subtypesof(/datum/gas))
		if(!initial(gas_path.name))
			continue

		var/list/material_info = list()

		material_info += "<li>It has a specific heat of [initial(gas_path.specific_heat)] J/(mol*K).</li>"
		if(initial(gas_path.dangerous))
			material_info += "<li>It is considered dangerous.</li>"
		if(initial(gas_path.fusion_power))
			material_info += "<li>It can accelerate fusion reactions (power: [initial(gas_path.fusion_power)]).</li>"
		if(initial(gas_path.desc))
			material_info += "<li>[initial(gas_path.desc)]</li>"

		var/datum/codex_entry/entry = new(
			_display_name = "[initial(gas_path.name)] (gas)",
			_mechanics_text = jointext(material_info, null)
		)

		items += entry

	return ..()
