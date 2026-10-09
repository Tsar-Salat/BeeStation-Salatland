/// A license or degree a character can hold.
/datum/qualification
	/// Stable key saved with the character. Don't change it once players have picked it.
	var/id
	var/name
	var/desc
	var/training
	/// Who the schooling makes the character, as in "trained as a physician"
	var/practitioner
	var/training_years = 0
	var/department

/datum/qualification/medical
	id = "medical"
	name = "Medical License"
	desc = "The result of years of Medical school and a residency. The only license that allows surgery without a signed waiver from the patient."
	training = "Medical school"
	practitioner = "a physician"
	training_years = 8
	department = DEPARTMENT_NAME_MEDICAL

/datum/qualification/paramedic
	id = "paramedic"
	name = "Paramedic Certification"
	desc = "An EMT course, then paramedic training. Covers emergency care, not surgery."
	training = "Paramedic training"
	practitioner = "a paramedic"
	training_years = 2
	department = DEPARTMENT_NAME_MEDICAL

/datum/qualification/pharmacy
	id = "pharmacy"
	name = "Pharmacy License"
	desc = "A Doctor of Pharmacy degree."
	training = "Pharmacy school"
	practitioner = "a pharmacist"
	training_years = 6
	department = DEPARTMENT_NAME_MEDICAL

/datum/qualification/genetics
	id = "genetics"
	name = "Genetics License"
	desc = "A master's degree in genetics."
	training = "Genetics master's"
	practitioner = "a geneticist"
	training_years = 6
	department = DEPARTMENT_NAME_MEDICAL

/datum/qualification/biosafety
	id = "biosafety"
	name = "Biosafety Certification"
	desc = "A doctorate in virology and training in high containment labs."
	training = "Virology doctorate"
	practitioner = "a virologist"
	training_years = 9
	department = DEPARTMENT_NAME_MEDICAL

/datum/qualification/engineering
	id = "engineering"
	name = "Engineering License"
	desc = "An electrical apprenticeship."
	training = "Electrical apprenticeship"
	practitioner = "an electrician"
	training_years = 3
	department = DEPARTMENT_NAME_ENGINEERING

/datum/qualification/atmospherics
	id = "atmospherics"
	name = "Atmospherics Certification"
	desc = "A pipefitting apprenticeship."
	training = "Pipefitting apprenticeship"
	practitioner = "a pipefitter"
	training_years = 4
	department = DEPARTMENT_NAME_ENGINEERING

/datum/qualification/science
	id = "science"
	name = "Science Degree"
	desc = "A bachelor's degree in a natural science."
	training = "Science degree"
	practitioner = "a scientist"
	training_years = 4
	department = DEPARTMENT_NAME_SCIENCE

/datum/qualification/robotics
	id = "robotics"
	name = "Robotics Certification"
	desc = "A bachelor's degree in mechatronics. Surgery, including taking brains for MMIs, still needs a signed waiver or direct order from a superior."
	training = "Mechatronics degree"
	practitioner = "a roboticist"
	training_years = 4
	department = DEPARTMENT_NAME_SCIENCE

/datum/qualification/spaceflight
	id = "spaceflight"
	name = "Spaceflight Certification"
	desc = "EVA and piloting school."
	training = "EVA and flight school"
	practitioner = "a pilot"
	training_years = 3
	department = DEPARTMENT_NAME_SCIENCE

/datum/qualification/security
	id = "security"
	name = "Security License"
	desc = "A security academy."
	training = "Security academy"
	practitioner = "a security officer"
	training_years = 3
	department = DEPARTMENT_NAME_SECURITY

/datum/qualification/bartending
	id = "bartending"
	name = "Bartending License"
	desc = "Server training, at the legal drinking age."
	training = "Server training"
	practitioner = "a bartender"
	training_years = 3
	department = DEPARTMENT_NAME_SERVICE

/datum/qualification/law
	id = "law"
	name = "Law License"
	desc = "Law school and the bar exam."
	training = "Law school"
	practitioner = "a lawyer"
	training_years = 7
	department = DEPARTMENT_NAME_CIVILIAN

/datum/qualification/ordination
	id = "ordination"
	name = "Ordination"
	desc = "Seminary and ordination into a faith."
	training = "Seminary"
	practitioner = "a member of the clergy"
	training_years = 7
	department = DEPARTMENT_NAME_CIVILIAN

/datum/qualification/library_science
	id = "library_science"
	name = "Library Science Degree"
	desc = "A master's degree in library science."
	training = "Library science master's"
	practitioner = "a librarian"
	training_years = 6
	department = DEPARTMENT_NAME_CIVILIAN

/datum/qualification/logistics
	id = "logistics"
	name = "Logistics Certification"
	desc = "Supply chain management."
	training = "Logistics training"
	practitioner = "a logistics manager"
	training_years = 7
	department = DEPARTMENT_NAME_CARGO

/datum/qualification/command
	id = "command"
	name = "Command Certification"
	desc = "Officer school, for those who lead a crew."
	training = "Officer school"
	practitioner = "a commanding officer"
	training_years = 12
	department = DEPARTMENT_NAME_CAPTAIN

GLOBAL_LIST_INIT(qualifications, init_qualifications())

/proc/init_qualifications()
	. = list()
	for(var/qualification_type in subtypesof(/datum/qualification))
		var/datum/qualification/qualification = new qualification_type
		.[qualification.id] = qualification

/proc/get_qualification_names(list/ids)
	. = list()
	for(var/id in ids)
		var/datum/qualification/qualification = GLOB.qualifications[id]
		if(qualification)
			. += qualification.name

/// The character's career: their picked qualifications in pick order, each as a list of
/// "id", "started" and "earned" (the ages its schooling began and ended), and "held" (earned by their current age).
/datum/preferences/proc/get_career()
	. = list()
	var/age = read_character_preference(/datum/preference/numeric/age)
	var/earned = AGE_MIN
	for(var/id in qualifications)
		var/datum/qualification/qualification = GLOB.qualifications[id]
		var/started = earned
		earned += qualification.training_years
		. += list(list("id" = id, "started" = started, "earned" = earned, "held" = earned <= age))

/datum/preferences/proc/drop_invalid_qualifications()
	for(var/id in qualifications)
		if(!GLOB.qualifications[id])
			qualifications -= id
			. = TRUE
	if(length(qualifications) > MAX_QUALIFICATIONS)
		qualifications.Cut(MAX_QUALIFICATIONS + 1)
		. = TRUE

/// Ids of the qualifications this character holds, in pick order
/datum/preferences/proc/get_valid_qualifications()
	. = list()
	for(var/list/stage as anything in get_career())
		if(stage["held"])
			. += stage["id"]
