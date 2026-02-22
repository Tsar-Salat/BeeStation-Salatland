//Called on /mob/living/carbon/Initialize(mapload), for the carbon mobs to register relevant signals.
/mob/living/carbon/register_init_signals()
	. = ..()

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_SOFT_CRITICAL_CONDITION), PROC_REF(on_softcrit_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_SOFT_CRITICAL_CONDITION), PROC_REF(on_softcrit_loss))

/mob/living/carbon/proc/on_softcrit_gain(datum/source)
	stamina.maximum -= 100
	stamina.regen_rate -= 5
	stamina.process()
	throw_alert(ALERT_SOFTCRIT, /atom/movable/screen/alert/softcrit)
	add_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)

/mob/living/carbon/proc/on_softcrit_loss(datum/source)
	stamina.maximum += 100
	stamina.regen_rate += 5
	stamina.process()
	clear_alert(ALERT_SOFTCRIT)
	remove_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
