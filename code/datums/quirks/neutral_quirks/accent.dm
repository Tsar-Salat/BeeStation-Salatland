/datum/quirk/accent //base accent is medieval
	name = "Accent"
	desc = "You have a distinct way of speaking! (Select one in character creation)"
	icon = "comment-dots"
	gain_text = span_notice("You are afflicted with an accent.")
	lose_text = span_danger("You are no longer afflicted with an accent.")
	medical_record_text = "Patient has a distinct accent."
	/// Accent to be used in accent traits
	var/accent_to_use = null
	/// Reference to the speechmod component so we can remove it on quirk removal
	var/datum/component/speechmod/accent_component

/datum/quirk/accent/add(client/client_source)
	var/client/player_client = GLOB.directory[ckey(quirk_holder.key)]
	var/list/available = GLOB.accents.Copy()
	//special accents for BEE donators and BYOND patrons
	if(IS_PATRON(ckey(quirk_holder.key)) || player_client?.IsByondMember())
		available += GLOB.accents_donator
	var/chosen = read_choice_preference(/datum/preference/choiced/accent)
	if(chosen && !available[chosen])
		to_chat(player_client, span_warning("Your chosen accent is only accessible to patrons. A random accent has been selected instead."))
		chosen = null
	accent_to_use = available[chosen || pick(available)]
	accent_component = quirk_target.AddComponent(/datum/component/speechmod, file_path = accent_to_use)

/datum/quirk/accent/remove()
	if(!isnull(accent_component))
		QDEL_NULL(accent_component)

/datum/quirk/accent/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, accent_to_use))
		if(!isnull(accent_component))
			qdel(accent_component)
		accent_component = quirk_target.AddComponent(/datum/component/speechmod, file_path = accent_to_use)
