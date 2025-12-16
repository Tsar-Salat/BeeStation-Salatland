/datum/codex_category/reagents
	name = "Reagents"
	desc = "Chemicals and reagents, both natural and artificial."

/datum/codex_category/reagents/Initialize()

	for(var/thing in subtypesof(/datum/reagent))
		var/datum/reagent/reagent = thing

		if(initial(reagent.hidden_from_codex))
			continue

		var/chem_name = lowertext(initial(reagent.name))
		var/datum/codex_entry/entry = new( \
			_display_name = "[chem_name] (chemical)", \
			_associated_strings = list("[chem_name] pill"), \
			_lore_text = "[initial(reagent.description)] It apparently tastes of [initial(reagent.taste_description)].")

		var/list/production_strings = list()
		if(GLOB.chemical_reactions_list_reactant_index[thing])
			for(var/datum/chemical_reaction/reaction as anything in GLOB.chemical_reactions_list_reactant_index[thing])

				if(reaction.hidden_from_codex)
					continue

				var/list/reactant_values = list()
				for(var/reactant_id in reaction.required_reagents)
					var/datum/reagent/reactant = reactant_id
					reactant_values += "[reaction.required_reagents[reactant_id]]u [lowertext(initial(reactant.name))]"

				if(!length(reactant_values))
					continue

				var/list/catalysts = list()
				for(var/catalyst_id in reaction.required_catalysts)
					var/datum/reagent/catalyst = catalyst_id
					catalysts += "[reaction.required_catalysts[catalyst_id]]u [lowertext(initial(catalyst.name))]"

				var/list/result_strings = list()
				for(var/result_id in reaction.results)
					var/datum/reagent/result = result_id
					result_strings += "[reaction.results[result_id]]u [lowertext(initial(result.name))]"

				if(!length(result_strings))
					continue

				if(length(catalysts))
					production_strings += "- [jointext(reactant_values, " + ")] (catalysts: [jointext(catalysts, ", ")]): [jointext(result_strings, ", ")]"
				else
					production_strings += "- [jointext(reactant_values, " + ")]: [jointext(result_strings, ", ")]"

				if(reaction.required_temp > 0)
					if(reaction.is_cold_recipe)
						production_strings += "- Maximum temperature: [KELVIN_TO_CELSIUS(reaction.required_temp)]C ([reaction.required_temp]K)"
					else
						production_strings += "- Minimum temperature: [KELVIN_TO_CELSIUS(reaction.required_temp)]C ([reaction.required_temp]K)"

		if(length(production_strings))
			if(!entry.mechanics_text)
				entry.mechanics_text = "It can be produced as follows:<br>"
			else
				entry.mechanics_text += "<br><br>It can be produced as follows:<br>"
			entry.mechanics_text += jointext(production_strings, "<br>")

		entry.update_links()
		SScodex.add_entry_by_string(entry.display_name, entry)
		items += entry.display_name
	..()
