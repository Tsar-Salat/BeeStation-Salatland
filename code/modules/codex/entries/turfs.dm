/datum/codex_entry/turfs
	category = CODEX_CATEGORY_TURFS

/datum/codex_entry/turfs/plating
	associated_paths = list(/turf/open/floor/plating)
	mechanics_text = "Plating cannot be deconstructed by normal means.<br>\
	You can build floor plating by using floor tiles on a lattice.<br>\"

/datum/codex_entry/turfs/floor_tile
	associated_paths = list(/turf/open/floor)
	mechanics_text = "You can deconstruct this by crowbar, pulling it up from the plating below.<br>\
	You can build floor tiles from material stacks.<br>"

/datum/codex_entry/turfs/wall
	associated_paths = list(/turf/closed/wall)
	mechanics_text = "You can deconstruct this by welding it, and then wrenching the girder.<br>\
	You can build a wall by using metal sheets to make a girder, then adding almost any material as plating.<br>\
	Walls are typically made of girders, plated with iron."

/datum/codex_entry/turfs/r_wall
	associated_paths = list(/turf/closed/wall/r_wall)
	mechanics_text = "You can deconstruct this by wirecutting it, and then screwdriving to reveal its support lines.<br>\
	You can build a reinforced wall by using iron sheets to make a girder, then adding plasteel as plating.<br>"
