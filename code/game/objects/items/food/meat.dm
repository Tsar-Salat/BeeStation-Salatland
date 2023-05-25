//Not only meat, actually, but also snacks that are almost meat, such as fish meat or tofu


////////////////////////////////////////////FISH////////////////////////////////////////////

/obj/item/food/cubancarp
	name = "\improper Cuban carp"
	desc = "A grifftastic sandwich that burns your tongue and then leaves it numb!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "cubancarp"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/capsaicin = 1,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("fish" = 4, "batter" = 1, "hot peppers" = 1)
	foodtypes = MEAT | FRIED
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fishmeat
	name = "fish fillet"
	desc = "A fillet of some fish meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("fish" = 1)
	foodtypes = MEAT
	eatverbs = list("bite", "chew", "gnaw", "swallow", "chomp")
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fishmeat/carp
	name = "carp fillet"
	desc = "A fillet of spess carp meat."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/toxin/carpotoxin = 2,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)

/obj/item/food/fishmeat/carp/imitation
	name = "imitation carp fillet"
	desc = "Almost just like the real thing, kinda."

/obj/item/food/fishfingers
	name = "fish fingers"
	desc = "A finger of fish."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 1
	tastes = list("fish" = 1, "breadcrumbs" = 1)
	foodtypes = MEAT | FRIED
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fishandchips
	name = "fish and chips"
	desc = "I do say so myself chap."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishandchips"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("fish" = 1, "chips" = 1)
	foodtypes = MEAT | VEGETABLES | FRIED

/*
/obj/item/food/fishfry
	name = "fish fry"
	desc = "All that and no bag of chips..."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfry"
	food_reagents = list (/datum/reagent/consumable/nutriment = 6, /datum/reagent/consumable/nutriment/vitamin = 3)
	tastes = list("fish" = 1, "pan seared vegtables" = 1)
	foodtypes = SEAFOOD | VEGETABLES | FRIED
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fishtaco
	name = "fish taco"
	desc = "A taco with fish, cheese, and cabbage."
	icon_state = "fishtaco"
	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/nutriment/protein = 3, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("taco" = 4, "fish" = 2, "cheese" = 2, "cabbage" = 1)
	foodtypes = SEAFOOD | DAIRY | GRAIN | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL
*/

////////////////////////////////////////////MEATS AND ALIKE////////////////////////////////////////////

/obj/item/food/tofu
	name = "tofu"
	desc = "We all love tofu."
	icon_state = "tofu"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	tastes = list("tofu" = 1)
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/tofu/prison
	name = "soggy tofu"
	desc = "You refuse to eat this strange bean curd."
	tastes = list("sour, rotten water" = 1)
	foodtypes = GROSS

/obj/item/food/spiderleg
	name = "spider leg"
	desc = "A still twitching leg of a giant spider... you don't really want to eat this, do you?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderleg"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 3,
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/toxin = 2
	)
	tastes = list("cobwebs" = 1)
	foodtypes = MEAT | TOXIC
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/cornedbeef
	name = "corned beef and cabbage"
	desc = "Now you can feel like a real tourist vacationing in Ireland."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "cornedbeef"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("meat" = 1, "cabbage" = 1)
	foodtypes = MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/bearsteak
	name = "Filet migrawr"
	desc = "Because eating bear wasn't manly enough."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "bearsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/vitamin = 9,
		/datum/reagent/consumable/ethanol/manly_dorf = 5
	)
	tastes = list("meat" = 1, "salmon" = 1)
	foodtypes = MEAT | ALCOHOL
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_meatball
	name = "raw meatball"
	desc = "A great meal all round. Not a cord of wood. Kinda raw"
	icon_state = "raw_meatball"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/meatball_type = /obj/item/food/meatball
	var/patty_type = /obj/item/food/raw_patty

