// Invisible bodyparts that serve as placeholders for a missing limb
// Used so we can add behavior to "missing limbs" without putting it on the mob itself
// Stumps are never disabled and never count as hands, so they stay out of limb and hand bookkeeping

/obj/item/bodypart/head/stump
	limb_id = null
	plaintext_zone = "neck stump"
	stump_typepath = null
	butcher_replacement = null
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN
	head_flags = NONE

/obj/item/bodypart/head/stump/Initialize(mapload)
	. = ..()
	name = "stump"

/obj/item/bodypart/leg/left/stump
	limb_id = null
	plaintext_zone = "left leg stump"
	stump_typepath = null
	butcher_replacement = null
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN
	can_be_disabled = FALSE

/obj/item/bodypart/leg/left/stump/Initialize(mapload)
	. = ..()
	name = "stump"

/obj/item/bodypart/leg/right/stump
	limb_id = null
	plaintext_zone = "right leg stump"
	stump_typepath = null
	butcher_replacement = null
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN
	can_be_disabled = FALSE

/obj/item/bodypart/leg/right/stump/Initialize(mapload)
	. = ..()
	name = "stump"

/obj/item/bodypart/arm/left/stump
	limb_id = null
	plaintext_zone = "left arm stump"
	stump_typepath = null
	butcher_replacement = null
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN
	can_be_disabled = FALSE
	held_index = 0

/obj/item/bodypart/arm/left/stump/Initialize(mapload)
	. = ..()
	name = "stump"

/obj/item/bodypart/arm/right/stump
	limb_id = null
	plaintext_zone = "right arm stump"
	stump_typepath = null
	butcher_replacement = null
	biological_state = NONE
	bodypart_flags = BODYPART_UNREMOVABLE | BODYPART_STUMP | BODYPART_VIRGIN
	can_be_disabled = FALSE
	held_index = 0

/obj/item/bodypart/arm/right/stump/Initialize(mapload)
	. = ..()
	name = "stump"
