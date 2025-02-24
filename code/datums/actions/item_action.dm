//Presets for item actions
/datum/action/item_action
	name = "Item Action"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null

/datum/action/item_action/New(Target)
	. = ..()

	// If our button state is null, use the master's icon instead
	if(master && isnull(button_icon_state))
		AddComponent(/datum/component/action_item_overlay, master)

/datum/action/item_action/vv_edit_var(var_name, var_value)
	. = ..()
	if(!. || !master)
		return

	if(var_name == NAMEOF(src, button_icon_state))
		// If someone vv's our icon either add or remove the component
		if(isnull(var_name))
			AddComponent(/datum/component/action_item_overlay, master)
		else
			qdel(GetComponent(/datum/component/action_item_overlay))

/datum/action/item_action/on_activate(mob/user, atom/target)
	if(target)
		var/obj/item/item_target = target
		item_target.ui_action_click(owner, src)
	return TRUE
