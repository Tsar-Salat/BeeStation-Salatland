/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CONTROL_INTERFACES, RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligences."
	id = "mmi_posi"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500, /datum/material/copper = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/posibrain
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CONTROL_INTERFACES, RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 5000, /datum/material/plasma = 3000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/reagent_containers/cup/beaker/bluespace
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000)
	build_path = /obj/item/reagent_containers/cup/beaker/noreact
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/xlarge_beaker
	name = "X-large Beaker"
	id = "xlarge_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000)
	build_path = /obj/item/reagent_containers/cup/beaker/plastic
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)

/datum/design/meta_beaker
	name = "Metamaterial Beaker"
	id = "meta_beaker"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/glass = 2500, /datum/material/plastic = 3000, /datum/material/gold = 1000, /datum/material/titanium = 1000)
	build_path = /obj/item/reagent_containers/cup/beaker/meta
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)

/datum/design/blood_pack
	name = "Blood Pack"
	desc = "An empty pack for blood transfusions"
	id = "blood_pack"
	build_type = PROTOLATHE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/reagent_containers/blood
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)

/datum/design/bluespacesyringe
	name = "Bluespace Syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals"
	id = "bluespacesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/plasma = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/reagent_containers/syringe/bluespace
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cloning_disk
	name = "Cloning Data Disk"
	desc = "Produce additional disks for storing genetic data."
	id = "cloning_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver = 50, /datum/material/copper = 50)
	build_path = /obj/item/disk/data
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/noreactsyringe
	name = "Cryo Syringe"
	desc = "An advanced syringe that freezes reagents close to absolute 0. It can hold up to 20 units."
	id = "noreactsyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/gold = 1000)
	build_path = /obj/item/reagent_containers/syringe/cryo
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/piercesyringe
	name = "Piercing Syringe"
	desc = "A diamond-tipped syringe that pierces clothing, but not heavy armor, when launched at high velocity. It can hold up to 10 units."
	id = "piercesyringe"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 2000, /datum/material/diamond = 1000)
	build_path = /obj/item/reagent_containers/syringe/piercing
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/plasmarefiller
	name = "Plasma-Man Jumpsuit Refill"
	desc = "A refill pack for the auto-extinguisher on Plasma-man suits."
	id = "plasmarefiller" //Why did this have no plasmatech
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/plasma = 1000)
	build_path = /obj/item/extinguisher_refill
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/crewpinpointer
	name = "Crew Pinpointer"
	desc = "Allows tracking of someone's location if their suit sensors are turned to tracking beacon."
	id = "crewpinpointer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1500, /datum/material/gold = 200, /datum/material/copper = 200)
	build_path = /obj/item/pinpointer/crew
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator
	name = "Defibrillator"
	desc = "A portable defibrillator, used for resuscitating recently deceased crew."
	id = "defibrillator"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 4000, /datum/material/silver = 3000, /datum/material/gold = 1500)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_mount
	name = "Defibrillator Wall Mount"
	desc = "An all-in-one mounted frame for holding defibrillators, complete with ID-locked clamps and recharging cables."
	id = "defibmount"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	build_path = /obj/item/wallframe/defib_mount
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/defibrillator_compact
	name = "Compact Defibrillator"
	desc = "A compact defibrillator that can be worn on a belt."
	id = "defibrillator_compact"
	build_type = PROTOLATHE
	build_path = /obj/item/defibrillator/compact
	materials = list(/datum/material/iron = 16000, /datum/material/glass = 8000, /datum/material/silver = 6000, /datum/material/gold = 3000)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/genescanner
	name = "Genetic Sequence Analyzer"
	desc = "A handy hand-held analyzers for quickly determining mutations and collecting the full sequence."
	id = "genescanner"
	build_path = /obj/item/sequence_scanner
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/healthanalyzer_advanced
	name = "Advanced Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject with high accuracy."
	id = "healthanalyzer_advanced"
	build_path = /obj/item/healthanalyzer/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 2500, /datum/material/silver = 2000, /datum/material/gold = 1500)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_TOOLS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medspray
	name = "Medical Spray"
	desc = "A medical spray bottle, designed for precision application, with an unscrewable cap."
	id = "medspray"
	build_path = /obj/item/reagent_containers/medspray
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_epi
	name = "Epinephrine Medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge. Contains a powerful preservative that can delay decomposition when applied to a dead body."
	id = "medipen_epi"
	build_path = /obj/item/reagent_containers/hypospray/medipen
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/toxin/formaldehyde = 3)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_dex
	name = "Dexalin Medipen"
	desc = "An autoinjector containing dexalin, used to heal oxygen damage quickly."
	id = "medipen_dex"
	build_path = /obj/item/reagent_containers/hypospray/medipen/dexalin
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/dexalin = 10)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medipen_atropine
	name = "Atropine Medipen"
	desc = "A rapid way to save a person from a critical injury state!"
	id = "medipen_atropine"
	build_path = /obj/item/reagent_containers/hypospray/medipen/atropine
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 200)
	reagents_list = list(/datum/reagent/medicine/atropine = 10)
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_CHEMISTRY)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/surgical_drapes
	name = "Surgical Drapes"
	id = "surgical_drapes"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 2000)
	build_path = /obj/item/surgical_drapes
	category = list(RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/laserscalpel
	name = "Laser Scalpel"
	desc = "A laser scalpel used for precise cutting."
	id = "laserscalpel"
	build_path = /obj/item/scalpel/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1500, /datum/material/silver = 2000, /datum/material/gold = 1500, /datum/material/diamond = 200, /datum/material/titanium = 4000)
	category = list(RND_CATEGORY_TOOL_DESIGNS + RND_SUBCATEGORY_TOOLS_MEDICAL_ADVANCED)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/mechanicalpinches
	name = "Mechanical Pinches"
	desc = "These pinches can be either used as retractor or hemostat."
	id = "mechanicalpinches"
	build_path = /obj/item/retractor/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 12000, /datum/material/glass = 4000, /datum/material/silver = 4000, /datum/material/titanium = 5000)
	category = list(RND_CATEGORY_TOOL_DESIGNS + RND_SUBCATEGORY_TOOLS_MEDICAL_ADVANCED)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/searingtool
	name = "Searing Tool"
	desc = "Used to mend tissue together."
	id = "searingtool"
	build_path = /obj/item/cautery/advanced
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/plasma = 2000, /datum/material/uranium = 3000, /datum/material/titanium = 3000)
	category = list(RND_CATEGORY_TOOL_DESIGNS + RND_SUBCATEGORY_TOOLS_MEDICAL_ADVANCED)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/stethoscope
	name = "Stethoscope"
	desc = "A medical tool used for listening to the body. Makes you look competent"
	id = "stethoscope"
	build_path = /obj/item/clothing/neck/stethoscope
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 200)
	category = list(RND_CATEGORY_TOOL_DESIGNS + RND_SUBCATEGORY_TOOLS_MEDICAL)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/flesh_reshapers
	name = "Flesh Reshaper"
	desc = "Reshape those external features!"
	id = "fleshreshaper"
	build_path = /obj/item/flesh_shears
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 2000)
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL_ADVANCED
	)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE

