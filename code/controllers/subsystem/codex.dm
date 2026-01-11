SUBSYSTEM_DEF(codex)
	name = "Codex"
	flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/culture,
	)
	var/regex/linkRegex

	var/list/entries_by_path =   list()
	var/list/entries_by_string = list()
	var/list/index_file =        list()
	var/list/search_cache =      list()
	var/list/codex_categories =  list() // Store category instances


/datum/controller/subsystem/codex/stat_entry()
	return ..()  // No additional stat info needed


/datum/controller/subsystem/codex/Initialize(start_uptime)
	// Ensure chemical reagents and reactions are built before creating codex entries
	if(!GLOB.chemical_reagents_list)
		build_chemical_reagent_list()
	if(!GLOB.chemical_reactions_list)
		build_chemical_reactions_list()

	// Codex link syntax is such:
	// <l>keyword</l> when keyword is mentioned verbatim,
	// <span codexlink='keyword'>whatever</span> when shit gets tricky
	linkRegex = regex(@"<(span|l)(\s+codexlink='([^>]*)'|)>([^<]+)</(span|l)>","g")

	// Create general hardcoded entries.
	for(var/ctype in typesof(/datum/codex_entry))
		var/datum/codex_entry/centry = ctype
		if(initial(centry.display_name) || initial(centry.associated_paths) || initial(centry.associated_strings))
			centry = new centry()
			for(var/associated_path in centry.associated_paths)
				entries_by_path[associated_path] = centry
			for(var/associated_string in centry.associated_strings)
				add_entry_by_string(associated_string, centry)
			if(centry.display_name)
				add_entry_by_string(centry.display_name, centry)
			centry.update_links()

	// Now register subtypes for entries, excluding paths that have their own specific entries
	for(var/entry_path in entries_by_path)
		var/datum/codex_entry/entry = entries_by_path[entry_path]
		for(var/subtype in subtypesof(entry_path))
			// Only register this subtype if it doesn't already have its own entry
			if(!entries_by_path[subtype])
				entries_by_path[subtype] = entry

	// Create categorized entries.
	for(var/ctype in subtypesof(/datum/codex_category))
		var/datum/codex_category/cat = new ctype
		codex_categories[ctype] = cat
		cat.Initialize()

	// Create the index file for later use.
	for(var/thing in SScodex.entries_by_path)
		var/datum/codex_entry/entry = SScodex.entries_by_path[thing]
		index_file[entry.display_name] = entry
	for(var/thing in SScodex.entries_by_string)
		var/datum/codex_entry/entry = SScodex.entries_by_string[thing]
		index_file[entry.display_name] = entry
	index_file = sortAssoc(index_file)


/datum/controller/subsystem/codex/proc/parse_links(string, viewer)
	while(linkRegex.Find_char(string))
		var/key = linkRegex.group[4]
		if(linkRegex.group[2])
			key = linkRegex.group[3]
		key = lowertext(trimtext(key))
		var/datum/codex_entry/linked_entry = get_entry_by_string(key)
		var/replacement = linkRegex.group[4]
		if(linked_entry)
			replacement = "<a href='byond://?src=\ref[SScodex];show_examined_info=\ref[linked_entry];show_to=\ref[viewer]'>[replacement]</a>"
		string = replacetextEx(string, linkRegex.match, replacement)
	return string

/datum/controller/subsystem/codex/proc/get_codex_entry(entry)
	if(isloc(entry))
		var/atom/entity = entry
		if(entity.get_specific_codex_entry())
			return entity.get_specific_codex_entry()
		return get_entry_by_string(entity.name) || entries_by_path[entity.type]
	else if(entries_by_path[entry])
		return entries_by_path[entry]
	else if(entries_by_string[lowertext(entry)])
		return entries_by_string[lowertext(entry)]

/datum/controller/subsystem/codex/proc/add_entry_by_string(string, entry)
	entries_by_string[lowertext(trimtext(string))] = entry

/datum/controller/subsystem/codex/proc/get_entry_by_string(string)
	return entries_by_string[lowertext(trimtext(string))]

/datum/controller/subsystem/codex/proc/present_codex_entry(mob/presenting_to, datum/codex_entry/entry)
	if(entry && istype(presenting_to) && presenting_to.client)
		var/datum/codex_viewer/viewer = new(entry, presenting_to)
		viewer.ui_interact(presenting_to)

/datum/controller/subsystem/codex/proc/retrieve_entries_for_string(searching)

	if(!initialized)
		return list()

	searching = sanitize(lowertext(trimtext(searching)))
	if(!searching)
		return list()
	if(!search_cache[searching])
		var/list/results
		if(entries_by_string[searching])
			results = list(entries_by_string[searching])
		else
			results = list()
			for(var/entry_title in entries_by_string)
				var/datum/codex_entry/entry = entries_by_string[entry_title]
				if(findtext(entry.display_name, searching) || \
					findtext(entry.lore_text, searching) || \
					findtext(entry.mechanics_text, searching) || \
					findtext(entry.antag_text, searching))
					results |= entry
		search_cache[searching] = sortTim(results, GLOBAL_PROC_REF(cmp_codex_entry_asc))
	return search_cache[searching]

