/datum/codex_entry/stacks
	category = CODEX_CATEGORY_MATERIALS

/datum/codex_entry/stacks/telecrystal
	associated_paths = list(/obj/item/stack/sheet/telecrystal)
	antag_text = "Telecrystals can be activated by utilizing them on devices with an actively running uplink. They will not activate on unactivated uplinks."

/datum/codex_entry/stacks/rods
	associated_paths = list(/obj/item/stack/rods)
	mechanics_text = "Made from steel sheets.  You can build a grille by using it in your hand. \
	Clicking on a floor without any tiles will reinforce the floor.  You can make reinforced glass by combining rods and normal glass sheets."

/datum/codex_entry/stacks/glass
	associated_paths = list(/obj/item/stack/sheet/glass)
	mechanics_text = "Use in your hand to build a window.  Can be upgraded to reinforced glass by adding metal rods, which are made from metal sheets."

/*
/datum/codex_entry/stacks/glass_borg
	associated_paths = list(/obj/item/stack/sheet/glass/cyborg)
	mechanics_text = "Use in your hand to build a window.  Can be upgraded to reinforced glass by adding metal rods, which are made from metal sheets.<br>\
	As a synthetic, you can acquire more sheets of glass by recharging."
*/

/datum/codex_entry/stacks/glass_reinf
	associated_paths = list(/obj/item/stack/sheet/rglass)
	mechanics_text = "Use in your hand to build a window.  Reinforced glass is much stronger against damage."

/datum/codex_entry/stacks/glass_reinf_borg
	associated_paths = list(/obj/item/stack/sheet/rglass/cyborg)
	mechanics_text = "Use in your hand to build a window. Reinforced glass is much stronger against damage.<br>\
	As a synthetic, you can gain more reinforced glass by recharging."

/datum/codex_entry/stacks/material_sheet
	display_name = "material sheet"
	associated_paths = list(/obj/item/stack/sheet)
	mechanics_text = "Use in your hand to bring up the recipe menu.  If you have enough sheets, click on something on the list to build it."
