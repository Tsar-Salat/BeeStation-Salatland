/* SKYRAT EDIT REMOVAL
SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE
	init_stage = INITSTAGE_EARLY

	var/file_path
	var/lobby_screen_size = "15x15"
	var/icon/icon
	var/icon/previous_icon
	var/turf/newplayer_start_loc
	var/turf/closed/indestructible/splashscreen/splash_turf

/datum/controller/subsystem/title/Initialize()
	if(file_path && icon)
		return SS_INIT_SUCCESS

	if(fexists("data/previous_title.dat"))
		var/previous_path = rustg_file_read("data/previous_title.dat")
		if(istext(previous_path))
			previous_icon = new(previous_icon)
	fdel("data/previous_title.dat")

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	LAZYREMOVE(provisional_title_screens, "exclude")
	if(length(provisional_title_screens))
		file_path = "[global.config.directory]/title_screens/images/[pick(provisional_title_screens)]"
	else
		file_path = "icons/runtime/default_title.dmi"

	ASSERT(fexists(file_path))

	icon = new(fcopy_rsc(file_path))

	//Calculate the screen size
	var/regex/size_regex = new("(\\d+)x(\\d+)\\.\\w*$")
	if (size_regex.Find(file_path))
		var/width = text2num(size_regex.group[1])
		var/height = text2num(size_regex.group[2])
		lobby_screen_size = "[width]x[height]"

		//Update the new player start (views are centered)
		var/new_player_x = splash_turf.x + FLOOR(width / 2, 1)
		var/new_player_y = splash_turf.y + FLOOR(height / 2, 1)
		newplayer_start_loc = locate(new_player_x, new_player_y, splash_turf.z)
		// Reset the newplayer start loc
		GLOB.newplayer_start.Cut()
		GLOB.newplayer_start += newplayer_start_loc

		//Update fast joiners
		for (var/mob/dead/new_player/fast_joiner in GLOB.new_player_list)
			if(isnull(fast_joiner.client?.view_size))
				fast_joiner.client?.change_view(getScreenSize(fast_joiner))
			else
				fast_joiner.client?.view_size.resetToDefault(getScreenSize(fast_joiner))
			// Execute this immediately, change_view runs through SStimer which doesn't execute until after
			// initialisation
			if (fast_joiner.client?.prefs.read_player_preference(/datum/preference/toggle/auto_fit_viewport))
				fast_joiner.client?.fit_viewport()
			fast_joiner.forceMove(newplayer_start_loc)

	if(splash_turf)
		splash_turf.icon = icon

	return SS_INIT_SUCCESS

/datum/controller/subsystem/title/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if(NAMEOF(src, icon))
				if(splash_turf)
					splash_turf.icon = icon

/datum/controller/subsystem/title/Shutdown()
	if(file_path)
		var/F = file("data/previous_title.dat")
		WRITE_FILE(F, file_path)

	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/atom/movable/screen/splash/S = new(null, thing, FALSE)
		S.Fade(FALSE,FALSE)

/datum/controller/subsystem/title/Recover()
	icon = SStitle.icon
	splash_turf = SStitle.splash_turf
	file_path = SStitle.file_path
	previous_icon = SStitle.previous_icon
*/

GLOBAL_VAR(current_title_screen)

GLOBAL_VAR(current_title_screen_notice)

GLOBAL_VAR(title_html)

GLOBAL_LIST_EMPTY(title_screens)

#define DEFAULT_TITLE_SCREEN_IMAGE 'config/title_screens/icons/skyrat_title_screen.png'
#define DEFAULT_TITLE_LOADING_SCREEN 'config/title_screens/icons/loading_screen.gif'

