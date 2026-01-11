/datum/codex_entry/medical
	category = CODEX_CATEGORY_MEDICAL

/datum/codex_entry/medical/cryocell
	associated_paths = list(/obj/machinery/cryo_cell)
	mechanics_text = "The cryogenic chamber, or 'cryo', treats most damage types, most notably genetic damage. It also stabilizes patients \
	in critical condition by placing them in stasis, so they can be treated at a later time.<br>\
	<br>\
	In order for it to work, it must be loaded with chemicals, and the temperature of the solution must reach a certain point. Additionally, it \
	requires a supply of pure oxygen, provided by canisters that are attached. The most commonly used chemicals in the chambers are Cryoxadone and \
	Clonexadone. Clonexadone is more effective in treating all damage, including Genetic damage, but is otherwise functionally identical.<br>\
	<br>\
	Activating the freezer nearby, and setting it to a temperature setting below 150, is recommended before operation! Further, any clothing the patient \
	is wearing that act as an insulator will reduce its effectiveness, and should be removed.<br>\
	<br>\
	Clicking the tube with a beaker full of chemicals in hand will place it in its storage to distribute when it is activated.<br>\
	<br>\
	Grab your target with a ctrl+click, then click on the tube, with an empty hand, to place them in it. Click the tube again to open the menu. \
	Press the button on the menu to activate it. Once they have reached 100 health, click the cell and click 'Eject Occupant' to remove them. \
	Remember to turn it off, once you've finished, to save power and chemicals!"

/datum/codex_entry/medical/optable
	associated_paths = list(/obj/structure/table/optable)
	mechanics_text = "Grab your target with a ctrl+click, then click on the table with an empty hand, to place them on it.<br>Click on table after that to enable knockout function."

/datum/codex_entry/medical/operating
	associated_paths = list(/obj/machinery/computer/operating)
	mechanics_text = "This console gives information on the status of the patient on the adjacent operating table, notably their consciousness."

/datum/codex_entry/medical/sleeper
	associated_paths = list(/obj/machinery/sleeper)
	mechanics_text = "The sleeper allows you to clean the blood by means of dialysis, and to administer medication in a controlled environment.<br>\
	<br>\
	Grab your target with a ctrl+click, then drag them into the sleeper. Click the sleeper, with an empty hand, to open the menu. \
	<br>\
	You can also inject common medicines directly into their bloodstream.\
	<br>\
	Click the cell and click 'Eject Occupant' to remove them.  You can enter the cell yourself by dragging yourself into it. \
	Note that you cannot control the sleeper while inside of it."

/datum/codex_entry/medical/defibrillator
	associated_paths = list(/obj/item/defibrillator)
	mechanics_text = "A defibrillator is used to restart a stopped heart on a patient recently deceased. Revival ability is determined by the amount of damage to their body, as well as their organ health and if their soul is still around(the player is still connected to the game)."

