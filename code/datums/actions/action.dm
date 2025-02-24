/**
 * # Action system
 *
 * A simple base for an modular behavior attached to atom or datum.
 */
/datum/action
	/// The name of the action
	var/name = "Generic Action"
	/// The description of what the action does, shown in button tooltips
	var/desc
	/// The datum the action is attached to. If the master datum is deleted, the action is as well.
	/// Set in New() via the proc link_to().
	/// DO NOT ASSIGN TO THIS VARIABLE, ASSIGN IT ON /NEW()
	VAR_PRIVATE/datum/master
	/// Where any buttons we create should be by default. Accepts screen_loc and location defines
	var/default_button_position = SCRN_OBJ_IN_LIST
	/// This is who currently owns the action, and most often, this is who is using the action if it is triggered
	/// This can be the same as "target" but is not ALWAYS the same - this is set and unset with Grant() and Remove()
	var/mob/owner
	// =====================================
	// Action Behaviour
	// =====================================
	/// Flags that will determine of the owner / user of the action can... use the action
	var/check_flags = NONE
	/// Whether the button becomes transparent when it can't be used, or just reddened
	var/transparent_when_unavailable = TRUE
	/// If TRUE, this action button will be shown to observers / other mobs who view from this action's owner's eyes.
	/// Used in [/mob/proc/show_other_mob_action_buttons]
	var/show_to_observers = TRUE

	/// Setting for intercepting clicks before activating the ability
	var/requires_target = FALSE
	/// The cooldown added onto the user's next click. Requires requires_target
	var/click_cd_override = CLICK_CD_CLICK_ABILITY
	/// If toggleable, deactivate will be called when the action button is pressed after
	/// being activated.
	var/toggleable = FALSE
	// =====================================
	// Action Appearance
	// =====================================
	/// The style the button's tooltips appear to be
	var/buttontooltipstyle = ""

	/// This is the file for the BACKGROUND underlay icon of the button
	var/background_icon = 'icons/hud/actions/backgrounds.dmi'
	/// This is the icon state state for the BACKGROUND underlay icon of the button
	/// (If set to ACTION_BUTTON_DEFAULT_BACKGROUND, uses the hud's default background)
	var/background_icon_state = ACTION_BUTTON_DEFAULT_BACKGROUND

	/// This is the file for the icon that appears on the button
	var/button_icon = 'icons/hud/actions.dmi'
	/// This is the icon state for the icon that appears on the button
	var/button_icon_state = "default"

	/// This is the file for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon = 'icons/hud/actions/backgrounds.dmi'
	/// This is the icon state for any FOREGROUND overlay icons on the button (such as borders)
	var/overlay_icon_state

	/// This is the icon state for any FOREGROUND overlay icons on the button (such as borders)
	///List of all mobs that are viewing our action button -> A unique movable for them to view.
	var/list/viewers = list()
	/// What icon to replace our mouse cursor with when active. Optional, Requires requires_target
	var/ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	/// Whether or not you want the cooldown for the ability to display in text form
	var/show_cooldown = TRUE
	// =====================================
	// Cooldown
	// =====================================
	/// The default cooldown applied when start_cooldown() is called
	/// Actions are responsible for setting their own cooldown.
	var/cooldown_time = 0
	/// Shares cooldowns with other cooldown abilities of the same value, not active if null
	/// This allows a single thing with cooldowns to have multiple actions which share the same cooldown
	var/cooldown_group
	// =====================================
	// Internal
	// =====================================
	/// The actual next time this ability can be used
	VAR_PRIVATE/next_use_time = 0
	/// If the ability is currently active or not
	VAR_PRIVATE/active = FALSE
	/// If we require a target and are a toggleable button, we track a reference to the
	/// object that we are targetting.
	VAR_PRIVATE/datum/selected_target = null
	/// Overlay currently applied to this action
	VAR_PRIVATE/mutable_appearance/timer_overlay
	/// Timer icon file
	VAR_PROTECTED/timer_icon = 'icons/effects/cooldown.dmi'
	/// Icon state for the timer icon
	VAR_PROTECTED/timer_icon_state_active = "second"

	// These are only used for click_to_activate actions
	/// Setting for intercepting clicks before activating the ability
	var/click_to_activate = FALSE
	/// If TRUE, we will unset after using our click intercept.
	var/unset_after_click = TRUE
	/// The base icon_state of this action's background
	var/base_background_icon_state
	/// The icon state the background uses when active
	var/active_background_icon_state
	/// The base icon_state of the overlay we apply
	var/base_overlay_icon_state
	/// The active icon_state of the overlay we apply
	var/active_overlay_icon_state
	/// The base icon state of the spell's button icon, used for editing the icon "off"
	var/base_icon_state
	/// The active icon state of the spell's button icon, used for editing the icon "on"
	var/active_icon_state

