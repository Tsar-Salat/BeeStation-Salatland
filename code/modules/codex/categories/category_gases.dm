/datum/codex_category/gases
	name = "Gases"
	desc = "Notable gases."

/datum/codex_category/gases/Initialize()
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/gas = gas_path
		// BeeStation's /datum/gas doesn't have hidden_from_codex
		// All gas types are shown in codex

		var/list/gas_info = list()
		gas_info += "Specific heat: [initial(gas.specific_heat)] J/(mol*K)."

		if(initial(gas.dangerous))
			gas_info += "This gas is considered dangerous."

		if(initial(gas.fusion_power) > 0)
			gas_info += "Fusion power: [initial(gas.fusion_power)]."

		if(initial(gas.desc))
			gas_info += initial(gas.desc)

		var/datum/codex_entry/entry = new(
			_display_name = "[lowertext(initial(gas.name))] (gas)",
			_mechanics_text = jointext(gas_info, "<br>")
		)
		SScodex.add_entry_by_string(entry.display_name, entry)
		items += entry.display_name
	..()
