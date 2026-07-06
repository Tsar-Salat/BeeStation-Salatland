/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as you can remember, you've always been afraid of the dark. While in the dark without a light source, you instinctually act careful, and constantly feel a sense of dread."
	icon = "lightbulb"
	quirk_value = -1
	medical_record_text = "Patient demonstrates a fear of the dark."
	mail_goodies = list(/obj/effect/spawner/random/engineering/flashlight)

/datum/quirk/nyctophobia/add()
	RegisterSignal(quirk_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_holder_moved))

/datum/quirk/nyctophobia/remove()
	UnregisterSignal(quirk_target, COMSIG_MOVABLE_MOVED)
	SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/// Called when the quirk holder moves. Updates the quirk holder's mood.
/datum/quirk/nyctophobia/proc/on_holder_moved(/mob/living/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	if(quirk_target.stat != CONSCIOUS || quirk_target.IsSleeping() || quirk_target.IsUnconscious())
		return

	if(HAS_TRAIT(quirk_target, TRAIT_FEARLESS))
		return

	var/mob/living/carbon/human/human_holder = quirk_target

	if(human_holder.dna?.species.id in list(SPECIES_SHADOW, SPECIES_NIGHTMARE))
		return

	if((human_holder.sight & SEE_TURFS) == SEE_TURFS)
		return

	var/turf/holder_turf = get_turf(quirk_target)

	var/lums = holder_turf.get_lumcount()

	if(lums > LIGHTING_TILE_IS_DARK)
		SEND_SIGNAL(quirk_target, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")
		return

	if(quirk_target.move_intent == MOVE_INTENT_RUN)
		to_chat(quirk_target, span_warning("Easy, easy, take it slow... you're in the dark..."))
		quirk_target.toggle_move_intent()
	SEND_SIGNAL(quirk_target, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