/obj/item/food/raw_meatball/make_grillable()
	AddComponent(/datum/component/grillable, meatball_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/food/raw_meatball/make_processable()
	AddElement(/datum/element/processable, TOOL_ROLLINGPIN, patty_type, 1, 20)
/obj/item/food/raw_meatball/human
	name = "strange raw meatball"
	meatball_type = /obj/item/food/meatball/human
	patty_type = /obj/item/food/raw_patty/human

/obj/item/food/raw_meatball/corgi
	name = "raw corgi meatball"
	meatball_type = /obj/item/food/meatball/corgi
	patty_type = /obj/item/food/raw_patty/corgi

/obj/item/food/raw_meatball/xeno
	name = "raw xeno meatball"
	meatball_type = /obj/item/food/meatball/xeno
	patty_type = /obj/item/food/raw_patty/xeno

/obj/item/food/raw_meatball/bear
	name = "raw bear meatball"
	meatball_type = /obj/item/food/meatball/bear
	patty_type = /obj/item/food/raw_patty/bear

/obj/item/food/raw_meatball/chicken
	name = "raw chicken meatball"
	meatball_type = /obj/item/food/meatball/chicken
	patty_type = /obj/item/food/raw_patty/chicken

/obj/item/food/meatball
	name = "meatball"
	desc = "A great meal all round. Not a cord of wood."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatball"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

/obj/item/food/meatball/human
	name = "strange meatball"

/obj/item/food/meatball/corgi
	name = "corgi meatball"

/obj/item/food/meatball/bear
	name = "bear meatball"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meatball/xeno
	name = "xenomorph meatball"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meatball/chicken
	name = "chicken meatball"
	tastes = list("chicken" = 1)
	icon_state = "chicken_meatball"

/obj/item/food/raw_patty
	name = "raw patty"
	desc = "I'm.....NOT REAAADDYY."
	icon_state = "raw_patty"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL
	var/patty_type = /obj/item/food/patty/plain

/obj/item/food/raw_patty/make_grillable()
	AddComponent(/datum/component/grillable, patty_type, rand(30 SECONDS, 40 SECONDS), TRUE)

/obj/item/food/raw_patty/human
	name = "strange raw patty"
	patty_type = /obj/item/food/patty/human

/obj/item/food/raw_patty/corgi
	name = "raw corgi patty"
	patty_type = /obj/item/food/patty/corgi

/obj/item/food/raw_patty/bear
	name = "raw bear patty"
	tastes = list("meat" = 1, "salmon" = 1)
	patty_type = /obj/item/food/patty/bear

/obj/item/food/raw_patty/xeno
	name = "raw xenomorph patty"
	tastes = list("meat" = 1, "acid" = 1)
	patty_type = /obj/item/food/patty/xeno

/obj/item/food/raw_patty/chicken
	name = "raw chicken patty"
	tastes = list("chicken" = 1)
	patty_type = /obj/item/food/patty/chicken

/obj/item/food/patty
	name = "patty"
	desc = "The nanotrasen patty is the patty for you and me!"
	icon_state = "patty"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 2)
	tastes = list("meat" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

///Exists purely for the crafting recipe (because itll take subtypes)
/obj/item/food/patty/plain

/obj/item/food/patty/human
	name = "strange patty"

/obj/item/food/patty/corgi
	name = "corgi patty"

/obj/item/food/patty/bear
	name = "bear patty"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/patty/xeno
	name = "xenomorph patty"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/patty/chicken
	name = "chicken patty"
	tastes = list("chicken" = 1)
	icon_state = "chicken_patty"

/obj/item/food/raw_sausage
	name = "raw sausage"
	desc = "A piece of mixed, long meat, but then raw"
	icon_state = "raw_sausage"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 5, /datum/reagent/consumable/nutriment/vitamin = 2)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	eatverbs = list("bite","chew","nibble","deep throat","gobble","chomp")
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/raw_sausage/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/sausage, rand(60 SECONDS, 75 SECONDS), TRUE)

/obj/item/food/sausage
	name = "sausage"
	desc = "A piece of mixed, long meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sausage"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT | BREAKFAST
	food_flags = FOOD_FINGER_FOOD
	eatverbs = list("bite", "chew", "nibble", "deep throat", "gobble", "chomp")
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE
	var/roasted = FALSE

/obj/item/food/sausage/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/salami, 6, 30)
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/american_sausage, 1, 30)

/obj/item/food/american_sausage
	name = "american sausage"
	desc = "Snip."
	icon_state = "american_sausage"

/obj/item/food/sausage/american/make_processable()
	return

/obj/item/food/salami
	name = "salami"
	desc = "A slice of cured salami."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "salami"
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 1)
	tastes = list("meat" = 1, "smoke" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/rawkhinkali
	name = "raw khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "khinkali"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/garlic = 1
	)
	tastes = list("meat" = 1, "onions" = 1, "garlic" = 1)
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/rawkhinkali/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/khinkali, rand(50 SECONDS, 60 SECONDS), TRUE)

