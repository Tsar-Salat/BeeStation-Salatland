//Cloning revival method.
//The pod handles the actual cloning while the computer manages the clone profiles

#define CLONE_INITIAL_DAMAGE     150    //Clones in clonepods start with 150 cloneloss damage and 150 brainloss damage, thats just logical
#define MINIMUM_HEAL_LEVEL 40

#define SPEAK(message) radio?.talk_into(src, message, radio_channel)

/obj/machinery/clonepod
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = list(ACCESS_CLONING) //FOR PREMATURE UNLOCKING.
	verb_say = "states"
	circuit = /obj/item/circuitboard/machine/clonepod
	interaction_flags_click = ALLOW_SILICON_REACH

	var/heal_level //The clone is released once its health reaches this level.
	var/obj/machinery/computer/cloning/connected //So we remember the connected clone machine.
	var/mess = FALSE //Need to clean out it if it's full of exploded clone.
	var/attempting = FALSE //One clone attempt at a time thanks
	var/speed_coeff
	var/efficiency

	var/fleshamnt = 1 //Amount of synthflesh needed per cloning cycle, is divided by efficiency

	var/datum/mind/clonemind

	var/internal_radio = TRUE
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_med
	var/radio_channel = RADIO_CHANNEL_MEDICAL

	var/obj/effect/countdown/clonepod/countdown

	var/list/unattached_flesh
	var/flesh_number = 0
	var/datum/bank_account/current_insurance
	fair_market_price = 5 // He nodded, because he knew I was right. Then he swiped his credit card to pay me for arresting him.
	var/experimental_pod = FALSE //experimental cloner will have true. TRUE allows you to clone a weird brain after scanning it.

/obj/machinery/clonepod/Initialize(mapload)
	create_reagents(100, OPENCONTAINER)

	. = ..()

	countdown = new(src)

	if(internal_radio)
		radio = new(src)
		radio.keyslot = new radio_key
		radio.subspace_transmission = TRUE
		radio.canhear_range = 0
		radio.recalculateChannels()

/obj/machinery/clonepod/Destroy()
	eject_clone("due to Destroy()")
	QDEL_NULL(radio)
	QDEL_NULL(countdown)
	if(connected)
		connected.detach_clonepod(src)
	QDEL_LIST(unattached_flesh)
	. = ..()

/obj/machinery/clonepod/RefreshParts()
	. = ..()
	speed_coeff = 0
	efficiency = 0
	reagents.maximum_volume = 0
	fleshamnt = 1
	for(var/obj/item/reagent_containers/cup/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/datum/stock_part/scanning_module/S in component_parts)
		efficiency += S.tier
		fleshamnt = 1/max(efficiency-1, 1)
	for(var/datum/stock_part/manipulator/manipulator in component_parts)
		speed_coeff += manipulator.tier
	heal_level = (efficiency * 15) + 10
	if(heal_level < MINIMUM_HEAL_LEVEL)
		heal_level = MINIMUM_HEAL_LEVEL
	if(heal_level > 100)
		heal_level = 100

SCREENTIP_ATTACK_HAND(/obj/machinery/clonepod, "Examine")

/obj/machinery/clonepod/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.examinate(src)

/obj/machinery/clonepod/click_alt(mob/user)
	if (alert(user, "Are you sure you want to empty the cloning pod?", "Empty Reagent Storage:", "Yes", "No") != "Yes")
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("You empty \the [src]'s release valve onto the floor."))
	reagents.expose(user.loc)
	src.reagents.clear_reagents()
	return CLICK_ACTION_SUCCESS

/obj/machinery/clonepod/attack_silicon(mob/user)
	return attack_hand(user)