/datum/design/flesh_reshapers/medical // slight variant with different color palette
	name = "Medical Flesh Reshaper"
	id = "fleshreshapermed"
	build_path = /obj/item/flesh_shears/medical
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield Eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 400, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/shield
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_gloweyes
	name = "Luminescent Eyes"
	desc = "A pair of cybernetic eyes that can emit multicolored light"
	id = "ci-gloweyes"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/glow
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	id = "ci-breather"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(/datum/material/iron = 600, /datum/material/glass = 250, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/mouth/breathing_tube
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_surgical
	name = "Surgical Arm Implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-surgery"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/surgery
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/toolset
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_botany
	name = "Botanical toolset implant"
	desc = "Everything a botanist needs in an arm implant, designed to be installed on a subject's arm."
	id = "ci-botany"
	build_type = MECHFAB | PROTOLATHE
	materials = list(/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/plastic = 2000)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/botany
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_janitor
	name = "Janitorial Arm Implant"
	desc = "A set of janitor tools fitted into an arm implant, designed to be installed on subject's arm."
	id = "ci-janitor"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 3500, /datum/material/glass = 1500, /datum/material/silver = 1500)
	construction_time = 200
	build_path = /obj/item/organ/cyberimp/arm/janitor
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_medical_hud
	name = "Medical HUD Implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/medical
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_security_hud
	name = "Security HUD Implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 750, /datum/material/gold = 750, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/security
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_diagnostic_hud
	name = "Diagnostic HUD Implant"
	desc = "These cybernetic eyes will display a diagnostic HUD over everything you see. Wiggle eyes to control."
	id = "ci-diaghud"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/eyes/hud/diagnostic
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_xray
	name = "X-ray Eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/uranium = 1000, /datum/material/diamond = 1000, /datum/material/bluespace = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/xray
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thermals
	name = "Thermal Eyes"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 600, /datum/material/gold = 600, /datum/material/plasma = 1000, /datum/material/diamond = 2000, /datum/material/copper = 200)
	build_path = /obj/item/organ/eyes/robotic/thermals
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antidrop
	name = "Anti-Drop Implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 400, /datum/material/gold = 400, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/brain/anti_drop
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/silver = 500, /datum/material/gold = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/brain/anti_stun
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_linkedsurgery
	name = "Surgical Serverlink Brain Implant"
	desc = "A brain implant with a bluespace technology that lets you perform an advanced surgery through your station research server."
	id = "ci-linkedsurgery"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 1500, /datum/material/silver = 1500, /datum/material/copper = 200, /datum/material/gold = 3000, /datum/material/diamond = 1500, /datum/material/uranium = 250, /datum/material/bluespace = 2000)
	build_path = /obj/item/organ/cyberimp/brain/linkedsurgery
	category = list(RND_CATEGORY_IMPLANTS, RND_CATEGORY_BLUESPACE_DESIGNS)
	dangerous_construction = TRUE
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment
	name = "Nutriment Pump Implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	id = "ci-nutriment"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/gold = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/nutriment
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment Pump Implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 600, /datum/material/glass = 600, /datum/material/gold = 500, /datum/material/uranium = 750, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/nutriment/plus
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 800, /datum/material/glass = 800, /datum/material/gold = 300, /datum/material/uranium = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/reviver
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_thrusters
	name = "Thrusters Set Implant"
	desc = "This implant will allow you to use gas from environment or your internals for propulsion in zero-gravity areas."
	id = "ci-thrusters"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 80
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 2000, /datum/material/silver = 1000, /datum/material/diamond = 1000, /datum/material/copper = 200)
	build_path = /obj/item/organ/cyberimp/chest/thrusters
	category = list(RND_CATEGORY_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cyberimp_hydraulic_blade
	name = "Hydraulic Blade"
	desc = "Highly dangerous implanted plasteel blade."
	id = "hydraulic_blade"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 250
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 10000, /datum/material/diamond = 3000, /datum/material/titanium = 8000, /datum/material/bluespace = 2000, /datum/material/plasma = 5000)
	build_path = /obj/item/organ/cyberimp/arm/hydraulic_blade
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200)
	build_path = /obj/item/implanter
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_IMPLANT_CASES)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case for containing an implant."
	id = "implantcase"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500)
	build_path = /obj/item/implantcase
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_IMPLANT_CASES)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_sadtrombone
	name = "Sad Trombone Implant Case"
	desc = "Makes death amusing."
	id = "implant_trombone"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/bananium = 500)
	build_path = /obj/item/implantcase/sad_trombone
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_IMPLANT_CASES)
	departmental_flags = DEPARTMENTAL_FLAG_ALL		//if you get bananium you get the sad trombones.

