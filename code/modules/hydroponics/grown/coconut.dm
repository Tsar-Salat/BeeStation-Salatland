/*Adds a Coconut tree and fruit to the game.
when processed, it lets you choose between coconut flesh or the coconut cup*/
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into a coconut tree."
	icon_state = "seed-coconut"
	species = "coconut"
	plantname = "Coconut Tree"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	production = 7
	yield = 3
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "coconut-grow"
	icon_dead = "coconut-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list(/datum/reagent/consumable/coconutmilk = 0.2, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.2)

/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A coconut. It's a hard nut to crack."
	icon_state = "coconut"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 4

/obj/item/grown/coconut/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	// Attach the processable element with the knife tool and specify the results
	AddElement(/datum/element/processable, TOOL_KNIFE, list(/obj/item/food/coconutflesh, /obj/item/reagent_containers/cup/coconutcup), list(5, 1), 15)

/obj/item/grown/coconut/UsedforProcessing(mob/living/user, obj/item/used_item, list/chosen_option, atom/original_atom)
	// Iterate through the chosen options to find a coconutcup
	for(var/list/current_option in chosen_option)
		if(!ispath(current_option["result"]))
			stack_trace("Current option is not an path.")

		var/atom/item = current_option["result"] // Access the "result" key directly
		stack_trace("Processing item: [item]")

		if(istype(item, /obj/item/reagent_containers))
			var/obj/item/reagent_containers/cup/coconutcup/cup = item

			// Ensure the original atom has reagents to transfer
			if(original_atom.reagents && original_atom.reagents.total_volume > 0)
				// Ensure the coconutcup has a valid reagents datum
				if(!cup.reagents)
					stack_trace("Coconut cup has no reagents datum, creating one.")
					cup.reagents = new /datum/reagents(cup)

				// Transfer the reagents from the original atom to the coconutcup
				original_atom.reagents.trans_to(cup.reagents, original_atom.reagents.total_volume)
			else
				stack_trace("Coconut has no reagents to transfer.")
			break

