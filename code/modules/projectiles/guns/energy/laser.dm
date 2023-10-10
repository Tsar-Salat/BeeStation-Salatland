/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/iron=2000)
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	item_flags = NONE

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/retro/old
	name ="laser gun"
	icon_state = "retro"
	desc = "First generation lasergun, developed by Nanotrasen. Suffers from ammo issues but its unique ability to recharge its ammo without the need of a magazine helps compensate. You really hope someone has developed a better lasergun while you were in cryo."
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/old)
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13 with the words NTSSGolden engraved. The station is exploding."
	force = 10
	ammo_x_offset = 3
	selfcharge = 1
	charge_delay = 8
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun/captain)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	weapon_weight = WEAPON_LIGHT
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lens to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theoretically infinite use."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/cyborg
	can_charge = FALSE
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	use_cyborg_cell = TRUE

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/laser/scatter/shotty
	name = "energy shotgun"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "cshotgun"
	item_state = "shotgun"
	desc = "A combat shotgun gutted and refitted with an internal laser system. Can switch between taser and scattered disabler shots."
	shaded_charge = 0
	pin = /obj/item/firing_pin/implant/mindshield
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter/disabler, /obj/item/ammo_casing/energy/electrode)

///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	pin = null
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "scatterlaser"
	range = 255
	damage = 6

/obj/projectile/beam/laser/accelerator/Range()
	..()
	damage += 7
	transform *= 1 + ((damage/7) * 0.2)//20% larger per tile

/obj/item/gun/energy/xray
	name = "\improper X-ray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated X-ray blasts that pass through multiple soft targets and heavier materials."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/xray)
	pin = null
	ammo_x_offset = 3
	w_class = WEIGHT_CLASS_BULKY

////////Laser Tag////////////////////

/obj/item/gun/energy/laser/bluetag
	name = "laser tag gun"
	icon_state = "bluetag"
	desc = "A retro laser gun modified to fire harmless blue beams of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/blue
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/bluetag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag/hitscan)

/obj/item/gun/energy/laser/redtag
	name = "laser tag gun"
	icon_state = "redtag"
	desc = "A retro laser gun modified to fire harmless beams red of light. Sound effects included!"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
	item_flags = NONE
	clumsy_check = FALSE
	pin = /obj/item/firing_pin/tag/red
	ammo_x_offset = 2
	selfcharge = TRUE

/obj/item/gun/energy/laser/redtag/hitscan
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag/hitscan)

//The ammo/gun is stored in a back slot item
/obj/item/hitscanpack
	name = "hitscan power source"
	desc = "The massive external power source for God's most unholy creation"
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "holstered"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	var/obj/item/gun/energy/hitscan/gun
	var/armed = 0 //whether the gun is attached, 0 is attached, 1 is the gun is wielded.

/obj/item/hitscanpack/Initialize(mapload)
	. = ..()
	gun = new(src)

/obj/item/hitscanpack/Destroy()
	if(!QDELETED(gun))
		qdel(gun)
	gun = null
	return ..()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/hitscanpack/attack_hand(var/mob/living/carbon/user)
	if(src.loc == user)
		if(!armed)
			if(user.get_item_by_slot(ITEM_SLOT_BACK) == src)
				armed = 1
				if(!user.put_in_hands(gun))
					armed = 0
					to_chat(user, "<span class='warning'>You need a free hand to hold the gun!</span>")
					return
				update_icon()
				user.update_inv_back()
		else
			to_chat(user, "<span class='warning'>You are already holding the gun!</span>")
	else
		..()

/obj/item/hitscanpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/hitscanpack/dropped(mob/user)
	..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/hitscanpack/MouseDrop(atom/over_object)
	. = ..()
	if(armed)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.incapacitated())

			if(istype(over_object, /atom/movable/screen/inventory/hand))
				var/atom/movable/screen/inventory/hand/H = over_object
				M.putItemFromInventoryInHandIfPossible(src, H.held_index)


/obj/item/hitscanpack/update_icon()
	if(armed)
		icon_state = "notholstered"
	else
		icon_state = "holstered"

