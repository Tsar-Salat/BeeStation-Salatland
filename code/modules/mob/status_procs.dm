
//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, and TRAIT_NEARSIGHT trait.

///Set the jitter of a mob
/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/**
  * Set the dizzyness of a mob to a passed in amount
  *
  * Except if dizziness is already higher in which case it does nothing
  */
/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)

///FOrce set the dizzyness of a mob
/mob/proc/set_dizziness(amount)
	dizziness = max(amount, 0)

///Adjust the drugginess of a mob
/mob/proc/adjust_drugginess(amount)
	return

///Set the drugginess of a mob
/mob/proc/set_drugginess(amount)
	return

///Adjust the disgust level of a mob
/mob/proc/adjust_disgust(amount)
	return

///Set the disgust level of a mob
/mob/proc/set_disgust(amount)
	return

///Adjust the body temperature of a mob, with min/max settings
/mob/proc/adjust_bodytemperature(amount,min_temp=0,max_temp=INFINITY)
	if(bodytemperature >= min_temp && bodytemperature <= max_temp)
		bodytemperature = clamp(bodytemperature + amount,min_temp,max_temp)
