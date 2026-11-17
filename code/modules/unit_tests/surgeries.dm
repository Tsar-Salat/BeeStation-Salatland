/datum/unit_test/amputation/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/circular_saw/saw = allocate(/obj/item/circular_saw)

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 0, "Patient is somehow missing limbs before surgery")

	var/datum/surgery_operation/limb/amputate/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]

	UNLINT(surgery.success(patient.get_bodypart(BODY_ZONE_R_ARM), user, saw, list()))

	TEST_ASSERT_EQUAL(patient.get_missing_limbs().len, 1, "Patient did not lose any limbs")
	TEST_ASSERT_EQUAL(patient.get_missing_limbs()[1], BODY_ZONE_R_ARM, "Patient is missing a limb that isn't the one we operated on")

/datum/unit_test/brain_surgery/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_SURGERY)
	patient.setOrganLoss(ORGAN_SLOT_BRAIN, 20)

	TEST_ASSERT(patient.has_trauma_type(), "Patient does not have any traumas, despite being given one")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	var/datum/surgery_operation/organ/repair/brain/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient.get_organ_slot(ORGAN_SLOT_BRAIN), user, hemostat, list()))

	TEST_ASSERT(!patient.has_trauma_type(), "Patient kept their brain trauma after brain surgery")
	TEST_ASSERT(patient.getOrganLoss(ORGAN_SLOT_BRAIN) < 20, "Patient did not heal their brain damage after brain surgery")

/datum/unit_test/head_transplant/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)

	var/mob/living/carbon/human/alice = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/bob = allocate(/mob/living/carbon/human/consistent)

	alice.fully_replace_character_name(null, "Alice")
	bob.fully_replace_character_name(null, "Bob")

	var/obj/item/bodypart/head/alices_head = alice.get_bodypart(BODY_ZONE_HEAD)
	alices_head.drop_limb()

	var/obj/item/bodypart/head/bobs_head = bob.get_bodypart(BODY_ZONE_HEAD)
	bobs_head.drop_limb()

	TEST_ASSERT_EQUAL(alice.get_bodypart(BODY_ZONE_HEAD), null, "Alice still has a head after dismemberment")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Unknown", "Alice's head was dismembered, but they are not Unknown")

	TEST_ASSERT_EQUAL(bobs_head.real_name, "Bob", "Bob's head does not remember that it is from Bob")

	// Put Bob's head onto Alice's body
	var/datum/surgery_operation/prosthetic_replacement/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	user.put_in_active_hand(bobs_head)
	UNLINT(surgery.success(alice.get_bodypart(BODY_ZONE_CHEST), user, bobs_head, list()))

	TEST_ASSERT(!isnull(alice.get_bodypart(BODY_ZONE_HEAD)), "Alice has no head after prosthetic replacement")
	TEST_ASSERT_EQUAL(alice.get_visible_name(), "Bob", "Bob's head was transplanted onto Alice's body, but their name is not Bob")

/// Ensures that the tend wounds surgery can be started
/datum/unit_test/start_tend_wounds

/datum/unit_test/start_tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	patient.set_body_position(LYING_DOWN)

	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	var/obj/item/bodypart/chest/patient_chest = patient.get_bodypart(BODY_ZONE_CHEST)
	ADD_TRAIT(patient_chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds available on an undamaged, unoperated patient")

	patient.take_overall_damage(10, 10)
	TEST_ASSERT(!surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds available on a damaged, unoperated patient")

	patient_chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	TEST_ASSERT(surgery.check_availability(patient, patient, user, hemostat, BODY_ZONE_CHEST), "Tend wounds unavailable on a damaged, operated patient")

/datum/unit_test/tend_wounds/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	patient.take_overall_damage(100, 100)

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/hemostat/hemostat = allocate(/obj/item/hemostat)

	// Test that tending wounds actually lowers damage
	var/datum/surgery_operation/basic/tend_wounds/surgery = GLOB.operations.operations_by_typepath[__IMPLIED_TYPE__]
	UNLINT(surgery.success(patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))
	TEST_ASSERT(patient.getBruteLoss() < 100, "Tending brute wounds didn't lower brute damage ([patient.getBruteLoss()])")

	// Test that wearing clothing lowers heal amount
	var/mob/living/carbon/human/naked_patient = allocate(/mob/living/carbon/human/consistent)
	naked_patient.take_overall_damage(100)

	var/mob/living/carbon/human/clothed_patient = allocate(/mob/living/carbon/human/consistent)
	clothed_patient.equipOutfit(/datum/outfit/job/medical_doctor, TRUE)
	clothed_patient.take_overall_damage(100)

	UNLINT(surgery.success(naked_patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))
	UNLINT(surgery.success(clothed_patient, user, hemostat, list("[OPERATION_BRUTE_HEAL]" = 10, "[OPERATION_BRUTE_MULTIPLIER]" = 0.1)))

	TEST_ASSERT(naked_patient.getBruteLoss() < clothed_patient.getBruteLoss(), "Naked patient did not heal more from wounds tending than a clothed patient")

/// Checks all operations have a name and description
/datum/unit_test/verify_surgery_setup

/datum/unit_test/verify_surgery_setup/Run()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation), filter_replaced = FALSE))
		if (isnull(operation.name))
			TEST_FAIL("Surgery operation [operation.type] has no name set")
		if (isnull(operation.desc))
			TEST_FAIL("Surgery operation [operation.type] has no description set")

