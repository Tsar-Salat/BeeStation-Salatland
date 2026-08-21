/obj/item/organ/cyberimp/eyes
	abstract_type = /obj/item/organ/cyberimp/eyes

/obj/item/organ/cyberimp/eyes/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity)) //They same effect as having cybernetic eyes
		to_chat(owner, span_warning("Static obfuscates your vision!"))
		owner.flash_act(visual = 1)

/obj/item/organ/cyberimp/eyes/hud
	name = "HUD implant"
	desc = "These cybernetic eyes will display a HUD over everything you see. Maybe."
	icon_state = "eye_implant"
	slot = ORGAN_SLOT_EYES
	zone = BODY_ZONE_PRECISE_EYES
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/toggle_hud)
	var/HUD_traits = list()
	/// Whether the HUD implant is on or off
	var/toggled_on = TRUE
	/// Eyecolor from the HUD
	var/hud_color = "#3CB8A5"

/obj/item/organ/cyberimp/eyes/hud/Initialize(mapload)
	. = ..()
	if(toggled_on)
		for(var/hud_trait in HUD_traits)
			add_organ_trait(hud_trait)

/obj/item/organ/cyberimp/eyes/hud/proc/toggle_hud(mob/living/carbon/human/eye_owner)
	if(toggled_on)
		toggled_on = FALSE
		for(var/hud_trait in HUD_traits)
			remove_organ_trait(hud_trait)
		balloon_alert(eye_owner, "hud disabled")
		if(hud_color)
			eye_owner.remove_eye_color(EYE_COLOR_HUD_PRIORITY)
		return
	toggled_on = TRUE
	for(var/hud_trait in HUD_traits)
		add_organ_trait(hud_trait)
	balloon_alert(eye_owner, "hud enabled")
	if(hud_color)
		eye_owner.add_eye_color_right(hud_color, EYE_COLOR_HUD_PRIORITY)

/obj/item/organ/cyberimp/eyes/hud/Insert(mob/living/carbon/human/eye_owner, special = FALSE, drop_if_replaced, pref_load)
	. = ..()
	if(toggled_on && hud_color)
		eye_owner.add_eye_color_right(hud_color, EYE_COLOR_HUD_PRIORITY, !special)

/obj/item/organ/cyberimp/eyes/hud/Remove(mob/living/carbon/human/eye_owner, special, pref_load)
	. = ..()
	if(toggled_on && hud_color)
		eye_owner.remove_eye_color(EYE_COLOR_HUD_PRIORITY, !special)

/obj/item/organ/cyberimp/eyes/hud/medical
	name = "Medical HUD implant"
	desc = "These cybernetic eye implants will display a medical HUD over everything you see."
	HUD_traits = list(TRAIT_MEDICAL_HUD)
	hud_color = "#1D8FEC"

/obj/item/organ/cyberimp/eyes/hud/security
	name = "Security HUD implant"
	desc = "These cybernetic eye implants will display a security HUD over everything you see."
	HUD_traits = list(TRAIT_SECURITY_HUD)
	hud_color = "#9A151E"

/obj/item/organ/cyberimp/eyes/hud/diagnostic
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see."
	HUD_traits = list(TRAIT_DIAGNOSTIC_HUD, TRAIT_BOT_PATH_HUD)
	hud_color = "#CC6E33"

/obj/item/organ/cyberimp/eyes/hud/security/syndicate
	name = "Contraband Security HUD Implant"
	desc = "A Cybersun Industries brand Security HUD Implant. These illicit cybernetic eye implants will display a security HUD over everything you see."
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN
	hud_color = null
