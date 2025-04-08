GLOBAL_VAR_INIT(icon_holographic_wall, init_holographic_wall())
GLOBAL_VAR_INIT(icon_holographic_window, init_holographic_window())

// `initial` does not work here. Neither does instantiating a wall/whatever
// and referencing that. I don't know why.
/proc/init_holographic_wall()
	return getHologramIcon(
		icon('icons/turf/walls/wall.dmi', "wall-0"),
		opacity = 1,
	)

/proc/init_holographic_window()
	var/icon/grille_icon = icon('icons/obj/structures.dmi', "grille")
	var/icon/window_icon = icon('icons/obj/smooth_structures/windows/window.dmi', "window-0")

	grille_icon.Blend(window_icon, ICON_OVERLAY)

	return getHologramIcon(grille_icon)
