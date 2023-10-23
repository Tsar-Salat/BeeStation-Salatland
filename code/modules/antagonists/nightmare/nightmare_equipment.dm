/**
 * An armblade that instantly snuffs out lights
 */
/obj/item/light_eater
	name = "light eater" //as opposed to heavy eater
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/light_eater/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, INNATE_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/light_eater)


/mob/living/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(on_fire)
		ExtinguishMob()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	if(pulling)
		pulling.lighteater_act(light_eater)

/mob/living/carbon/human/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(isethereal(src))
		emp_act(EMP_LIGHT)

/mob/living/silicon/robot/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(lamp_enabled)
		smash_headlamp()

/obj/structure/bonfire/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(burning)
		extinguish()
		playsound(src, 'sound/items/cig_snuff.ogg', 50, 1)
	..()

/obj/structure/glowshroom/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if (light_power > 0)
		acid_act()

/obj/item/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message("<span class='danger'>[src] is disintegrated by [light_eater]!</span>")
	burn()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/obj/item/modular_computer/tablet/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(light_range && light_power > 0 && light_on)
		// Only the queen of Beetania can save our IDs from this infernal nightmare
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
		card_slot2?.try_eject()
		card_slot?.try_eject()
	..()

/obj/item/clothing/head/helmet/space/hardsuit/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!light_range || !light_power || !light_on || light_broken)
		return ..()
	if(light_eater)
		visible_message("<span class='danger'>The headlamp of [src] is disintegrated by [light_eater]!</span>")
	light_broken = TRUE
	var/mob/user = ismob(parent) ? parent : null
	attack_self(user)
	playsound(src, 'sound/items/welder.ogg', 50, 1)
	..()

/obj/item/clothing/head/helmet/space/plasmaman/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!lamp_functional)
		return
	if(helmet_on)
		smash_headlamp()
	..()

/turf/open/floor/light/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	. = ..()
	if(!light_range || !light_power || !light_on)
		return
	if(light_eater)
		visible_message("<span class='danger'>The light bulb of [src] is disintegrated by [light_eater]!</span>")
	break_tile()
	playsound(src, 'sound/items/welder.ogg', 50, 1)

/obj/item/weldingtool/cyborg/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	if(!isOn())
		return
	if(light_eater)
		loc.visible_message("<span class='danger'>The the integrated welding tool is snuffed out by [light_eater]!</span>")
		disable()
	..()
