/datum/id_card_view
	var/title
	var/list/card_data
	var/datum/weakref/card_ref
	var/datum/weakref/holder_ref

/datum/id_card_view/New(obj/item/card/id/card, mob/living/carbon/human/holder)
	title = card.name
	card_ref = WEAKREF(card)
	holder_ref = WEAKREF(holder)
	// Should probably be recorded on the ID, but this is easier (albeit more restrictive) on chameleon ID users
	var/datum/record/crew/record = find_record(card.registered_name, GLOB.manifest.general)
	var/gender = record?.gender
	var/species = record?.species
	var/blood_type = record?.blood_type
	var/list/qualifications = record?.qualifications?.Copy()
	var/icon/photo
	if(istype(card, /obj/item/card/id/syndicate))
		// Fill in some blanks for chameleon IDs to maintain the illusion of a real ID
		gender ||= holder.gender
		species ||= holder.dna.species.name
		blood_type ||= holder.dna.blood_type?.name
		qualifications ||= get_qualification_names(holder.mind?.qualifications)
		photo = get_flat_existing_human_icon(holder, list(SOUTH))
	else
		var/obj/item/photo/record_photo = record?.get_front_photo()
		if(istype(record_photo))
			photo = record_photo.picture.picture_image
	card_data = list(
		"name" = card.registered_name,
		"job" = card.assignment,
		"age" = card.registered_age,
		"gender" = gender,
		"species" = species,
		"blood_type" = blood_type,
		"qualifications" = qualifications,
		"photo" = photo && icon2base64(icon(photo, "", SOUTH, 1)),
		"card_icon" = icon2base64(card.get_cached_flat_icon()),
	)

/datum/id_card_view/Destroy(force)
	SStgui.close_uis(src)
	return ..()

/datum/id_card_view/proc/show(mob/viewer)
	for(var/datum/tgui/open_ui as anything in viewer.tgui_open_uis.Copy())
		if(istype(open_ui.src_object, /datum/id_card_view))
			open_ui.close()
	ui_interact(viewer)

/// Closes once the viewer can't make out the card anymore
/datum/id_card_view/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_INTERACTIVE
	var/mob/living/viewer = user
	var/obj/item/card/id/card = card_ref.resolve()
	var/mob/living/carbon/human/holder = holder_ref.resolve()
	if(!istype(viewer) || !card || !holder || viewer.stat != CONSCIOUS || viewer.is_blind())
		return UI_CLOSE
	if(holder.wear_id?.GetID() != card && !(card in holder.held_items))
		return UI_CLOSE
	if(HAS_TRAIT(holder, TRAIT_UNKNOWN_APPEARANCE) || get_dist(viewer, holder) > ID_EXAMINE_DISTANCE + 1 || !(viewer in viewers(holder)))
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/id_card_view/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IdCard", title)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/id_card_view/ui_static_data(mob/user)
	return card_data

/datum/id_card_view/ui_close(mob/user, datum/tgui/tgui)
	qdel(src)
