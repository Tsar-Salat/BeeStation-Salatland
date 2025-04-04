/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery."
	icon_state = "plumberer2"
	worn_icon_state = "plumbing"
	icon = 'icons/obj/tools.dmi'
	slot_flags = ITEM_SLOT_BELT
	///it does not make sense why any of these should be installed.
	banned_upgrades = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS  | RCD_UPGRADE_FURNISHING
	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/blueprint = null
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/choices = list()
	///index, used in the attack self to get the type. stored here since it doesnt change
	///This list that holds all the plumbing design types the plumberer can construct. Its purpose is to make it easy to make new plumberer subtypes with a different selection of machines.
	var/list/static/plumbing_design_types

	var/list/name_to_type = list()
	///
	var/list/machinery_data = list("cost" = list(), "delay" = list())


/obj/item/construction/plumbing/Initialize(mapload)
	. = ..()
	set_plumbing_designs()

///Set the list of designs this plumbing rcd can make
/obj/item/construction/plumbing/proc/set_plumbing_designs()
	plumbing_design_types = list(
	/obj/machinery/plumbing/input = 5,
	/obj/machinery/plumbing/output = 5,
	/obj/machinery/plumbing/tank = 20,
	/obj/machinery/plumbing/synthesizer = 15,
	/obj/machinery/plumbing/reaction_chamber = 15,
	//Above are the most common machinery which is shown on the first cycle. Keep new additions below THIS line, unless they're probably gonna be needed alot
	/obj/machinery/plumbing/acclimator = 10,
	/obj/machinery/plumbing/disposer = 10,
	/obj/machinery/plumbing/filter = 5,
	/obj/machinery/plumbing/grinder_chemical = 30,
	/obj/machinery/plumbing/splitter = 5,
	/obj/machinery/plumbing/bottle_dispenser = 20,
)

/obj/item/construction/plumbing/attack_self(mob/user)
	..()
	if(!choices.len)
		for(var/A in plumbing_design_types)
			var/obj/machinery/plumbing/M = A
			if(initial(M.rcd_constructable))
				choices += list(initial(M.name) = image(icon = initial(M.icon), icon_state = initial(M.icon_state)))
				name_to_type[initial(M.name)] = M
				machinery_data["cost"][A] = initial(M.rcd_cost)
				machinery_data["delay"][A] = initial(M.rcd_delay)

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return

	blueprint = name_to_type[choice]
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	to_chat(user, span_notice("You change [name]s blueprint to '[choice]'."))

///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(atom/A, mob/user)
	if(!machinery_data || !isopenturf(A))
		return FALSE

	if(checkResource(machinery_data["cost"][blueprint], user) && blueprint)
		if(do_after(user, machinery_data["delay"][blueprint], target = A))
			if(checkResource(machinery_data["cost"][blueprint], user) && canPlace(A))
				useResource(machinery_data["cost"][blueprint], user)
				activate()
				playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
				new blueprint (A, FALSE, FALSE)
				return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/T)
	if(!isopenturf(T))
		return FALSE
	. = TRUE
	for(var/obj/O in T.contents)
		if(O.density) //let's not built ontop of dense stuff, like big machines and other obstacles, it kills my immershion
			return FALSE

/obj/item/construction/plumbing/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(A, /obj/machinery/plumbing))
		var/obj/machinery/plumbing/P = A
		if(P.anchored)
			to_chat(user, span_warning("The [P.name] needs to be unanchored!"))
			return
		if(do_after(user, 20, target = P))
			P.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
	else
		create_machine(A, user)
