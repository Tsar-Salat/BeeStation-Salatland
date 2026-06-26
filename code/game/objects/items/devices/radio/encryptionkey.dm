/obj/item/encryptionkey
	name = "standard encryption key"
	desc = "An encryption key for a radio headset."
	icon = 'icons/obj/radio.dmi'
	icon_state = "cypherkey"
	w_class = WEIGHT_CLASS_TINY
	/// What channels does this encryption key grant to the parent headset.
	var/list/channels = list()
	/// Flags for which "special" radio networks should be accessible
	var/special_channels = NONE
	/// Assoc list of language to how well understood it is. 0 is invalid, 100 is perfect.
	var/list/language_data

/obj/item/encryptionkey/examine(mob/user)
	. = ..()
	if(!LAZYLEN(channels) && !(special_channels & RADIO_SPECIAL_BINARY) && !LAZYLEN(language_data))
		. += span_warning("Has no special codes in it. You should probably tell a coder!")
		return

	var/list/examine_text_list = list()
	for(var/i in channels)
		examine_text_list += "[GLOB.channel_tokens[i]] - [LOWER_TEXT(i)]"

	if(special_channels & RADIO_SPECIAL_BINARY)
		examine_text_list += "[GLOB.channel_tokens[MODE_BINARY]] - [MODE_BINARY]"

	if(length(examine_text_list))
		. += span_notice("It can access the following channels; [jointext(examine_text_list, ", ")].")

	var/list/language_text_list = list()
	for(var/lang in language_data)
		var/langstring = "[GLOB.language_datum_instances[lang].name]"
		switch(language_data[lang])
			if(25 to 50)
				langstring += " (poor)"
			if(50 to 75)
				langstring += " (average)"
			if(75 to 100)
				langstring += " (good)"
		language_text_list += langstring

	if(length(language_text_list))
		. += span_notice("It can translate the following languages; [jointext(language_text_list, ", ")].")

/obj/item/encryptionkey/syndicate
	name = "syndicate encryption key"
	icon_state = "syn_cypherkey"
	channels = list(RADIO_CHANNEL_SYNDICATE = 1)
	special_channels = RADIO_SPECIAL_SYNDIE

/obj/item/encryptionkey/binary
	name = "binary translator key"
	desc = "An encryption key that interchanges the form of anaologue brainwave and binary electric signals."
	icon_state = "bin_cypherkey"
	special_channels = RADIO_SPECIAL_BINARY
	language_data = list(
		/datum/language/machine = 100,
	)

/obj/item/encryptionkey/amplification
	name = "amplification module key"
	desc = "An amplification module key for a radio headset. It will enable the \"Loud mode\" ability on any headset it is inserted into."
	special_channels = RADIO_SPECIAL_AMPLIFIER

/obj/item/encryptionkey/headset_sec
	name = "security radio encryption key"
	icon_state = "sec_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_eng
	name = "engineering radio encryption key"
	icon_state = "eng_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_rob
	name = "robotics radio encryption key"
	icon_state = "rob_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_ENGINEERING = 1)

/obj/item/encryptionkey/headset_med
	name = "medical radio encryption key"
	icon_state = "med_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1)

/obj/item/encryptionkey/headset_sci
	name = "science radio encryption key"
	icon_state = "sci_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_srvsec
	name = "law and order radio encryption key"
	icon_state = "srvsec_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_medsec
	name = "medical-security encryption key"
	icon_state = "medsec_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/encryptionkey/headset_com
	name = "command radio encryption key"
	icon_state = "com_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/captain
	name = "\proper the captain's encryption key"
	icon_state = "cap_cypherkey"
	channels = list(RADIO_CHANNEL_COMMAND = 1, RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_ENGINEERING = 0, RADIO_CHANNEL_SCIENCE = 0, RADIO_CHANNEL_MEDICAL = 0, RADIO_CHANNEL_SUPPLY = 0, RADIO_CHANNEL_SERVICE = 0, RADIO_CHANNEL_EXPLORATION = 0)

/obj/item/encryptionkey/heads/captain/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/rd
	name = "\proper the research director's encryption key"
	icon_state = "rd_cypherkey"
	channels = list(RADIO_CHANNEL_SCIENCE = 1, RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/rd/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/hos
	name = "\proper the head of security's encryption key"
	icon_state = "hos_cypherkey"
	channels = list(RADIO_CHANNEL_SECURITY = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hos/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/ce
	name = "\proper the chief engineer's encryption key"
	icon_state = "ce_cypherkey"
	channels = list(RADIO_CHANNEL_ENGINEERING = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/ce/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/cmo
	name = "\proper the chief medical officer's encryption key"
	icon_state = "cmo_cypherkey"
	channels = list(RADIO_CHANNEL_MEDICAL = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/cmo/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/heads/hop
	name = "\proper the head of personnel's encryption key"
	icon_state = "hop_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_COMMAND = 1)

/obj/item/encryptionkey/heads/hop/fake
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_cargo
	name = "supply radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1)

/obj/item/encryptionkey/headset_mining
	name = "mining radio encryption key"
	icon_state = "cargo_cypherkey"
	channels = list(RADIO_CHANNEL_SUPPLY = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_exp
	name = "exploration encryption key"
	icon_state = "exp_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_expteam
	name = "exploration team encryption key"
	icon_state = "expteam_cypherkey"
	channels = list(RADIO_CHANNEL_EXPLORATION = 1, RADIO_CHANNEL_SCIENCE = 1)

/obj/item/encryptionkey/headset_service
	name = "service radio encryption key"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1)

/obj/item/encryptionkey/headset_curator
	name = "curator radio encryption key"
	icon_state = "srv_cypherkey"
	channels = list(RADIO_CHANNEL_SERVICE = 1, RADIO_CHANNEL_EXPLORATION = 1)

/obj/item/encryptionkey/headset_cent
	name = "\improper CentCom radio encryption key"
	icon_state = "cent_cypherkey"
	special_channels = RADIO_SPECIAL_CENTCOM
	channels = list(RADIO_CHANNEL_CENTCOM = 1)

/obj/item/encryptionkey/debug
	name = "\improper omni radio encryption key"
	desc = "A god-like key of omni-presence to eavesdrop anything you would want to hear."
	icon_state = "cent_cypherkey"
	special_channels = RADIO_SPECIAL_SYNDIE|RADIO_SPECIAL_CENTCOM|RADIO_SPECIAL_BINARY|RADIO_SPECIAL_AMPLIFIER

/obj/item/encryptionkey/debug/Initialize(mapload)
	. = ..()
	for(var/each in GLOB.radiochannels)
		channels |= list("[each]" = 1)

/obj/item/encryptionkey/ai //ported from NT, this goes 'inside' the AI.
	channels = list(
		RADIO_CHANNEL_COMMAND = 1,
		RADIO_CHANNEL_SECURITY = 1,
		RADIO_CHANNEL_ENGINEERING = 1,
		RADIO_CHANNEL_SCIENCE = 1,
		RADIO_CHANNEL_MEDICAL = 1,
		RADIO_CHANNEL_SUPPLY = 1,
		RADIO_CHANNEL_SERVICE = 1,
		RADIO_CHANNEL_EXPLORATION = 1,
		RADIO_CHANNEL_AI_PRIVATE = 1
	)

/obj/item/encryptionkey/secbot
	channels = list(RADIO_CHANNEL_AI_PRIVATE = 1, RADIO_CHANNEL_SECURITY = 1)

/obj/item/storage/box/command_keys // heads toys
	name = "box of amplification keys"

/obj/item/storage/box/command_keys/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/encryptionkey/amplification(src)
