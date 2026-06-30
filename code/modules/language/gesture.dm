/**
 * Gesture / line-of-sight reliance for languages (see /datum/language/var/gestural_reliance).
 *
 * Some tongues - the Vraksa hearth-tongue Vraksh especially - carry a chunk of their meaning in
 * posture and hand-sign rather than the voice. That means:
 *  - The voice only carries (100 - gestural_reliance)% of the message, so it degrades badly over
 *    comms (no visual channel) and to anyone who can't see the speaker (blind / x-ray hearing).
 *  - The gestural part needs line of sight AND a speaker who can physically gesture - a lizard with
 *    its hands full or cuffed conveys less of it.
 *
 * This generalises the line-of-sight idea from the (removed) player sign-language feature into a
 * per-language property, applied as a comprehension cap in /atom/movable/proc/translate_language.
 */

/// How much of their gestural channel a speaker can physically produce right now (0-100).
/// Non-carbons (and anything without hands to worry about) gesture freely.
/mob/living/proc/get_gesture_capacity()
	return 100

/// Carbons gesture with their hands, so being cuffed / full-handed / armless cuts it down.
/// Mirrors the old sign-language check_signables_state() logic.
/mob/living/carbon/get_gesture_capacity()
	if(usable_hands <= 0)
		return 0 // no working hands -> can't gesture at all

	if(HAS_TRAIT(src, TRAIT_RESTRAINED))
		// Handcuffs let you sign slowly and clumsily; anything heavier locks you up.
		return HAS_TRAIT_FROM_ONLY(src, TRAIT_RESTRAINED, HANDCUFFED_TRAIT) ? 50 : 0

	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED) || HAS_TRAIT(src, TRAIT_EMOTEMUTE))
		return 0

	var/busy_hands = 0
	for(var/obj/item/held_item as anything in held_items)
		if(isnull(held_item) || (held_item.item_flags & HAND_ITEM)) // slappers/claws/etc. don't count
			continue
		busy_hands++

	var/free_hands = usable_hands - busy_hands
	if(free_hands <= 0)
		return 0 // hands full
	if(free_hands == 1)
		return 50 // one-handed signing is clumsy
	return 100

/**
 * The cap (0-100) on how much of a gesture-reliant language THIS listener can comprehend right now,
 * given which channels are open to them. Returns 100 (no cap) for ordinary spoken languages.
 *
 * cap = (audible fraction, if we can hear) + (visual fraction, if we can see the speaker gesture)
 *  - audible fraction = 100 - gestural_reliance      (carried by the voice; works over radio)
 *  - visual fraction  = gestural_reliance * speaker's gesture capacity   (needs line of sight, no radio)
 */
/// can_hear_them / can_see_them are the channels actually open to this listener (computed by the
/// caller, since they're reused for delivery). Returns the 0-100 comprehension cap.
/mob/living/proc/gesture_comprehension_cap(atom/movable/speaker, datum/language/dialect, can_hear_them, can_see_them)
	var/reliance = dialect.gestural_reliance
	if(reliance <= 0)
		return 100

	var/cap = 0
	if(can_hear_them) // audible fraction, carried by the voice
		cap += (100 - reliance)
	if(can_see_them) // visual fraction, carried by gesture - scaled by how well the speaker can gesture
		var/capacity = 100
		if(isliving(speaker))
			var/mob/living/living_speaker = speaker
			capacity = living_speaker.get_gesture_capacity()
		cap += round(reliance * capacity / 100)
	return cap

/// Whether sound from the speaker can physically reach us right now.
/// Mirrors say()'s "no screams in space, unless you're next to someone": in (near-)vacuum the voice
/// only carries one tile.
/mob/living/proc/sound_reaches_from(atom/movable/speaker)
	var/turf/speaker_turf = get_turf(speaker)
	if(!speaker_turf)
		return TRUE
	var/datum/gas_mixture/air = speaker_turf.return_air()
	var/pressure = air ? air.return_pressure() : 0
	if(pressure >= SOUND_MINIMUM_PRESSURE)
		return TRUE
	return get_dist(src, speaker) <= 1
