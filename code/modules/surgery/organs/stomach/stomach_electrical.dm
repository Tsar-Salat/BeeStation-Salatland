/obj/item/organ/stomach/battery
	name = "implantable battery"
	icon_state = "implant-power"
	desc = "A battery that stores charge for species that run on electricity."
	///basically satiety but electrical
	var/crystal_charge = ETHEREAL_CHARGE_FULL
	///used to keep ethereals from spam draining power sources
	var/drain_time = 0

/obj/item/organ/stomach/battery/on_life(delta_time, times_fired)
	. = ..()
	adjust_charge(-ETHEREAL_CHARGE_FACTOR * delta_time)
	handle_charge(owner, delta_time, times_fired)

/obj/item/organ/stomach/battery/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))
	ADD_TRAIT(owner, TRAIT_NOHUNGER, src)

/obj/item/organ/stomach/battery/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, src)

	carbon.clear_alert("ethereal_charge")
	carbon.clear_alert("ethereal_overcharge")

	return ..()

/obj/item/organ/stomach/battery/ethereal/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	adjust_charge(amount / 3.5)

/obj/item/organ/stomach/battery/ethereal/proc/adjust_charge(amount)
	crystal_charge = clamp(crystal_charge + amount, ETHEREAL_CHARGE_NONE, ETHEREAL_CHARGE_DANGEROUS)

/obj/item/organ/stomach/battery/proc/adjust_charge_scaled(amount)
	adjust_charge(amount*max_charge/NUTRITION_LEVEL_FULL)

/obj/item/organ/stomach/battery/proc/set_charge(amount)
	charge = clamp(amount*(1-(damage/maxHealth)), 0, max_charge)
	update_nutrition()

/obj/item/organ/stomach/battery/proc/set_charge_scaled(amount)
	set_charge(amount*max_charge/NUTRITION_LEVEL_FULL)

/obj/item/organ/stomach/battery/proc/update_nutrition()
	if(!HAS_TRAIT(owner, TRAIT_NOHUNGER) && HAS_TRAIT(owner, TRAIT_POWERHUNGRY))
		owner.nutrition = (charge/max_charge)*NUTRITION_LEVEL_FULL

/obj/item/organ/stomach/battery/emp_act(severity)
	switch(severity)
		if(1)
			adjust_charge(-0.5 * max_charge)
			applyOrganDamage(30)
		if(2)
			adjust_charge(-0.25 * max_charge)
			applyOrganDamage(15)

/obj/item/organ/stomach/battery/ipc
	name = "micro-cell"
	icon_state = "microcell"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("assault and battery'd")
	desc = "A micro-cell, for IPC use. Do not swallow."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	max_charge = 2750 //50 nutrition from 250 charge
	charge = 2750

/obj/item/organ/stomach/battery/ipc/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			to_chat(owner, "<span class='warning'>Alert: Heavy EMP Detected. Rebooting power cell to prevent damage.</span>")
		if(2)
			to_chat(owner, "<span class='warning'>Alert: EMP Detected. Cycling battery.</span>")

/obj/item/organ/stomach/battery/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."
	///basically satiety but electrical
	var/crystal_charge = ETHEREAL_CHARGE_FULL
	///used to keep ethereals from spam draining power sources
	var/drain_time = 0

/obj/item/organ/stomach/battery/ethereal/handle_hunger_slowdown(mob/living/carbon/human/human)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (1.5 * (1 - crystal_charge / 100)))

/obj/item/organ/stomach/battery/ethereal/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coeff = 1, safety = 0, tesla_shock = 0, illusion = 0, stun = TRUE)
	SIGNAL_HANDLER

	if(illusion)
		return
	adjust_charge(shock_damage * siemens_coeff * 2)
	to_chat(owner, "<span class='notice'>You absorb some of the shock into your body!</span>")

/obj/item/organ/stomach/battery/ethereal/proc/handle_charge(mob/living/carbon/carbon, delta_time, times_fired)
	switch(crystal_charge)
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/emptycell/ethereal)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.65, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 3)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.325 * delta_time, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 2)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 1)
			carbon.apply_damage(0.2, TOX, null, null, carbon)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 2)
			carbon.apply_damage(0.325 * delta_time, TOX, null, null, carbon)
			if(DT_PROB(5, delta_time)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(carbon)
		else
			carbon.clear_alert("ethereal_charge")
			carbon.clear_alert("ethereal_overcharge")

/obj/item/organ/stomach/battery/ethereal/proc/discharge_process(mob/living/carbon/carbon)
	to_chat(carbon, span_warning("You begin to lose control over your charge!"))
	carbon.visible_message(span_danger("[carbon] begins to spark violently!"))

	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	carbon.add_overlay(overcharge)

	if(do_after(carbon, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED)))
		if(ishuman(carbon))
			var/mob/living/carbon/human/human = carbon
			if(human.dna?.species)
				//fixed_mut_color is also ethereal color (for some reason)
				carbon.flash_lighting_fx(5, 7, human.dna.species.fixed_mut_color ? human.dna.species.fixed_mut_color : human.dna.features["mcolor"])

		playsound(carbon, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		carbon.cut_overlay(overcharge)
		tesla_zap(carbon, 2, crystal_charge*2.5, ZAP_OBJ_DAMAGE | ZAP_ALLOW_DUPLICATES)
		adjust_charge(ETHEREAL_CHARGE_FULL - crystal_charge)
		to_chat(carbon, span_warning("You violently discharge energy!"))
		carbon.visible_message(span_danger("[carbon] violently discharges energy!"))

		if(prob(10)) //chance of developing heart disease to dissuade overcharging oneself
			var/datum/disease/D = new /datum/disease/heart_failure
			carbon.ForceContractDisease(D)
			to_chat(carbon, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
			carbon.playsound_local(carbon, 'sound/effects/singlebeat.ogg', 100, 0)

		carbon.Paralyze(100)