/datum/action/New(master)
	if(active_background_icon_state)
		base_background_icon_state ||= background_icon_state
	if(active_overlay_icon_state)
		base_overlay_icon_state ||= overlay_icon_state
	if(active_icon_state)
		base_icon_state ||= button_icon_state

	if (master)
		link_to(master)

/// Links the passed target to our action, registering any relevant signals
/datum/action/proc/link_to(master)
	src.master = master
	RegisterSignal(master, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	if(isatom(master))
		RegisterSignal(master, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_target_icon_update))

	if(istype(master, /datum/mind))
		RegisterSignal(master, COMSIG_MIND_TRANSFERRED, PROC_REF(on_master_mind_swapped))

/datum/action/Destroy()
	if(owner)
		Remove(owner)
	master = null
	if (selected_target)
		UnregisterSignal(selected_target, COMSIG_PARENT_QDELETING)
		selected_target = null
	QDEL_LIST_ASSOC_VAL(viewers) // Qdel the buttons in the viewers list **NOT THE HUDS**
	return ..()

/// Signal proc that clears any references based on the owner or target deleting
/// If the owner's deleted, we will simply remove from them, but if the target's deleted, we will self-delete
/datum/action/proc/clear_ref(datum/ref)
	SIGNAL_HANDLER
	if(ref == owner)
		Remove(owner)
	if(ref == master)
		qdel(src)
	if (ref == selected_target)
		deactivate(owner)

/// Grants the action to the passed mob, making it the owner
/datum/action/proc/Grant(mob/grant_to)
	if(!grant_to)
		Remove(owner)
		return
	if(owner)
		if(owner == grant_to)
			return
		Remove(owner)
	SEND_SIGNAL(src, COMSIG_ACTION_GRANTED, grant_to)
	SEND_SIGNAL(grant_to, COMSIG_MOB_GRANTED_ACTION, src)
	owner = grant_to
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref), override = TRUE)

	// Register some signals based on our check_flags
	// so that our button icon updates when relevant
	if(check_flags & (AB_CHECK_CONSCIOUS | AB_CHECK_DEAD))
		RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_IMMOBILE)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_HANDS_BLOCKED)
		RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED), PROC_REF(update_status_on_signal))
	if(check_flags & AB_CHECK_LYING)
		RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(update_status_on_signal))

	give_action(grant_to)
	// Start cooldown timer if we gained it mid-cooldown
	if(!owner)
		return
	build_all_button_icons()
	if(next_use_time > world.time)
		START_PROCESSING(SSfastprocess, src)

/// Remove the passed mob from being owner of our action
/datum/action/proc/Remove(mob/remove_from)
	SHOULD_CALL_PARENT(TRUE)

	if (!remove_from)
		return

	for(var/datum/hud/hud in viewers)
		if(!hud.mymob)
			continue
		hide_from(hud.mymob)
	LAZYREMOVE(remove_from.actions, src) // We aren't always properly inserted into the viewers list, gotta make sure that action's cleared
	viewers = list()

	if(owner)
		SEND_SIGNAL(src, COMSIG_ACTION_REMOVED, owner)
		SEND_SIGNAL(owner, COMSIG_MOB_REMOVED_ACTION, src)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)

		// Clean up our check_flag signals
		UnregisterSignal(owner, list(
			COMSIG_LIVING_SET_BODY_POSITION,
			COMSIG_MOB_STATCHANGE,
			SIGNAL_ADDTRAIT(TRAIT_HANDS_BLOCKED),
			SIGNAL_ADDTRAIT(TRAIT_IMMOBILIZED),
		))

		if(master == owner)
			RegisterSignal(master, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref))
		owner = null

	if (remove_from.click_intercept == src)
		unset_click_ability(remove_from)

