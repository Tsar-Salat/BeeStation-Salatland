/// minutes ckey played in a playtime source
/proc/get_playtime_for_source(player_ckey, source)
	var/list/source_jobs = SSjob.experience_jobs_map[source]
	var/client/player_client = GLOB.directory[player_ckey]
	if(player_client && length(player_client.prefs.exp))
		return source_jobs ? player_client.calc_exp_type(source) : (player_client.prefs.exp[source] || 0)

	var/list/job_titles = list()
	if(source_jobs)
		for(var/datum/job/job as anything in source_jobs)
			job_titles += job.title
	else
		job_titles += source
	var/list/query_args = list("ckey" = player_ckey)
	var/list/placeholders = list()
	for(var/i in 1 to length(job_titles))
		query_args["job[i]"] = job_titles[i]
		placeholders += ":job[i]"
	var/datum/db_query/query_playtime = SSdbcore.NewQuery(
		"SELECT IFNULL(SUM(minutes), 0) FROM [format_table_name("role_time")] WHERE ckey = :ckey AND job IN ([placeholders.Join(", ")])",
		query_args
	)
	if(!query_playtime.warn_execute())
		qdel(query_playtime)
		return
	. = 0
	if(query_playtime.NextRow())
		. = text2num(query_playtime.item[1])
	qdel(query_playtime)

/// adds a ban row to a ban cache, else to playtime_bans if theres a target
/proc/add_ban_to_cache(list/ban_cache, list/playtime_bans, ban_id, role, source, target)
	ban_cache[role] = TRUE
	if(target)
		playtime_bans += list(list("id" = ban_id, "role" = role, "source" = source, "target" = text2num(target)))

/// lifts playtime bans for targets reached
/client/proc/check_playtime_bans()
	set waitfor = FALSE
	var/list/due_bans = list()
	for(var/list/playtime_ban as anything in playtime_bans)
		if(get_playtime_for_source(ckey, playtime_ban["source"]) >= playtime_ban["target"])
			due_bans += list(playtime_ban)
	if(!length(due_bans))
		return

	var/player_name = key_name(src)
	var/list/lifted_roles = list()
	for(var/list/playtime_ban as anything in due_bans)
		var/datum/db_query/query_lift_playtime_ban = SSdbcore.NewQuery({"
			UPDATE [format_table_name("ban")] SET
				unbanned_datetime = NOW(),
				unbanned_ckey = :lifter,
				unbanned_round_id = :round_id
			WHERE id = :ban_id AND unbanned_datetime IS NULL
		"}, list("ban_id" = playtime_ban["id"], "lifter" = PLAYTIME_BAN_LIFTER, "round_id" = GLOB.round_id))
		if(query_lift_playtime_ban.warn_execute() && query_lift_playtime_ban.affected)
			lifted_roles |= playtime_ban["role"]
		qdel(query_lift_playtime_ban)
	if(!length(lifted_roles))
		return
	log_admin_private("[player_name] has played off their playtime ban from [lifted_roles.Join(", ")].")
	if(QDELETED(src))
		return
	build_ban_cache(src)
	to_chat(src, span_boldnotice("You have played enough to lift your playtime ban from [lifted_roles.Join(", ")]."))
