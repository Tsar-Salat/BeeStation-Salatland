/**
 * Allows a Carbon to toggle sign language on/off. The button is invisible for mute Carbons.
 * Theory of Operation:
 * A. If TRAIT_SIGN_LANG is added/removed, and the button is visible, then update the button.
 * B. React to presence of trait TRAIT_MUTE for quality/convenience purposes:
 * C. If TRAIT_MUTE is added, then activate and hide the Action.
 * D. If TRAIT_MUTE is then removed, then show the Action.
 *
 * * Credits:
 * - Action sprite created by @Wallemations (icons/hud/actions.dmi:sign_language)
*/
/datum/action/innate/sign_language
	name = "Sign Language"
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "sign_language"
	desc = "Allows you to communicate via sign language."
	owner_has_control = FALSE

/datum/action/innate/sign_language/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	. = ..()
	if(!. || !button)
		return
	if(HAS_TRAIT(owner, TRAIT_SIGN_LANG))
		button.icon_state = "template_active"
	else
		button.icon_state = "template"

/datum/action/innate/sign_language/Grant(mob/living/carbon/grant_to)
	..()
	RegisterSignal(grant_to, SIGNAL_REMOVETRAIT(TRAIT_MUTE), PROC_REF(on_unmuted))
	RegisterSignal(grant_to, SIGNAL_ADDTRAIT(TRAIT_MUTE), PROC_REF(on_muted))

	if (HAS_TRAIT(grant_to, TRAIT_MUTE))
		// Convenience. Mute Carbons can only speak with sign language.
		if (!active)
			on_activate()
	else
		// Convenience. Only display action if the Carbon isn't mute.
		show_action()

/datum/action/innate/sign_language/Remove(mob/living/carbon/grant_to)
	..()
	UnregisterSignal(grant_to, list(
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG),
		SIGNAL_ADDTRAIT(TRAIT_MUTE),
		SIGNAL_REMOVETRAIT(TRAIT_MUTE)
	))
	REMOVE_TRAIT(grant_to, TRAIT_SIGN_LANG, ACTION_TRAIT)

/datum/action/innate/sign_language/on_activate(mob/user, atom/target)
	active = TRUE
	ADD_TRAIT(owner, TRAIT_SIGN_LANG, ACTION_TRAIT)
	to_chat(owner, span_green("You are now communicating with sign language."))

/datum/action/innate/sign_language/on_deactivate(mob/user, atom/target)
	active = FALSE
	REMOVE_TRAIT(owner, TRAIT_SIGN_LANG, ACTION_TRAIT)
	to_chat(owner, span_green("You have stopped using sign language."))

/// Shows the linked action to the owner Carbon.
/datum/action/innate/sign_language/proc/show_action()
	owner_has_control = TRUE
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG), PROC_REF(update_icon_on_signal))
	RegisterSignal(owner, SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG), PROC_REF(update_icon_on_signal))
	give_action(owner)

/// Hides the linked action from the owner Carbon.
/datum/action/innate/sign_language/proc/hide_action()
	owner_has_control = FALSE
	UnregisterSignal(owner, list(
		SIGNAL_ADDTRAIT(TRAIT_SIGN_LANG),
		SIGNAL_REMOVETRAIT(TRAIT_SIGN_LANG)
	))
	hide_from(owner)

/// Signal handler for SIGNAL_ADDTRAIT(TRAIT_MUTE)
/// Hides the action if the signing Carbon gains TRAIT_MUTE.
/datum/action/innate/sign_language/proc/on_muted()
	SIGNAL_HANDLER

	hide_action()
	// Enable sign language if the Carbon knows it and just gained TRAIT_MUTE
	if (!HAS_TRAIT(owner, TRAIT_SIGN_LANG))
		on_activate()

/// Signal handler for SIGNAL_REMOVETRAIT(TRAIT_MUTE)
/// Re-shows the action if the signing Carbon loses TRAIT_MUTE.
/datum/action/innate/sign_language/proc/on_unmuted()
	SIGNAL_HANDLER

	show_action()
