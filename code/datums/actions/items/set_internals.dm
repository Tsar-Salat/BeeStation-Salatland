/datum/action/item_action/set_internals
	name = "Set Internals"
	overlay_icon_state = "ab_goldborder"

/datum/action/item_action/set_internals/is_action_active(atom/movable/screen/movable/action_button/current_button)
	var/mob/living/carbon/carbon_owner = owner
	return istype(carbon_owner) && master == carbon_owner.internal
