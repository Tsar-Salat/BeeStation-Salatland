
/// Phobia types that can be pulled randomly for brain traumas.
/// Also determines what phobias you can choose as your preference with the quirk.
GLOBAL_LIST_INIT(phobia_types, sort_list(list(
	"aliens",
	"anime",
	"authority",
	"birds",
	"blood",
	"clowns",
	"doctors",
	"falling",
	"fish",
	"greytide",
	"guns",
	"insects",
	"lizards",
	"robots",
	"security",
	"skeletons",
	"snakes",
	"space",
	"spiders",
	"strangers",
	"the supernatural",
)))

GLOBAL_LIST_INIT(phobia_regexes, list(
	"aliens" = construct_phobia_regex("aliens"),
	"anime" = construct_phobia_regex("anime"),
	"authority"	= construct_phobia_regex("authority"),
	"birds" = construct_phobia_regex("birds"),
	"clowns" = construct_phobia_regex("clowns"),
	"conspiracies" = construct_phobia_regex("conspiracies"),
	"doctors" = construct_phobia_regex("doctors"),
	"falling" = construct_phobia_regex("falling"),
	"greytide" = construct_phobia_regex("greytide"),
	"lizards" = construct_phobia_regex("lizards"),
	"robots" = construct_phobia_regex("robots"),
	"security" = construct_phobia_regex("security"),
	"skeletons" = construct_phobia_regex("skeletons"),
	"snakes" = construct_phobia_regex("snakes"),
	"space" = construct_phobia_regex("space"),
	"spiders" = construct_phobia_regex("spiders"),
	"strangers"	= construct_phobia_regex("strangers"),
	"the supernatural"	= construct_phobia_regex("the supernatural"),
))

GLOBAL_LIST_INIT(phobia_mobs, list(
	"aliens" = typecacheof(list(
		/mob/living/carbon/alien,
		/mob/living/simple_animal/slime,
	)),
	"anime" = typecacheof(list(
		/mob/living/simple_animal/hostile/holoparasite,
	)),
	"authority" = typecacheof(list(
		/mob/living/simple_animal/bot/secbot,
	)),
	"birds" = typecacheof(list(
		/mob/living/simple_animal/chick,
		/mob/living/simple_animal/chicken,
		/mob/living/simple_animal/hostile/retaliate/goose,
		/mob/living/simple_animal/parrot,
		/mob/living/simple_animal/pet/penguin,
	)),
	"conspiracies" = typecacheof(list(
		/mob/living/simple_animal/drone,
		/mob/living/simple_animal/pet/penguin,
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/bot/ed209,
	)),
	"doctors" = typecacheof(list(
		/mob/living/simple_animal/bot/medbot,
	)),
	"fish" = typecacheof(list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/hostile/space_dragon,
	)),
	"insects" = typecacheof(list(
		/mob/living/simple_animal/hostile/ant,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/butterfly,
		/mob/living/basic/cockroach,
		/mob/living/basic/mothroach,
	)),
	"lizards" = typecacheof(list(
		/mob/living/simple_animal/hostile/lizard,
	)),
	"robots" = typecacheof(list(
		/mob/living/silicon/robot,
		/mob/living/silicon/ai,
		/mob/living/simple_animal/bot,
		/mob/living/simple_animal/drone,
		/mob/living/simple_animal/hostile/swarmer,
	)),
	"security" = typecacheof(list(
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/bot/ed209,
	)),
	"spiders" = typecacheof(list(
		/mob/living/simple_animal/hostile/poison/giant_spider,
	)),
	"skeletons" = typecacheof(list(
		/mob/living/simple_animal/hostile/skeleton,
	)),
	"snakes" = typecacheof(list(
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
	)),
	"the supernatural" = typecacheof(list(
		/mob/dead/observer,
		/mob/living/simple_animal/hostile/retaliate/ghost,
		/mob/living/simple_animal/hostile/faithless,
		/mob/living/simple_animal/hostile/construct,
		/mob/living/simple_animal/hostile/heretic_summon,
		/mob/living/simple_animal/revenant,
		/mob/living/simple_animal/shade,
	)),
))

