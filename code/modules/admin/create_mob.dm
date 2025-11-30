
/datum/admins/proc/create_mob(mob/user)
	var/static/create_mob_html
	if (!create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		create_mob_html = rustg_file_read('html/create_object.html')
		create_mob_html = replacetext(create_mob_html, "Create Object", "Create Mob")
		create_mob_html = replacetext(create_mob_html, "null /* object types */", "\"[mobjs]\"")

	user << browse(create_panel_helper(create_mob_html), "window=create_mob;size=425x475")

/**
 * Randomizes everything about a human, including DNA and name
 */
/proc/randomize_human(mob/living/carbon/human/human, randomize_mutations = FALSE, unique = FALSE)
	human.gender = human.dna.species.sexes ? pick(MALE, FEMALE, PLURAL, NEUTER) : PLURAL
	human.real_name = human.dna?.species.random_name(human.gender) || random_unique_name(human.gender)
	human.name = human.get_visible_name()
	human.underwear = random_underwear(human.gender)
	human.socks = random_socks(human.gender)
	human.undershirt = random_undershirt(human.undershirt)
	human.underwear_color = random_short_color()
	human.skin_tone = random_skin_tone()
	human.eye_color = random_eye_color()
	human.dna.blood_type = random_blood_type()
	// Things that we should be more careful about to make realistic characters
	human.hair_style = random_hairstyle(human.gender)
	human.facial_hair_style = random_facial_hairstyle(human.gender)
	// Randomized humans get more unique hair styles than the preference editor
	// since they are usually important characters, and as we know from anime
	// important characters always have colourful hair
	if (unique)
		human.hair_color = random_short_color()
		human.facial_hair_color = human.hair_color
		var/list/rgb_list = ReadRGB(human.hair_color)
		var/list/hsl = rgb2hsl(rgb_list[1], rgb_list[2], rgb_list[3])
		hsl[1] = CLAMP01(hsl[1] + (rand(-6, 6)/360))
		hsl[2] = CLAMP01(hsl[2] + (rand(-4, 4)/100))
		hsl[3] = CLAMP01(hsl[3] + (rand(-2, 2)/100))
		rgb_list = hsl2rgb(hsl[1], hsl[2], hsl[3])
		human.gradient_color = copytext(rgb(rgb_list[1], rgb_list[2], rgb_list[3]), 2)
	else
		// Copy the behaviour of the preferences selection
		// Hair colour
		switch (human.gender)
			if (MALE)
				human.hair_color = pick(GLOB.natural_hair_colours)
			else
				if (prob(10))
					human.hair_color = pick(GLOB.female_dyed_hair_colours)
				else
					human.hair_color = pick(GLOB.natural_hair_colours)
		// Gradient colour
		if (prob(40))
			human.gradient_color = human.hair_color
		else
			switch (human.gender)
				if (MALE)
					human.gradient_color = pick(GLOB.secondary_dye_hair_colours)
				else
					human.gradient_color = pick(GLOB.secondary_dye_hair_colours + GLOB.secondary_dye_female_hair_colours)
		// Facial hair colour
		human.facial_hair_color = human.hair_color
	var/datum/sprite_accessory/gradient_style = pick_default_accessory(SSaccessories.hair_gradients_list, required_gender = human.gender)
	human.gradient_style = gradient_style.name

	// Needs to be called towards the end to update all the UIs just set above
	human.dna.initialize_dna(newblood_type = random_blood_type(), create_mutation_blocks = randomize_mutations, randomize_features = TRUE)

	human.dna.species.spec_updatehealth(human)
	human.updateappearance(mutcolor_update = TRUE)