/obj/machinery/clonepod/examine(mob/user)
	. = ..()
	. += span_notice("The <i>linking</i> device can be <i>scanned<i> with a multitool. It can be emptied by Alt-Clicking it.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Cloning speed at <b>[speed_coeff*50]%</b>.<br>Predicted amount of cellular damage: <b>[100-heal_level]%</b><br> Storing up to <b>[reagents.maximum_volume]cm<sup>3</sup></b> of synthflesh.<br>")
		. += "Synthflesh consumption at <b>[round(fleshamnt*90, 1)]cm<sup>3</sup></b> per clone.</span><br>"
		. += span_notice("The reagent display reads: [round(reagents.total_volume, 1)] / [reagents.maximum_volume] cm<sup>3</sup>")
		if(efficiency > 5)
			. += span_notice("Pod has been upgraded to support autoprocessing and apply beneficial mutations.")
	var/mob/living/mob_occupant = occupant
	if(mess)
		. += "It's filled with blood and viscera. You swear you can see it moving..."
	if(is_operational && istype(mob_occupant))
		if(mob_occupant.stat != DEAD)
			. += "Current clone cycle is [round(get_completion())]% complete."

/obj/machinery/clonepod/return_air()
	var/datum/gas_mixture/nitrogen_atmosphere = new
	nitrogen_atmosphere.set_gas(/datum/gas/nitrogen, 104)
	nitrogen_atmosphere.temperature = T20C
	return nitrogen_atmosphere

/obj/machinery/clonepod/proc/get_completion()
	. = FALSE
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		. = (100 * ((mob_occupant.health + 100) / (heal_level + 100)))

//Start growing a human clone in the pod!
/obj/machinery/clonepod/proc/growclone(datum/record/cloning/record, experimental)
	var/body_only = record.body_only
	if(!reagents.has_reagent(/datum/reagent/medicine/synthflesh, fleshamnt))
		connected_message("Cannot start cloning: Not enough synthflesh.")
		return ERROR_NO_SYNTHFLESH
	if(panel_open)
		return ERROR_PANEL_OPENED
	if(mess || attempting)
		return ERROR_MESS_OR_ATTEMPTING
	if(experimental && !experimental_pod)
		return ERROR_MISSING_EXPERIMENTAL_POD

	if(!body_only && !experimental)
		var/datum/mind/mind = record.resolve_mind()
		if(!istype(mind))
			return ERROR_NOT_MIND
		if(record.last_death < 0) //presaved clone is not clonable
			return ERROR_PRESAVED_CLONE
		if(abs(mind.last_death - record.last_death) > 5) //You can't clone old ones. 5 seconds grace because a sync-failure can happen.
			return ERROR_OUTDATED_CLONE
		if(!QDELETED(mind.current))
			if(mind.current.stat != DEAD)
				return ERROR_ALREADY_ALIVE
			if(mind.current.suiciding)
				return ERROR_COMMITED_SUICIDE
		if(!mind.active)
			// get_ghost() will fail if they're unable to reenter their body
			var/mob/dead/observer/G = mind.get_ghost()
			if(!G)
				return ERROR_SOUL_DEPARTED
			if(G.suiciding)
				return ERROR_SUICIDED_BODY
		clonemind = mind
	if(experimental || !body_only)
		current_insurance = record.bank_account
	attempting = TRUE //One at a time!!
	countdown.start()

	var/mob/living/carbon/human/H = new /mob/living/carbon/human(src)

	var/clonename = record.name || "clone ([rand(1,999)])"
	H.real_name = clonename
	if(record.gender in list(MALE, FEMALE, PLURAL, NEUTER))
		H.gender = record.gender
	if(record.age)
		H.age = record.age

	H.hardset_dna(record.unique_identity, record.datum_dna.mutation_index.Copy(), clonename, record.datum_dna.blood_type, record.species, record.datum_dna.features.Copy())
	if(record.unique_enzymes)
		H.dna.unique_enzymes = record.unique_enzymes

	if(!HAS_TRAIT(H, TRAIT_RADIMMUNE))//dont apply mutations if the species is Mutation proof.
		if(efficiency > 2)
			var/list/unclean_mutations = (GLOB.not_good_mutations|GLOB.bad_mutations)
			H.dna.remove_mutation_group(unclean_mutations)
		if(efficiency > 5 && prob(20))
			H.easy_random_mutate(POSITIVE)
		if(efficiency < 3 && prob(50))
			var/mob/M = H.easy_random_mutate(NEGATIVE+MINOR_NEGATIVE)
			if(ismob(M))
				H = M

	H.adjust_silence(40 SECONDS) //Prevents an extreme edge case where clones could speak if they said something at exactly the right moment.
	occupant = H

	icon_state = "pod_1"
	//Get the clone body ready
	maim_clone(H)
	ADD_TRAIT(H, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_MUTE, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOBREATH, CLONING_POD_TRAIT)
	ADD_TRAIT(H, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	H.Unconscious(80)

	var/result = CLONING_SUCCESS
	if(experimental || (experimental_pod && !body_only))
		offer_to_ghost(H)
		result = CLONING_SUCCESS_EXPERIMENTAL
	else if(!body_only)
		clonemind.transfer_to(H)

	if(H.mind)
		H.ghostize(TRUE)	//Only does anything if they were still in their old body and not already a ghost
		to_chat(H.get_ghost(TRUE), span_notice("Your body is beginning to regenerate in a cloning pod. You will become conscious when it is complete."))

	H.faction |= record.factions
	for(var/datum/brain_trauma/BT as anything in record.traumas)
		var/datum/brain_trauma/cloned_trauma = BT.on_clone()
		if(cloned_trauma)
			H.gain_trauma(cloned_trauma, BT.resilience)

	H.set_cloned_appearance()
	H.set_suicide(FALSE)

	attempting = FALSE
	return result

/obj/machinery/clonepod/proc/offer_to_ghost(mob/living/carbon/H)
	set waitfor = FALSE
	var/datum/poll_config/config = new(
		check_jobban = ROLE_EXPERIMENTAL_CLONE,
		poll_time = 30 SECONDS,
		jump_target = src,
		role_name_text = "[H.real_name]'s experimental clone?",
		alert_pic = src,
		amount_to_pick = 1,
	)
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, H)
	if(candidate)
		H.key = candidate.key

		log_game("[key_name(candidate)] became [H.real_name]'s experimental clone.")
		message_admins("[key_name_admin(candidate)] became [H.real_name]'s experimental clone.")
		to_chat(H, span_warning("You will instantly die if you do 'ghost'. Please stand by until the cloning is done."))

