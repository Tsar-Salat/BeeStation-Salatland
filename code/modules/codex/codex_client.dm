/client
	var/codex_on_cooldown = FALSE

/client/proc/reset_codex_cooldown()
	codex_on_cooldown = FALSE

/client/verb/codex()
	set name = "Codex"
	set category = "IC"
	set src = usr

	if(!mob || !SScodex)
		return

	if(codex_on_cooldown || !mob.can_use_codex())
		to_chat(src, span_warning("You cannot perform codex actions currently."))
		return

	codex_on_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_codex_cooldown)), 3 SECONDS)

	var/datum/codex_entry/entry = SScodex.get_codex_entry("nexus")
	SScodex.present_codex_entry(mob, entry)