/obj/item/food/khinkali
	name = "khinkali"
	desc = "One hundred khinkalis? Do I look like a pig?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "khinkali"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/garlic = 1
	)
	bite_consumption = 3
	tastes = list("meat" = 1, "onions" = 1, "garlic" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

/obj/item/food/meatbun
	name = "meat bun"
	desc = "Has the potential to not be dog."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatbun"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
	)
	tastes = list("bun" = 3, "meat" = 2)
	foodtypes = GRAIN | MEAT | VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/stewedsoymeat
	name = "stewed soy meat"
	desc = "Even non-vegetarians will LOVE this!"
	icon_state = "stewedsoymeat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("soy" = 1, "vegetables" = 1)
	eatverbs = list("slurp", "sip", "inhale", "drink")
	foodtypes = VEGETABLES
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/boiledspiderleg
	name = "boiled spider leg"
	desc = "A giant spider's leg that's still twitching after being cooked. Gross!"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spiderlegcooked"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 4,
		/datum/reagent/consumable/capsaicin = 4,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("hot peppers" = 1, "cobwebs" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL
	burns_on_grill = TRUE

/obj/item/food/spiderleg/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/boiledspiderleg, rand(50 SECONDS, 60 SECONDS), TRUE, TRUE)

/obj/item/food/spidereggsham
	name = "green eggs and ham"
	desc = "Would you eat them on a train? Would you eat them on a plane? Would you eat them on a state of the art corporate deathtrap floating through space?"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "spidereggsham"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	bite_consumption = 4
	tastes = list("meat" = 1, "the colour green" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/sashimi
	name = "carp sashimi"
	desc = "Celebrate surviving attack from hostile alien lifeforms by hospitalising yourself. You sure hope whoever made this is skilled."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "sashimi"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/capsaicin = 9,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("fish" = 1, "hot peppers" = 1)
	foodtypes = MEAT
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/nugget
	name = "chicken nugget"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	icon = 'icons/obj/food/meat.dmi'
	tastes = list("\"chicken\"" = 1)
	foodtypes = MEAT
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/nugget/Initialize(mapload)
	. = ..()
	var/shape = pick("lump", "star", "lizard", "corgi")
	desc = "A 'chicken' nugget vaguely shaped like a [shape]."
	icon_state = "nugget_[shape]"

/obj/item/food/pigblanket
	name = "pig in a blanket"
	desc = "A tiny sausage wrapped in a flakey, buttery roll. Free this pig from its blanket prison by eating it."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "pigblanket"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("meat" = 1, "butter" = 1)
	foodtypes = MEAT | DAIRY | GRAIN
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/bbqribs
	name = "bbq ribs"
	desc = "BBQ ribs, slathered in a healthy coating of BBQ sauce. The least vegan thing to ever exist."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "ribs"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/bbqsauce = 10
	)
	tastes = list("meat" = 3, "smokey sauce" = 1)
	foodtypes = MEAT | SUGAR

/obj/item/food/meatclown
	name = "meat clown"
	desc = "A delicious, round piece of meat clown. How horrifying."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "meatclown"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/banana = 2
	)
	tastes = list("meat" = 5, "clowns" = 3, "sixteen teslas" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/meatclown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 3 SECONDS)

//////////////////////////////////////////// KEBABS AND OTHER SKEWERS ////////////////////////////////////////////

/obj/item/food/kebab
	trash_type = /obj/item/stack/rods
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "kebab"
	w_class = WEIGHT_CLASS_NORMAL
	food_reagents = list(
	/datum/reagent/consumable/nutriment/protein = 14
	)
	tastes = list("meat" = 3, "metal" = 1)
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/kebab/human
	name = "human-kebab"
	desc = "A human meat, on a stick."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("tender meat" = 3, "metal" = 1)
	foodtypes = MEAT | GROSS

/obj/item/food/kebab/monkey
	name = "meat-kebab"
	desc = "Delicious meat, on a stick."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 16,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("meat" = 3, "metal" = 1)
	foodtypes = MEAT

/obj/item/food/kebab/tofu
	name = "tofu-kebab"
	desc = "Vegan meat, on a stick."
	food_reagents = list(/datum/reagent/consumable/nutriment/protein = 15)
	tastes = list("tofu" = 3, "metal" = 1)
	foodtypes = VEGETABLES


/obj/item/food/kebab/tail
	name = "lizard-tail kebab"
	desc = "Severed lizard tail on a stick."
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 30,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("meat" = 8, "metal" = 4, "scales" = 1)
	foodtypes = MEAT

/obj/item/food/kebab/rat
	name = "rat-kebab"
	desc = "Not so delicious rat meat, on a stick."
	icon_state = "ratkebab"
	w_class = WEIGHT_CLASS_NORMAL
	trash_type = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 10,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("rat meat" = 1, "metal" = 1)
	foodtypes = MEAT | GROSS

