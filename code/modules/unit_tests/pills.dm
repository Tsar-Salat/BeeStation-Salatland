/datum/unit_test/pills/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/tox/pill = allocate(/obj/item/reagent_containers/pill/tox)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/toxin), FALSE, "Human somehow has iron before taking pill")

	pill.attack(human, human)
	human.Life()

	TEST_ASSERT(human.has_reagent(/datum/reagent/toxin), "Human doesn't have iron after taking pill")
