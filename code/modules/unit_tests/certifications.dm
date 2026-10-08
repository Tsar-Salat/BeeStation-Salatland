/// Characters hold one certification, a second from CERTIFICATION_SECOND_SLOT_AGE and a third from CERTIFICATION_THIRD_SLOT_AGE
/datum/unit_test/certification_slots

/datum/unit_test/certification_slots/Run()
	TEST_ASSERT_EQUAL(get_certification_slots(AGE_MIN), 1, "A new adult did not get one slot")
	TEST_ASSERT_EQUAL(get_certification_slots(CERTIFICATION_SECOND_SLOT_AGE - 1), 1, "The second slot opened early")
	TEST_ASSERT_EQUAL(get_certification_slots(CERTIFICATION_SECOND_SLOT_AGE), 2, "The second slot did not open")
	TEST_ASSERT_EQUAL(get_certification_slots(CERTIFICATION_THIRD_SLOT_AGE), 3, "The third slot did not open")
	TEST_ASSERT_EQUAL(get_certification_slots(AGE_MAX), 3, "There are more than three slots")

/// Only the picks a character's age allows count, in pick order, up to their slot count
/datum/unit_test/certification_valid_picks

/datum/unit_test/certification_valid_picks/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	prefs.certifications = list("medical", "paramedic", "security", "engineering")

	prefs.write_preference(age_preference, 21)
	TEST_ASSERT_EQUAL(jointext(prefs.get_valid_certifications(), ","), "paramedic", "A 21 year old held certifications they are too young for, or more than one")

	prefs.write_preference(age_preference, 40)
	TEST_ASSERT_EQUAL(jointext(prefs.get_valid_certifications(), ","), "medical,paramedic,security", "A 40 year old did not hold their first three picks")

/// Jobs need their certification and their age, and entry jobs need neither
/datum/unit_test/job_character_requirements

/datum/unit_test/job_character_requirements/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	var/datum/job/doctor = SSjob.get_job_type(/datum/job/medical_doctor)
	var/datum/job/cmo = SSjob.get_job_type(/datum/job/chief_medical_officer)
	var/datum/job/assistant = SSjob.get_job_type(/datum/job/assistant)

	prefs.certifications = list()
	prefs.write_preference(age_preference, 40)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_UNAVAILABLE_CERTIFICATION, "A Medical Doctor didn't need a Medical License")
	TEST_ASSERT_EQUAL(assistant.check_character_requirements(prefs), JOB_AVAILABLE, "An Assistant needed something")

	prefs.certifications = list("medical")
	prefs.write_preference(age_preference, 25)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_UNAVAILABLE_CHARACTER_AGE, "A 25 year old could be a Medical Doctor")

	prefs.write_preference(age_preference, 26)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_AVAILABLE, "A 26 year old with a Medical License could not be a Medical Doctor")
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_UNAVAILABLE_CHARACTER_AGE, "A 26 year old could be the CMO")

	prefs.write_preference(age_preference, 35)
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_AVAILABLE, "A 35 year old with a Medical License could not be the CMO")

/// Certifications and the jobs that use them are set up sensibly
/datum/unit_test/certification_setup

/datum/unit_test/certification_setup/Run()
	TEST_ASSERT_EQUAL(length(GLOB.certifications), length(subtypesof(/datum/certification)), "Two certifications share an id")
	for(var/id in GLOB.certifications)
		var/datum/certification/certification = GLOB.certifications[id]
		TEST_ASSERT(certification.minimum_age >= AGE_MIN && certification.minimum_age <= AGE_MAX, "[certification.type] has a minimum age outside AGE_MIN to AGE_MAX")

	for(var/datum/job/job as anything in SSjob.all_occupations)
		TEST_ASSERT(job.minimum_character_age <= AGE_MAX, "[job.type] has a minimum age no character can reach")
		if(!job.certification)
			continue
		TEST_ASSERT(GLOB.certifications[initial(job.certification.id)], "[job.type] needs a certification that isn't registered")
		if(job.minimum_character_age)
			TEST_ASSERT(job.minimum_character_age > initial(job.certification.minimum_age), "[job.type] has a minimum age that its certification already covers")

/// The server refuses picks a client shouldn't be able to make
/datum/unit_test/certification_picking

/datum/unit_test/certification_picking/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	var/datum/preference_middleware/certifications/middleware = new(prefs)

	prefs.write_preference(age_preference, 25)
	TEST_ASSERT(!middleware.give_certification(list("certification" = "not_a_certification"), null), "An unknown certification was accepted")
	TEST_ASSERT(!middleware.give_certification(list("certification" = "medical"), null), "A 25 year old picked a Medical License")

	prefs.write_preference(age_preference, 26)
	TEST_ASSERT(middleware.give_certification(list("certification" = "medical"), null), "A 26 year old could not pick a Medical License")

	prefs.certifications = list()
	prefs.write_preference(age_preference, 21)
	TEST_ASSERT(middleware.give_certification(list("certification" = "security"), null), "A 21 year old could not pick a Security License")
	TEST_ASSERT(!middleware.give_certification(list("certification" = "engineering"), null), "A 21 year old picked a second certification")

	prefs.certifications = list("medical")
	TEST_ASSERT(middleware.give_certification(list("certification" = "security"), null), "A pick the character is too young for blocked a new one")
	TEST_ASSERT_EQUAL(jointext(prefs.certifications, ","), "security", "A pick the character is too young for was not dropped")

	TEST_ASSERT(middleware.remove_certification(list("certification" = "security"), null), "Removing a pick failed")
	TEST_ASSERT_EQUAL(length(prefs.certifications), 0, "The removed pick is still there")

	qdel(middleware)