/datum/controller/subsystem/codex/Topic(href, href_list)
	. = ..()
	if(!. && href_list["show_examined_info"] && href_list["show_to"])
		var/mob/showing_mob =   locate(href_list["show_to"])
		if(!istype(showing_mob) || !showing_mob.can_use_codex())
			return
		var/atom/showing_atom = locate(href_list["show_examined_info"])
		var/entry
		if(istype(showing_atom, /datum/codex_entry))
			entry = showing_atom
		else
			if(istype(showing_atom))
				entry = get_codex_entry(showing_atom.get_codex_value())
			else
				entry = get_codex_entry(showing_atom)
		if(entry)
			present_codex_entry(showing_mob, entry)
			return TRUE

/// A datum for viewing codex entries through TGUI
/datum/codex_viewer
	/// The codex entry being viewed
	var/datum/codex_entry/entry
	/// The mob viewing the codex
	var/mob/viewer
	/// Search text for filtering entries
	var/search_text = ""
	/// Current mode (CODEX_MODE_LORE or CODEX_MODE_INFO)
	var/mode = CODEX_MODE_LORE
	/// Raw selected entry/category key for Info mode categories
	var/selected_entry = ""

/datum/codex_viewer/New(datum/codex_entry/_entry, mob/_viewer)
	entry = _entry
	viewer = _viewer
	selected_entry = _entry?.display_name || ""

/datum/codex_viewer/Destroy()
	entry = null
	viewer = null
	return ..()

/datum/codex_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CodexInfo", entry?.display_name || "Codex")
		ui.open()

/datum/codex_viewer/ui_data(mob/user)
	var/list/data = list()

	// In Info mode, check if selected_entry is a category name
	var/is_info_category_selection = FALSE
	if(mode == CODEX_MODE_INFO && selected_entry)
		// Check entries_by_string
		for(var/entry_key in SScodex.entries_by_string)
			var/datum/codex_entry/e = SScodex.entries_by_string[entry_key]
			if(e.category == lowertext(selected_entry))
				is_info_category_selection = TRUE
				break
		// If not found, check entries_by_path
		if(!is_info_category_selection)
			for(var/path in SScodex.entries_by_path)
				var/datum/codex_entry/e = SScodex.entries_by_path[path]
				if(e.category == lowertext(selected_entry))
					is_info_category_selection = TRUE
					break

	data["entry_name"] = is_info_category_selection ? selected_entry : (entry?.display_name || "Unknown")
	data["search_text"] = search_text
	data["mode"] = mode

	// Send categories based on current mode
	var/list/categories = list()
	if(mode == CODEX_MODE_LORE)
		// Lore mode: show datum/codex_category categories
		for(var/type in subtypesof(/datum/codex_category))
			var/datum/codex_category/C = type
			var/key = "[initial(C.name)] (category)"
			var/datum/codex_entry/cat_entry = SScodex.get_codex_entry(key)
			if(cat_entry)
				categories += list(list(
					"name" = initial(C.name),
					"desc" = initial(C.desc),
					"key" = key
				))
	else if(mode == CODEX_MODE_INFO)
		// Info mode: build categories from codex entries with category field
		var/list/info_categories = list()
		var/list/processed = list()
		// Check entries_by_string
		for(var/entry_key in SScodex.entries_by_string)
			var/datum/codex_entry/e = SScodex.entries_by_string[entry_key]
			if(e.category && e.category != CODEX_CATEGORY_GENERIC && !(e in processed))
				info_categories[e.category] = TRUE
				processed[e] = TRUE
		// Also check entries_by_path
		for(var/path in SScodex.entries_by_path)
			var/datum/codex_entry/e = SScodex.entries_by_path[path]
			if(e.category && e.category != CODEX_CATEGORY_GENERIC && !(e in processed))
				info_categories[e.category] = TRUE
				processed[e] = TRUE
		for(var/cat_name in info_categories)
			categories += list(list(
				"name" = capitalize(cat_name),
				"desc" = "[capitalize(cat_name)] information",
				"key" = cat_name
			))
	data["categories"] = categories

	// Determine view mode
	var/is_nexus = istype(entry, /datum/codex_entry/nexus)
	var/is_category = findtext(entry?.display_name, "(category)")

	data["view_mode"] = "entry" // Default: showing an entry
	if(search_text)
		data["view_mode"] = "search"
	else if(is_nexus)
		data["view_mode"] = "nexus"
	else if(is_category || is_info_category_selection)
		data["view_mode"] = "category"

	// If searching, send search results
	if(search_text)
		var/list/search_results = list()
		var/searching = lowertext(search_text)
		for(var/entry_id in SScodex.entries_by_string)
			if(findtext(entry_id, searching))
				var/datum/codex_entry/result_entry = SScodex.entries_by_string[entry_id]
				var/already_have = FALSE
				for(var/list/existing in search_results)
					if(existing["key"] == result_entry.display_name)
						already_have = TRUE
						break
				if(!already_have)
					search_results += list(list(
						"name" = result_entry.display_name,
						"key" = result_entry.display_name
					))
		data["search_results"] = search_results
	else
		data["search_results"] = list()

	// If viewing a category, send the list of items
	if(is_category && mode == CODEX_MODE_LORE)
		var/list/category_items = list()
		for(var/type in subtypesof(/datum/codex_category))
			var/datum/codex_category/C = SScodex.codex_categories[type]
			if(C && ("[C.name] (category)" == entry.display_name))
				for(var/item_name in C.items)
					category_items += list(list(
						"name" = item_name,
						"key" = item_name
					))
				break
		data["category_items"] = category_items
	else if(is_info_category_selection && mode == CODEX_MODE_INFO)
		// In Info mode, show items with matching category
		var/list/category_items = list()
		var/list/added = list()
		var/category_name = lowertext(selected_entry)
		// Check entries_by_string
		for(var/entry_key in SScodex.entries_by_string)
			var/datum/codex_entry/e = SScodex.entries_by_string[entry_key]
			if(e.category == category_name && !(e in added))
				category_items += list(list(
					"name" = e.display_name,
					"key" = e.display_name
				))
				added[e] = TRUE
		// Also check entries_by_path
		for(var/path in SScodex.entries_by_path)
			var/datum/codex_entry/e = SScodex.entries_by_path[path]
			if(e.category == category_name && !(e in added))
				category_items += list(list(
					"name" = e.display_name,
					"key" = e.display_name
				))
				added[e] = TRUE
		data["category_items"] = category_items
	else
		data["category_items"] = list()

	// Check if entry has content (but not for Info category selections)
	if(entry && istype(entry, /datum/codex_entry) && !is_info_category_selection)
		// Get icon data if entry has associated paths
		if(entry.associated_paths && length(entry.associated_paths))
			var/atom/first_path = entry.associated_paths[1]
			var/icon = initial(first_path.icon)
			var/icon_state = initial(first_path.icon_state)
			var/icon_dir = initial(first_path.dir)
			data["icon"] = icon
			data["icon_state"] = icon_state
			data["icon_dir"] = icon_dir
			data["icon_class"] = "codex32x32 [sanitize_css_class_name(first_path)]"
		else
			data["icon"] = ""
			data["icon_state"] = ""
			data["icon_dir"] = ""
			data["icon_class"] = ""

		// For entries that just use the basic fields, use those directly
		if(entry.lore_text)
			data["lore_text"] = SScodex.parse_links(entry.lore_text, user)
		else
			data["lore_text"] = ""

		if(entry.mechanics_text)
			data["mechanics_text"] = SScodex.parse_links(entry.mechanics_text, user)
		else
			data["mechanics_text"] = ""

		if(entry.antag_text && user.mind && player_is_antag(user.mind))
			data["antag_text"] = SScodex.parse_links(entry.antag_text, user)
		else
			data["antag_text"] = ""
	else
		data["icon_class"] = ""
		data["lore_text"] = ""
		data["mechanics_text"] = ""
		data["antag_text"] = ""

	data["is_antag"] = (user.mind && player_is_antag(user.mind)) ? 1 : 0

	return data