/obj/item/food/kebab/rat/double
	name = "double rat-kebab"
	icon_state = "doubleratkebab"
	tastes = list("rat meat" = 2, "metal" = 1)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 20,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/iron = 2
	)

/obj/item/food/kebab/fiesta
	name = "fiesta skewer"
	icon_state = "fiestaskewer"
	tastes = list("tex-mex" = 3, "cumin" = 2)
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/consumable/capsaicin = 3
	)

////////////////////////////////////// MEAT STEAKS ///////////////////////////////////////////////////////////

/obj/item/food/meat/steak
	name = "steak"
	desc = "A piece of hot spicy meat."
	icon_state = "meatsteak"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

/obj/item/food/meat/steak/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	name = "[source_item.name] steak"

/obj/item/food/meat/steak/plain
    foodtypes = MEAT

/obj/item/food/meat/steak/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | GORE

///Make sure the steak has the correct name
/obj/item/food/meat/steak/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency = 1)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	subjectname = origin_meat.subjectname
	subjectjob = origin_meat.subjectjob
	if(subjectname)
		name = "[origin_meat.subjectname] meatsteak"
	else if(subjectjob)
		name = "[origin_meat.subjectjob] meatsteak"

/obj/item/food/meat/steak/killertomato
	name = "killer tomato steak"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT // And dont let anybody tell you otherwise!

/obj/item/food/meat/steak/bear
	name = "bear steak"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meat/steak/xeno
	name = "xeno steak"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meat/steak/spider
	name = "spider steak"
	tastes = list("cobwebs" = 1)

/obj/item/food/meat/steak/goliath
	name = "goliath steak"
	desc = "A delicious, lava cooked steak."
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	icon_state = "goliathsteak"
	trash_type = null
	tastes = list("meat" = 1, "rock" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/gondola
	name = "gondola steak"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/food/meat/steak/penguin
	name = "penguin steak"
	//icon_state = "birdsteak"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/food/meat/steak/chicken
	name = "chicken steak" //Can you have chicken steaks? Maybe this should be renamed once it gets new sprites. //I concur
	//icon_state = "birdsteak"
	tastes = list("chicken" = 1)

/obj/item/food/meat/steak/plain/human/lizard
	name = "lizard steak"
	//icon_state = "birdsteak"
	tastes = list("juicy chicken" = 3, "scales" = 1)
	foodtypes = MEAT

/obj/item/food/meat/steak/meatproduct
	name = "thermally processed meat product"
	//icon_state = "meatproductsteak"
	tastes = list("enhanced char" = 2, "suspicious tenderness" = 2, "natural & artificial dyes" = 2, "emulsifying agents" = 1)

/obj/item/food/meat/steak/plain/synth
	name = "synthsteak"
	desc = "A synthetic meat steak. It doesn't look quite right, now does it?"
	icon_state = "meatsteak"
	tastes = list("meat" = 4, "cryoxandone" = 1)

/obj/item/food/meat/steak/ashflake
	name = "ashflaked steak"
	desc = "A common delicacy among miners."
	icon_state = "ashsteak"
	food_reagents = list(
		/datum/reagent/consumable/vitfro = 2
	)
	tastes = list("tough meat" = 2, "bubblegum" = 1)
	foodtypes = MEAT

//////////////////////////////// MEAT CUTLETS ///////////////////////////////////////////////////////

//Raw cutlets

/obj/item/food/meat/rawcutlet
	name = "raw cutlet"
	desc = "A raw meat cutlet."
	icon_state = "rawcutlet"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT | RAW
	var/meat_type = "meat"

/obj/item/food/meat/rawcutlet/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/plain, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/OnCreatedFromProcessing(mob/living/user, obj/item/work_tool, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat/slab))
		var/obj/item/food/meat/slab/original_slab = original_atom
		var/mutable_appearance/filling = mutable_appearance(icon, "rawcutlet_coloration")
		filling.color = original_slab.slab_color
		add_overlay(filling)
		name = "raw [original_atom.name] cutlet"
		meat_type = original_atom.name

/obj/item/food/meat/rawcutlet/plain
	foodtypes = MEAT

/obj/item/food/meat/rawcutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | RAW | GORE

/obj/item/food/meat/rawcutlet/plain/human/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/plain/human, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/plain/human/OnCreatedFromProcessing(mob/living/user, obj/item/I, list/chosen_option, atom/original_atom)
	. = ..()
	if(istype(original_atom, /obj/item/food/meat))
		var/obj/item/food/meat/origin_meat = original_atom
		subjectname = origin_meat.subjectname
		subjectjob = origin_meat.subjectjob
		if(subjectname)
			name = "raw [origin_meat.subjectname] cutlet"
		else if(subjectjob)
			name = "raw [origin_meat.subjectjob] cutlet"

