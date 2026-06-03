/datum/quirk/depression
	name = "Depression"
	desc = "You sometimes just hate life."
	icon = "frown"
	quirk_value = -1
	gain_text = span_danger("You start feeling depressed.")
	lose_text = span_notice("You no longer feel depressed.") //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder causing them to experience sudden moments of sadness."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES
	mail_goodies = list(/obj/item/storage/pill_bottle/happinesspsych)

/datum/quirk/depression/process(seconds_per_tick)
	// 0.416% is 15 successes / 3600 seconds. Calculated with 2 minute
	// mood runtime, so 50% average uptime across the hour.
	if(DT_PROB(0.416, seconds_per_tick))
		SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/depression/remove()
	SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "depression")
