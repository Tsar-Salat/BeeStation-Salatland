///called on item when microwaved (): (obj/machinery/microwave/M)
#define COMSIG_ITEM_MICROWAVE_ACT "microwave_act"
	/// Return on success - that is, a microwaved item was produced
	#define COMPONENT_MICROWAVE_SUCCESS (1<<0)
	/// Returned on "failure" - an item was produced but it was the default fail recipe
	#define COMPONENT_MICROWAVE_BAD_RECIPE (1<<1)
///called on item when created through microwaving (): (obj/machinery/microwave/M, cooking_efficiency)
#define COMSIG_ITEM_MICROWAVE_COOKED "microwave_cooked"

///From /datum/component/edible/on_compost(source, /mob/living/user)
#define COMSIG_EDIBLE_ON_COMPOST "on_compost"
	// Used to stop food from being composted.
	#define COMPONENT_EDIBLE_BLOCK_COMPOST 1