GLOBAL_LIST_INIT(phobia_objs, list(
	"aliens" = typecacheof(list(
		/obj/item/clothing/mask/facehugger,
		/obj/item/organ/body_egg/alien_embryo,
		/obj/structure/alien,
		/obj/item/toy/toy_xeno,
		/obj/item/clothing/suit/armor/abductor,
		/obj/item/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/melee/baton/abductor,
		/obj/item/radio/headset/abductor,
		/obj/item/scalpel/alien,
		/obj/item/hemostat/alien,
		/obj/item/retractor/alien,
		/obj/item/circular_saw/alien,
		/obj/item/surgicaldrill/alien,
		/obj/item/cautery/alien,
		/obj/item/clothing/head/helmet/abductor,
		/obj/structure/bed/abductor,
		/obj/structure/table_frame/abductor,
		/obj/structure/table/abductor,
		/obj/structure/table/optable/abductor,
		/obj/structure/closet/abductor,
		/obj/item/organ/heart/gland,
		/obj/machinery/abductor,
		/obj/item/crowbar/abductor,
		/obj/item/screwdriver/abductor,
		/obj/item/weldingtool/abductor,
		/obj/item/wirecutters/abductor,
		/obj/item/wrench/abductor,
		/obj/item/stack/sheet/mineral/abductor,
		/obj/item/toy/plush/slimeplushie,
	)),

	"anime" = typecacheof(list(
		/obj/item/clothing/under/costume/schoolgirl,
		/obj/item/katana,
		/obj/item/food/sashimi,
		/obj/item/food/chawanmushi,
		/obj/item/reagent_containers/cup/glass/bottle/sake,
		/obj/item/throwing_star,
		/obj/item/clothing/head/costume/kitty/genuine,
		/obj/item/clothing/under/syndicate/ninja,
		/obj/item/clothing/mask/gas/ninja,
		/obj/item/vibro_weapon,
		/obj/item/nullrod/scythe/vibro,
		/obj/item/energy_katana,
		/obj/item/toy/katana,
		/obj/item/nullrod/claymore/katana,
		/obj/item/katana/weak/curator,
		/obj/structure/window/paperframe,
		/obj/structure/mineral_door/paperframe,
	)),

	"authority" = typecacheof(list(
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/rank/civilian/hop,
		/obj/item/clothing/under/rank/security/head_of_security,
		/obj/item/clothing/under/rank/rnd/research_director,
		/obj/item/clothing/under/rank/medical/chief_medical_officer,
		/obj/item/clothing/under/rank/engineering/chief_engineer,
		/obj/item/clothing/under/rank/centcom/official,
		/obj/item/clothing/under/rank/centcom/commander,
		/obj/item/melee/baton/telescopic,
		/obj/item/card/id/silver,
		/obj/item/card/id/gold,
		/obj/item/card/id/captains_spare,
		/obj/item/card/id/centcom,
		/obj/machinery/door/airlock/command,
	)),

	"birds" = typecacheof(list(
		/obj/item/clothing/mask/gas/plaguedoctor,
		/obj/item/food/cracker,
		/obj/item/clothing/suit/costume/chickensuit,
		/obj/item/clothing/head/costume/chicken,
		/obj/item/clothing/suit/toggle/owlwings,
		/obj/item/clothing/under/costume/owl,
		/obj/item/clothing/mask/gas/owl_mask,
		/obj/item/clothing/under/costume/griffin,
		/obj/item/clothing/shoes/griffin,
		/obj/item/clothing/head/costume/griffin,
		/obj/item/clothing/head/helmet/space/freedom,
		/obj/item/clothing/suit/space/freedom,
	)),

	"clowns" = typecacheof(list(
		/obj/item/clothing/under/rank/civilian/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/instrument/bikehorn,
		/obj/item/modular_computer/tablet/pda/preset/clown,
		/obj/item/grown/bananapeel,
	)),

	"conspiracies" = typecacheof(list(
		/obj/item/clothing/under/rank/captain,
		/obj/item/clothing/under/rank/security/head_of_security,
		/obj/item/clothing/under/rank/engineering/chief_engineer,
		/obj/item/clothing/under/rank/medical/chief_medical_officer,
		/obj/item/clothing/under/rank/civilian/hop,
		/obj/item/clothing/under/rank/rnd/research_director,
		/obj/item/clothing/under/rank/security/head_of_security/white,
		/obj/item/clothing/under/rank/security/head_of_security/alt,
		/obj/item/clothing/under/rank/rnd/research_director/alt,
		/obj/item/clothing/under/rank/rnd/research_director/turtleneck,
		/obj/item/clothing/under/rank/captain/parade,
		/obj/item/clothing/under/rank/security/head_of_security/parade,
		/obj/item/clothing/under/rank/security/head_of_security/parade/female,
		/obj/item/clothing/head/helmet/abductor,
		/obj/item/clothing/suit/armor/abductor/vest,
		/obj/item/melee/baton/abductor,
		/obj/item/storage/belt/military/abductor,
		/obj/item/gun/energy/alien,
		/obj/item/abductor/silencer,
		/obj/item/abductor/gizmo,
		/obj/item/clothing/under/rank/centcom/official,
		/obj/item/clothing/suit/space/hardsuit/ert,
		/obj/item/clothing/suit/space/hardsuit/ert/sec,
		/obj/item/clothing/suit/space/hardsuit/ert/engi,
		/obj/item/clothing/suit/space/hardsuit/ert/med,
		/obj/item/clothing/suit/space/hardsuit/deathsquad,
		/obj/item/clothing/head/helmet/space/hardsuit/deathsquad,
		/obj/machinery/door/airlock/centcom
	)),

	"doctors" = typecacheof(list(
		/obj/item/clothing/under/rank/medical,
		/obj/item/clothing/under/rank/medical/chemist,
		/obj/item/clothing/under/rank/medical/doctor/nurse,
		/obj/item/clothing/under/rank/medical/chief_medical_officer,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill/,
		/obj/item/reagent_containers/hypospray,
		/obj/item/storage/firstaid,
		/obj/item/storage/pill_bottle,
		/obj/item/healthanalyzer,
		/obj/structure/sign/departments/medbay,
		/obj/machinery/door/airlock/medical,
		/obj/machinery/sleeper,
		/obj/machinery/stasis,
		/obj/machinery/dna_scannernew,
		/obj/machinery/cryo_cell,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/head/costume/plague,
		/obj/item/clothing/mask/gas/plaguedoctor,
	)),

	"greytide" = typecacheof(list(
		/obj/item/clothing/under/color/grey,
		/obj/item/melee/baton/security/cattleprod,
		/obj/item/spear,
		/obj/item/clothing/mask/gas/old,
	)),

	"lizards" = typecacheof(list(
		/obj/item/toy/plush/lizard_plushie,
		/obj/item/food/kebab/tail,
		/obj/item/organ/tail/lizard,
		/obj/item/reagent_containers/cup/glass/bottle/lizardwine,
		/obj/item/clothing/head/costume/lizard,
	)),

	"robots" = typecacheof(list(
		/obj/machinery/computer/upload,
		/obj/item/ai_module/,
		/obj/machinery/recharge_station,
		/obj/item/aicard,
		/obj/item/deactivated_swarmer,
		/obj/effect/mob_spawn/swarmer,
	)),

	"security" = typecacheof(list(
		/obj/item/clothing/under/rank/security/officer,
		/obj/item/clothing/under/rank/security/warden,
		/obj/item/clothing/under/rank/security/head_of_security,
		/obj/item/clothing/under/rank/security/detective,
		/obj/item/melee/baton,
		/obj/item/gun/energy/taser,
		/obj/item/restraints/handcuffs,
		/obj/item/melee/tonfa,
		/obj/machinery/door/airlock/security,
		/obj/effect/client_image_holder/securitron,
	)),

	"skeletons" = typecacheof(list(
		/obj/item/organ/tongue/bone,
		/obj/item/clothing/suit/armor/bone,
		/obj/item/dog_bone,
		/obj/item/stack/sheet/bone,
		/obj/item/food/meat/slab/human/mutant/skeleton,
		/obj/effect/decal/remains/human,
	)),

	"snakes" = typecacheof(list(
		/obj/item/rod_of_asclepius,
		/obj/item/toy/plush/snakeplushie,
	)),

	"spiders" = typecacheof(list(
		/obj/structure/spider,
	)),

	"the supernatural" = typecacheof(list(
		/obj/structure/destructible/cult,
		/obj/item/tome,
		/obj/item/melee/cultblade,
		/obj/item/restraints/legcuffs/bola/cult,
		/obj/item/clothing/suit/hooded/cultrobes,
		/obj/item/clothing/suit/hooded/cultrobes,
		/obj/item/clothing/head/hooded/cult_hoodie,
		/obj/effect/rune,
		/obj/item/stack/sheet/runed_metal,
		/obj/machinery/door/airlock/cult,
		/obj/eldritch/narsie,
		/obj/item/soulstone,
		/obj/item/clockwork,
		/obj/item/stack/sheet/brass,
		/obj/machinery/door/airlock/clockwork,
		/obj/item/clothing/suit/wizrobe,
		/obj/item/clothing/head/wizard,
		/obj/item/spellbook,
		/obj/item/staff,
		/obj/item/gun/magic/staff,
		/obj/item/gun/magic/wand,
		/obj/item/nullrod,
		/obj/item/clothing/under/rank/civilian/chaplain,
	)),
))