/obj/item/hitscanpack/proc/attach_gun(var/mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = 0
	if(user)
		to_chat(user, "<span class='notice'>You attach the [gun.name] to the [name].</span>")
	else
		src.visible_message("<span class='warning'>The [gun.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()

/obj/item/stock_parts/cell/minigun
	name = "Minigun gun fusion core"
	maxcharge = 500000
	self_recharge = 0

/obj/item/gun/energy/hitscan
	name = "hitscan gatling gun"
	desc = "Evil Incarnate"
	icon = 'icons/obj/guns/minigun.dmi'
	icon_state = "minigun_spin"
	item_state = "minigun"
	flags_1 = CONDUCT_1
	slowdown = 1
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	materials = list()
	automatic = 1
	fire_rate = 10
	weapon_weight = WEAPON_HEAVY
	ammo_type = list(/obj/item/ammo_casing/energy/hitscan)
	cell_type = /obj/item/stock_parts/cell/minigun
	can_charge = FALSE
	fire_sound = 'sound/weapons/laser.ogg'
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	full_auto = TRUE
	var/cooldown
	var/last_fired
	var/spin = 0
	var/current_heat = 0
	var/overheat = 80 //8 second cooldown
	var/obj/item/hitscanpack/ammo_pack

/obj/item/gun/energy/hitscan/Initialize(mapload)
	if(istype(loc, /obj/item/hitscanpack)) //We should spawn inside an ammo pack so let's use that one.
		ammo_pack = loc
	else
		return INITIALIZE_HINT_QDEL //No pack, no gun

	return ..()

/obj/item/gun/energy/hitscan/Destroy()
	if(!QDELETED(ammo_pack))
		qdel(ammo_pack)
	ammo_pack = null
	return ..()

/obj/item/gun/energy/hitscan/attack_self(mob/living/user)
	return

/obj/item/gun/energy/hitscan/dropped(mob/user)
	..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/gun/energy/hitscan/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack)
		if(cooldown < world.time)
			if(current_heat >= overheat) //We've been firing too long, shut it down
				to_chat(user, "<span class='warning'>[src]'s heat sensor locked the trigger to prevent lens damage.</span>")
				shoot_with_empty_chamber(user)
				stop_firing()
			if(spin >= 12) //full rate of fire
				fire_effect(TRUE)
				..()
			else if(spin >= 6 && spin % 2) //Starting to fire rounds
				fire_effect(TRUE)
				..()
			else if(spin < 6 && spin % 2) //Just starting to spin, no rounds fired
				fire_effect()
			else if(spin >= 6) //Full spin sound between shots
				fire_effect()
			spin++
			last_fired = world.time
		else
			to_chat(user, "<span class='warning'>[src] is not ready to fire again yet!</span>")
	else
		to_chat(user, "<span class='warning'>There is no power supply for [src]</span>")
		return //don't process firing the gun if it's on cooldown or doesn't have an ammo pack somehow.

/obj/item/gun/energy/hitscan/proc/stop_firing()
	if(current_heat) //Don't play the sound or apply cooldown unless it has actually fired at least once
		playsound(get_turf(src), 'sound/weapons/heavyminigunstop.ogg', 50, 0, 0)
		cooldown = world.time + max(current_heat, 2 SECONDS) //2 to 8 seconds depending on how hot it was. At least 1.5 seconds is required to prevent overlapping conflicts with spinups and spindowns.
		current_heat = 0
	spin = 0

/obj/item/gun/energy/hitscan/proc/check_firing()
	if(last_fired + 4 <= world.time)
		stop_firing()

/obj/item/gun/energy/hitscan/proc/fire_effect(heating)
	playsound(get_turf(src), 'sound/weapons/heavyminigunstart.ogg', 40, 0, 0)
	addtimer(CALLBACK(src, PROC_REF(check_firing),), 5)
	if(heating)
		current_heat += 2

/obj/item/gun/energy/hitscan/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "<span class='warning'>You need the backpack power source to fire the gun!</span>")
	. = ..()

/obj/item/gun/energy/hitscan/dropped(mob/living/user)
	..()
	ammo_pack.attach_gun(user)
