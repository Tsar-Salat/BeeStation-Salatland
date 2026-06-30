///Currently not used?
#define NO_STUTTER 1
///Language will be speakable even if you don't have a tongue - although you'll murmur. non-carbon that doesn't have a tongue will not murmur.
#define TONGUELESS_SPEECH (1<<1)

// --- NOTE:
// 		language icon is basically hidden if not understood in the current language code. It was originally visible to everyone before, but they no longer know which language you're talking even.

// HIDE_ICON flags: icons will be usually visible because you know, but these flags will not show the icon to you.
///Language icon will be hidden if you understand it (i.e. Solbind)
#define LANGUAGE_HIDE_ICON_IF_UNDERSTOOD (1<<2)
///Language icon will be hidden even if you have the linguist trait. remove __LINGUIST_ONLY part if it's no longer specific. (i.e. Aphasia, Codepeak)
#define LANGUAGE_HIDE_ICON_IF_NOT_UNDERSTOOD__LINGUIST_ONLY (1<<3)
///Language icon will always be hidden to yourself. This is necessary to Aphasia, because you shouldn't diagnose yourself. (i.e. Aphasia)
#define LANGUAGE_HIDE_ICON_TO_YOURSELF (1<<4)

// ALWAYS_SHOW_ICON flags
///Language icon will always be visible if you don't understand it. typically, should go with LANGUAGE_HIDE_ICON_IF_UNDERSTOOD define (i.e. Solbind)
#define LANGUAGE_ALWAYS_SHOW_ICON_IF_NOT_UNDERSTOOD (1<<5)
///Language icon will always be visible to ghosts even if it is set hidden to people. This is because people shouldn't know they talk in a specific language, meanwhile ghosts are supposed to know. (i.e. Metalanguage)
#define LANGUAGE_ALWAYS_SHOW_ICON_TO_GHOSTS (1<<6)


// LANGUAGE SOURCE DEFINES
/// For use in full removal only.
#define LANGUAGE_ALL "all"

// Generic language sources.
/// Language is linked to the movable directly.
#define LANGUAGE_ATOM "atom"
/// Language is linked to the mob's mind.
/// If a mind transfer happens, language follows.
#define LANGUAGE_MIND "mind"
/// Language is linked to the mob's species.
/// If a species change happens, language goes away.
/// If applied to a non-human (no species) atom, this is effectively the same as [LANGUAGE_ATOM].
#define LANGUAGE_SPECIES "species"

// More specific language sources.
// Only ever goes away when dismissed directly.
#define LANGUAGE_FRIEND	"friend"
#define LANGUAGE_ABSORB	"absorb"
#define LANGUAGE_APHASIA "aphasia"
#define LANGUAGE_CULTIST "cultist"
#define LANGUAGE_CURATOR "curator"
#define LANGUAGE_REVENANT "revenant"
#define LANGUAGE_GLAND "gland"
#define LANGUAGE_HAT "hat"
#define LANGUAGE_HIGH "high"
#define LANGUAGE_MALF "malf"
#define LANGUAGE_PIRATE "pirate"
#define LANGUAGE_MASTER	"master"
#define LANGUAGE_SOFTWARE "software"
#define LANGUAGE_STONER	"stoner"
#define LANGUAGE_DRUGGY	"druggy"
#define LANGUAGE_VOICECHANGE "voicechange"
#define LANGUAGE_RADIOKEY "radiokey"
#define LANGUAGE_QUIRK "quirk"
#define LANGUAGE_JOB "job"
#define LANGUAGE_REAGENT "reagent"
#define LANGUAGE_MULTILINGUAL "multilingual"
#define LANGUAGE_EMP "emp"
#define LANGUAGE_HOLOPARA "holoparasite"
#define LANGUAGE_BABEL "babel"
#define LANGUAGE_VAMPIRE "vampire"
#define LANGUAGE_CHANGELING "changeling"

// Language flags. Used in granting and removing languages.
/// This language can be spoken.
#define SPOKEN_LANGUAGE (1<<0)
/// This language can be understood.
#define UNDERSTOOD_LANGUAGE (1<<1)

// --- Intrinsic language loadout (chargen) ---
/// Max number of languages a character may know in total (species-required + player-learned).
#define MAX_KNOWN_LANGUAGES 3