/datum/design/implant_chem
	name = "Chemical Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_chem"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 700)
	build_path = /obj/item/implantcase/chem
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_IMPLANT_CASES)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/implant_tracking
	name = "Tracking Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_tracking"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/tracking
	category = list(RND_CATEGORY_MEDICAL_DESIGNS + RND_SUBCATEGORY_MEDICAL_IMPLANT_CASES)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

//Cybernetic organs

/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	desc = "A cybernetic liver"
	id = "cybernetic_liver"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/liver/cybernetic
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_liver_u
	name = "Upgraded Cybernetic Liver"
	desc = "An upgraded cybernetic liver"
	id = "cybernetic_liver_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/liver/cybernetic/tier2
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	desc = "A cybernetic heart"
	id = "cybernetic_heart"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/heart/cybernetic
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_heart_u
	name = "Upgraded Cybernetic Heart"
	desc = "An upgraded cybernetic heart"
	id = "cybernetic_heart_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver=500, /datum/material/copper = 300)
	build_path = /obj/item/organ/heart/cybernetic/upgraded
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/lungs/cybernetic
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_lungs_u
	name = "Upgraded Cybernetic Lungs"
	desc = "A pair of upgraded cybernetic lungs."
	id = "cybernetic_lungs_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/copper = 300)
	build_path = /obj/item/organ/lungs/cybernetic/upgraded
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach
	name = "Cybernetic Stomach"
	desc = "A cybernetic cybernetic stomach."
	id = "cybernetic_stomach"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/copper = 200)
	build_path = /obj/item/organ/stomach/cybernetic
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_stomach_u
	name = "Upgraded Cybernetic Stomach"
	desc = "A upgraded cybernetic stomach."
	id = "cybernetic_stomach_u"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500, /datum/material/copper = 300)
	build_path = /obj/item/organ/stomach/cybernetic/tier2
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ORGANS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/wingpack
	name = "Cybernetic Wingpack"
	desc = "A compact pair of mechanical wings, which use the atmosphere to create thrust."
	id = "wingpack"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 500
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000, /datum/material/uranium = 4000, /datum/material/silver = 100, /datum/material/titanium = 8000, /datum/material/plasma = 10000)
	build_path = /obj/item/organ/wings/cybernetic
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/wingpack_alien
	name = "Advanced Cybernetic Wingpack"
	desc = "A compact pair of mechanical wings. They are equipped with miniaturized void engines, and can fly in any atmosphere, or lack thereof."
	id = "wingpack_ayy"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 1000
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 1000, /datum/material/uranium = 500, /datum/material/silver = 100, /datum/material/titanium = 8000, /datum/material/bluespace = 2000, /datum/material/plasma = 5000)
	build_path = /obj/item/organ/wings/cybernetic/ayy
	category = list(RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_IMPLANTS)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/medibot_upgrade
	name = "Medibot Upgrade"
	desc = "Automatically upgrades the effectiveness of all medibots linked to the research network."
	id = "medibot_upgrade"
	research_icon = 'icons/mob/silicon/aibots.dmi'
	research_icon_state = "medibot0"
	/// Added to linked medibots' efficiency when researched
	var/additive_multiplier = 0.125

