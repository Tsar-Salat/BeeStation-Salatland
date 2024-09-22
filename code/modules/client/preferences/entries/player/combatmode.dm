/datum/preference/toggle/sound_combatmode
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	db_key = "sound_combatmode"
	preference_type = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/sound_combatmode/is_accessible(datum/preferences/preferences, ignore_page)
	return ..()

/datum/preference/toggle/sound_combatmode/compile_constant_data()
	return list(
		"forced" = CONFIG_GET(flag/auto_sound_combatmode),
	)
