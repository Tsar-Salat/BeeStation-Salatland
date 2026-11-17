/obj/machinery/rnd/server/oldstation
	name = "\improper Ancient R&D Server"
	circuit = /obj/item/circuitboard/machine/rdserver/oldstation
	req_access = null
	generates_heat = FALSE

/obj/machinery/rnd/server/oldstation/Initialize(mapload)
	var/datum/techweb/oldstation/oldstation_web = locate() in SSresearch.techwebs
	oldstation_web ||= new /datum/techweb/oldstation()
	stored_research = oldstation_web
	return ..()

/obj/machinery/button/add_context_self(datum/screentip_context/context, mob/user)
	context.add_left_click_item_action("Generate Research Points", /obj/item/research_notes)

/obj/machinery/rnd/server/oldstation/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return
	. += span_notice("Insert <b>Research Notes</b> to generate points.")

/obj/machinery/rnd/server/oldstation/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/research_notes) && stored_research)
		var/obj/item/research_notes/research_notes = tool
		stored_research.add_point_list(list(
			TECHWEB_POINT_TYPE_GENERIC = research_notes.value,
			TECHWEB_POINT_TYPE_DISCOVERY = research_notes.value,
		))
		playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
		qdel(research_notes)
		return ITEM_INTERACT_SUCCESS

	return ..()

///Ancient computer that starts with dissection to tell players they have it.
/obj/machinery/computer/operating/oldstation
	name = "ancient operating computer"
	advanced_surgeries = list(/datum/surgery_operation/basic/dissection)