// Fluency tiers shown in the chargen language panel. Bee models fluency as comprehension level;
// speaking is binary (in spoken_languages or not). See /datum/preferences/proc/apply_character_languages.
/// Speak fluently + fully understand.
#define LANGUAGE_FLUENCY_FLUENT "Fluent"
/// Speak it, but only partially follow what's said back (~50%).
#define LANGUAGE_FLUENCY_WORKING "Working"
/// Catch only the common words (~25%); understand-only by default.
#define LANGUAGE_FLUENCY_BASIC "Basic"

/// Percentage of partial understanding granted by the "Working" tier.
#define LANGUAGE_FLUENCY_WORKING_AMOUNT 50
/// Percentage of partial understanding granted by the "Basic" tier.
#define LANGUAGE_FLUENCY_BASIC_AMOUNT 25

/// Understand-only grasp of your assigned job's department register, granted free at spawn so you can
/// limp through your own department's language-gated consoles/documents (read garbled) without having
/// invested in the language. Real fluency (origin pick / learning) removes the friction; other
/// departments' registers stay fully gated. See /datum/job/proc/grant_job_register.
/// Kept equal to LANGUAGE_FIT_PASSABLE_THRESHOLD so your own department always reads as at least
/// "passable" in the chargen fit cue (you can always limp through your own consoles).
#define LANGUAGE_JOB_REGISTER_PARTIAL 40

// Chargen picker grouping. A language's /datum/language/chargen_category places it under a family
// header in the "learn a language" panel; chargen_priority orders within the family (higher = more
// prevalent = nearer the top). A null category means "never offered" (debug/internal, e.g. metalanguage).
#define LANGUAGE_CATEGORY_HUMAN "Human"
#define LANGUAGE_CATEGORY_LIZARD "Lizard"
/// Catch-all for selectable languages with no curated family (e.g. other species' tongues).
#define LANGUAGE_CATEGORY_OTHER "Other"

/// The order families appear in the chargen picker. Unlisted categories are appended alphabetically.
GLOBAL_LIST_INIT(language_chargen_category_order, list(LANGUAGE_CATEGORY_HUMAN, LANGUAGE_CATEGORY_LIZARD, LANGUAGE_CATEGORY_OTHER))

// --- Character origin (heritage). A persistent chargen pick - where the character is from / how they
// were raised - that sets their primary spoken tongue. Overrides the job-derived default; AUTO defers
// to the assigned role's origin_language. See /datum/preference/choiced/origin + grant_origin_language.
#define LANGUAGE_ORIGIN_AUTO "Auto (from your role)"
#define LANGUAGE_ORIGIN_AURI "Auri Frontier"
#define LANGUAGE_ORIGIN_TELLUNE "Tellune Core"
#define LANGUAGE_ORIGIN_INDOL "Indol Academies"
#define LANGUAGE_ORIGIN_CETI "Ceti Rigs"
#define LANGUAGE_ORIGIN_OLDEARTH "Old Earth"
#define LANGUAGE_ORIGIN_SPACER "Spacer"
// Lizard (Vraksa) origins - offered only to lizard species (see origins_for_species).
#define LANGUAGE_ORIGIN_COLONY "Colony Vraksa"
#define LANGUAGE_ORIGIN_ASHWALKER "Ashwalker Holdout"

