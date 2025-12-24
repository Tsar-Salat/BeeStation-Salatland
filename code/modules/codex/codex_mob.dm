/mob/proc/can_use_codex()
	return FALSE

/mob/dead/new_player/authenticated/can_use_codex()
	return TRUE

/mob/living/silicon/can_use_codex()
	return TRUE

/mob/observer/can_use_codex()
	return TRUE

/mob/living/carbon/human/can_use_codex()
	return TRUE //has_implant(/obj/item/implant/codex, functioning = TRUE)

/mob/living/carbon/human/get_codex_value()
	return "[lowertext(dna.species.name)] (species)"
