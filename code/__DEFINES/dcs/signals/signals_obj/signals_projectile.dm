// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /obj/item/projectile signals (sent to the firer)

///from base of /obj/projectile/proc/on_hit(), like COMSIG_PROJECTILE_ON_HIT but on the projectile itself and with the hit limb (if any): (atom/movable/firer, atom/target, Angle, hit_limb)
#define COMSIG_PROJECTILE_SELF_ON_HIT "projectile_self_on_hit"
///from base of /obj/projectile/proc/on_hit(): (atom/movable/firer, atom/target, Angle)
#define COMSIG_PROJECTILE_ON_HIT "projectile_on_hit"
///from base of /obj/projectile/proc/fire(): (obj/projectile, atom/original_target)
#define COMSIG_PROJECTILE_BEFORE_FIRE "projectile_before_fire"
///sent to targets during the process_hit proc of projectiles
#define COMSIG_PROJECTILE_PREHIT "com_proj_prehit"
///from the base of /obj/projectile/on_range(): ()
#define COMSIG_PROJECTILE_RANGE_OUT "projectile_range_out"
///from [/obj/item/proc/tryEmbed] sent when trying to force an embed (mainly for projectiles and eating glass)
#define COMSIG_EMBED_TRY_FORCE "item_try_embed"
	#define COMPONENT_EMBED_SUCCESS (1<<1)
// FROM [/obj/item/proc/updateEmbedding] sent when an item's embedding properties are changed : ()
#define COMSIG_ITEM_EMBEDDING_UPDATE "item_embedding_update"

#define COMSIG_PELLET_CLOUD_INIT "pellet_cloud_init"				// sent to targets during the process_hit proc of projectiles