#define DEFAULT_TITLE_HTML {"
	<html>
		<head>
			<meta http-equiv="X-UA-Compatible" content="IE=edge">
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<style type='text/css'>
				@font-face {
					font-family: "Fixedsys";
					src: url("FixedsysExcelsior3.01Regular.ttf");
				}
				body,
				html {
					margin: 0;
					overflow: hidden;
					text-align: center;
					background-color: black;
					padding-top: 5vmin;
					-ms-user-select: none;
				}

				img {
					border-style:none;
				}

				.fone{
					position: absolute;
					width: auto;
					height: 100vmin;
					min-width: 100vmin;
					min-height: 100vmin;
					top: 50%;
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 0;
				}

				.container_nav {
					position: absolute;
					width: auto;
					min-width: 100vmin;
					min-height: 10vmin;
					padding-left: 0vmin;
					padding-top: 45vmin;
					box-sizing: border-box;
					top: 50%;
					left:50%;
					transform: translate(-50%, -50%);
					z-index: 1;
				}

				.container_terminal {
					position: absolute;
					width: auto;
					box-sizing: border-box;
					padding-top: 3vmin;
					top: 0%;
					left:0%;
					z-index: 1;
				}

				.container_notice {
					position: absolute;
					width: auto;
					box-sizing: border-box;
					padding-top: 1vmin;
					top: 0%;
					left:0%;
					z-index: 1;
				}

				.menu_a {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: left;
					color: #add8e6;
					margin-right: 100%;
					margin-top: 5px;
					padding-left: 6px;
					font-size: 4vmin;
					line-height: 4vmin;
					height: 4vmin;
					letter-spacing: 1px;
					border: 2px solid white;
					background-color: #0080ff;
					opacity: 0.5;
				}

				.menu_a:hover {
					border-left: 3px solid red;
					border-right: 3px solid red;
					font-weight: bolder;
					color: red;
					padding-left: 3px;
				}

				@keyframes pollsmove {
				50% {opacity: 0;}
				}

				.menu_ab {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: left;
					color: #add8e6;
					margin-right: 100%;
					margin-top: 5px;
					padding-left: 6px;
					font-size: 4vmin;
					line-height: 4vmin;
					height: 4vmin;
					letter-spacing: 1px;
					border: 2px solid white;
					background-color: #0080ff;
					opacity: 0.5;
					animation: pollsmove 5s infinite;
				}

				.menu_b {
					display: inline-block;
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: right;
					color:green;
					margin-right: 0%;
					margin-top: 0px;
					font-size: 2vmin;
					line-height: 1vmin;
					letter-spacing: 1px;
				}

				.menu_c {
					display: inline-block;
					font-family: "Fixedsys";
					font-weight: lighter;
					text-decoration: none;
					width: 100%;
					text-align: left;
					color: red;
					margin-right: 0%;
					margin-top: 0px;
					font-size: 3vmin;
					line-height: 2vmin;
				}

			</style>
		</head>
		<body>
			"}

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return

	if(!client)
		return

	if(client.interviewee)
		return FALSE

	if(href_list["observe"])
		play_lobby_button_sound()
		make_me_an_observer()
		return

	if(href_list["server_swap"])
		play_lobby_button_sound()
		server_swap()
		return

	if(href_list["view_manifest"])
		play_lobby_button_sound()
		ViewManifest()
		return

	//if(href_list["toggle_antag"])
	//	play_lobby_button_sound()
	//	var/datum/preferences/preferences = client.prefs
	//	preferences.write_preference(GLOB.preference_entries[/datum/preference/toggle/be_antag], !preferences.read_preference(/datum/preference/toggle/be_antag))
	//	client << output(!preferences.read_preference(/datum/preference/toggle/be_antag), "title_browser:toggle_antag")
	//	return

	if(href_list["character_setup"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
		preferences.update_static_data(src)
		preferences.ui_interact(src)
		return

	if(href_list["game_options"])
		play_lobby_button_sound()
		var/datum/preferences/preferences = client.prefs
		preferences.current_window = PREFERENCE_TAB_GAME_PREFERENCES
		preferences.update_static_data(usr)
		preferences.ui_interact(usr)
		return

	if(href_list["toggle_ready"])
		play_lobby_button_sound()
		//if(!is_admin(client) && length_char(client?.prefs?.read_preference(/datum/preference/text/flavor_text)) < FLAVOR_TEXT_CHAR_REQUIREMENT)
		//	to_chat(src, span_notice("You need at least [FLAVOR_TEXT_CHAR_REQUIREMENT] characters of flavor text to ready up for the round. You have [length_char(client.prefs.read_preference(/datum/preference/text/flavor_text))] characters."))
		//	return

		ready = !ready
		client << output(ready, "title_browser:toggle_ready")
		return

	if(href_list["late_join"])
		play_lobby_button_sound()
		if(!SSticker?.IsRoundInProgress())
			to_chat(src, "<span class='boldwarning'>The round is either not ready, or has already finished...</span>")
			return

		//Determines Relevent Population Cap
		var/relevant_cap
		var/hard_popcap = CONFIG_GET(number/hard_popcap)
		var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
		if(hard_popcap && extreme_popcap)
			relevant_cap = min(hard_popcap, extreme_popcap)
		else
			relevant_cap = max(hard_popcap, extreme_popcap)

		if(SSticker.queued_players.len || (relevant_cap && living_player_count() >= relevant_cap && !(ckey(key) in GLOB.admin_datums)))
			to_chat(src, "<span class='danger'>[CONFIG_GET(string/hard_popcap_message)]</span>")

			var/queue_position = SSticker.queued_players.Find(src)
			if(queue_position == 1)
				to_chat(src, "<span class='notice'>You are next in line to join the game. You will be notified when a slot opens up.</span>")
			else if(queue_position)
				to_chat(src, "<span class='notice'>There are [queue_position-1] players in front of you in the queue to join the game.</span>")
			else
				SSticker.queued_players += src
				to_chat(src, "<span class='notice'>You have been added to the queue to join the game. Your position in queue is [SSticker.queued_players.len].</span>")
			return

		//if(length_char(src.client.prefs.read_preference(/datum/preference/text/flavor_text)) < FLAVOR_TEXT_CHAR_REQUIREMENT)
		//	to_chat(src, "<span class='notice'>You need at least [FLAVOR_TEXT_CHAR_REQUIREMENT] characters of flavor text to join the round. You have [length_char(src.client.prefs.read_preference(/datum/preference/text/flavor_text))] characters."))
		//	return

		LateChoices()
		return

	if(href_list["cancrand"])
		src << browse(null, "window=randjob") //closes the random job window
		LateChoices()
		return

	if(href_list["SelectedJob"])
		select_job(href_list["SelectedJob"])
		return

	if(href_list["viewpoll"])
		play_lobby_button_sound()
		var/datum/poll_question/poll = locate(href_list["viewpoll"]) in GLOB.polls
		poll_player(poll)
		return

	if(href_list["votepollref"])
		var/datum/poll_question/poll = locate(href_list["votepollref"]) in GLOB.polls
		vote_on_poll_handler(poll, href_list)
		return


/mob/dead/new_player/Login()
	. = ..()
	show_title_screen()

/**
 * Shows the titlescreen to a new player.
 */
/mob/dead/new_player/proc/show_title_screen()
	if (client?.interviewee)
		return

	winset(src, "title_browser", "is-disabled=false;is-visible=true")

	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/lobby) //Sending pictures to the client
	assets.send(src)

	update_title_screen()

/**
 * Hard updates the title screen HTML, it causes visual glitches if used.
 */
/mob/dead/new_player/proc/update_title_screen()
	var/dat = get_title_html()

	src << browse(GLOB.current_title_screen, "file=loading_screen.gif;display=0")
	src << browse(dat, "window=title_browser")

/datum/asset/simple/lobby
	assets = list(
		"FixedsysExcelsior3.01Regular.ttf" = 'html/browser/FixedsysExcelsior3.01Regular.ttf',
	)

/**
 * Removes the titlescreen entirely from a mob.
 */
/mob/dead/new_player/proc/hide_title_screen()
	if(client?.mob)
		winset(client, "title_browser", "is-disabled=true;is-visible=false")

/mob/dead/new_player/proc/play_lobby_button_sound()
	SEND_SOUND(src, sound('sound/effects/save.ogg'))

/**
 * Selects a new job or gives random if unset.
 */
/mob/dead/new_player/proc/select_job(job)
	if(job == "Random")
		var/list/dept_data = list()
		for(var/datum/job/job_datum as anything in sort_list(SSjob.occupations, /proc/cmp_job_display_asc))
			if(IsJobUnavailable(job_datum.title, TRUE) != JOB_AVAILABLE)
				continue
			dept_data += job_datum.title
		var/random = pick(dept_data)
		var/randomjob = "<p><center><a href='byond://?src=[REF(src)];SelectedJob=[random]'>[random]</a></center><center><a href='byond://?src=[REF(src)];SelectedJob=Random'>Reroll</a></center><center><a href='byond://?src=[REF(src)];cancrand=[1]'>Cancel</a></center></p>"
		var/datum/browser/popup = new(src, "randjob", "<div align='center'>Random Job</div>", 200, 150)
		popup.set_window_options("can_close=0")
		popup.set_content(randomjob)
		popup.open(FALSE)
		return

	if(!SSticker?.IsRoundInProgress())
		to_chat(usr, "<span class='danger'>The round is either not ready, or has already finished...</span>")
		return

	//if(SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	//	to_chat(usr, span_notice("There is an administrative lock on entering the game!"))
	//	return

	//Determines Relevent Population Cap
	var/relevant_cap
	var/hard_popcap = CONFIG_GET(number/hard_popcap)
	var/extreme_popcap = CONFIG_GET(number/extreme_popcap)
	if(hard_popcap && extreme_popcap)
		relevant_cap = min(hard_popcap, extreme_popcap)
	else
		relevant_cap = max(hard_popcap, extreme_popcap)

	if(LAZYLEN(SSticker.queued_players) && !(ckey(key) in GLOB.admin_datums))
		if((living_player_count() >= relevant_cap) || (src != SSticker.queued_players[1]))
			to_chat(usr, "<span class='warning'>Server is full.</span>")
			return

	AttemptLateSpawn(job)

/**
 * Allows the player to select a server to join from any loaded servers.
 */
/mob/dead/new_player/proc/server_swap()
	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	if(LAZYLEN(servers) == 1)
		var/server_name = servers[1]
		var/server_ip = servers[server_name]
		var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Send me there", "Stay here"))
		if(confirm == "Connect me!")
			to_chat_immediate(src, "So long, spaceman.")
			client << link(server_ip)
		return
	var/server_name = tgui_input_list(src, "Please select the server you wish to swap to:", "Swap servers!", servers)
	if(!server_name)
		return
	var/server_ip = servers[server_name]
	var/confirm = tgui_alert(src, "Are you sure you want to swap to [server_name] ([server_ip])?", "Swapping server!", list("Connect me!", "Stay here!"))
	if(confirm == "Connect me!")
		to_chat_immediate(src, "So long, spaceman.")
		src.client << link(server_ip)

/**
 * Shows the player a list of current polls, if any.
 */
/mob/dead/new_player/proc/playerpolls()
	var/output
	if (!SSdbcore.Connect())
		return
	var/isadmin = FALSE
	if(client?.holder)
		isadmin = TRUE
	var/datum/db_query/query_get_new_polls = SSdbcore.NewQuery({"
		SELECT id FROM [format_table_name("poll_question")]
		WHERE (adminonly = 0 OR :isadmin = 1)
		AND Now() BETWEEN starttime AND endtime
		AND deleted = 0
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_vote")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
		AND id NOT IN (
			SELECT pollid FROM [format_table_name("poll_textreply")]
			WHERE ckey = :ckey
			AND deleted = 0
		)
	"}, list("isadmin" = isadmin, "ckey" = ckey))

	if(!query_get_new_polls.Execute())
		qdel(query_get_new_polls)
		return
	if(query_get_new_polls.NextRow())
		output +={"<a class="menu_ab" href='?src=\ref[src];viewpoll=1'>POLLS (NEW)</a>"}
	else
		output +={"<a class="menu_a" href='?src=\ref[src];viewpoll=1'>POLLS</a>"}
	qdel(query_get_new_polls)
	if(QDELETED(src))
		return
	return output

GLOBAL_LIST_EMPTY(startup_messages)
// FOR MOR INFO ON HTML CUSTOMISATION, SEE: https://github.com/Skyrat-SS13/Skyrat-tg/pull/4783

#define MAX_STARTUP_MESSAGES 27

/mob/dead/new_player/proc/get_title_html()
	var/dat = GLOB.title_html
	if(SSticker.current_state == GAME_STATE_STARTUP)
		dat += {"<img src="loading_screen.gif" class="fone" alt="">"}
		dat += {"
		<div class="container_terminal">
			<p class="menu_b">SYSTEMS INITIALIZING:</p>
		"}
		var/loop_index = 0
		for(var/i in GLOB.startup_messages)
			if(loop_index >= MAX_STARTUP_MESSAGES)
				break
			dat += i
			loop_index++
		dat += "</div>"

	else
		dat += {"<img src="loading_screen.gif" class="fone" alt="">"}

		if(GLOB.current_title_screen_notice)
			dat += {"
			<div class="container_notice">
				<p class="menu_c">[GLOB.current_title_screen_notice]</p>
			</div>
		"}

		dat += {"
		<div class="container_nav">
			<a class="menu_a" href='?src=\ref[src];character_setup=1'>SETUP ([uppertext(client.prefs.read_preference(/datum/preference/name/real_name))])</a>
		"}

		dat += {"<a class="menu_a" href='?src=\ref[src];game_options=1'>GAME OPTIONS</a>
		"}

		if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
			dat += {"<a id="ready" class="menu_a" href='?src=\ref[src];toggle_ready=1'>[ready == PLAYER_READY_TO_PLAY ? "READY ☑" : "READY ☒"]</a>
		"}
		else
			dat += {"<a class="menu_a" href='?src=\ref[src];late_join=1'>JOIN</a>
		"}
			dat += {"<a class="menu_a" href='?src=\ref[src];view_manifest=1'>CREW</a>
		"}

		//dat += {"<a id="be_antag" class="menu_a" href='?src=\ref[src];toggle_antag=1'>[client.prefs.read_preference(/datum/preference/toggle/be_antag) ? "BE ANTAG ☑" : "BE ANTAG ☒"]</a>
		//"}

		dat += {"<a class="menu_a" href='?src=\ref[src];observe=1'>OBSERVE</a>
		"}

		dat += {"
			<a class="menu_a" href='?src=\ref[src];server_swap=1'>SWAP SERVERS</a>
		"}

		//if(!is_guest_key(src.key))
		//	dat += playerpolls()

		dat += "</div>"
		dat += {"
		<script language="JavaScript">
			var ready_int=0;
			var ready_mark=document.getElementById("ready");
			var ready_marks=new Array('READY ☒', 'READY ☑');
			function toggle_ready(setReady) {
				if(setReady) {
					ready_int = setReady;
					ready_mark.textContent = ready_marks\[ready_int\];
				}
				else {
					ready_int++;
					if (ready_int == ready_marks.length)
						ready_int = 0;
					ready_mark.textContent = ready_marks\[ready_int\];
				}
			}
			var antag_int=0;
			var antag_mark=document.getElementById("be_antag");
			var antag_marks=new Array('BE ANTAG ☑', 'BE ANTAG ☒');
			function toggle_antag(setAntag) {
				if(setAntag) {
					antag_int = setAntag;
					antag_mark.textContent = antag_marks\[antag_int\];
				}
				else {
					antag_int++;
					if (antag_int == antag_marks.length)
						antag_int = 0;
					antag_mark.textContent = antag_marks\[antag_int\];
				}
			}
		</script>
		"}
	dat += "</body></html>"

	return dat

SUBSYSTEM_DEF(title)
	name = "Title Screen"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TITLE

	var/file_path
	var/icon/startup_splash

/datum/controller/subsystem/title/Initialize()
	var/dat
	if(!fexists("[global.config.directory]/skyrat/title_html.txt"))
		to_chat(world, "<span class='boldwarning'>CRITICAL ERROR: Unable to read title_html.txt, reverting to backup title html, please check your server config and ensure this file exists.</span>")
		dat = DEFAULT_TITLE_HTML
	else
		dat = file2text("[global.config.directory]/skyrat/title_html.txt")

	GLOB.title_html = dat

	var/list/provisional_title_screens = flist("[global.config.directory]/title_screens/images/")
	var/list/title_screens = list()

	for(var/screen in provisional_title_screens)
		var/list/formatted_list = splittext(screen, "+")
		if((LAZYLEN(formatted_list) == 1 && (formatted_list[1] != "exclude" && formatted_list[1] != "blank.png" && formatted_list[1] != "startup_splash")))
			title_screens += screen

		if(LAZYLEN(formatted_list) > 1 && lowertext(formatted_list[1]) == "startup_splash")
			var/file_path = "[global.config.directory]/title_screens/images/[screen]"
			ASSERT(fexists(file_path))
			startup_splash = new(fcopy_rsc(file_path))

	if(startup_splash)
		change_title_screen(startup_splash)
	else
		change_title_screen(DEFAULT_TITLE_LOADING_SCREEN)

	if(length(title_screens))
		for(var/i in title_screens)
			var/file_path = "[global.config.directory]/title_screens/images/[i]"
			ASSERT(fexists(file_path))
			var/icon/title2use = new(fcopy_rsc(file_path))
			GLOB.title_screens += title2use

	return ..()

/datum/controller/subsystem/title/Recover()
	startup_splash = SStitle.startup_splash
	file_path = SStitle.file_path

