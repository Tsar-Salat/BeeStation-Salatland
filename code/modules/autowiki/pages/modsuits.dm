/datum/autowiki/modsuits
	page = "Template:Autowiki/Content/Modsuits"

/datum/autowiki/modsuits/generate()
	// Define the order for each category
	var/list/station_order = list(
		"standard",
		"engineering", "atmospheric", "advanced",
		"loader", "mining",
		"medical", "rescue",
		"research",
		"security", "safeguard",
		"magnate",
		"cosmohonk"
	)

	var/list/offstation_order = list(
		"syndicate", "elite",
		"infiltrator",
		"enchanted",
		"ninja",
		"prototype"
	)

	var/list/centcom_order = list(
		"responsory",
		"apocryphal",
		"corporate",
		"debug",
		"administrative"
	)

	// Collect all themes
	var/list/all_themes = list()
	for(var/theme_path in subtypesof(/datum/mod_theme))
		var/datum/mod_theme/theme = new theme_path()
		all_themes[theme.name] = theme

	var/output = ""

	// Generate Station MODsuit Themes
	output += "= Station MODsuit Themes =\n"
	for(var/theme_name in station_order)
		if(theme_name in all_themes)
			output += generate_theme_output(all_themes[theme_name])

	// Generate Offstation MODsuit Themes
	output += "\n= Offstation MODsuit Themes =\n"
	for(var/theme_name in offstation_order)
		if(theme_name in all_themes)
			output += generate_theme_output(all_themes[theme_name])

	// Generate CentCom MODsuit Themes
	output += "\n= CentCom MODsuit Themes =\n"
	for(var/theme_name in centcom_order)
		if(theme_name in all_themes)
			output += generate_theme_output(all_themes[theme_name])

	// Generate Modules section
	output += "\n= Modules =\n"
	output += generate_modules()

	// Clean up remaining themes
	for(var/theme_name in all_themes)
		qdel(all_themes[theme_name])

	return output

/datum/autowiki/modsuits/proc/generate_theme_output(datum/mod_theme/theme)
	var/filename = SANITIZE_FILENAME(escape_value(format_text(theme.name)))

	// Create armor datum to get actual values
	var/datum/armor/armor_data = new theme.armor_type()

	var/output = include_template("Autowiki/ModsuitTheme", list(
		"name" = escape_value(capitalize(theme.name) + " MODsuit"),
		"description" = escape_value(theme.desc),
		"icon" = escape_value(filename),
		"melee" = armor_data.get_rating(MELEE),
		"bullet" = armor_data.get_rating(BULLET),
		"laser" = armor_data.get_rating(LASER),
		"energy" = armor_data.get_rating(ENERGY),
		"bomb" = armor_data.get_rating(BOMB),
		"bio" = armor_data.get_rating(BIO),
		"fire" = armor_data.get_rating(FIRE),
		"acid" = armor_data.get_rating(ACID),
		"bleed" = armor_data.bleed,
		"charge_drain" = theme.charge_drain || 5, // Default fallback
		"complexity_max" = theme.complexity_max || 15, // Default fallback
		"slowdown_deployed" = theme.slowdown_deployed || 0.5, // Default fallback
		"background_color" = get_theme_background_color(theme.name),
		"variants" = generate_variants(theme),
		"inbuilt_modules" = generate_inbuilt_modules(theme)
	))

	// Upload the main theme icon
	var/obj/item/mod/control/temp_suit = new()
	temp_suit.theme = theme
	temp_suit.skin = theme.default_skin
	upload_icon(getFlatIcon(temp_suit, no_anim = TRUE), filename)

	// Upload variant icons if they exist
	upload_variant_icons(theme)

	qdel(temp_suit)
	qdel(armor_data)

	return output

/datum/autowiki/modsuits/proc/get_theme_background_color(theme_name)
	// Match the background colors from the original page
	switch(theme_name)
		if("engineering", "atmospheric", "advanced")
			return "#FFF7E6"
		if("medical", "rescue")
			return "#E6F7FF"
		if("security", "safeguard")
			return "#FFE6E6"
		if("research")
			return "#F0E6FF"
		else
			return "#F2F2F2"

