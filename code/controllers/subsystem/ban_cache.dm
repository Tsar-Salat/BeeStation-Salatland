/// Subsystem that batches a ban cache list for clients on initialize
/// This way we don't need to do ban checks in series later in the code
SUBSYSTEM_DEF(ban_cache)

/datum/controller/subsystem/ban_cache
	name = "Ban Cache"
	init_stage = INITSTAGE_LAST
	ss_flags = SS_NO_FIRE
	var/query_started = FALSE

/datum/controller/subsystem/ban_cache/Initialize()
	generate_queries()
	return SS_INIT_SUCCESS

/// Generates ban caches for any logged in clients. This ensures the amount of in-series ban checking we have to do that actually involves sleeps is VERY low
/datum/controller/subsystem/ban_cache/proc/generate_queries()
	query_started = TRUE
	if(!SSdbcore.Connect())
		return
	var/current_time = REALTIMEOFDAY
	var/list/look_for = list()

	var/list/query_args = list()
	var/list/query_arg_keys = list()

	var/num_keys = 0
	for(var/ckey in GLOB.directory)
		var/client/lad = GLOB.directory[ckey]
		// If they've already got a ban cached, or a request goin, don't do it
		if(lad.ban_cache || lad.ban_cache_start)
			continue
		// skip pre-auth users
		if(!lad.logged_in)
			continue

		look_for += ckey
		lad.ban_cache_start = current_time

		query_args += list("key[num_keys]" = ckey)
		query_arg_keys += ":key[num_keys]"
		num_keys++

	if(num_keys == 0)
		return

	var/ssqlname = CONFIG_GET(string/serversqlname)
	var/server_check
	if(CONFIG_GET(flag/respect_global_bans))
		server_check = "(server_name = '[ssqlname]' OR global_ban = '1')"
	else
		server_check = "server_name = '[ssqlname]'"

	// We're gonna try and make a query for clients
	var/datum/db_query/query_batch_ban_cache = SSdbcore.NewQuery(
		"SELECT ckey, role, applies_to_admins, id, required_playtime_type, target_playtime FROM [format_table_name("ban")] WHERE ckey IN ([query_arg_keys.Join(",")]) AND unbanned_datetime IS NULL AND (expiration_time IS NULL OR expiration_time > NOW()) AND [server_check]",
		query_args
	)

	var/succeeded = query_batch_ban_cache.Execute()
	for(var/ckey in look_for)
		var/client/lad = GLOB.directory[ckey]
		if(!lad || lad.ban_cache_start != current_time)
			continue
		lad.ban_cache_start = 0

	if(!succeeded)
		qdel(query_batch_ban_cache)
		return

	var/list/ckey_to_bans = list()
	var/list/ckey_to_playtime_bans = list()
	// Runs after the check for safety, don't want to override anything
	for(var/ckey in look_for)
		ckey_to_bans[ckey] = list()
		ckey_to_playtime_bans[ckey] = list()

	while(query_batch_ban_cache.NextRow())
		var/ckey = query_batch_ban_cache.item[1]
		var/role = query_batch_ban_cache.item[2]
		var/hits_admins = query_batch_ban_cache.item[3]

		var/list/bans = ckey_to_bans[ckey]
		if(!bans)
			continue

		// Yes I know this is slightly unoptimal, no I do not care
		var/is_admin = GLOB.admin_datums[ckey] || GLOB.deadmins[ckey]
		if(is_admin && !text2num(hits_admins))
			continue

		add_ban_to_cache(bans, ckey_to_playtime_bans[ckey], query_batch_ban_cache.item[4], role, query_batch_ban_cache.item[5], query_batch_ban_cache.item[6])

	for(var/ckey in ckey_to_bans)
		var/client/lad = GLOB.directory[ckey]
		if(!lad)
			continue
		lad.ban_cache = ckey_to_bans[ckey]
		lad.playtime_bans = ckey_to_playtime_bans[ckey]

	qdel(query_batch_ban_cache)
