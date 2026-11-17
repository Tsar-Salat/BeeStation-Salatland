/// From /datum/surgery_operation/try_perform(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_STARTED "atom_surgery_started"
/// From /datum/surgery_operation/try_perform(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_FINISHED "atom_surgery_finished"
/// From /datum/surgery_operation/success(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_SUCCESS "atom_surgery_step_success"
/// From /datum/surgery_operation/failure(): (datum/surgery_operation/operation, atom/movable/operating_on, tool)
#define COMSIG_ATOM_SURGERY_FAILED "atom_surgery_step_failed"

/// Sent from /mob/living/perform_surgery: (atom/movable/operating_on, list/possible_operations)
#define COMSIG_LIVING_OPERATING_ON "living_operating_on"
/// Sent from /mob/living/perform_surgery: (mob/living/surgeon, list/possible_operations)
#define COMSIG_ATOM_BEING_OPERATED_ON "atom_being_operated_on"