/obj/item/food/meat/rawcutlet/killertomato
	name = "raw killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT

/obj/item/food/meat/rawcutlet/killertomato/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/killertomato, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/bear
	name = "raw bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meat/rawcutlet/bear/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/bear, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/xeno
	name = "raw xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meat/rawcutlet/xeno/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/xeno, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/spider
	name = "raw spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/food/meat/rawcutlet/spider/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/spider, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/gondola
	name = "raw gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/food/meat/rawcutlet/gondola/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/gondola, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/penguin
	name = "raw penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/food/meat/rawcutlet/penguin/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/penguin, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/chicken
	name = "raw chicken cutlet"
	tastes = list("chicken" = 1)

/obj/item/food/meat/rawcutlet/chicken/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/chicken, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

/obj/item/food/meat/rawcutlet/grub //grub meat is small, so its in cutlets
	name = "redgrub cutlet"
	desc = "A tough, slimy cut of raw Redgrub. Very toxic, and probably infectious, but delicious when cooked. Do not handle without proper biohazard equipment."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/toxin/slimejelly = 2
	)
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubmeat"
	bite_consumption = 1
	tastes = list("slime" = 1, "grub" = 1)
	foodtypes = RAW | MEAT | TOXIC

/obj/item/food/meat/rawcutlet/grub/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/cutlet/grub, rand(35 SECONDS, 50 SECONDS), TRUE, TRUE)

//Cooked cutlets

/obj/item/food/meat/cutlet
	name = "cutlet"
	desc = "A cooked meat cutlet."
	icon_state = "cutlet"
	bite_consumption = 2
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2
	)
	tastes = list("meat" = 1)
	foodtypes = MEAT
	burns_on_grill = TRUE

/obj/item/food/meat/cutlet/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))

///This proc handles setting up the correct meat name for the cutlet, this should definitely be changed with the food rework.
/obj/item/food/meat/cutlet/proc/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	SIGNAL_HANDLER

	if(!istype(source_item, /obj/item/food/meat/rawcutlet))
		return

	var/obj/item/food/meat/rawcutlet/original_cutlet = source_item
	name = "[original_cutlet.meat_type] cutlet"

/obj/item/food/meat/cutlet/plain

/obj/item/food/meat/cutlet/plain/human
	tastes = list("tender meat" = 1)
	foodtypes = MEAT | GORE

/obj/item/food/meat/cutlet/plain/human/on_microwave_cooked(datum/source, atom/source_item, cooking_efficiency)
	. = ..()
	if(!istype(source_item, /obj/item/food/meat))
		return

	var/obj/item/food/meat/origin_meat = source_item
	if(subjectname)
		name = "[origin_meat.subjectname] [initial(name)]"
	else if(subjectjob)
		name = "[origin_meat.subjectjob] [initial(name)]"

/obj/item/food/meat/cutlet/killertomato
	name = "killer tomato cutlet"
	tastes = list("tomato" = 1)
	foodtypes = FRUIT

/obj/item/food/meat/cutlet/bear
	name = "bear cutlet"
	tastes = list("meat" = 1, "salmon" = 1)

/obj/item/food/meat/cutlet/xeno
	name = "xeno cutlet"
	tastes = list("meat" = 1, "acid" = 1)

/obj/item/food/meat/cutlet/spider
	name = "spider cutlet"
	tastes = list("cobwebs" = 1)

/obj/item/food/meat/cutlet/gondola
	name = "gondola cutlet"
	tastes = list("meat" = 1, "tranquility" = 1)

/obj/item/food/meat/cutlet/penguin
	name = "penguin cutlet"
	tastes = list("beef" = 1, "cod fish" = 1)

/obj/item/food/meat/cutlet/chicken
	name = "chicken cutlet"
	tastes = list("chicken" = 1)

/obj/item/food/meat/cutlet/grub
	name = "redgrub rind"
	desc = "Cooking redgrub meat causes it to 'pop', and renders it non-toxic, crunchy and deliciously sweet"
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "grubsteak"
	trash_type = null
	bite_consumption = 1
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/medicine/regen_jelly = 1
	)
	tastes = list("jelly" = 1, "sweet meat" = 1, "oil" = 1)
	foodtypes = MEAT

/obj/item/food/dolphinmeat
	name = "dolphin fillet"
	desc = "A fillet of spess dolphin meat."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfillet"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	bite_consumption = 6
	tastes = list("fish" = 1,"cruelty" = 2)
	foodtypes = MEAT


