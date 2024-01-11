/turf/open/floor/plasteel
	icon_state = "floor"
	floor_tile = /obj/item/stack/tile/plasteel/base
	broken_states = list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")
	burnt_states = list("floorscorched1", "floorscorched2")
	max_integrity = 250

/turf/open/floor/plasteel/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's a <b>small crack</b> on the edge of it.</span>"


/turf/open/floor/plasteel/rust_heretic_act()
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	var/atom/changed_turf = ChangeTurf(/turf/open/floor/plating)
	changed_turf.AddElement(/datum/element/rust)
	return TRUE

/turf/open/floor/plasteel/update_icon_state()
	if(broken || burnt)
		return
	icon_state = base_icon_state
	return ..()

/turf/open/floor/plasteel/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/plasteel/dark
	icon_state = "darkfull"
	base_icon_state = "darkfull"
	floor_tile = /obj/item/stack/tile/plasteel/dark

/turf/open/floor/plasteel/dark/side
	icon_state = "dark"
	base_icon_state = "dark"
	floor_tile = /obj/item/stack/tile/plasteel/dark_side

/turf/open/floor/plasteel/dark/corner
	icon_state = "darkcorner"
	base_icon_state = "darkcorner"
	floor_tile = /obj/item/stack/tile/plasteel/dark_corner

/turf/open/floor/plasteel/checker
	icon_state = "checker"
	base_icon_state = "checker"
	floor_tile = /obj/item/stack/tile/plasteel/checker

/turf/open/floor/plasteel/dark/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/dark/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/plasteel/dark/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/dark/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/checker/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/white
	icon_state = "white"
	base_icon_state = "white"
	floor_tile = /obj/item/stack/tile/plasteel/white

/turf/open/floor/plasteel/white/side
	icon_state = "whitehall"
	base_icon_state = "whitehall"
	floor_tile = /obj/item/stack/tile/plasteel/white_side

/turf/open/floor/plasteel/white/corner
	icon_state = "whitecorner"
	base_icon_state = "whitecorner"
	floor_tile = /obj/item/stack/tile/plasteel/white_corner

/turf/open/floor/plasteel/cafeteria
	icon_state = "cafeteria"
	base_icon_state = "cafeteria"
	floor_tile = /obj/item/stack/tile/plasteel/cafeteria

/turf/open/floor/plasteel/white/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/white/telecomms
	initial_gas_mix = TCOMMS_ATMOS

/turf/open/floor/plasteel/white/side/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/white/corner/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/cafeteria/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/recharge_floor
	icon_state = "recharge_floor"
	base_icon_state = "recharge_floor"
	floor_tile = /obj/item/stack/tile/plasteel/recharge_floor

/turf/open/floor/plasteel/recharge_floor/asteroid
	icon_state = "recharge_floor_asteroid"
	base_icon_state = "recharge_floor_asteroid"

/turf/open/floor/plasteel/chapel
	icon_state = "chapel"
	base_icon_state = "chapel"
	floor_tile = /obj/item/stack/tile/plasteel/chapel

/turf/open/floor/plasteel/showroomfloor
	icon_state = "showroomfloor"
	base_icon_state = "showroomfloor"
	floor_tile = /obj/item/stack/tile/plasteel/showroomfloor

/turf/open/floor/plasteel/showroomfloor/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/solarpanel
	icon_state = "solarpanel"
	base_icon_state = "solarpanel"
	floor_tile = /obj/item/stack/tile/plasteel/solarpanel

/turf/open/floor/plasteel/solarpanel/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/freezer
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/plasteel/freezer

/turf/open/floor/plasteel/freezer/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plasteel/kitchen_coldroom
	name = "cold room floor"

/turf/open/floor/plasteel/kitchen_coldroom/Initialize(mapload)
	initial_gas_mix = KITCHEN_COLDROOM_ATMOS
	return ..()

/turf/open/floor/plasteel/kitchen_coldroom/freezerfloor
	icon_state = "freezerfloor"
	base_icon_state = "freezerfloor"
	floor_tile = /obj/item/stack/tile/plasteel/freezer

/turf/open/floor/plasteel/grimy
	icon_state = "grimy"
	base_icon_state = "grimy"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/plasteel/grimy

/turf/open/floor/plasteel/vaporwave
	icon_state = "pinkblack"
	base_icon_state = "pinkblack"
	floor_tile = /obj/item/stack/tile/plasteel/vaporwave

/turf/open/floor/plasteel/goonplaque
	name = "commemorative plaque"
	desc = "\"This is a plaque in honour of our comrades on the G4407 Stations. Hopefully TG4407 model can live up to your fame and fortune.\" Scratched in beneath that is a crude image of a meteor and a spaceman. The spaceman is laughing. The meteor is exploding."
	icon_state = "plaque"
	base_icon_state = "plaque"
	tiled_dirt = FALSE
	floor_tile = /obj/item/stack/tile/plasteel/goonplaque

