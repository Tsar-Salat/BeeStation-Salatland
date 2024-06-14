// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// simple_animal signals
/// called when a simplemob is given sentience from a potion (target = person who sentienced)
#define COMSIG_SIMPLEMOB_SENTIENCEPOTION "simplemob_sentiencepotion"

// /mob/living/simple_animal/hostile signals
///before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
///after attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK (1<<0)
