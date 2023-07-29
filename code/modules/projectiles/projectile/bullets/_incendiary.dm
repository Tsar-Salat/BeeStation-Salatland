/obj/item/projectile/bullet/incendiary
	damage = 20
	var/fire_stacks = 4

/obj/item/projectile/bullet/incendiary/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(fire_stacks)
		M.IgniteMob()

/obj/item/projectile/bullet/incendiary/Move(atom/newloc, direct, update_dir = TRUE, glide_size_override = 0)
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)
