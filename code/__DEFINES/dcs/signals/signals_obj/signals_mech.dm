// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/mecha signals

#define COMSIG_MECHA_ACTION_ACTIVATE "mecha_action_activate"	//sent from mecha action buttons to the mecha they're linked to

/// sent if you attach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_ATTACHED "mecha_equipment_attached"
/// sent if you detach equipment to mecha
#define COMSIG_MECHA_EQUIPMENT_DETACHED "mecha_equipment_detached"
/// sent when you are able to drill through a mob
#define COMSIG_MECHA_DRILL_MOB "mecha_drill_mob"
