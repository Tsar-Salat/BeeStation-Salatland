/// A license or degree a character holds. Jobs can require one, and Space Law can ask whether someone has it.
/// Players pick them for each character, limited by the character's age.
/datum/certification
	/// Stable key saved with the character. Don't change it once players have picked it.
	var/id
	var/name
	/// The schooling behind it, shown when picking
	var/desc
	/// The youngest a character can be to hold it
	var/minimum_age = AGE_MIN

/datum/certification/medical
	id = "medical"
	name = "Medical License"
	desc = "Medical school and a residency. The only license that allows surgery without a signed waiver from the patient."
	minimum_age = 26

/datum/certification/paramedic
	id = "paramedic"
	name = "Paramedic Certification"
	desc = "An EMT course, then paramedic training. Covers emergency care, not surgery."
	minimum_age = 20

/datum/certification/pharmacy
	id = "pharmacy"
	name = "Pharmacy License"
	desc = "A Doctor of Pharmacy degree."
	minimum_age = 24

/datum/certification/genetics
	id = "genetics"
	name = "Genetics License"
	desc = "A master's degree in genetics."
	minimum_age = 24

/datum/certification/biosafety
	id = "biosafety"
	name = "Biosafety Certification"
	desc = "A doctorate in virology and training in high containment labs."
	minimum_age = 27

/datum/certification/engineering
	id = "engineering"
	name = "Engineering License"
	desc = "An electrical apprenticeship."
	minimum_age = 21

/datum/certification/atmospherics
	id = "atmospherics"
	name = "Atmospherics Certification"
	desc = "A pipefitting apprenticeship."
	minimum_age = 22

/datum/certification/science
	id = "science"
	name = "Science Degree"
	desc = "A bachelor's degree in a natural science."
	minimum_age = 22

/datum/certification/robotics
	id = "robotics"
	name = "Robotics Certification"
	desc = "A bachelor's degree in mechatronics. Surgery, including taking brains for MMIs, still needs a signed waiver."
	minimum_age = 22

/datum/certification/spaceflight
	id = "spaceflight"
	name = "Spaceflight Certification"
	desc = "EVA and piloting school."
	minimum_age = 21

/datum/certification/security
	id = "security"
	name = "Security License"
	desc = "A security academy."
	minimum_age = 21

/datum/certification/bartending
	id = "bartending"
	name = "Bartending License"
	desc = "Server training, at the legal drinking age."
	minimum_age = 21

/datum/certification/law
	id = "law"
	name = "Law License"
	desc = "Law school and the bar exam."
	minimum_age = 25

/datum/certification/ordination
	id = "ordination"
	name = "Ordination"
	desc = "Seminary and ordination into a faith."
	minimum_age = 25

/datum/certification/library_science
	id = "library_science"
	name = "Library Science Degree"
	desc = "A master's degree in library science."
	minimum_age = 24

/datum/certification/logistics
	id = "logistics"
	name = "Logistics Certification"
	desc = "Supply chain management."
	minimum_age = 25

/datum/certification/command
	id = "command"
	name = "Command Certification"
	desc = "Officer school, for those who lead a crew."
	minimum_age = 30

GLOBAL_LIST_INIT(certifications, init_certifications())

/proc/init_certifications()
	. = list()
	for(var/certification_type in subtypesof(/datum/certification))
		var/datum/certification/certification = new certification_type
		.[certification.id] = certification

/// How many certifications a character of this age can hold
/proc/get_certification_slots(age)
	return 1 + (age >= CERTIFICATION_SECOND_SLOT_AGE) + (age >= CERTIFICATION_THIRD_SLOT_AGE)

/// The certifications this character actually holds: the picked ones their age allows, in pick order, up to their slot count.
/// Age can change outside the menu (randomizing, random bodies), so always go through this rather than the raw list.
/datum/preferences/proc/get_valid_certifications()
	var/age = read_character_preference(/datum/preference/numeric/age)
	var/slots = get_certification_slots(age)
	. = list()
	for(var/id in certifications)
		var/datum/certification/certification = GLOB.certifications[id]
		if(!certification || age < certification.minimum_age)
			continue
		. += id
		if(length(.) >= slots)
			break

/datum/preferences/proc/has_certification(datum/certification/certification_type)
	return initial(certification_type.id) in get_valid_certifications()