/// Checks replaced surgeries are filtered out correctly
/datum/unit_test/verify_surgery_replacements

/datum/unit_test/verify_surgery_replacements/Run()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(subtypesof(/datum/surgery_operation), filter_replaced = TRUE))
		if(!operation.replaced_by || operation.replaced_by == operation.type)
			continue
		TEST_FAIL("Surgery operation [operation.type] is replaced by [operation.replaced_by] but was not filtered by get_instances_from")

/// Tests that make incision shows up when expected
/datum/unit_test/incision_check

/datum/unit_test/incision_check/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)

	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)

	surgeon.put_in_active_hand(scalpel)
	var/list/operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(length(operations), 0, "Surgery operations were available on a standing patient")

	patient.set_body_position(LYING_DOWN)
	operations = surgeon.get_available_operations(patient, scalpel, BODY_ZONE_CHEST)
	TEST_ASSERT_EQUAL(length(operations), 1, "Expected exactly one operation on a prepped chest")

	var/list/found_operation_data = operations[operations[1]]
	var/datum/surgery_operation/operation = found_operation_data[1]
	TEST_ASSERT_EQUAL(operation.type, /datum/surgery_operation/limb/incise_skin, "The available operation was not make incision")
	TEST_ASSERT_EQUAL(found_operation_data[2], chest, "Make incision did not target the chest")

/// Checks is_location_accessible works as intended
/datum/unit_test/location_accessibility

/datum/unit_test/location_accessibility/Run()
	var/mob/living/carbon/human/test_mob = allocate(/mob/living/carbon/human/consistent)

	test_mob.equipOutfit(/datum/outfit/job/assistant/consistent)
	TEST_ASSERT(!test_mob.is_location_accessible(BODY_ZONE_CHEST), "Chest accessible under a jumpsuit")

	var/obj/item/clothing/under/jumpsuit = test_mob.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	jumpsuit.toggle_jumpsuit_adjust()
	TEST_ASSERT(test_mob.is_location_accessible(BODY_ZONE_CHEST), "Chest inaccessible with the jumpsuit rolled down")

/// Tests that a removed organ can be put back with organ manipulation
/datum/unit_test/organ_reinsertion

/datum/unit_test/organ_reinsertion/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)

	patient.set_body_position(LYING_DOWN)
	ADD_TRAIT(patient, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(chest, TRAIT_READY_TO_OPERATE, TRAIT_SOURCE_UNIT_TESTS)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED|SURGERY_VESSELS_CLAMPED)

	var/obj/item/organ/stomach/stomach = patient.get_organ_slot(ORGAN_SLOT_STOMACH)
	stomach.Remove(patient)
	surgeon.put_in_active_hand(stomach)

	var/list/operations = surgeon.get_available_operations(patient, stomach, BODY_ZONE_CHEST)
	var/found_insert = FALSE
	for(var/radial_slice in operations)
		var/datum/surgery_operation/operation = operations[radial_slice][1]
		if(istype(operation, /datum/surgery_operation/limb/organ_manipulation/internal))
			found_insert = TRUE
	TEST_ASSERT(found_insert, "Organ insertion not available with a removed stomach")

/// Makes sure surgery returns the correct implement
/datum/unit_test/surgery_implement

/datum/unit_test/surgery_implement/Run()
	var/datum/surgery_operation/limb/incise_skin/surgery = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]

	// matches via tool behaviour
	var/obj/item/scalpel/scalpel = allocate(/obj/item/scalpel)
	TEST_ASSERT_EQUAL(UNLINT(surgery.get_tool_quality(scalpel)), surgery.implements[TOOL_SCALPEL], "Wrong quality for a scalpel")

	// matches neither tool behaviour nor item type
	var/obj/item/retractor/retractor = allocate(/obj/item/retractor)
	TEST_ASSERT_EQUAL(UNLINT(surgery.get_tool_quality(retractor)), 0, "Retractor should not work")

	// matches via item type
	var/obj/item/knife/knife = allocate(/obj/item/knife)
	TEST_ASSERT_EQUAL(UNLINT(surgery.get_tool_quality(knife)), surgery.implements[/obj/item/knife], "Wrong quality for a knife")

	// matches via tool_check
	var/obj/item/claymore/claymore = allocate(/obj/item/claymore)
	TEST_ASSERT_EQUAL(UNLINT(surgery.get_tool_quality(claymore)), surgery.implements[/obj/item], "Wrong quality for a claymore")

	// fails tool_check
	var/obj/item/bikehorn/horn = allocate(/obj/item/bikehorn)
	TEST_ASSERT_EQUAL(UNLINT(surgery.get_tool_quality(horn)), 0, "Bike horn should not work")
