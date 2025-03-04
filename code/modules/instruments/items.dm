//copy pasta of the space piano, don't hurt me -Pete
/obj/item/instrument
	name = "generic instrument"
	resistance_flags = FLAMMABLE
	force = 10
	max_integrity = 100
	icon = 'icons/obj/musician.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/instruments_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/instruments_righthand.dmi'
	/// Our song datum.
	var/datum/song/handheld/song
	/// Our allowed list of instrument ids. This is nulled on initialize.
	var/list/allowed_instrument_ids
	/// How far away our song datum can be heard.
	var/instrument_range = 15
	item_flags = ISWEAPON

/obj/item/instrument/Initialize(mapload)
	. = ..()
	song = new(src, allowed_instrument_ids, instrument_range)
	allowed_instrument_ids = null			//We don't need this clogging memory after it's used.

/obj/item/instrument/Destroy()
	QDEL_NULL(song)
	return ..()

/obj/item/instrument/proc/should_stop_playing(mob/user)
	return user.incapacitated() || !((loc == user) || (isturf(loc) && Adjacent(user)))		// sorry, no more TK playing.

/obj/item/instrument/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins to play 'Gloomy Sunday'! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/instrument/attack_self(mob/user)
	interact(user)

/obj/item/instrument/ui_interact(mob/living/user)
	if((!isliving(user) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) && !ispAI(user))
		return

	user.set_machine(src)
	song.ui_interact(user)

/obj/item/instrument/violin
	name = "space violin"
	desc = "A wooden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "violin"
	item_state = "violin"
	hitsound = "swing_hit"
	allowed_instrument_ids = "violin"

/obj/item/instrument/violin/golden
	name = "golden violin"
	desc = "A golden musical instrument with four strings and a bow. \"The devil went down to space, he was looking for an assistant to grief.\""
	icon_state = "golden_violin"
	item_state = "golden_violin"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/instrument/piano_synth
	name = "synthesizer"
	desc = "An advanced electronic synthesizer that can be used as various instruments."
	icon_state = "synth"
	item_state = "synth"
	allowed_instrument_ids = "piano"

/obj/item/instrument/piano_synth/Initialize(mapload)
	. = ..()
	song.allowed_instrument_ids = SSinstruments.synthesizer_instrument_ids

/obj/item/instrument/banjo
	name = "banjo"
	desc = "A 'Mura' brand banjo. It's pretty much just a drum with a neck and strings."
	icon_state = "banjo"
	item_state = "banjo"
	attack_verb_continuous = list("scruggs-styles", "hum-diggitys", "shin-digs", "clawhammers")
	attack_verb_simple = list("scruggs-style", "hum-diggity", "shin-dig", "clawhammer")
	hitsound = 'sound/weapons/banjoslap.ogg'
	allowed_instrument_ids = "banjo"

/obj/item/instrument/guitar
	name = "guitar"
	desc = "It's made of wood and has bronze strings."
	icon_state = "guitar"
	item_state = "guitar"
	attack_verb_continuous = list("plays metal on", "serenades", "crashes", "smashes")
	attack_verb_simple = list("play metal on", "serenade", "crash", "smash")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = list("guitar","csteelgt","cnylongt", "ccleangt", "cmutedgt")

/obj/item/instrument/eguitar
	name = "electric guitar"
	desc = "Makes all your shredding needs possible."
	icon_state = "eguitar"
	item_state = "eguitar"
	force = 12
	attack_verb_continuous = list("plays metal on", "shreds", "crashes", "smashes")
	attack_verb_simple = list("play metal on", "shred", "crash", "smash")
	hitsound = 'sound/weapons/stringsmash.ogg'
	allowed_instrument_ids = "eguitar"

/obj/item/instrument/glockenspiel
	name = "glockenspiel"
	desc = "Smooth metal bars perfect for any marching band."
	icon_state = "glockenspiel"
	item_state = "glockenspiel"
	allowed_instrument_ids = list("glockenspiel","crvibr", "sgmmbox", "r3celeste")

/obj/item/instrument/accordion
	name = "accordion"
	desc = "Pun-Pun not included."
	icon_state = "accordion"
	item_state = "accordion"
	allowed_instrument_ids = list("crack", "crtango", "accordion")

/obj/item/instrument/trumpet
	name = "trumpet"
	desc = "To announce the arrival of the king!"
	icon_state = "trumpet"
	item_state = "trombone"
	allowed_instrument_ids = "crtrumpet"

/obj/item/instrument/trumpet/spectral
	name = "spectral trumpet"
	desc = "Things are about to get spooky!"
	icon_state = "trumpet"
	item_state = "trombone"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "trumpets", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "trumpet", "mourn", "doot", "spook")

/obj/item/instrument/trumpet/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trumpet/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/En4.mid', 100,1,-1)
	..()

/obj/item/instrument/saxophone
	name = "saxophone"
	desc = "This soothing sound will be sure to leave your audience in tears."
	icon_state = "saxophone"
	item_state = "saxophone"
	allowed_instrument_ids = "saxophone"

/obj/item/instrument/saxophone/spectral
	name = "spectral saxophone"
	desc = "This spooky sound will be sure to leave mortals in bones."
	icon_state = "saxophone"
	item_state = "saxophone"
	allowed_instrument_ids = "saxophone"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "saxxes", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "sax", "mourn", "doot", "spook")

