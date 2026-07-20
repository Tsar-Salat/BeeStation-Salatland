/**
 * Bits and pieces that make up the lobby screen.
 *
 * They all hang off one master object in the splash turf's vis_contents instead of going
 * on the turf directly, because ChangeTurf cuts vis_contents and this way putting them
 * back afterwards is one line.
 *
 * There's no per-client anything here on purpose. It's one shared set of objects, which
 * is why someone connecting halfway through init just sees the right thing with no setup.
 */
/obj/effect/splashscreen
	name = "lobby screen"
	icon = null
	icon_state = null
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// sits over the lobby image, which is on the turf at FLY_LAYER
	layer = FLY_LAYER + 0.1
	// no TILE_BOUND on purpose. these end up several tiles wide and hang off a turf in
	// the corner of the image that's usually off screen, so with it set byond reckons
	// they fit inside that one turf and culls them
	appearance_flags = KEEP_APART|PIXEL_SCALE

/// solid block, used for every piece of the bar
/obj/effect/splashscreen/bar
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"

/// stretches the block out to a pixel size, pinned to its bottom left corner. byond
/// scales around the middle of an icon, so the translate cancels the drift that causes
/obj/effect/splashscreen/bar/proc/set_size(width, height, animate_time = 0)
	// 1px floor rather than 0, since a zero scale is a degenerate matrix and you can't
	// see one pixel against a 288px track anyway
	var/scale_x = max(width, 1) / ICON_SIZE_X
	var/scale_y = max(height, 1) / ICON_SIZE_Y

	var/matrix/target = matrix()
	target.Scale(scale_x, scale_y)
	target.Translate(ICON_SIZE_X * 0.5 * (scale_x - 1), ICON_SIZE_Y * 0.5 * (scale_y - 1))

	if(animate_time > 0)
		animate(src, transform = target, time = animate_time, easing = LINEAR_EASING)
	else
		transform = target

/// maptext only, for the status line and the readout under the bar
/obj/effect/splashscreen/text
	maptext_height = 32
	maptext_width = 320
