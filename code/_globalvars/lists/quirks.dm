///Lists related to quirk selection

///Types of glasses that can be selected at character selection with the Nearsighted quirk
GLOBAL_LIST_INIT(nearsighted_glasses, list(
	"Regular" = /obj/item/clothing/glasses/regular,
	"Circle" = /obj/item/clothing/glasses/regular/circle,
	"Hipster" = /obj/item/clothing/glasses/regular/hipster,
	"Jamjar" = /obj/item/clothing/glasses/regular/jamjar,
))

///Options for the prosthetic limb quirk to choose from
GLOBAL_LIST_INIT(prosthetic_limb_choice, list(
	"Left Arm" = /obj/item/bodypart/arm/left/robot/surplus,
	"Right Arm" = /obj/item/bodypart/arm/right/robot/surplus,
	"Left Leg" = /obj/item/bodypart/leg/left/robot/surplus,
	"Right Leg" = /obj/item/bodypart/leg/right/robot/surplus,
))

GLOBAL_LIST_INIT(possible_smoker_addictions, setup_smoker_addictions(list(
	/obj/item/storage/fancy/cigarettes,
	/obj/item/storage/fancy/cigarettes/cigpack_midori,
	/obj/item/storage/fancy/cigarettes/cigpack_uplift,
	/obj/item/storage/fancy/cigarettes/cigpack_robust,
	/obj/item/storage/fancy/cigarettes/cigpack_robustgold,
	/obj/item/storage/fancy/cigarettes/cigpack_carp,
	/obj/item/storage/fancy/cigarettes/dromedaryco,
	/obj/item/storage/fancy/cigarettes/cigars,
	/obj/item/storage/fancy/cigarettes/cigars/cohiba,
	/obj/item/storage/fancy/cigarettes/cigars/havana,
	/obj/item/vape
)))

GLOBAL_LIST_INIT(possible_alcoholic_addictions, list(
	"Buckin' Bronco's Applejack" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/applejack, "reagent" = /datum/reagent/consumable/ethanol/applejack),
	"Caccavo Guaranteed Quality Tequila" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/tequila, "reagent" = /datum/reagent/consumable/ethanol/tequila),
	"Captain Pete's Cuban Spiced Rum" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/rum, "reagent" = /datum/reagent/consumable/ethanol/rum),
	"Chateau De Baton Premium Cognac" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/cognac, "reagent" = /datum/reagent/consumable/ethanol/cognac),
	"Doublebeard's Bearded Special Wine" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/wine, "reagent" = /datum/reagent/consumable/ethanol/wine),
	"Extra-strong Absinthe" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/absinthe, "reagent" = /datum/reagent/consumable/ethanol/absinthe),
	"Goldeneye Vermouth" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/vermouth, "reagent" = /datum/reagent/consumable/ethanol/vermouth),
	"Griffeater Gin" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/gin, "reagent" = /datum/reagent/consumable/ethanol/gin),
	"Jian Hard Cider" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/hcider, "reagent" = /datum/reagent/consumable/ethanol/hcider),
	"Magm-Ale" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/ale, "reagent" = /datum/reagent/consumable/ethanol/ale),
	"Phillipes Well-aged Grappa" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/grappa, "reagent" = /datum/reagent/consumable/ethanol/grappa),
	"Robert Robust's Coffee Liqueur" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/kahlua, "reagent" = /datum/reagent/consumable/ethanol/kahlua),
	"Ryo's Traditional Sake " = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/sake, "reagent" = /datum/reagent/consumable/ethanol/sake),
	"Space Beer" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/beer, "reagent" = /datum/reagent/consumable/ethanol/beer),
	"Tunguska Triple Distilled" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/vodka, "reagent" = /datum/reagent/consumable/ethanol/vodka),
	"Uncle Git's Special Reserve" = list("bottlepath" = /obj/item/reagent_containers/cup/glass/bottle/whiskey, "reagent" = /datum/reagent/consumable/ethanol/whiskey),
))

GLOBAL_LIST_INIT(possible_junkie_addictions, setup_junkie_addictions(list(
	/datum/reagent/drug/crank,
	/datum/reagent/drug/krokodil,
	/datum/reagent/medicine/morphine,
	/datum/reagent/drug/happiness,
	/datum/reagent/drug/methamphetamine,
	/datum/reagent/drug/ketamine
)))
