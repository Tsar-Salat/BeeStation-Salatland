/datum/codex_entry/robotics
	category = CODEX_CATEGORY_ROBOTICS

/datum/codex_entry/robotics/mechas
	associated_paths = list(/obj/vehicle/sealed/mecha)
	mechanics_text = "An exosuit is a type of vehicle that can mount a variety of tools and equipment."

/datum/codex_entry/robotics/exosuit_equipment
	associated_paths = list(/obj/item/mecha_parts/mecha_equipment)
	mechanics_text = "Exosuit equipment is mounted onto specific exosuit hardpoints. It includes armor, weapons, and utility equipment used by the operator."

/datum/codex_entry/robotics/man_machine_interace
	associated_paths = list(/obj/item/mmi)
	mechanics_text = "A man-machine interface (MMI) is an interface that allows for organic brains to control synthetic bodies, such as silicons or exosuits. \
	The organic brain is placed into the MMI, and the MMI is installed into the synthetic body."

/datum/codex_entry/robotics/posibrain
	associated_paths = list(/obj/item/mmi/posibrain)
	mechanics_text = "A posibrain is an artificial intelligence that polls ghosts to inhabit it, when used inhand by a human. If a ghost accepts it, the posibrain \
	functions like a MMI, allowing the new mind to inhabit silicon or mecha bodies."

/datum/codex_entry/robotics/modsuit
	associated_paths = list(/obj/item/mod/control)
	mechanics_text = "A modular suit (MODsuit) is a type of outerwear that can be customized with various modules to augment its capabilities. \
	Modules can provide additional armor, tools, or other functionalities to the modsuit. Said modules are researched and built through the techtree, found in maintenance, or spawn exclusively on certain premade MODsuits."