/turf/open/floor/plasteel/goonplaque/fland
	desc = "\"This plaque commemorates all the effort that has been put by the construction workers of this station, their department experts advisors, and the many roaming spacemans, that took the effort to walk around this station discovering anomalies that has been found during it's construction. This is a heartfelt thanks from the head developer of this station, hoping that the station will last for as long as possible.\" Beneath the text, you see engraved on the plaque a weird orb like being with a propeller on his head and a smile on it's face."
	floor_tile = /obj/item/stack/tile/plasteel/goonplaque/fland

/turf/open/floor/plasteel/stairs
	icon_state = "stairs"
	base_icon_state = "stairs"
	tiled_dirt = FALSE

/turf/open/floor/plasteel/stairs/left
	icon_state = "stairs-l"
	base_icon_state = "stairs-l"

/turf/open/floor/plasteel/stairs/medium
	icon_state = "stairs-m"
	base_icon_state = "stairs-m"

/turf/open/floor/plasteel/stairs/right
	icon_state = "stairs-r"
	base_icon_state = "stairs-r"

/turf/open/floor/plasteel/stairs/old
	icon_state = "stairs-old"
	base_icon_state = "stairs-old"

/turf/open/floor/plasteel/bluespace
	icon_state = "bluespace"
	base_icon_state = "bluespace"
	desc = "Sadly, these don't seem to make you faster..."
	floor_tile = /obj/item/stack/tile/plasteel/bluespace

/turf/open/floor/plasteel/monotile
	icon_state = "monotile"
	base_icon_state = "monotile"
	floor_tile = /obj/item/stack/tile/plasteel/monotile

/turf/open/floor/plasteel/sepia
	icon_state = "sepia"
	base_icon_state = "sepia"
	desc = "Well, the flow of time is normal on these tiles, weird."
	floor_tile = /obj/item/stack/tile/plasteel/sepia

/turf/open/floor/plasteel/yellowsiding
	icon_state = "yellowsiding"
	base_icon_state = "yellowsiding"

/turf/open/floor/plasteel/yellowsiding/corner
	icon_state = "yellowcornersiding"
	base_icon_state = "yellowcornersiding"

/turf/open/floor/plasteel/tech
	icon_state = "techfloor_grey"
	base_icon_state = "techfloor_grey"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/plasteel/tech/grid
	icon_state = "techfloor_grid"
	base_icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/plasteel/techmaint
	icon_state = "techmaint"
	base_icon_state = "techmaint"
	floor_tile = /obj/item/stack/tile/

/turf/open/floor/plasteel/ridged
	icon_state = "ridged"
	base_icon_state = "ridged"
	floor_tile = /obj/item/stack/tile/ridge

/turf/open/floor/plasteel/ridged/steel
	icon_state = "steel_ridged"
	base_icon_state = "steel_ridged"

/turf/open/floor/plasteel/grid
	icon_state = "grid"
	base_icon_state = "grid"
	floor_tile = /obj/item/stack/tile/grid

/turf/open/floor/plasteel/grid/steel
	icon_state = "steel_grid"
	base_icon_state = "steel_grid"

/turf/open/floor/plasteel/ameridiner
	icon_state = "ameridiner_kitchen"
	base_icon_state = "ameridiner_kitchen"

/turf/open/floor/plasteel/tiled
	icon_state = "tiled"
	base_icon_state = "tiled"
/turf/open/floor/plasteel/tiled/light
	icon_state = "tiled_light"
	base_icon_state = "tiled_light"

/turf/open/floor/plasteel/tech
	icon_state = "techfloor_grey"
	base_icon_state = "techfloor_grey"
	floor_tile = /obj/item/stack/tile/techgrey

/turf/open/floor/plasteel/tech/grid
	icon_state = "techfloor_grid"
	base_icon_state = "techfloor_grid"
	floor_tile = /obj/item/stack/tile/techgrid

/turf/open/floor/plasteel/techmaint
	icon_state = "techmaint"
	base_icon_state = "techmaint"
	floor_tile = /obj/item/stack/tile/techmaint

/turf/open/floor/plasteel/cafeteria_red
	icon_state = "cafeteria_red"
	base_icon_state = "cafeteria_red"

/turf/open/floor/plasteel/greyish
	icon_state = "floor_light"

/turf/open/floor/plasteel/cafeteria_dark
	icon_state = "cafeteria_dark"
	base_icon_state = "cafeteria_dark"

/turf/open/floor/plasteel/smart_checker
	icon_state = "smart_checker"
	base_icon_state = "smart_checker"
