/// Picks are earned one after another from AGE_MIN, and held once the character is old enough
/datum/unit_test/qualification_career

/datum/unit_test/qualification_career/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	prefs.qualifications = list("medical", "security", "paramedic")

	prefs.write_preference(age_preference, 28)
	TEST_ASSERT_EQUAL(jointext(prefs.get_valid_qualifications(), ","), "medical", "Wrong qualifications held at 28")
	var/list/career = prefs.get_career()
	TEST_ASSERT_EQUAL(career[2]["earned"], 29, "Security License earned at the wrong age")

	prefs.write_preference(age_preference, 31)
	TEST_ASSERT_EQUAL(jointext(prefs.get_valid_qualifications(), ","), "medical,security,paramedic", "Wrong qualifications held at 31")

/// Jobs need all their qualifications, and some need one held for years
/datum/unit_test/job_character_requirements

/datum/unit_test/job_character_requirements/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	var/datum/job/doctor = SSjob.get_job_type(/datum/job/medical_doctor)
	var/datum/job/cmo = SSjob.get_job_type(/datum/job/chief_medical_officer)
	var/datum/job/assistant = SSjob.get_job_type(/datum/job/assistant)

	prefs.qualifications = list()
	prefs.write_preference(age_preference, 40)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_UNAVAILABLE_QUALIFICATION, "Medical Doctor without a Medical License")
	TEST_ASSERT_EQUAL(assistant.check_character_requirements(prefs), JOB_AVAILABLE, "Assistant needed something")

	prefs.qualifications = list("medical")
	prefs.write_preference(age_preference, 25)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_UNAVAILABLE_QUALIFICATION_YEARS, "Medical Doctor before medical school ended")

	prefs.write_preference(age_preference, 26)
	TEST_ASSERT_EQUAL(doctor.check_character_requirements(prefs), JOB_AVAILABLE, "Medical Doctor unavailable at 26")
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_UNAVAILABLE_QUALIFICATION, "CMO without a Pharmacy License")

	prefs.qualifications = list("medical", "pharmacy")
	prefs.write_preference(age_preference, 32)
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_UNAVAILABLE_QUALIFICATION_YEARS, "CMO with a new Medical License")

	prefs.write_preference(age_preference, 35)
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_AVAILABLE, "CMO unavailable at 35")

	prefs.qualifications = list("pharmacy", "medical")
	TEST_ASSERT_EQUAL(cmo.check_character_requirements(prefs), JOB_UNAVAILABLE_QUALIFICATION_YEARS, "CMO at 35 after pharmacy school")
	TEST_ASSERT_EQUAL(cmo.get_minimum_character_age(prefs), 41, "Wrong CMO age after pharmacy school")

/// Qualifications and the jobs that use them are set up sensibly
/datum/unit_test/qualification_setup

/datum/unit_test/qualification_setup/Run()
	TEST_ASSERT_EQUAL(length(GLOB.qualifications), length(subtypesof(/datum/qualification)), "Two qualifications share an id")
	for(var/id in GLOB.qualifications)
		var/datum/qualification/qualification = GLOB.qualifications[id]
		TEST_ASSERT(qualification.training && qualification.practitioner, "[qualification.type] has no training or practitioner")
		TEST_ASSERT(qualification.training_years > 0, "[qualification.type] takes no training")
		TEST_ASSERT(qualification.department, "[qualification.type] has no department")

	var/list/unneeded = GLOB.qualifications.Copy()
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(!length(job.qualifications))
			continue
		TEST_ASSERT(length(job.qualifications) <= MAX_QUALIFICATIONS, "[job.type] needs more qualifications than a character can pick")
		// Training for the ones needed longest first meets every requirement soonest
		var/list/by_years = sortTim(job.qualifications.Copy(), GLOBAL_PROC_REF(cmp_numeric_dsc), associative = TRUE)
		var/earned = AGE_MIN
		var/youngest = AGE_MIN
		for(var/datum/qualification/qualification_type as anything in by_years)
			TEST_ASSERT(GLOB.qualifications[initial(qualification_type.id)], "[job.type] needs a qualification that isn't registered")
			unneeded -= initial(qualification_type.id)
			earned += initial(qualification_type.training_years)
			youngest = max(youngest, earned + by_years[qualification_type])
		TEST_ASSERT(youngest <= AGE_MAX, "[job.type] needs more years than any character has")
	TEST_ASSERT(!length(unneeded), "No job needs [jointext(unneeded, ", ")]")

/// The server refuses picks a client shouldn't be able to make
/datum/unit_test/qualification_picking