GLOBAL_LIST_INIT(phobia_turfs, list(
	"aliens" = typecacheof(list(
		/turf/open/floor/plating/abductor,
		/turf/open/floor/plating/abductor2,
		/turf/open/floor/mineral/abductor,
		/turf/closed/wall/mineral/abductor,
	)),
	"falling" = typecacheof(list(
		/turf/open/chasm,
		/turf/open/floor/fakepit,
	)),
	"space" = typecacheof(list(
		/turf/open/space,
		/turf/open/floor/holofloor/space,
		/turf/open/floor/fakespace
	)),
	"the supernatural" = typecacheof(list(
		/turf/open/floor/clockwork,
		/turf/closed/wall/clockwork,
		/turf/open/floor/cult,
		/turf/closed/wall/mineral/cult,
	)),
))

GLOBAL_LIST_INIT(phobia_species, list(
	"aliens" = typecacheof(list(
		/datum/species/abductor,
		/datum/species/diona,
		/datum/species/shadow,
	)),
	"anime" = typecacheof(list(
		/datum/species/human/felinid,
	)),
	"conspiracies" = typecacheof(list(
		/datum/species/abductor,
		/datum/species/lizard,
	)),
	"insects" = typecacheof(list(
		/datum/species/apid,
		/datum/species/fly,
		/datum/species/moth,
	)),
	"lizards" = typecacheof(list(
		/datum/species/lizard,
	)),
	"robots" = typecacheof(list(
		/datum/species/android,
	)),
	"skeletons" = typecacheof(list(
		/datum/species/skeleton,
		/datum/species/plasmaman,
	)),
	"the supernatural" = typecacheof(list(
		/datum/species/golem/clockwork,
		/datum/species/golem/runic,
	)),
))

///Creates a regular expression to match against the given phobia
///Capture group 2 = the scary word
///Capture group 3 = an optional suffix on the scary word
/proc/construct_phobia_regex(list/name)
	var/list/words = strings(PHOBIA_FILE, name)
	if(!length(words))
		CRASH("phobia [name] has no entries")
	var/words_match = ""
	for(var/word in words)
		words_match += "[REGEX_QUOTE(word)]|"
	words_match = copytext(words_match, 1, -1)
	return regex("(\\b|\\A)([words_match])('?s*)(\\b|\\|)", "ig")