/// Origin choices offered to humans / human-culture species (AUTO first as the default/fallback).
GLOBAL_LIST_INIT(language_origin_choices_human, list(LANGUAGE_ORIGIN_AUTO, LANGUAGE_ORIGIN_AURI, LANGUAGE_ORIGIN_TELLUNE, LANGUAGE_ORIGIN_INDOL, LANGUAGE_ORIGIN_CETI, LANGUAGE_ORIGIN_OLDEARTH, LANGUAGE_ORIGIN_SPACER))
/// Origin choices offered to ordinary (colony) lizards: the kin tongue plus the frontier / academy paths
/// a colony lizard could have taken. The holdout hearth-tongue (Ashwalker -> Vraksh) is deliberately
/// withheld here - it is earned-not-bought (compendium §5), reserved for the Ashwalker species below.
GLOBAL_LIST_INIT(language_origin_choices_lizard, list(LANGUAGE_ORIGIN_AUTO, LANGUAGE_ORIGIN_COLONY, LANGUAGE_ORIGIN_AURI, LANGUAGE_ORIGIN_INDOL))
/// Origin choices offered to the Ashwalker species (the holdout lizards): the colony list plus the
/// holdout hearth-tongue itself. Only this species' language holder unlocks the Ashwalker origin.
GLOBAL_LIST_INIT(language_origin_choices_lizard_ash, list(LANGUAGE_ORIGIN_AUTO, LANGUAGE_ORIGIN_ASHWALKER, LANGUAGE_ORIGIN_COLONY, LANGUAGE_ORIGIN_AURI, LANGUAGE_ORIGIN_INDOL))
/// The full union of every origin, used ONLY to validate a stored origin pref (so no save ever breaks);
/// the picker offers the species-appropriate subset via origins_for_species().
GLOBAL_LIST_INIT(language_origin_choices, list(LANGUAGE_ORIGIN_AUTO, LANGUAGE_ORIGIN_AURI, LANGUAGE_ORIGIN_TELLUNE, LANGUAGE_ORIGIN_INDOL, LANGUAGE_ORIGIN_CETI, LANGUAGE_ORIGIN_OLDEARTH, LANGUAGE_ORIGIN_SPACER, LANGUAGE_ORIGIN_COLONY, LANGUAGE_ORIGIN_ASHWALKER))
/// Origin -> the primary language it grants. AUTO is absent (falls back to the species primary tongue).
GLOBAL_LIST_INIT(language_origin_languages, list(
	LANGUAGE_ORIGIN_AURI = /datum/language/aurin,
	LANGUAGE_ORIGIN_TELLUNE = /datum/language/common,
	LANGUAGE_ORIGIN_INDOL = /datum/language/indolic,
	LANGUAGE_ORIGIN_CETI = /datum/language/dredge,
	LANGUAGE_ORIGIN_OLDEARTH = /datum/language/uncommon,
	LANGUAGE_ORIGIN_SPACER = /datum/language/driftspeak,
	LANGUAGE_ORIGIN_COLONY = /datum/language/draconic,
	LANGUAGE_ORIGIN_ASHWALKER = /datum/language/ashic,
))

/// Chargen "fit" grading: how well a character's spoken-default register matches their department's
/// register (mutual_understanding %, 100 if identical). Purely a display cue - tune freely.
#define LANGUAGE_FIT_NATIVE_THRESHOLD 70
#define LANGUAGE_FIT_PASSABLE_THRESHOLD 40

// --- Human-web intelligibility model invariants (see common.dm's anchor comment + language_web_model test) ---
/// Every human-category register must understand the Solbind broadcast standard at least this well.
#define LANGUAGE_WEB_BROADCAST_FLOOR 50
/// No partial-understanding value may exceed this dialect ceiling (nothing is near-fluent by intelligibility).
#define LANGUAGE_WEB_MAX 85

// --- Two-axis language gates (see /datum/language: speech_req / comprehend_req) ---
// Speech axis: who can physically PRODUCE the language. The body requirement itself is expressed by
// each language's has_speech_anatomy() override (a tongue, wings, a synthetic body, ...).
/// Anyone with a working mouth can speak it cleanly.
#define LANGUAGE_SPEECH_OPEN 0
/// Anyone can speak it, but it comes out degraded (capped comprehension) without the matching anatomy.
#define LANGUAGE_SPEECH_SOFT 1
/// Only the matching anatomy can produce it; otherwise it can still be known/picked, just not spoken.
#define LANGUAGE_SPEECH_HARD 2

// Comprehension axis: who can UNDERSTAND it, on top of actually knowing it. The condition itself is
// expressed by each language's meets_comprehension_condition() override (blindness, sentience, ...).
/// Anyone who knows it understands it.
#define LANGUAGE_COMPREHEND_OPEN 0
/// Only listeners who meet the condition understand it (e.g. the blind, for Sonus).
#define LANGUAGE_COMPREHEND_REQUIRE 1
/// Everyone EXCEPT listeners who meet the condition understands it (e.g. sentients, for Monkey).
#define LANGUAGE_COMPREHEND_FORBID 2

// CEFR comprehension floor/ceiling (see /datum/language/proc/scramble_sentence):
// - Below this understanding %, "tactical" plot/antag words never come through, so a half-fluent
//   or partially-intelligible listener can't out an antag off the survival floor / frequency roll.
//   (Full speakers bypass scrambling entirely, so this only gates partial listeners.)
#define LANGUAGE_TACTICAL_UNDERSTANDING_THRESHOLD 75

GLOBAL_LIST_INIT(language_fluency_levels, list(LANGUAGE_FLUENCY_FLUENT, LANGUAGE_FLUENCY_WORKING, LANGUAGE_FLUENCY_BASIC))
