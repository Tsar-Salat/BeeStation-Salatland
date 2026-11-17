/datum/techweb_node/oldstation_surgery
	id = TECHWEB_NODE_OLDSTATION_SURGERY
	display_name = "Experimental Dissection"
	description = "Grants access to experimental dissections, which allows generation of research points."
	design_ids = list(
		"surgery_exp_dissection",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	hidden = TRUE
	show_on_wiki = FALSE

/datum/techweb_node/imp_wt_surgery
	id = TECHWEB_NODE_IMP_WT_SURGERY
	tech_tier = 2
	display_name = "Improved Wound-Tending Surgery"
	description = "Who would have known being more gentle with a hemostat decreases patient pain?"
	prereq_ids = list(TECHWEB_NODE_ADV_BIOTECH)
	design_ids = list(
		"medibot_upgrade",
		"surgery_filter_upgrade",
		"surgery_heal_upgrade",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/adv_surgery
	id = TECHWEB_NODE_ADV_SURGERY
	tech_tier = 3
	display_name = "Advanced Surgery"
	description = "When simple medicine doesn't cut it."
	prereq_ids = list(TECHWEB_NODE_IMP_WT_SURGERY)
	design_ids = list(
		"medibot_upgrade_two",
		"surgery_exp_dissection",
		"surgery_filter_upgrade_femto",
		"surgery_heal_combo",
		"surgery_heal_upgrade_femto",
		"surgery_lobotomy",
		"surgery_lobotomy_mechanic",
		"surgery_wing_reconstruction",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)

/datum/techweb_node/exp_surgery
	id = TECHWEB_NODE_EXP_SURGERY
	tech_tier = 4
	display_name = "Experimental Surgery"
	description = "When evolution isn't fast enough."
	prereq_ids = list(TECHWEB_NODE_ADV_SURGERY)
	design_ids = list(
		"medibot_upgrade_three",
		"surgery_cortex_folding",
		"surgery_cortex_folding_mechanic",
		"surgery_cortex_imprint",
		"surgery_cortex_imprint_mechanic",
		"surgery_heal_combo_upgrade",
		"surgery_ligament_hook",
		"surgery_ligament_hook_mechanic",
		"surgery_ligament_reinforcement",
		"surgery_ligament_reinforcement_mechanic",
		"surgery_muscled_veins",
		"surgery_muscled_veins_mechanic",
		"surgery_nerve_ground",
		"surgery_nerve_ground_mechanic",
		"surgery_nerve_splice",
		"surgery_nerve_splice_mechanic",
		"surgery_pacify",
		"surgery_pacify_mechanic",
		"surgery_vein_thread",
		"surgery_vein_thread_mechanic",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_2_POINTS)
	announce_channels = list(RADIO_CHANNEL_MEDICAL)