/datum/design/medibot_upgrade/tier_two
	id = "medibot_upgrade_two"
	additive_multiplier = 0.3

/datum/design/medibot_upgrade/tier_three
	id = "medibot_upgrade_three"
	additive_multiplier = 0.075

/datum/design/medibot_upgrade/tier_four
	id = "medibot_upgrade_four"
	additive_multiplier = 0.075

/////////////////////
///Surgery Designs///
/////////////////////
/datum/design/surgery
	abstract_type = /datum/design/surgery
	id = DESIGN_ID_IGNORE
	name = null
	desc = null
	research_icon = 'icons/obj/medical/surgery_ui.dmi'
	research_icon_state = "surgery_any"
	/// Typepath of what operation this design unlocks
	var/datum/surgery_operation/surgery

/datum/design/surgery/New()
	. = ..()
	if(isnull(name))
		name = surgery::rnd_name || capitalize(surgery::name)
	if(isnull(desc))
		desc = surgery::rnd_desc || surgery::desc

/datum/design/surgery/experimental_dissection
	id = "surgery_exp_dissection"
	surgery = /datum/surgery_operation/basic/dissection
	research_icon_state = "surgery_chest"

/datum/design/surgery/lobotomy
	id = "surgery_lobotomy"
	surgery = /datum/surgery_operation/organ/lobotomy
	research_icon_state = "surgery_head"

