// If an item has the processable item, it can be processed into another item with a specific tool. This adds generic behavior for those actions to make it easier to set-up generically.
/datum/element/processable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///The types of atoms this creates when the processing recipe is used.
	var/list/result_atom_type = list()
	///The tool behaviour for this processing recipe
	var/tool_behaviour
	///Time to process the atom
	var/time_to_process
	///The amounts of the resulting actors this will create
	var/list/amount_created = list()
	///Whether or not the atom being processed has to be on a table or tray to process it
	var/table_required

/datum/element/processable/Attach(datum/target, tool_behaviour, result_atom_type = list(), amount_created = list(3), time_to_process = 2 SECONDS, table_required = FALSE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.result_atom_type = result_atom_type
	src.tool_behaviour = tool_behaviour
	src.time_to_process = time_to_process
	src.amount_created = amount_created
	src.table_required = table_required

	if(!islist(result_atom_type))
		stack_trace("result_atom_type on [src] is not a list. Fix yo shit")
	var/list/result_check = result_atom_type
	if(!result_check.len)
		stack_trace("[src] has no output result. You have made something processable into nothing. Fix yo shit.")
		return
	if(!islist(amount_created))
		stack_trace("amount_created on [src] is not a list. Fix yo shit")

	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(tool_behaviour), PROC_REF(try_process))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(OnExamine))

/datum/element/processable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ATOM_TOOL_ACT(tool_behaviour), COMSIG_PARENT_EXAMINE))

/datum/element/processable/proc/try_process(datum/source, mob/living/user, obj/item/I, list/mutable_recipes)
	SIGNAL_HANDLER

	if(table_required)
		var/obj/item/found_item = source
		var/found_location = found_item.loc
		var/found_turf = isturf(found_location)
		var/found_table = locate(/obj/structure/table) in found_location
		var/found_tray = locate(/obj/item/storage/bag/tray) in found_location
		if(!found_turf && !istype(found_location, /obj/item/storage/bag/tray) || found_turf && !(found_table || found_tray))
			var/atom/target = result_atom_type[1]
			to_chat(user, span_notice("You cannot make [initial(target.name)] here! You need a table or at least a tray."))
			return

	for(var/i in 1 to result_atom_type.len)
		mutable_recipes += list(list(TOOL_PROCESSING_RESULT = result_atom_type[i], TOOL_PROCESSING_AMOUNT = amount_created[i], TOOL_PROCESSING_TIME = time_to_process))

///So people know what the frick they're doing without reading from a wiki page (I mean they will inevitably but i'm trying to help, ok?)
/datum/element/processable/proc/OnExamine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/list/result_strings = list()

	for(var/i in 1 to result_atom_type.len)
		var/atom/target = result_atom_type[i]
		var/result_name = initial(target.name)
		var/result_gender = initial(target.gender)

		// Construct the result string for this item
		if(amount_created[i] > 1)
			if(result_gender == PLURAL)
				result_strings += "[amount_created[i]] [result_name]"
			else
				result_strings += "[amount_created[i]] [result_name][plural_s(result_name)]"
		else
			if(result_gender == PLURAL)
				result_strings += "some [result_name]"
			else
				result_strings += "\a [result_name]"

	// Combine all results into a single string with commas and "and" before the last item. Oxford comma this shit because its uggo otherwise
	var/result_output = ""
	if(result_strings.len == 1)
		result_output = result_strings[1]
	else if(result_strings.len == 2)
		result_output = "[result_strings[1]] and [result_strings[2]]"
	else
		for(var/i in 1 to result_strings.len)
			if(i == result_strings.len) // Last item
				result_output += "and [result_strings[i]]"
			else
				result_output += "[result_strings[i]], "

	var/tool_desc = tool_behaviour_name(tool_behaviour)
	examine_list += span_notice("It can be turned into [result_output] with <b>[tool_desc]</b>!")