//Grow clones to maturity then kick them out.  FREELOADERS
/obj/machinery/clonepod/process()
	var/mob/living/mob_occupant = occupant

	if(!is_operational) //Autoeject if power is lost (or the pod is dysfunctional due to whatever reason)
		if(mob_occupant)
			eject_clone("due to power loss", "Clone Ejected: Loss of power.")
		return

	if(!mob_occupant || mob_occupant.loc != src)
		set_occupant(null)
		if(!mess && !panel_open)
			icon_state = "pod_0"
		use_power(200)
		return

	if(!reagents.has_reagent(/datum/reagent/medicine/synthflesh, fleshamnt))
		eject_clone("due to insufficient material", "Clone Ejected: Not enough material.", \
			"The cloning of [mob_occupant.real_name] has been ended prematurely due to insufficient material.")
		return

	if(SSeconomy.full_ancap)
		if(!current_insurance)
			eject_clone("due to invalid bank account", "Clone Ejected: No bank account.", \
				"The cloning of [mob_occupant.real_name] has been terminated due to no bank account to draw payment from.")
			return
		if(!current_insurance.adjust_money(-fair_market_price))
			eject_clone("due to insufficient funds", "Clone Ejected: Out of Money.", \
				"The cloning of [mob_occupant.real_name] has been ended prematurely due to being unable to pay.")
			return
		// there's the same code in `_machinery.dm`
		if(fair_market_price && seller_department)
			var/list/dept_list = SSeconomy.get_dept_id_by_bitflag(seller_department)
			if(length(dept_list))
				fair_market_price = round(fair_market_price/length(dept_list))
				for(var/datum/bank_account/department/D in dept_list)
					D.adjust_money(fair_market_price)

	if(mob_occupant.stat == DEAD || mob_occupant.suiciding)
		eject_clone("after dying or suiciding", "Clone Rejected: Deceased.", \
			"The cloning of [mob_occupant.real_name] has been aborted due to unrecoverable tissue failure.")
		return

	if(mob_occupant.cloneloss <= (100 - heal_level))
		connected_message("Cloning Process Complete.")
		SPEAK("The cloning cycle of [mob_occupant.real_name] is complete.")

		// If the cloner is upgraded to debugging high levels, sometimes
		// organs and limbs can be missing.
		for(var/i in unattached_flesh)
			if(isorgan(i))
				var/obj/item/organ/O = i
				O.organ_flags &= ~ORGAN_FROZEN
				O.Insert(mob_occupant)
			else if(isbodypart(i))
				var/obj/item/bodypart/BP = i
				BP.try_attach_limb(mob_occupant)

		go_out()
		log_cloning("[key_name(mob_occupant)] completed cloning cycle in [src] at [AREACOORD(src)].")
		return

	mob_occupant.Unconscious(80)
	var/dmg_mult = CONFIG_GET(number/damage_multiplier)
	//Slowly get that clone healed and finished.
	mob_occupant.adjustCloneLoss(-((speed_coeff / 2) * dmg_mult), TRUE, TRUE)
	reagents.remove_reagent(/datum/reagent/medicine/synthflesh, fleshamnt)
	var/progress = CLONE_INITIAL_DAMAGE - mob_occupant.getCloneLoss()
	// To avoid the default cloner making incomplete clones
	progress += (100 - MINIMUM_HEAL_LEVEL)
	var/milestone = CLONE_INITIAL_DAMAGE / flesh_number
	var/installed = flesh_number - unattached_flesh.len

	if((progress / milestone) >= installed)
		// attach some flesh
		var/obj/item/I = pick_n_take(unattached_flesh)
		if(isorgan(I))
			var/obj/item/organ/O = I
			O.organ_flags &= ~ORGAN_FROZEN
			O.Insert(mob_occupant)
		else if(isbodypart(I))
			var/obj/item/bodypart/BP = I
			BP.try_attach_limb(mob_occupant)

	use_power(5000 * speed_coeff) //This might need tweaking.