/datum/design/surgery/lobotomy/mechanic
	id = "surgery_lobotomy_mechanic"
	surgery = /datum/surgery_operation/organ/lobotomy/mechanic

/datum/design/surgery/pacify
	id = "surgery_pacify"
	surgery = /datum/surgery_operation/organ/pacify
	research_icon_state = "surgery_head"

/datum/design/surgery/pacify/mechanic
	id = "surgery_pacify_mechanic"
	surgery = /datum/surgery_operation/organ/pacify/mechanic

/datum/design/surgery/tend_wounds_upgrade
	name = "Tend Wounds Upgrade"
	desc = "Upgrade the efficiency of the individual tend wound operations."
	id = "surgery_heal_upgrade"
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded
	research_icon_state = "surgery_chest"

/datum/design/surgery/tend_wounds_upgrade/femto
	id = "surgery_heal_upgrade_femto"
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded/master

/datum/design/surgery/tend_wounds_combo
	name = "Tend Wounds Combo"
	desc = "An alternative wound treatment operation that treats both bruises and burns at the same time, albeit less effectively than their individual counterparts."
	surgery = /datum/surgery_operation/basic/tend_wounds/combo
	id = "surgery_heal_combo"
	research_icon_state = "surgery_chest"

/datum/design/surgery/tend_wounds_combo/upgrade
	name = "Tend Wounds Combo Upgrade"
	surgery = /datum/surgery_operation/basic/tend_wounds/combo/upgraded
	id = "surgery_heal_combo_upgrade"

/datum/design/surgery/tend_wounds_combo/upgrade/femto
	desc = "The ultimate in wound treatment operations, treating both bruises and burns simultaneous and faster than their individual counterparts."
	surgery = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	id = "surgery_heal_combo_upgrade_femto"

/datum/design/surgery/filter_upgrade
	name = "Filter Blood Upgrade"
	desc = "Newfound knowledge allows us to remove the effect of toxins on the body whenever filtering someone's blood."
	surgery = /datum/surgery_operation/limb/filter_blood/upgraded
	id = "surgery_filter_upgrade"
	research_icon_state = "surgery_chest"

/datum/design/surgery/filter_upgrade/femto
	surgery = /datum/surgery_operation/limb/filter_blood/upgraded/femto
	id = "surgery_filter_upgrade_femto"

/datum/design/surgery/brainwashing
	id = "surgery_brainwashing"
	surgery = /datum/surgery_operation/organ/brainwash
	research_icon_state = "surgery_head"

/datum/design/surgery/brainwashing/mechanic
	id = "surgery_brainwashing_mechanic"
	surgery = /datum/surgery_operation/organ/brainwash/mechanic

/datum/design/surgery/nerve_splicing
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	id = "surgery_nerve_splice"
	surgery = /datum/surgery_operation/limb/bioware/nerve_splicing
	research_icon_state = "surgery_chest"

/datum/design/surgery/nerve_splicing/mechanic
	desc = "A robotic upgrade which upgrades a robotic patient's automatic systems, making them more resistant to stuns."
	id = "surgery_nerve_splice_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/nerve_splicing/mechanic

/datum/design/surgery/nerve_grounding
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	id = "surgery_nerve_ground"
	surgery = /datum/surgery_operation/limb/bioware/nerve_grounding
	research_icon_state = "surgery_chest"

