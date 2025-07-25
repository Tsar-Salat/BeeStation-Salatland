//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "Mirror mirror on the wall, who's the most robust of them all?"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	max_integrity = 200
	integrity_failure = 0.5
	flags_ricochet = RICOCHET_SHINY
	layer = ABOVE_WINDOW_LAYER
	var/magical = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/mirror, 28)

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/mirror)

/obj/structure/mirror/Initialize(mapload, dir, building)
	. = ..()
	if(icon_state == "mirror_broke" && !broken)
		atom_break(null, mapload)

/obj/structure/mirror/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(broken || !Adjacent(user))
		return

	if(ishuman(user) && !magical)
		var/mob/living/carbon/human/H = user

		//see code/modules/mob/dead/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.
		var/options = list("Hair", "Facial")
		var/choice = tgui_input_list(user, "Style your Hair or Facial Hair?", "Grooming", options, null)
		switch(choice)
			if("Hair")
				//handle normal hair
				var/new_style = tgui_input_list(user, "Select a hair style", "Grooming", GLOB.hair_styles_list, H.hair_style)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return	//no tele-grooming
				if(new_style)
					H.hair_style = new_style
			if("Facial")
				//handle facial hair
				var/new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", GLOB.facial_hair_styles_list, H.facial_hair_style)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return	//no tele-grooming
				if(new_style)
					H.facial_hair_style = new_style
		H.update_hair()

/obj/structure/mirror/examine_status(mob/user)
	if(broken)
		return list()// no message spam
	return ..()

/obj/structure/mirror/atom_break(damage_flag, mapload)
	. = ..()
	if(broken || (flags_1 & NODECONSTRUCT_1))
		return
	icon_state = "mirror_broke"
	if(!mapload)
		playsound(src, "shatter", 70, 1)
	if(desc == initial(desc))
		desc = "Oh no, seven years of bad luck!"
	broken = TRUE

/obj/structure/mirror/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			new /obj/item/shard( src.loc )
	qdel(src)

/obj/structure/mirror/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE

	if(!broken)
		return TRUE

	if(!I.tool_start_check(user, amount=0))
		return TRUE

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(I.use_tool(src, user, 10, volume=50))
		to_chat(user, span_notice("You repair [src]."))
		broken = 0
		icon_state = initial(icon_state)
		desc = initial(desc)

	return TRUE

/obj/structure/mirror/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		if(BURN)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)

/obj/structure/mirror/magic
	name = "magic mirror"
	desc = "Turn and face the strange... face."
	icon_state = "magic_mirror"
	var/list/choosable_races = list()
	magical = TRUE

/obj/structure/mirror/magic/Initialize(mapload)
	. = ..()
	if(!choosable_races.len)
		for(var/speciestype in subtypesof(/datum/species))
			var/datum/species/S = speciestype
			if(initial(S.changesource_flags) & MIRROR_MAGIC)
				choosable_races += initial(S.id)
		choosable_races = sort_list(choosable_races)

/obj/structure/mirror/magic/lesser/Initialize(mapload)
	var/list/selectable = get_selectable_species()
	choosable_races = selectable.Copy()
	return ..()

/obj/structure/mirror/magic/badmin/Initialize(mapload)
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_BADMIN)
			choosable_races += initial(S.id)
	return ..()