/obj/machinery/clonepod/proc/eject_clone(log_reason, console_message, radio_message)
	var/mob/living/mob_occupant = occupant
	connected_message(console_message)
	if(radio_message)
		SPEAK(radio_message)
	go_out()
	if(mob_occupant)
		log_cloning("[key_name(mob_occupant)] ejected from [src] at [AREACOORD(src)] [log_reason].")

REGISTER_BUFFER_HANDLER(/obj/machinery/clonepod)

DEFINE_BUFFER_HANDLER(/obj/machinery/clonepod)
	if(istype(buffer, /obj/machinery/computer/cloning))
		if(get_area(buffer) != get_area(src))
			to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
			FLUSH_BUFFER(buffer_parent)
			return NONE
		to_chat(user, "<font color = #666633>-% Successfully linked [buffer] with [src] %-</font color>")
		var/obj/machinery/computer/cloning/comp = buffer
		if(connected)
			connected.detach_clonepod(src)
		comp.attach_clonepod(src)
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<font color = #666633>-% Successfully stored [REF(src)] [name] in buffer %-</font color>")
	else
		return NONE
	return COMPONENT_BUFFER_RECEIVED

//Let's unlock this early I guess.  Might be too early, needs tweaking.
/obj/machinery/clonepod/attackby(obj/item/W, mob/user, list/modifiers)
	if(!(occupant || mess))
		if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]",W))
			return

	if(default_deconstruction_crowbar(W))
		return

	var/mob/living/mob_occupant = occupant
	if(W.GetID())
		if(!check_access(W))
			to_chat(user, span_danger("Access Denied."))
			return
		if(!(mob_occupant || mess))
			to_chat(user, span_danger("Error: Pod has no occupant."))
			return
		else
			add_fingerprint(user)
			to_chat(user, span_notice("You force an emergency ejection."))
			eject_clone("manually by [key_name(user)]", "Emergency Ejection", \
				mob_occupant ? "An emergency ejection of [mob_occupant.real_name] has occurred. Survival not guaranteed." : null)
			log_combat(user, mob_occupant, "ejected", W, "from [src]", important = FALSE)
	else
		return ..()

