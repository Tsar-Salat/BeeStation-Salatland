

/mob/living/carbon/human/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	if(stat != DEAD && (damagetype==BRUTE || damagetype==BURN) && damage>10 && prob(10+damage/2))
		INVOKE_ASYNC(src, PROC_REF(emote), "scream")
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, wound_bonus, bare_wound_bonus, sharpness)

/mob/living/carbon/human/revive(full_heal = 0, admin_revive = 0)
	if(..())
		if(dna && dna.species)
			dna.species.spec_revival(src)
