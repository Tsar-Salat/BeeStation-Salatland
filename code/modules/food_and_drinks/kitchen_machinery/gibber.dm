/obj/machinery/gibber
	name = "gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/machines/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/gibber

	var/operating = FALSE //Is it on?
	var/dirty = FALSE // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/meat_produced = 0
	/// Fraction of each limb's butcher drops we produce when gibbing humans
	var/efficiency = 0.25
	var/ignore_clothing = FALSE


/obj/machinery/gibber/Initialize(mapload)
	. = ..()
	add_overlay("grjam")

/obj/machinery/gibber/RefreshParts()
	. = ..()
	gibtime = 40
	meat_produced = 0
	efficiency = initial(efficiency)
	for(var/datum/stock_part/matter_bin/B in component_parts)
		meat_produced += B.tier
		efficiency += B.tier * 0.25
	for(var/datum/stock_part/manipulator/M in component_parts)
		gibtime -= 5 * M.tier
		if(M.tier >= 2)
			ignore_clothing = TRUE

/obj/machinery/gibber/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Outputting <b>[meat_produced]</b> meat slab(s), or <b>[efficiency * 100]%</b> of a human's meat, after <b>[gibtime*0.1]</b> seconds of processing.")
		for(var/datum/stock_part/manipulator/M in component_parts)
			if(M.tier >= 2)
				. += span_notice("Gibber has been upgraded to process inorganic materials.")

/obj/machinery/gibber/update_icon()
	cut_overlays()
	if (dirty)
		add_overlay("grbloody")
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		add_overlay("grjam")
	else if (operating)
		add_overlay("gruse")
	else
		add_overlay("gridle")

/obj/machinery/gibber/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/gibber/container_resist(mob/living/user)
	go_out()

/obj/machinery/gibber/relaymove(mob/living/user, direction)
	go_out()

