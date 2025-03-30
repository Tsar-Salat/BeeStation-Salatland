

/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "sticky"
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	merge_type = /obj/item/stack/sticky_tape

	var/conferred_embed = /datum/embed_data/sticky_tape
	var/overwrite_existing = FALSE

/datum/embed_data/sticky_tape
	pain_mult = 0
	jostle_pain_mult = 0
	ignore_throwspeed_threshold = 0

/obj/item/stack/sticky_tape/afterattack(obj/item/target, mob/living/user)
	if(!istype(target))
		return

	if(target.get_embed()?.type == conferred_embed)
		to_chat(user, span_warning("[target] is already coated in [src]!"))
		return

	user.visible_message(span_notice("[user] begins wrapping [target] with [src]."), span_notice("You begin wrapping [target] with [src]."))

	if(do_after(user, 30, target=target))
		use(1)
		if(istype(target, /obj/item/clothing/gloves/fingerless))
			var/obj/item/clothing/gloves/tackler/offbrand/O = new /obj/item/clothing/gloves/tackler/offbrand
			to_chat(user, span_notice("You turn [target] into [O] with [src]."))
			use(1)
			QDEL_NULL(target)
			user.put_in_hands(O)
			return

		if(target.get_embed() && target.get_embed().type == conferred_embed)
			to_chat(user, span_warning("[target] is already coated in [src]!"))
			return

		target.set_embed(conferred_embed)
		to_chat(user, span_notice("You finish wrapping [target] with [src]."))
		use(1)
		target.name = "[prefix] [target.name]"

		if(istype(target, /obj/item/grenade))
			var/obj/item/grenade/sticky_bomb = target
			sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	icon_state = "tape_y"
	prefix = "super sticky"
	conferred_embed = /datum/embed_data/sticky_tape/super
	merge_type = /obj/item/stack/sticky_tape

/datum/embed_data/sticky_tape/super
	embed_chance = 100
	fall_chance = 0.1

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	conferred_embed = /datum/embed_data/pointy_tape
	merge_type = /obj/item/stack/sticky_tape/pointy

/datum/embed_data/pointy_tape
	ignore_throwspeed_threshold = TRUE

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	icon_state = "tape_spikes"
	prefix = "super pointy"
	conferred_embed = /datum/embed_data/pointy_tape/super
	merge_type = /obj/item/stack/sticky_tape/pointy/super

/datum/embed_data/pointy_tape/super
	embed_chance = 100