/datum/design/surgery/nerve_grounding/mechanic
	desc = "A robotic upgrade which installs grounding rods into the robotic patient's system, protecting them from electrical shocks."
	id = "surgery_nerve_ground_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/nerve_grounding/mechanic

/datum/design/surgery/vein_threading
	desc = "A surgical procedure which severely reduces the amount of blood lost in case of injury."
	id = "surgery_vein_thread"
	surgery = /datum/surgery_operation/limb/bioware/vein_threading
	research_icon_state = "surgery_chest"

/datum/design/surgery/vein_threading/mechanic
	desc = "A robotic upgrade which severely reduces the amount of hydraulic fluid lost in case of injury."
	id = "surgery_vein_thread_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/vein_threading/mechanic

/datum/design/surgery/muscled_veins
	desc = "A surgical procedure which adds a muscled membrane to blood vessels, allowing a patient to pump blood without a heart."
	id = "surgery_muscled_veins"
	surgery = /datum/surgery_operation/limb/bioware/muscled_veins
	research_icon_state = "surgery_chest"

/datum/design/surgery/muscled_veins/mechanic
	desc = "A robotic upgrade which adds sophisticated hydraulics redundancies, allowing a patient to pump hydraulic fluid without an engine."
	id = "surgery_muscled_veins_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/muscled_veins/mechanic

/datum/design/surgery/ligament_hook
	desc = "A surgical procedure which reshapes the connections between torso and limbs, making it so limbs can be attached manually if severed. \
		However, this weakens the connection, making them easier to detach as well."
	id = "surgery_ligament_hook"
	surgery = /datum/surgery_operation/limb/bioware/ligament_hook
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_hook/mechanic
	desc = "A robotic upgrade which installs rapid detachment anchor points, making it so limbs can be attached manually if detached. \
		However, this weakens the connection, making them easier to detach as well."
	id = "surgery_ligament_hook_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/ligament_hook/mechanic

/datum/design/surgery/ligament_reinforcement
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
		However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	id = "surgery_ligament_reinforcement"
	surgery = /datum/surgery_operation/limb/bioware/ligament_reinforcement
	research_icon_state = "surgery_chest"

/datum/design/surgery/ligament_reinforcement/mechanic
	desc = "A surgical procedure which adds reinforced limb anchor points to the patient's chassis, preventing dismemberment. \
		However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	id = "surgery_ligament_reinforcement_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic

/datum/design/surgery/cortex_imprint
	desc = "A surgical procedure which modifies the cerebral cortex into a redundant neural pattern, making the brain able to bypass damage caused by minor brain traumas."
	id = "surgery_cortex_imprint"
	surgery = /datum/surgery_operation/limb/bioware/cortex_imprint
	research_icon_state = "surgery_head"

/datum/design/surgery/cortex_imprint/mechanic
	desc = "A surgical procedure which updates the patient's operating system to the 'latest version', whatever that means, making the brain able to bypass damage caused by minor brain traumas."
	id = "surgery_cortex_imprint_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/cortex_imprint/mechanic

/datum/design/surgery/cortex_folding
	desc = "A surgical procedure which modifies the cerebral cortex into a complex fold, giving space to non-standard neural patterns."
	id = "surgery_cortex_folding"
	surgery = /datum/surgery_operation/limb/bioware/cortex_folding
	research_icon_state = "surgery_head"

/datum/design/surgery/cortex_folding/mechanic
	desc = "A robotic upgrade which reprograms the patient's neural network in a downright eldritch programming language, giving space to non-standard neural patterns."
	id = "surgery_cortex_folding_mechanic"
	surgery = /datum/surgery_operation/limb/bioware/cortex_folding/mechanic

/datum/design/surgery/necrotic_revival
	id = "surgery_zombie"
	surgery = /datum/surgery_operation/limb/bionecrosis
	research_icon_state = "surgery_head"

/datum/design/surgery/wing_reconstruction
	id = "surgery_wing_reconstruction"
	surgery = /datum/surgery_operation/organ/fix_wings
	research_icon_state = "surgery_chest"