/obj/structure/mirror/magic/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/choice = input(user, "Something to change?", "Magical Grooming") as null|anything in list("name", "race", "gender", "hair", "eyes")

	if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	switch(choice)
		if("name")
			var/newname = sanitize_name(reject_bad_text(stripped_input(H, "Who are we again?", "Name change", H.name, MAX_NAME_LEN)))

			if(!newname)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.real_name = newname
			H.name = newname
			if(H.dna)
				H.dna.real_name = newname
			if(H.mind)
				H.mind.name = newname

		if("race")
			var/newrace
			var/racechoice = input(H, "What are we again?", "Race change") as null|anything in choosable_races
			newrace = GLOB.species_list[racechoice]

			if(!newrace)
				return
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			H.set_species(newrace, icon_update=0)

			if(H.dna.species.use_skintones)
				var/new_s_tone = input(user, "Choose your skin tone:", "Race change")  as null|anything in GLOB.skin_tones
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return

				if(new_s_tone)
					H.skin_tone = new_s_tone
					H.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)

			if(MUTCOLORS in H.dna.species.species_traits)
				var/new_mutantcolor = tgui_color_picker(user, "Choose your skin color:", "Race change","#"+H.dna.features["mcolor"])
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_mutantcolor)
					var/temp_hsv = RGBtoHSV(new_mutantcolor)

					if(ReadHSV(temp_hsv)[3] >= ReadHSV("#7F7F7F")[3]) // mutantcolors must be bright
						H.dna.features["mcolor"] = sanitize_hexcolor(new_mutantcolor)
						H.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)

					else
						to_chat(H, span_notice("Invalid color. Your color is not bright enough."))

			H.update_body()
			H.update_hair()
			H.update_body_parts(TRUE)
			H.update_mutations_overlay() // no hulk lizard

		if("gender")
			if(!(H.gender in list("male", "female"))) //blame the patriarchy
				return
			if(H.gender == "male")
				if(alert(H, "Become a Witch?", "Confirmation", "Yes", "No") == "Yes")
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					H.gender = "female"
					to_chat(H, span_notice("Man, you feel like a woman!"))
				else
					return

			else
				if(alert(H, "Become a Warlock?", "Confirmation", "Yes", "No") == "Yes")
					if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
						return
					H.gender = "male"
					to_chat(H, span_notice("Whoa man, you feel like a man!"))
				else
					return
			H.dna.update_ui_block(DNA_GENDER_BLOCK)
			H.update_body()
			H.update_mutations_overlay() //(hulk male/female)

		if("hair")
			var/hairchoice = alert(H, "Hair style or hair color?", "Change Hair", "Style", "Color")
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(hairchoice == "Style") //So you just want to use a mirror then?
				var/new_style = tgui_input_list(user, "Select a hair style", "Hair Style", GLOB.hair_styles_list, H.hair_style)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_style)
					H.hair_style = new_style
			else
				var/new_hair_color = tgui_color_picker(H, "Choose your hair color", "Hair Color","#"+H.hair_color)
				if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
					return
				if(new_hair_color)
					H.hair_color = sanitize_hexcolor(new_hair_color)
					H.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
				if(H.gender == "male")
					var/new_face_color = tgui_color_picker(H, "Choose your facial hair color", "Hair Color","#"+H.facial_hair_color)
					if(new_face_color)
						H.facial_hair_color = sanitize_hexcolor(new_face_color)
						H.dna.update_ui_block(DNA_FACIAL_HAIR_COLOR_BLOCK)
			H.update_hair()

		if(BODY_ZONE_PRECISE_EYES)
			var/new_eye_color = tgui_color_picker(H, "Choose your eye color", "Eye Color","#"+H.eye_color)
			if(!user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
				return
			if(new_eye_color)
				H.eye_color = sanitize_hexcolor(new_eye_color)
				H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
				H.update_body()
	if(choice)
		curse(user)

/obj/structure/mirror/magic/proc/curse(mob/living/user)
	return


//basically stolen from human_defense.dm
/obj/structure/mirror/bullet_act(obj/projectile/P)
	if(P.reflectable & REFLECT_NORMAL)
		if(P.starting)
			var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
			var/turf/current_location = get_turf(src)

			// redirect the projectile
			P.original = locate(new_x, new_y, P.z)
			P.starting = current_location
			P.firer = src
			P.yo = new_y - current_location.y
			P.xo = new_x - current_location.x
			var/new_angle_s = P.Angle + 180
			while(new_angle_s > 180)	// Translate to regular projectile degrees
				new_angle_s -= 360
			P.set_angle(new_angle_s)

	return BULLET_ACT_FORCE_PIERCE // complete projectile permutation

/obj/item/wallframe/mirror
	name = "wall mirror frame"
	desc = "Now with 100% less lead!"
	icon_state = "wallmirror"
	result_path = /obj/structure/mirror
	pixel_shift = -28
