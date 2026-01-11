/datum/codex_category/recipes
	name = "Recipes"
	desc = "Recipes for a variety of food and crafted items."

/datum/codex_category/recipes/Initialize()
	for(var/datum/crafting_recipe/recipe in GLOB.cooking_recipes)
		if(recipe.hidden_from_codex || !recipe.result)
			continue

		var/mechanics_text = ""

		if(recipe.desc)
			mechanics_text = "[recipe.desc]<br><br>"

		mechanics_text += "This recipe requires the following ingredients:<br><ul>"

		// reqs is an associative list of type path -> amount
		for(var/requirement_path in recipe.reqs)
			var/amount = recipe.reqs[requirement_path]
			if(ispath(requirement_path, /datum/reagent))
				var/datum/reagent/reagent = requirement_path
				mechanics_text += "<li>[amount]u [initial(reagent.name)]</li>"
			else if(ispath(requirement_path, /obj/item))
				var/obj/item/item = requirement_path
				mechanics_text += "<li>[amount]x [initial(item.name)]</li>"
			else
				// Generic fallback for any other type
				mechanics_text += "<li>[amount]x [requirement_path]</li>"

		// Add catalyst info if present
		if(LAZYLEN(recipe.chem_catalysts))
			mechanics_text += "</ul><br>Required catalysts (not consumed):<br><ul>"
			for(var/catalyst_path in recipe.chem_catalysts)
				var/amount = recipe.chem_catalysts[catalyst_path]
				var/datum/reagent/catalyst = catalyst_path
				mechanics_text += "<li>[amount]u [initial(catalyst.name)]</li>"

		mechanics_text += "</ul>"

		// Add tool requirements if present
		if(LAZYLEN(recipe.tool_behaviors))
			mechanics_text += "<br>Required tools:<br><ul>"
			for(var/tool in recipe.tool_behaviors)
				mechanics_text += "<li>[tool]</li>"
			mechanics_text += "</ul>"

		var/cook_time = recipe.time / 10 // Convert deciseconds to seconds
		var/atom/movable/recipe_product = recipe.result
		mechanics_text += "<br>This recipe takes [ceil(cook_time)] second\s to craft and creates \a [initial(recipe_product.name)]."

		var/lore_text = initial(recipe_product.desc)

		var/recipe_name = recipe.name
		if(!recipe_name)
			recipe_name = reject_bad_name(initial(recipe_product.name))

		var/datum/codex_entry/entry = new( \
			_display_name = "[recipe_name] (recipe)", \
			_associated_strings = list(lowertext(recipe_name)), \
			_lore_text = lore_text, \
			_mechanics_text = mechanics_text \
		)

		entry.update_links()
		SScodex.add_entry_by_string(entry.display_name, entry)
		items += entry.display_name
	..()
