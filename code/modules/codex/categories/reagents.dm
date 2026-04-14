/datum/codex_category/reagents
	name = "Reagents"
	desc = "Chemicals and reagents, both natural and artificial."

/datum/codex_category/reagents/Populate()
	// Build a product index from the global reactions list
	var/list/reactions_by_product = list()
	for(var/reaction_path in GLOB.chemical_reactions_list)
		var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[reaction_path]
		for(var/product in reaction.results)
			if(!reactions_by_product[product])
				reactions_by_product[product] = list()
			reactions_by_product[product] += reaction

	for(var/datum/reagent/R as anything in subtypesof(/datum/reagent))
		if(isabstract(R) || !(initial(R.show_in_codex) || R == /datum/reagent/toxin)) //OOP moment
			continue

		var/datum/codex_entry/entry = new(
			_display_name = "[initial(R.name)] (chemical)",
			_lore_text = "&nbsp;&nbsp;&nbsp;&nbsp;[initial(R.description)] It apparently tastes of [initial(R.taste_description)].",
			_mechanics_text = initial(R.codex_mechanics)
		)

		var/list/production_strings = list()

		for(var/datum/chemical_reaction/reaction as anything in reactions_by_product[R])

			if(!length(reaction.required_reagents))
				continue

			var/list/reaction_info = list()
			var/list/reactant_values = list()

			for(var/datum/reagent/reactant as anything in reaction.required_reagents)
				reactant_values += "[reaction.required_reagents[reactant]]u [lowertext(initial(reactant.name))]"


			var/list/catalysts = list()

			for(var/datum/reagent/catalyst as anything in reaction.required_catalysts)
				catalysts += "[reaction.required_catalysts[catalyst]]u [lowertext(initial(catalyst.name))]"


			if(length(catalysts))
				reaction_info += "- [jointext(reactant_values, " + ")] (catalysts: [jointext(catalysts, ", ")]): [reaction.results[R]]u [lowertext(initial(R.name))]"
			else
				reaction_info += "- [jointext(reactant_values, " + ")]: [reaction.results[R]]u [lowertext(initial(R.name))]"

			if(reaction.required_temp > 0)
				if(reaction.is_cold_recipe)
					reaction_info += "- Must be below [reaction.required_temp]K"
				else
					reaction_info += "- Requires temperature of at least [reaction.required_temp]K"

			production_strings += jointext(reaction_info, "<br>")

		if(length(production_strings))
			if(!entry.mechanics_text)
				entry.mechanics_text = "It can be produced as follows:<br>"
			else
				entry.mechanics_text += "<br><br>It can be produced as follows:<br>"
			entry.mechanics_text += jointext(production_strings, "<hr>")

		items += entry

	return ..()