/datum/codex_viewer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("home")
			var/datum/codex_entry/nexus = SScodex.get_codex_entry("nexus")
			if(nexus)
				entry = nexus
				selected_entry = "nexus"
				search_text = ""
				. = TRUE
		if("view_entry")
			var/entry_key = params["key"]
			if(entry_key)
				var/datum/codex_entry/new_entry = SScodex.get_codex_entry(entry_key)
				if(new_entry)
					entry = new_entry
					selected_entry = entry_key
					search_text = ""
					. = TRUE
				else if(mode == CODEX_MODE_INFO)
					// Check if this is an Info category name
					// Check entries_by_string
					for(var/check_key in SScodex.entries_by_string)
						var/datum/codex_entry/e = SScodex.entries_by_string[check_key]
						if(e.category == lowertext(entry_key))
							// This is an Info category - clear entry so view_mode logic works
							entry = null
							selected_entry = entry_key
							search_text = ""
							. = TRUE
							break
					// If not found in entries_by_string, check entries_by_path
					if(!.)
						for(var/path in SScodex.entries_by_path)
							var/datum/codex_entry/e = SScodex.entries_by_path[path]
							if(e.category == lowertext(entry_key))
								// This is an Info category - clear entry so view_mode logic works
								entry = null
								selected_entry = entry_key
								search_text = ""
								. = TRUE
								break
		if("search")
			search_text = params["text"] || ""
			. = TRUE
		if("toggle_mode")
			mode = !mode
			search_text = ""
			selected_entry = ""
			var/datum/codex_entry/nexus = SScodex.get_codex_entry("nexus")
			if(nexus)
				entry = nexus
			. = TRUE

/datum/codex_viewer/ui_state(mob/user)
	return GLOB.always_state

/datum/codex_viewer/ui_status(mob/user, datum/ui_state/state)
	if(!viewer || !viewer.can_use_codex())
		return UI_CLOSE
	return UI_INTERACTIVE
