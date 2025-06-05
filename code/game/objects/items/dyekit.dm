/obj/item/dyespray
	name = "hair dye spray"
	desc = "A spray to dye your hair any gradients you'd like."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/dyespray.dmi'
	icon_state = "dyespray"

/obj/item/dyespray/attack_self(mob/user)
	dye(user, user)

/obj/item/dyespray/pre_attack(atom/target, mob/living/user, params)
	dye(target, user)
	return ..()

/**
 * Applies a gradient and a gradient color to a mob.
 *
 * Arguments:
 * * target - The mob who we will apply the gradient and gradient color to.
 */

/obj/item/dyespray/proc/dye(mob/target, mob/user)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	var/beard_or_hair = input(user, "What do you want to dye?", "Character Preference")  as null|anything in list("Hair", "Facial Hair")
	if(!beard_or_hair || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE))
		return

	var/list/choices = beard_or_hair == "Hair" ? GLOB.hair_gradients_list : GLOB.facial_hair_gradients_list
	var/new_gradient_style = input(user, "Choose a color pattern:", "Character Preference")  as null|anything in choices
	if(!new_gradient_style || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE))
		return

	var/new_gradient_color = input(user, "Choose a secondary hair color:", "Character Preference",human_target.gradient_color) as color|null
	if(!new_gradient_color || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE) || !user.CanReach(target))
		return

	to_chat(user, span_notice("You start applying the hair dye..."))
	if(!do_after(user, 3 SECONDS, target))
		return
	var/gradient_key = beard_or_hair == "Hair" ? GRADIENT_HAIR_KEY : GRADIENT_FACIAL_HAIR_KEY
	LAZYSETLEN(human_target.gradient_style, GRADIENTS_LEN)
	LAZYSETLEN(human_target.gradient_color, GRADIENTS_LEN)
	human_target.gradient_style[gradient_key] = new_gradient_style
	human_target.gradient_color[gradient_key] = sanitize_hexcolor(new_gradient_color)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	human_target.update_hair()
