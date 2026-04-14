/datum/codex_category/plants
	name = "Plants"
	desc = "Information on plants found ingame."

/datum/codex_category/plants/Populate()
	for(var/obj/item/seeds/seed_type as anything in subtypesof(/obj/item/seeds))
		if(!initial(seed_type.plantname) || initial(seed_type.plantname) == "Plants")
			continue

		var/obj/item/seeds/S = new seed_type(null)
		var/list/mechanics = list()

		mechanics += "It matures in [S.maturation] cycles."
		mechanics += "It produces harvests every [S.production] cycles."

		if(S.yield >= 0)
			mechanics += "It has a base yield of [S.yield]."
		if(S.potency >= 0)
			mechanics += "It has a base potency of [S.potency]."

		if(length(S.mutatelist))
			mechanics += "It can mutate into the following plants:"
			for(var/mutation_path in S.mutatelist)
				var/obj/item/seeds/mutation_seed = mutation_path
				mechanics += "[FOURSPACES][initial(mutation_seed.plantname)]"

		var/datum/codex_entry/entry = new(
			_display_name = "[S.plantname] (plant)",
			_associated_paths = list(S.type),
			_mechanics_text = jointext(mechanics, "<br>"),
		)

		items += entry
		qdel(S)

	return ..()