/// Actually triggers the effects of the action.
/// Called when the on-screen button is clicked, for example.
/// If you want to implement an action, override:
/// - on_activate to do the effect
/// - is_available for things that need checks (only if you handle button icon updates, otherwise put the check in pre_activation)
/datum/action/proc/trigger(trigger_flags)
	SHOULD_NOT_OVERRIDE(TRUE)
	// We don't return a value, so the things we call are allowed to sleep
	set waitfor = FALSE
	if(!is_available())
		return
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return
	if(!owner)
		return

	var/mob/user = usr || owner

	// If we were active and we clicked again, disable the action
	if (active && toggleable)
		deactivate(user)
		return

	// If our cooldown action is a requires_target action:
	// The actual action is activated on whatever the user clicks on -
	// the target is what the action is being used on
	// In trigger, we handle setting the click intercept
	if(requires_target)
		var/datum/action/already_set = user.click_intercept
		if(already_set == src)
			// if we clicked ourself and we're already set, unset and return
			unset_click_ability(user, refund_cooldown = TRUE)
			return

		else if(istype(already_set))
			// if we have an active set already, unset it before we set our's
			already_set.unset_click_ability(user, refund_cooldown = TRUE)

		set_click_ability(user)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		return

	// If our cooldown action is not a requires_target action:
	// We can just continue on and use the action
	// the target is the user of the action (often, the owner)
	pre_activate(user, master, trigger_flags)

/// Adds the ability for signals to intercept the ability
/datum/action/proc/pre_activate(mob/user, atom/target, trigger_flags)
	if(SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_STARTED, src) & COMPONENT_BLOCK_ABILITY_START)
		return
	// If we successfully activated and are a toggle action, become active
	if (toggleable)
		active = TRUE
		if (target)
			selected_target = target
			RegisterSignal(selected_target, COMSIG_PARENT_QDELETING, PROC_REF(clear_ref))
	. = on_activate(user, target, trigger_flags)
	// There is a possibility our action (or owner) is qdeleted in on_activate().
	if(!QDELETED(src) && !QDELETED(owner))
		SEND_SIGNAL(owner, COMSIG_MOB_ABILITY_FINISHED, src)

/// Override to implement behaviour
/// If this action is not a targetted spell, target will be the master
/// If this action is a toggleable action, must return true to signify successful activation
/datum/action/proc/on_activate(mob/user, atom/target, trigger_flags)
	return