/obj/machinery/clonepod/should_emag(mob/user)
	return !!occupant

/obj/machinery/clonepod/on_emag(mob/user)
	..()
	to_chat(user, span_warning("You corrupt the genetic compiler."))
	malfunction()
	add_fingerprint(user)
	log_cloning("[key_name(user)] emagged [src] at [AREACOORD(src)], causing it to malfunction.")
	log_combat(user, src, "emagged", null, occupant ? "[occupant] inside, killing them via malfunction." : null, important = FALSE)

//Put messages in the connected computer's temp var for display.
/obj/machinery/clonepod/proc/connected_message(message)
	if(!connected || !message)
		return
	connected.temp = message
	connected.ui_update()

/obj/machinery/clonepod/proc/go_out(move = TRUE)
	countdown.stop()
	var/mob/living/mob_occupant = occupant
	var/turf/T = get_turf(src)

	if(mess) //Clean that mess and dump those gibs!
		for(var/obj/fl in unattached_flesh)
			fl.forceMove(T)
			if(istype(fl, /obj/item/organ))
				var/obj/item/organ/O = fl
				O.organ_flags &= ~ORGAN_FROZEN
		unattached_flesh.Cut()
		mess = FALSE
		new /obj/effect/gibspawner/generic(get_turf(src), mob_occupant)
		audible_message(span_italics("You hear a splat."))
		icon_state = "pod_0"
		return

	if(!mob_occupant)
		return

	if(HAS_TRAIT(mob_occupant, TRAIT_NOCLONELOSS))
		var/cl_loss = mob_occupant.getCloneLoss()
		mob_occupant.adjustBruteLoss(cl_loss, FALSE)
		mob_occupant.setCloneLoss(0, FALSE, TRUE)

	current_insurance = null
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLEHEART, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_STABLELIVER, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_EMOTEMUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_MUTE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOCRITDAMAGE, CLONING_POD_TRAIT)
	REMOVE_TRAIT(mob_occupant, TRAIT_NOBREATH, CLONING_POD_TRAIT)

	mob_occupant.grab_ghost()
	to_chat(occupant, span_notice("<b>There is a bright flash!</b><br><i>You feel like a new being.</i>"))
	var/postclonemessage = CONFIG_GET(string/policy_postclonetext)
	if(postclonemessage)
		to_chat(occupant, postclonemessage)
	mob_occupant.flash_act()

	if(move)
		occupant.forceMove(T)
	icon_state = "pod_0"
	mob_occupant.domutcheck(1) //Waiting until they're out before possible monkeyizing. The 1 argument forces powers to manifest.
	for(var/fl in unattached_flesh)
		qdel(fl)
	unattached_flesh.Cut()

	set_occupant(null)
	clonemind = null

// Guess they moved out on their own, remove any clone status effects
// If the occupant var is null, welp what can we do
/obj/machinery/clonepod/Exited(atom/movable/AM, atom/newloc)
	if(AM == occupant)
		go_out(FALSE)
	. = ..()