/obj/item/instrument/saxophone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/saxophone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/saxophone/En4.mid', 100,1,-1)
	..()

/obj/item/instrument/trombone
	name = "trombone"
	desc = "How can any pool table ever hope to compete?"
	icon_state = "trombone"
	item_state = "trombone"
	allowed_instrument_ids = list("crtrombone", "crbrass", "trombone")

/obj/item/instrument/trombone/spectral
	name = "spectral trombone"
	desc = "A skeleton's favorite instrument. Apply directly on the mortals."
	icon_state = "trombone"
	item_state = "trombone"
	force = 0
	attack_verb_continuous = list("plays", "jazzes", "trombones", "mourns", "doots", "spooks")
	attack_verb_simple = list("play", "jazz", "trombone", "mourn", "doot", "spook")

/obj/item/instrument/trombone/spectral/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spooky)

/obj/item/instrument/trombone/spectral/attack(mob/living/carbon/C, mob/user)
	playsound (loc, 'sound/instruments/trombone/Cn4.mid', 100,1,-1)
	..()

/obj/item/instrument/recorder
	name = "recorder"
	desc = "Just like in school, playing ability and all."
	force = 5
	icon_state = "recorder"
	item_state = "recorder"
	allowed_instrument_ids = "recorder"

/obj/item/instrument/harmonica
	name = "harmonica"
	desc = "For when you get a bad case of the space blues."
	icon_state = "harmonica"
	item_state = "harmonica"
	allowed_instrument_ids = list("harmonica", "crharmony")
	slot_flags = ITEM_SLOT_MASK
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/instrument)

/obj/item/instrument/harmonica/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(song.playing && ismob(loc))
		to_chat(loc, span_warning("You stop playing the harmonica to talk..."))
		song.playing = FALSE

/obj/item/instrument/harmonica/equipped(mob/M, slot)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/obj/item/instrument/harmonica/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/datum/action/item_action/instrument
	name = "Use Instrument"
	desc = "Use the instrument specified"

/datum/action/item_action/instrument/on_activate(mob/user, atom/target)
	if(istype(target, /obj/item/instrument))
		var/obj/item/instrument/I = target
		I.interact(usr)
		return
	return ..()

/obj/item/instrument/bikehorn
	name = "gilded bike horn"
	desc = "An exquisitely decorated bike horn, capable of honking in a variety of notes."
	icon_state = "bike_horn"
	item_state = "bike_horn"
	lefthand_file = 'icons/mob/inhands/equipment/horns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/horns_righthand.dmi'
	attack_verb_continuous = list("beautifully honks")
	attack_verb_simple = list("beautifully honk")
	allowed_instrument_ids = list("bikehorn", "honk")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	throw_speed = 3
	throw_range = 15
	hitsound = 'sound/items/bikehorn.ogg'

///

/obj/item/choice_beacon/radial/music
	name = "instrument delivery beacon"
	desc = "Summon your tool of art."
	icon_state = "gangtool-music"
	var/static/list/instrument_list

/obj/item/choice_beacon/radial/music/Initialize(mapload)
	. = ..()
	instrument_list = list(/obj/item/instrument/violin,
							/obj/item/instrument/piano_synth,
							/obj/item/instrument/banjo,
							/obj/item/instrument/guitar,
							/obj/item/instrument/eguitar,
							/obj/item/instrument/glockenspiel,
							/obj/item/instrument/accordion,
							/obj/item/instrument/trumpet,
							/obj/item/instrument/saxophone,
							/obj/item/instrument/trombone,
							/obj/item/instrument/recorder,
							/obj/item/instrument/harmonica
							)

/obj/item/choice_beacon/radial/music/generate_options(mob/living/M)
	var/list/item_list = generate_item_list()
	if(!item_list.len)
		return
	var/choice = show_radial_menu(M, src, item_list, radius = 36, require_near = TRUE)
	if(!QDELETED(src) && !(isnull(choice)) && !M.incapacitated() && in_range(M,src))
		for(var/V in instrument_list)
			var/atom/A = V
			if(initial(A.name) == choice)
				spawn_option(A,M)
				uses--
				if(!uses)
					qdel(src)
				else
					balloon_alert(M, "[uses] use[uses > 1 ? "s" : ""] remaining")
					to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))
				return

/obj/item/choice_beacon/radial/music/generate_item_list()
	var/static/list/item_list
	if(!item_list)
		item_list = list()
		for(var/V in instrument_list)
			var/obj/item/instrument/I = V
			var/image/instrument_icon = image(initial(I.icon), initial(I.icon_state))
			var/datum/radial_menu_choice/choice = new
			choice.image = instrument_icon
			item_list[initial(I.name)] = choice
	return item_list

/obj/item/instrument/musicalmoth
	name = "musical moth"
	desc = "Despite its popularity, this controversial musical toy was eventually banned due to its unethically sampled sounds of moths screaming in agony."
	icon_state = "mothsician"
	allowed_instrument_ids = "mothscream"
	attack_verb_continuous = list("flutters", "flaps")
	attack_verb_simple = list("flutter", "flap")
	w_class = WEIGHT_CLASS_TINY
	force = 0
	hitsound = 'sound/voice/moth/scream_moth.ogg'
	custom_price = 237
	custom_premium_price = 237