/// Deactivates the action. Can be called internally if an action
/// does something to a target until deactivated.
/datum/action/proc/deactivate(mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if (!active)
		return
	active = FALSE
	on_deactivate(user, selected_target)
	if (selected_target)
		UnregisterSignal(selected_target, COMSIG_PARENT_QDELETING)
		selected_target = null

/// Called when the action is deactivated.
/// Called under the following conditions:
/// - toggleable is set to true
/// - the action is currently active
/datum/action/proc/on_deactivate(mob/user, atom/target)
	return

/// Intercepts client owner clicks to activate the ability
/// This proc is called via reflection, do not change the name if you do
/// not know what that means.
/datum/action/InterceptClickOn(mob/living/caller, params, atom/target)
	return _internal_InterceptClickOn(caller, params, target)

/datum/action/proc/_internal_InterceptClickOn(mob/living/caller, params, atom/target)
	set waitfor = FALSE
	if(!is_available())
		unset_click_ability(caller, refund_cooldown = FALSE)
		return FALSE
	if(!target)
		return FALSE
	// Once we are here, there is no reason we should ever allow the click to go through as
	// normal, even if the action isn't able to run; the user asked for it after all.
	. = TRUE
	// The actual action begins here
	if(!pre_activate(caller, target))
		return

	// And if we reach here, the action was complete successfully
	if(unset_after_click)
		start_cooldown()
		unset_click_ability(caller, refund_cooldown = FALSE)
	caller.next_click = world.time + click_cd_override

/// Whether our action is currently available to use or not
/datum/action/proc/is_available()
	if(!owner)
		return FALSE
	if (next_use_time && world.time < next_use_time)
		return FALSE
	if((check_flags & AB_CHECK_HANDS_BLOCKED) && HAS_TRAIT(owner, TRAIT_HANDS_BLOCKED))
		return FALSE
	if((check_flags & AB_CHECK_IMMOBILE) && HAS_TRAIT(owner, TRAIT_IMMOBILIZED))
		return FALSE
	if((check_flags & AB_CHECK_LYING) && isliving(owner))
		var/mob/living/action_user = owner
		if(action_user.body_position == LYING_DOWN)
			return FALSE
	if((check_flags & AB_CHECK_CONSCIOUS) && owner.stat != CONSCIOUS)
		return FALSE
	if ((check_flags & AB_CHECK_DEAD) && owner.stat == DEAD)
		return FALSE
	return TRUE

/// Builds / updates all buttons we have shared or given out
/datum/action/proc/build_all_button_icons(update_flags = ALL, force)
	for(var/datum/hud/hud as anything in viewers)
		build_button_icon(viewers[hud], update_flags, force)

/**
 * Builds the icon of the button.
 *
 * Concept:
 * - Underlay (Background icon)
 * - Icon (button icon)
 * - Maptext
 * - Overlay (Background border)
 *
 * button - which button we are modifying the icon of
 * force - whether we're forcing a full update
 */
/datum/action/proc/build_button_icon(atom/movable/screen/movable/action_button/button, update_flags = ALL, force = FALSE)
	if(!button)
		return

	if(update_flags & UPDATE_BUTTON_NAME)
		update_button_name(button, force)

	if(update_flags & UPDATE_BUTTON_BACKGROUND)
		apply_button_background(button, force)

	if(update_flags & UPDATE_BUTTON_ICON)
		apply_button_icon(button, force)

	if(update_flags & UPDATE_BUTTON_OVERLAY)
		apply_button_overlay(button, force)

	if(update_flags & UPDATE_BUTTON_STATUS)
		update_button_status(button, force)

/**
 * Updates the name and description of the button to match our action name and discription.
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_name(atom/movable/screen/movable/action_button/button, force = FALSE)
	button.name = name
	if(desc)
		button.desc = desc

/**
 * Creates the background underlay for the button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_background(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(active_background_icon_state)
		background_icon_state = is_action_active(current_button) ? active_background_icon_state : base_background_icon_state

	if(!background_icon || !background_icon_state || (current_button.active_underlay_icon_state == background_icon_state && !force))
		return

	// What icons we use for our background
	var/list/icon_settings = list(
		// The icon file
		"bg_icon" = background_icon,
		// The icon state, if is_action_active() returns FALSE
		"bg_state" = background_icon_state,
		// The icon state, if is_action_active() returns TRUE
		"bg_state_active" = background_icon_state,
	)

	// If background_icon_state is ACTION_BUTTON_DEFAULT_BACKGROUND instead use our hud's action button scheme
	if(background_icon_state == ACTION_BUTTON_DEFAULT_BACKGROUND && owner?.hud_used)
		icon_settings = owner.hud_used.get_action_buttons_icons()

	// Determine which icon to use
	var/used_icon_key = is_action_active(current_button) ? "bg_state_active" : "bg_state"

	// Make the underlay
	current_button.underlays.Cut()
	current_button.underlays += image(icon = icon_settings["bg_icon"], icon_state = icon_settings[used_icon_key])
	current_button.active_underlay_icon_state = icon_settings[used_icon_key]

/**
 * Applies our button icon and icon state to the button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_icon(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(active_icon_state)
		button_icon_state = is_action_active(current_button) ? active_icon_state : base_icon_state

	if(!button_icon || !button_icon_state || (current_button.icon_state == button_icon_state && !force))
		return

	current_button.icon = button_icon
	current_button.icon_state = button_icon_state

/**
 * Applies any overlays to our button
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/apply_button_overlay(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(active_overlay_icon_state)
		overlay_icon_state = is_action_active(current_button) ? active_overlay_icon_state : base_overlay_icon_state

	SEND_SIGNAL(src, COMSIG_ACTION_OVERLAY_APPLY, current_button, force)

	if(!overlay_icon || !overlay_icon_state || (current_button.active_overlay_icon_state == overlay_icon_state && !force))
		return

	current_button.cut_overlay(current_button.button_overlay)
	current_button.button_overlay = mutable_appearance(icon = overlay_icon, icon_state = overlay_icon_state)
	current_button.add_overlay(current_button.button_overlay)
	current_button.active_overlay_icon_state = overlay_icon_state

/**
 * Any other miscellaneous "status" updates within the action button is handled here,
 * such as redding out when unavailable or modifying maptext.
 *
 * current_button - what button are we editing?
 * force - whether an update is forced regardless of existing status
 */
/datum/action/proc/update_button_status(atom/movable/screen/movable/action_button/current_button, force = FALSE)
	if(is_available())
		current_button.color = rgb(255,255,255,255)
	else
		current_button.color = transparent_when_unavailable ? rgb(128,0,0,128) : rgb(128,0,0)

	/*
	var/time_left = max(next_use_time - world.time, 0)
	if(!text_cooldown || !owner || time_left == 0 || time_left >= COOLDOWN_NO_DISPLAY_TIME)
		current_button.maptext = ""
	else
		if (cooldown_rounding > 0)
			current_button.maptext = MAPTEXT_TINY_UNICODE("[round(time_left/10, cooldown_rounding)]")
		else
			current_button.maptext = MAPTEXT_TINY_UNICODE("[round(time_left/10)]")
	*/

	if(!is_available() || !is_action_active(current_button))
		return
	// If we don't change the icon state, or don't apply a special overlay,
	if(active_background_icon_state || active_icon_state || active_overlay_icon_state)
		return
	// ...we need to show it's active somehow. So, make it greeeen
	current_button.color = COLOR_GREEN

/// Gives our action to the passed viewer.
/// Puts our action in their actions list and shows them the button.
/datum/action/proc/give_action(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(viewers[our_hud]) // Already have a copy of us? go away
		return

	LAZYOR(viewer.actions, src) // Move this in
	show_to(viewer)

/// Adds our action button to the screen of the passed viewer.
/datum/action/proc/show_to(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	if(!our_hud || viewers[our_hud]) // There's no point in this if you have no hud in the first place
		return

	var/atom/movable/screen/movable/action_button/button = create_button()
	set_id(button, viewer)

	button.our_hud = our_hud
	viewers[our_hud] = button
	if(viewer.client)
		viewer.client.screen += button

	button.load_position(viewer)
	viewer.update_item_action_buttons()

/// Removes our action from the passed viewer.
/datum/action/proc/hide_from(mob/viewer)
	var/datum/hud/our_hud = viewer.hud_used
	var/atom/movable/screen/movable/action_button/button = viewers[our_hud]
	LAZYREMOVE(viewer.actions, src)
	if(button)
		qdel(button)

/// Creates an action button movable for the passed mob, and returns it.
/datum/action/proc/create_button()
	var/atom/movable/screen/movable/action_button/button = new()
	button.linked_action = src
	build_button_icon(button, ALL, TRUE)
	return button

/datum/action/proc/set_id(atom/movable/screen/movable/action_button/our_button, mob/owner)
	//button id generation
	var/bitfield = 0
	for(var/datum/action/action in owner.actions)
		if(action == src) // This could be us, which is dumb
			continue
		var/atom/movable/screen/movable/action_button/button = action.viewers[owner.hud_used]
		if(action.name == name && button.id)
			bitfield |= button.id

	bitfield = ~bitfield // Flip our possible ids, so we can check if we've found a unique one
	for(var/i in 0 to 23) // We get 24 possible bitflags in dm
		var/bitflag = 1 << i // Shift us over one
		if(bitfield & bitflag)
			our_button.id = bitflag
			return

/// Updates our buttons if our target's icon was updated
/datum/action/proc/on_target_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER

	var/update_flag = NONE
	var/forced = FALSE
	if(updates & UPDATE_ICON_STATE)
		update_flag |= UPDATE_BUTTON_ICON
		forced = TRUE
	if(updates & UPDATE_OVERLAYS)
		update_flag |= UPDATE_BUTTON_OVERLAY
		forced = TRUE
	if(updates & (UPDATE_NAME|UPDATE_DESC))
		update_flag |= UPDATE_BUTTON_NAME
	// Status is not relevant, and background is not relevant. Neither will change

	// Force the update if an icon state or overlay change was done
	build_all_button_icons(update_flag, forced)

/// A general use signal proc that reacts to an event and updates JUST our button's status
/datum/action/proc/update_status_on_signal(datum/source)
	SIGNAL_HANDLER

	build_all_button_icons(UPDATE_BUTTON_STATUS)

/// Signal proc for COMSIG_MIND_TRANSFERRED - for minds, transfers our action to our new mob on mind transfer
/datum/action/proc/on_master_mind_swapped(datum/mind/source, mob/old_current)
	SIGNAL_HANDLER

	// Grant() calls Remove() from the existing owner so we're covered on that
	Grant(source.current)

/// Checks if our action is actively selected. Used for selecting icons primarily.
/datum/action/proc/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return click_to_activate && current_button.our_hud?.mymob?.click_intercept == src

/// Starts a cooldown time to be shared with similar abilities
/// Will use default cooldown time if an override is not specified
/datum/action/proc/start_cooldown(override_cooldown_time)
	// "Shared cooldowns" covers actions which are not the same type,
	// but have the same cooldown group and are on the same mob
	if(cooldown_group)
		for(var/datum/action/shared_ability in owner.actions - src)
			if(cooldown_group != shared_ability.cooldown_group)
				continue
			shared_ability.start_cooldown_self(override_cooldown_time)

	start_cooldown_self(override_cooldown_time)

/// Starts a cooldown time for this ability only
/// Will use default cooldown time if an override is not specified
/datum/action/proc/start_cooldown_self(override_cooldown_time)
	if(isnum(override_cooldown_time))
		next_use_time = world.time + override_cooldown_time
	else
		next_use_time = world.time + cooldown_time
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	// Needs to update once per second
	START_PROCESSING(SSprocessing, src)

/// Actions process to handle their cooldown timer
/datum/action/process()
	if(!owner || (next_use_time - world.time) <= 0)
		build_all_button_icons(UPDATE_BUTTON_STATUS)
		STOP_PROCESSING(SSfastprocess, src)
		return

	build_all_button_icons(UPDATE_BUTTON_STATUS)

/**
 * Set our action as the click override on the passed mob.
 */
/datum/action/proc/set_click_ability(mob/on_who)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = src
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = ranged_mousepointer
		on_who.update_mouse_pointer()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/**
 * Unset our action as the click override of the passed mob.
 *
 * if refund_cooldown is TRUE, we are being unset by the user clicking the action off
 * if refund_cooldown is FALSE, we are being forcefully unset, likely by someone actually using the action
 */
/datum/action/proc/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	on_who.click_intercept = null
	if(ranged_mousepointer)
		on_who.client?.mouse_override_icon = initial(on_who.client?.mouse_override_icon)
		on_who.update_mouse_pointer()
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	return TRUE

/datum/action/proc/reduce_cooldown(amount)
	next_use_time -= amount

/datum/action/proc/is_active()
	return active