/obj/machinery/clonepod/proc/malfunction()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		connected_message("Critical Error!")
		SPEAK("Critical error! Please contact a Thinktronic Systems \
			technician, as your warranty may be affected.")
		mess = TRUE
		maim_clone(mob_occupant)	//Remove every bit that's grown back so far to drop later, also destroys bits that haven't grown yet
		icon_state = "pod_g"
		if(clonemind && mob_occupant.mind != clonemind)
			clonemind.transfer_to(mob_occupant)
		mob_occupant.grab_ghost() // We really just want to make you suffer.
		flash_color(mob_occupant, flash_color="#960000", flash_time=100)
		to_chat(mob_occupant, span_warning("<b>Agony blazes across your consciousness as your body is torn apart.</b><br><i>Is this what dying is like? Yes it is.</i>"))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
		SEND_SOUND(mob_occupant, sound('sound/hallucinations/veryfar_noise.ogg',0,1,50))
		log_cloning("[key_name(mob_occupant)] destroyed within [src] at [AREACOORD(src)] due to malfunction.")
		QDEL_IN(mob_occupant, 40)

/obj/machinery/clonepod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/clonepod/container_resist(mob/living/user)
	if(user.stat == CONSCIOUS)
		go_out()

/obj/machinery/clonepod/emp_act(severity)
	. = ..()
	if (!(. & EMP_PROTECT_SELF))
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && prob(100/(severity*efficiency)))
			eject_clone("due to EMP pulse", Gibberish("EMP-caused Accidental Ejection"), \
				Gibberish("Exposure to electromagnetic fields has caused the ejection of [mob_occupant.real_name] prematurely."))

/obj/machinery/clonepod/ex_act(severity, target)
	..()
	if(!QDELETED(src) && occupant)
		eject_clone("due to explosion")

/obj/machinery/clonepod/handle_atom_del(atom/A)
	if(A == occupant)
		set_occupant(null)
		countdown.stop()

/obj/machinery/clonepod/deconstruct(disassembled = TRUE)
	for(var/obj/item/reagent_containers/cup/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	if(occupant)
		eject_clone("due to deconstruction")
	..()

/obj/machinery/clonepod/proc/maim_clone(mob/living/carbon/human/H)
	if(!unattached_flesh)
		unattached_flesh = list()
	else
		for(var/fl in unattached_flesh)
			qdel(fl)
		unattached_flesh.Cut()

	H.setCloneLoss(CLONE_INITIAL_DAMAGE, TRUE, TRUE)     //Yeah, clones start with very low health, not with random, because why would they start with random health
	// In addition to being cellularly damaged, they also have no limbs or internal organs.
	// Applying brainloss is done when the clone leaves the pod, so application of traumas can happen
	// based on the level of damage sustained.

	if(!HAS_TRAIT(H, TRAIT_NODISMEMBER))
		var/static/list/zones = list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG)
		for(var/zone in zones)
			var/obj/item/bodypart/BP = H.get_bodypart(zone)
			if(BP)
				BP.drop_limb()
				BP.forceMove(src)
				unattached_flesh += BP

	for(var/o in H.internal_organs)
		var/obj/item/organ/organ = o
		if(!istype(organ) || (organ.organ_flags & ORGAN_VITAL))
			continue
		organ.organ_flags |= ORGAN_FROZEN
		organ.Remove(H, special=TRUE)
		organ.forceMove(src)
		unattached_flesh += organ

	flesh_number = unattached_flesh.len

/obj/machinery/clonepod/prefilled

/obj/machinery/clonepod/prefilled/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/medicine/synthflesh, 100)

//Experimental cloner; clones a body regardless of the owner's status.
/obj/machinery/clonepod/experimental
	name = "experimental cloning pod"
	desc = "An ancient cloning pod. It seems to be an early prototype of the experimental cloners used in Nanotrasen Stations."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	req_access = null
	circuit = /obj/item/circuitboard/machine/clonepod/experimental
	internal_radio = FALSE
	experimental_pod = TRUE

/*
 *	Manual -- A big ol' manual.
 */

/obj/item/paper/guides/jobs/medical/cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	default_raw_text = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR IMPLANT into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}

#undef CLONE_INITIAL_DAMAGE
#undef SPEAK
#undef MINIMUM_HEAL_LEVEL