/datum/unit_test/qualification_picking/Run()
	var/datum/preferences/mock/prefs = new
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	var/datum/preference_middleware/qualifications/middleware = new(prefs)

	prefs.write_preference(age_preference, 25)
	TEST_ASSERT(!middleware.give_qualification(list("qualification" = "not_a_qualification"), null), "Unknown qualification accepted")
	TEST_ASSERT(!middleware.give_qualification(list("qualification" = "medical"), null), "Medical License picked at 25")

	prefs.write_preference(age_preference, 26)
	TEST_ASSERT(middleware.give_qualification(list("qualification" = "medical"), null), "Medical License refused at 26")
	TEST_ASSERT(!middleware.give_qualification(list("qualification" = "security"), null), "Security License picked with no time left")

	prefs.write_preference(age_preference, 40)
	TEST_ASSERT(middleware.give_qualification(list("qualification" = "security"), null), "Security License refused at 40")
	TEST_ASSERT(middleware.give_qualification(list("qualification" = "paramedic"), null), "Paramedic Certification refused at 40")
	TEST_ASSERT(!middleware.give_qualification(list("qualification" = "engineering"), null), "Picked past MAX_QUALIFICATIONS")

	TEST_ASSERT(middleware.remove_qualification(list("qualification" = "paramedic"), null), "Removing a pick failed")
	TEST_ASSERT_EQUAL(jointext(prefs.qualifications, ","), "medical,security", "Wrong picks after removing one")

	prefs.qualifications = list("medical", "security", "paramedic")
	TEST_ASSERT(middleware.move_qualification(list("qualification" = "paramedic", "position" = 1), null), "Moving a pick failed")
	TEST_ASSERT_EQUAL(jointext(prefs.qualifications, ","), "paramedic,medical,security", "Wrong order after moving a pick first")
	TEST_ASSERT(middleware.move_qualification(list("qualification" = "paramedic", "position" = 3), null), "Moving a pick failed")
	TEST_ASSERT_EQUAL(jointext(prefs.qualifications, ","), "medical,security,paramedic", "Wrong order after moving a pick last")
	TEST_ASSERT(!middleware.move_qualification(list("qualification" = "engineering", "position" = 1), null), "Moved a qualification that wasn't picked")

	qdel(middleware)

/// Roundstart and latejoin eligibility check the character's qualifications
/datum/unit_test/job_eligibility_qualifications

/datum/unit_test/job_eligibility_qualifications/Run()
	var/mob/dead/new_player/authenticated/new_player = allocate(/mob/dead/new_player/authenticated)
	new_player.mind = new /datum/mind
	var/datum/client_interface/mock_client = new
	mock_client.prefs = new /datum/preferences/mock()
	new_player.mock_client = mock_client
	var/datum/preference/age_preference = GLOB.preference_entries[/datum/preference/numeric/age]
	var/datum/job/doctor = SSjob.get_job_type(/datum/job/medical_doctor)

	mock_client.prefs.write_preference(age_preference, 25)
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(new_player, doctor), JOB_UNAVAILABLE_QUALIFICATION, "Medical Doctor without a Medical License")

	mock_client.prefs.qualifications = list("medical")
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(new_player, doctor), JOB_UNAVAILABLE_QUALIFICATION_YEARS, "Medical Doctor before medical school ended")

	mock_client.prefs.write_preference(age_preference, 26)
	TEST_ASSERT_EQUAL(SSjob.check_job_eligibility(new_player, doctor), JOB_AVAILABLE, "Medical Doctor unavailable at 26")

/// A random body too young for its job has its age rolled again within the job's range
/datum/unit_test/random_body_job_age

/datum/unit_test/random_body_job_age/Run()
	var/datum/job/warden = SSjob.get_job_type(/datum/job/warden)
	var/datum/client_interface/mock_client = new
	mock_client.prefs = new /datum/preferences/mock()
	mock_client.prefs.qualifications = list("command", "security")
	mock_client.prefs.write_preference(GLOB.preference_entries[/datum/preference/choiced/random_body], RANDOM_ENABLED)
	mock_client.prefs.randomize = list("age" = RANDOM_ENABLED)
	var/youngest = warden.get_minimum_character_age(mock_client.prefs)

	for(var/i in 1 to 20)
		mock_client.prefs.write_preference(GLOB.preference_entries[/datum/preference/numeric/age], AGE_MAX)
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		mock_client.mob = human
		human.apply_prefs_job(mock_client, warden)
		TEST_ASSERT(human.age >= youngest, "Warden rolled at [human.age], under [youngest]")

/// Picks that were removed from the game, or are past MAX_QUALIFICATIONS, are dropped when the character loads
/datum/unit_test/invalid_qualifications_dropped

/datum/unit_test/invalid_qualifications_dropped/Run()
	var/datum/preferences/mock/prefs = new
	prefs.qualifications = list("removed_qualification", "medical", "security", "paramedic", "engineering")
	TEST_ASSERT(prefs.drop_invalid_qualifications(), "Invalid qualifications not dropped")
	TEST_ASSERT_EQUAL(jointext(prefs.qualifications, ","), "medical,security,paramedic", "Wrong picks after dropping")
	TEST_ASSERT(!prefs.drop_invalid_qualifications(), "Dropped something with nothing to drop")
