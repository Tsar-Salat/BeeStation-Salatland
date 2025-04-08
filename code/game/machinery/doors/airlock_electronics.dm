/obj/item/electronics/airlock
	name = "airlock electronics"
	req_access = list(ACCESS_MAINT_TUNNELS)
	custom_price = 5
	/// A list of all granted accesses
	var/list/accesses = list()
	/// If the airlock should require ALL or only ONE of the listed accesses
	var/one_access = 0
	/// Unrestricted sides, or sides of the airlock that will open regardless of access
	var/unres_sides = 0
	///what name are we passing to the finished airlock
	var/passed_name
	///what string are we passing to the finished airlock as the cycle ID
	var/passed_cycle_id
	/// A holder of the electronics, in case of them working as an integrated part
	var/holder

/obj/item/electronics/airlock/examine(mob/user)
	. = ..()
	. += span_notice("Has a neat <i>selection menu</i> for modifying airlock access levels.")


/obj/item/electronics/airlock/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/electronics/airlock/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirlockElectronics")
		ui.open()

/obj/item/electronics/airlock/ui_static_data(mob/user)
	var/list/data = list()
	var/list/regions = list()
	for(var/i in 1 to 7)
		var/list/accesses = list()
		for(var/access in get_region_accesses(i))
			if (get_access_desc(access))
				accesses += list(list(
					"desc" = replacetext(get_access_desc(access), "&nbsp", " "),
					"ref" = access,
				))

		regions += list(list(
			"name" = get_region_accesses_name(i),
			"regid" = i,
			"accesses" = accesses
		))

	data["regions"] = regions
	return data

/obj/item/electronics/airlock/ui_data()
	var/list/data = list()
	data["accesses"] = accesses
	data["oneAccess"] = one_access
	data["unres_direction"] = unres_sides
	data["passedName"] = passed_name
	data["passedCycleId"] = passed_cycle_id
	return data

///shared by rcd & airlock electronics
/obj/item/electronics/airlock/proc/do_action(action, params)
	switch(action)
		if("clear_all")
			accesses = list()
			one_access = 0
		if("grant_all")
			accesses = get_all_accesses()
		if("one_access")
			one_access = !one_access
		if("set")
			var/access = text2num(params["access"])
			if (!(access in accesses))
				accesses += access
			else
				accesses -= access
		if("direc_set")
			var/unres_direction = text2num(params["unres_direction"])
			unres_sides ^= unres_direction //XOR, toggles only the bit that was clicked
		if("grant_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses |= get_region_accesses(region)
		if("deny_region")
			var/region = text2num(params["region"])
			if(isnull(region))
				return
			accesses -= get_region_accesses(region)
		if("passedName")
			var/new_name = trim(sanitize("[params["passedName"]]"), 30)
			passed_name = new_name
		if("passedCycleId")
			var/new_cycle_id = trim(sanitize(params["passedCycleId"]), 30)
			passed_cycle_id = new_cycle_id

/obj/item/electronics/airlock/ui_act(action, params)
	. = ..()
	if(.)
		return
	do_action(action, params)
	return TRUE

/obj/item/electronics/airlock/ui_host()
	if(holder)
		return holder
	return src
