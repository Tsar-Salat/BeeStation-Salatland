/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	greyscale_colors = "#f32110"
	equip_delay_other = 60
	species_exception = list(/datum/species/golem) // now you too can be a golem boxing champion

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	greyscale_colors = "#00a500"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	greyscale_colors = "#0074fa"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	greyscale_colors = "#d2a800"

/obj/item/clothing/gloves/boxing/yellow/insulated //This is dumb
	name = "budget boxing gloves"
	desc = "Standard boxing gloves coated in a makeshift insulating coat. This can't possibly go wrong at all."
	greyscale_colors = "#d2a800"
	siemens_coefficient = 1	//Set to a default of 1, gets overridden in Initialize()

/obj/item/clothing/gloves/boxing/yellow/insulated/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0,0.25,2)