/obj/machinery/gibber/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(operating)
		to_chat(user, span_danger("It's locked and running."))
		return

	if(!anchored)
		to_chat(user, span_notice("[src] cannot be used unless bolted to the ground."))
		return

	if(user.pulling && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(!iscarbon(L))
			to_chat(user, span_danger("This item is not suitable for the gibber!"))
			return
		var/mob/living/carbon/C = L
		if(C.buckled ||C.has_buckled_mobs())
			to_chat(user, span_warning("[C] is attached to something!"))
			return

		if(!ignore_clothing)
			for(var/obj/item/I in C.held_items + C.get_equipped_items())
				if(!HAS_TRAIT(I, TRAIT_NODROP))
					to_chat(user, span_danger("Subject may not have abiotic items on."))
					return

		user.visible_message(span_danger("[user] starts to put [C] into the gibber!"))

		add_fingerprint(user)

		if(do_after(user, gibtime, target = src))
			if(C && user.pulling == C && !C.buckled && !C.has_buckled_mobs() && !occupant)
				user.visible_message(span_danger("[user] stuffs [C] into the gibber!"))
				C.forceMove(src)
				set_occupant(C)
				update_icon()
	else
		startgibbing(user)

/obj/machinery/gibber/attackby(obj/item/P, mob/user, list/modifiers)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", P))
		return

	else if(default_pry_open(P))
		return

	else if(default_unfasten_wrench(user, P))
		return

	else if(default_deconstruction_crowbar(P))
		return
	else
		return ..()



/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "empty gibber"
	set src in oview(1)
	if(usr.incapacitated)
		return
	if(!usr.canUseTopic())
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/gibber/proc/go_out()
	dump_inventory_contents()
	update_icon()

/obj/machinery/gibber/proc/startgibbing(mob/user)
	if(operating)
		return
	if(!occupant)
		visible_message(span_italics("You hear a loud metallic grinding sound."))
		return
	use_power(1000)
	visible_message(span_italics("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, 1)
	operating = TRUE
	update_use_power(ACTIVE_POWER_USE)
	update_icon()

	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	var/mob/living/mob_occupant = occupant
	var/sourcename = mob_occupant.real_name
	var/sourcejob
	if(ishuman(occupant))
		var/mob/living/carbon/human/gibee = occupant
		sourcejob = gibee.job
	var/sourcenutriment = mob_occupant.nutrition / 15
	var/gibtype = /obj/effect/decal/cleanable/blood/gibs
	var/typeofmeat = /obj/item/food/meat/slab/human
	var/typeofskin

	var/list/obj/item/results = list()
	var/list/datum/disease/diseases = mob_occupant.get_static_viruses()

	if(ishuman(occupant))
		results = get_limb_drops(occupant)
	else
		if(iscarbon(occupant))
			var/mob/living/carbon/C = occupant
			typeofmeat = C.type_of_meat
			gibtype = C.gib_type
			if(ismonkey(C))
				typeofskin = /obj/item/stack/sheet/animalhide/monkey
			else if(isalien(C))
				typeofskin = /obj/item/stack/sheet/animalhide/xeno
		for(var/i in 1 to meat_produced)
			results += new typeofmeat(src)
		if(typeofskin)
			results += new typeofskin(src)

	var/list/obj/item/food/meat/slab/allmeat = list()
	for(var/obj/item/food/meat/slab/newmeat in results)
		allmeat += newmeat
	var/occupant_volume
	if(occupant?.reagents)
		occupant_volume = occupant.reagents.total_volume
	for(var/obj/item/food/meat/slab/newmeat as anything in allmeat)
		newmeat.name = "[sourcename] [newmeat.name]"
		newmeat.subjectname = sourcename
		newmeat.reagents.add_reagent(/datum/reagent/consumable/nutriment, sourcenutriment / length(allmeat)) // Thehehe. Fat guys go first
		if(occupant_volume)
			occupant.reagents.trans_to(newmeat, occupant_volume / length(allmeat), remove_blacklisted = TRUE)
		if(sourcejob)
			newmeat.subjectjob = sourcejob

	log_combat(user, occupant, "gibbed")
	mob_occupant.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
	mob_occupant.death(TRUE)
	mob_occupant.ghostize()
	set_occupant(null)
	qdel(mob_occupant)
	addtimer(CALLBACK(src, PROC_REF(make_meat), results, gibtype, diseases), gibtime)

/// Rolls each limb's butcher drops against our efficiency
/obj/machinery/gibber/proc/get_limb_drops(mob/living/carbon/human/victim)
	var/list/obj/item/results = list()
	var/drop_chance = 0
	for(var/obj/item/bodypart/limb as anything in victim.get_bodyparts())
		for(var/obj/item/drop_type as anything in limb.butcher_drops)
			var/amount = limb.butcher_drops[drop_type] || 1
			drop_chance += amount * efficiency
			if(drop_chance > 1)
				amount = floor(drop_chance)
				if(prob((drop_chance - amount) * 100))
					amount += 1
			else
				amount = 1
				if(!prob(drop_chance * 100))
					continue
			drop_chance = 0

			for(var/i in 1 to amount)
				var/obj/item/result = new drop_type(src)
				if(limb.blood_dna_info)
					result.add_blood_DNA(limb.blood_dna_info)
				results += result
	return results

/obj/machinery/gibber/proc/make_meat(list/obj/item/results, gibtype, list/datum/disease/diseases)
	playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
	operating = FALSE
	update_use_power(IDLE_POWER_USE)
	var/turf/T = get_turf(src)
	var/list/turf/nearby_turfs = RANGE_TURFS(3,T) - T
	var/result_count = length(results)
	for(var/i in 1 to result_count)
		var/obj/item/result = results[i]
		result.forceMove(loc)
		result.throw_at(pick(nearby_turfs), i, 3)
		for(var/turfs in 1 to result_count)
			var/turf/gibturf = pick(nearby_turfs)
			if(!gibturf.density && (src in view(gibturf)))
				new gibtype(gibturf, i, diseases)

	pixel_x = base_pixel_x //return to its spot after shaking
	operating = FALSE
	update_use_power(IDLE_POWER_USE)
	update_icon()

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/input_dir = NORTH

/obj/machinery/gibber/autogibber/Bumped(atom/movable/AM)
	var/atom/input = get_step(src, input_dir)
	if(isliving(AM))
		var/mob/living/victim = AM

		if(victim.loc == input)
			victim.forceMove(src)
			victim.gib()