/datum/autowiki/modsuits/proc/generate_variants(datum/mod_theme/theme)
	var/output = ""

	// Check if theme has variants property, if not return empty
	if(!theme.variants || !length(theme.variants))
		return output

	for(var/skin_name in theme.variants)
		if(skin_name == theme.default_skin)
			continue // Skip the default skin

		var/filename = SANITIZE_FILENAME("[theme.name]_[skin_name]")
		output += include_template("Autowiki/ModsuitVariant", list(
			"name" = capitalize(skin_name),
			"icon" = escape_value(filename)
		))

	return output

/datum/autowiki/modsuits/proc/generate_inbuilt_modules(datum/mod_theme/theme)
	var/output = ""

	// Check if theme has inbuilt_modules property, if not return empty
	if(!theme.inbuilt_modules || !length(theme.inbuilt_modules))
		return output

	for(var/module_path in theme.inbuilt_modules)
		var/obj/item/mod/module/module = new module_path()
		output += include_template("Autowiki/ModsuitModule", list(
			"name" = escape_value(module.name)
		))
		qdel(module)

	return output

/datum/autowiki/modsuits/proc/upload_variant_icons(datum/mod_theme/theme)
	if(!theme.variants || !length(theme.variants))
		return

	for(var/skin_name in theme.variants)
		if(skin_name == theme.default_skin)
			continue

		var/obj/item/mod/control/temp_suit = new()
		temp_suit.theme = theme
		temp_suit.skin = skin_name

		var/filename = SANITIZE_FILENAME("[theme.name]_[skin_name]")
		upload_icon(getFlatIcon(temp_suit, no_anim = TRUE), filename)

		qdel(temp_suit)

/datum/autowiki/modsuits/proc/generate_modules()
	var/output = ""

	// Collect all modules and organize by parent type
	var/list/base_modules = list()
	var/list/module_hierarchy = list()

	// First pass: identify base modules (direct children of /obj/item/mod/module)
	for(var/module_path in subtypesof(/obj/item/mod/module))
		var/parent_path = get_parent_module(module_path)
		if(parent_path == /obj/item/mod/module)
			// This is a base module
			base_modules += module_path
			module_hierarchy["[module_path]"] = list(module_path)
		else if(parent_path in base_modules)
			// This is a subtype of a base module
			if(!module_hierarchy["[parent_path]"])
				module_hierarchy["[parent_path]"] = list()
			module_hierarchy["[parent_path]"] += module_path

	// Second pass: handle modules whose parent isn't a direct child
	for(var/module_path in subtypesof(/obj/item/mod/module))
		if(module_path in base_modules)
			continue
		var/found = FALSE
		for(var/base_path in base_modules)
			if(ispath(module_path, base_path))
				if(module_path in module_hierarchy["[base_path]"])
					found = TRUE
					break
				module_hierarchy["[base_path]"] += module_path
				found = TRUE
				break
		if(!found && get_parent_module(module_path) != /obj/item/mod/module)
			// Edge case: subtype of subtype, add to appropriate base
			var/search_path = module_path
			while(search_path && search_path != /obj/item/mod/module)
				search_path = get_parent_module(search_path)
				if(search_path in base_modules)
					module_hierarchy["[search_path]"] += module_path
					break

	// Generate output for each base module and its subtypes
	for(var/base_module_path in base_modules)
		var/obj/item/mod/module/base_module = new base_module_path()
		var/module_header = base_module.name
		output += "\n== [escape_value(module_header)] ==\n"

		// Generate entry for base module and all its subtypes
		var/list/modules_to_process = module_hierarchy["[base_module_path]"]
		for(var/module_path in modules_to_process)
			var/obj/item/mod/module/module = new module_path()
			output += generate_module_output(module)
			qdel(module)

		qdel(base_module)

	return output

/datum/autowiki/modsuits/proc/get_parent_module(module_path)
	var/list/path_parts = splittext("[module_path]", "/")
	if(length(path_parts) <= 1)
		return null
	path_parts.len-- // Remove the last part
	return text2path(jointext(path_parts, "/"))

/datum/autowiki/modsuits/proc/generate_module_output(obj/item/mod/module/module)
	var/filename = SANITIZE_FILENAME(escape_value(format_text(module.name)))

	// Upload module icon
	upload_icon(getFlatIcon(module, no_anim = TRUE), filename)

	return include_template("Autowiki/ModsuitModuleEntry", list(
		"name" = escape_value(module.name),
		"description" = escape_value(module.desc),
		"icon" = escape_value(filename),
		"complexity" = module.complexity,
		"idle_drain" = module.idle_power_cost,
		"active_drain" = module.active_power_cost,
		"use_drain" = module.use_power_cost
	))
