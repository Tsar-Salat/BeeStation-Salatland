/*ALL DEFINES FOR AIS, CYBORGS, AND SIMPLE ANIMAL BOTS*/

#define DEFAULT_AI_LAWID "default"
#define LAW_VALENTINES "valentines"
#define LAW_DEVIL "devil"
#define LAW_ZEROTH "zeroth"
#define LAW_INHERENT "inherent"
#define LAW_SUPPLIED "supplied"
#define LAW_ION "ion"
#define LAW_HACKED "hacked"

//AI notification defines
#define AI_NOTIFICATION_NEW_BORG 1
#define AI_NOTIFICATION_NEW_MODULE 2
#define AI_NOTIFICATION_CYBORG_RENAMED 3
#define AI_NOTIFICATION_AI_SHELL 4
#define AI_NOTIFICATION_CYBORG_DISCONNECTED 5

//Bot defines, placed here so they can be read by other things!
#define BOT_STEP_DELAY 4 //Delay between movemements
#define BOT_STEP_MAX_RETRIES 5 //Maximum times a bot will retry to step from its position

#define DEFAULT_SCAN_RANGE		7	//default view range for finding targets.

//Bot types
/// Secutritrons (Beepsky), ED-209s
#define SEC_BOT (1<<0)
/// ED-209s (unused)
//#define ADVANCED_SEC_BOT (1<<1)
/// MULEbots
#define MULE_BOT (1<<2)
/// Floorbots
#define FLOOR_BOT (1<<3)
/// Cleanbots
#define CLEAN_BOT (1<<4)
/// Medibots
#define MED_BOT (1<<5)
/// Honkbots & ED-Honks
#define HONK_BOT (1<<6)
/// Firebots
#define FIRE_BOT (1<<7)
/// Hygienebots
#define HYGIENE_BOT (1<<8)
/// Vibe bots
#define VIBE_BOT (1<<9)

//Mode defines
#define BOT_IDLE 			0	//!  idle
#define BOT_HUNT 			1	//!  found target, hunting
#define BOT_PREP_ARREST 	2	//!  at target, preparing to arrest
#define BOT_ARREST			3	//!  arresting target
#define BOT_START_PATROL	4	//!  start patrol
#define BOT_PATROL			5	//!  patrolling
#define BOT_SUMMON			6	//!  summoned by PDA
#define BOT_CLEANING 		7	//!  cleaning (cleanbots)
#define BOT_REPAIRING		8	//!  repairing hull breaches (floorbots)
#define BOT_MOVING			9	//!  for clean/floor/med bots, when moving.
#define BOT_HEALING			10	//!  healing people (medbots)
#define BOT_RESPONDING		11	//!  responding to a call from the AI
#define BOT_DELIVER			12	//!  moving to deliver
#define BOT_GO_HOME			13	//!  returning to home
#define BOT_BLOCKED			14	//!  blocked
#define BOT_NAV				15	//!  computing navigation
#define BOT_WAIT_FOR_NAV	16	//!  waiting for nav computation
#define BOT_NO_ROUTE		17	//!  no destination beacon found (or no route)
#define BOT_EMPTY			18  //!  no fuel/chems inside of them

//transfer_ai() defines. Main proc in ai_core.dm
///Downloading AI to InteliCard
#define AI_TRANS_TO_CARD 1
///Uploading AI from InteliCard
#define AI_TRANS_FROM_CARD 2
///Malfunctioning AI hijacking mecha
#define AI_MECH_HACK 3

//Assembly defines
#define ASSEMBLY_FIRST_STEP 	0
#define ASSEMBLY_SECOND_STEP 	1
#define ASSEMBLY_THIRD_STEP     2
#define ASSEMBLY_FOURTH_STEP    3
#define ASSEMBLY_FIFTH_STEP     4
