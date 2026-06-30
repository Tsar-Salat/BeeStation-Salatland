# Language Overhaul — Session Handoff

> **Audience:** a fresh Claude/dev session continuing this work cold.
> **Branch:** `lang-dispersal`. **Date of this handoff:** 2026-06-27.
> **Companion doc:** all design + lore + Bay reference is aggregated verbatim in
> [language_design_compendium.md](language_design_compendium.md). Read that for the *fiction and the
> design rationale*; read this for *what is built, where, and why*.
> **Build:** DM compiles clean — `/home/boneyards/bin/DreamMaker beestation.dme` (~28s, expect
> `0 errors, 2 warnings`; the 2 warnings are the stock "Building with Dream Maker is deprecated"
> notices, not ours). TGUI typechecks clean — `cd tgui && yarn tgui:tsc`.
>
> **⚠ READ THE ADDENDA (SESSIONS 3–7) BEFORE §0–7 — newest wins.** This file grew by dated addenda at
> the bottom; **Session 7 (2026-06-30) is the current source of truth**, and each later addendum supersedes
> the earlier ones (and §0–7) where they conflict. Skim them newest-first. Highlights that override §0–7:
> two-axis speech/comprehension gates + the grouped/gated chargen picker + per-character
> **origin/background** (S3); humans default to **Aurin**, Solbind opt-in (S4); comprehension-gated
> documents + species-aware origins (S5); intelligibility-matrix model + paper authoring (S6); **every
> roundstart species now learns Aurin so non-humans aren't half-deaf to the crew** (S7). Also: Draconic is
> no longer a "contact-creole"; "Ashic" displays as **Vraksh**; the "no per-job language" principle is reversed.

---

## 0. North star (why any of this exists)

Keep BeeStation's strong language **engine** (the "substratum": frequency-weighted partial
comprehension, `/datum/language_holder` with provenance `source`s, body-vs-tongue gating on the
tongue organ) and layer on **Baystation-grade flavor** (the "superstratum": real constructed
language names, culture/origin-based acquisition, grounded lore). The guiding phrase throughout:
**"inspired by Bay, not a copy of Bay."** All fiction is grounded in BeeStation's own wiki canon
(the Geminae home system + the Auri frontier), not Bay's setting.

Everything below was done across two working sessions; this handoff describes the **end state**.

---

## 1. The language web + lore  *(foundation — built first, already in tree)*

The human "common" family and the lizard split, with a mutual-intelligibility web. Full lore +
intelligibility matrices are in the compendium (Part 1).

- **Solbind** — `/datum/language/common` (rebranded in place, key `0`). The engineered human standard.
- **Sertan** — `/datum/language/uncommon` (rebranded, key `!`). Old-Earth heritage tongue.
- **Aurin** `aurin.dm` (key `2`), **Indolic** `indolic.dm` (key `3`), **Dredge** `dredge.dm` (key
  `5`), **Driftspeak** `driftspeak.dm` (key `7`) — new human-web members.
- **Draconic** `draconic.dm` (key `o`) — *(Session 3: recharacterized)* the colony lizards' **in-group
  / kin tongue**, kept among their own; they use lizard-inflected **Aurin** with outsiders. (Was
  described here as a "contact-creole" — that's superseded.)
- **Vraksh** `ashic.dm` (key `c`) — *(Session 3: renamed from "Ashic")* the isolated **hearth-tongue**
  of the holdout "Ashwalker" Vraksa. Body-gated to lizard anatomy. **Display name is now "Vraksh"; the
  typepath stays `/datum/language/ashic`** (file kept, to avoid a wide rename).

Supporting wiring (all already in tree):
- `code/modules/surgery/organs/tongue.dm` — `get_possible_languages()`: base humanoids speak the
  human web; the **lizard** tongue adds Ashic (also in `languages_native`); the **plasmaman** bone
  tongue drops the human tongues (Calcic-only body gate).
- `code/modules/language/_language_holder.dm` — `/datum/language_holder/lizard/ash` grants Ashic +
  blocks Solbind.
- `code/modules/mob/living/carbon/human/_species.dm` — `generate_selectable_species_and_languages()`
  seeds the human web into `GLOB.uncommon_roundstart_languages` (the selectable pool).
- `code/modules/unit_tests/language_web.dm` — validates every `mutual_understanding` key is a real
  keyed language, no self-reference, values 0–100.

Canon used (see compendium for detail): **Geminae** home system (Tellune="Earth", Seta=TelGov
capital, Unope=Felinid birthplace, Indol=oldest colony/IPCs, Ceti=gas miners, Thars=Moth arkship);
**Auri** frontier (~23-yr transit windows → linguistic drift; **Cinis**="Lavaland" where lizards are
native); the lizards' autonym is **Vraksa** ("ash-crossers").

---

## 2. Intrinsic language loadout  *(replaced the Bilingual + CSL quirks)*

**Why:** knowing a couple of tongues at varying fluency should be *intrinsic* to a character (Bay's
model), not a quirk you spend a slot on. Every character now gets a **Languages** chargen tab.

**Locked design decisions (confirmed with the user):**
- **Fluency = 3 tiers** (Native / Working / Basic) **+ an understand-only flag**.
- **Budget = 3 total, species-required languages count against the cap** (Bay-style scarcity: a plain
  human with Solbind free can learn 2 more; a lizard with Solbind+Draconic free can learn 1).
- **Required set comes from the species language holder; selectable pool = the existing
  `GLOB.uncommon_roundstart_languages`.** The `/datum/culture` + age layer is **Phase 2** (deferred).

**Fluency → engine mapping** (comprehension is engine-modelled; *speaking* is binary):
| Tier | Grant |
|---|---|
| Native | `grant_language(SPOKEN_LANGUAGE \| UNDERSTOOD_LANGUAGE)` |
| Working | `grant_language(SPOKEN_LANGUAGE)` + `grant_partial_language(50)` |
| Basic | `grant_partial_language(25)` (understand-only) |
| + understand-only | drop `SPOKEN_LANGUAGE` |
| a required language set **below Native** | downgrade (remove species `UNDERSTOOD`, grant partial) → the **CSL** case |

**Key files:**
- Storage: `var/list/alternate_languages` on `/datum/preferences`
  (`code/modules/client/preferences/preferences.dm`). Entry = `list("language"=<typepath text>,
  "fluency"="Native|Working|Basic", "understand_only"=TRUE/FALSE, "native"=TRUE/FALSE)`.
- Serialization: `code/modules/client/preferences/serialization/preferences_database.dm`
  (JSONREAD/WRITEPREF) + define `CHARACTER_PREFERENCE_ALTERNATE_LANGUAGES` in
  `code/__DEFINES/preferences.dm`. **DB column** `alternate_languages` added to
  `SQL/beestation_schema.sql`; migration `SQL/intrinsic_languages_migration_2026-06-27.sql`.
- Middleware (data + edit actions): `code/modules/client/preferences/middleware/languages.dm`
  (`/datum/preference_middleware/languages`). Also hosts the spawn applier
  **`/datum/preferences/proc/apply_character_languages(human)`**.
- Spawn application (ungated by quirk flags): `code/controllers/subsystem/ticker.dm` (~L442,
  roundstart) and `code/modules/mob/dead/new_player/new_player.dm` (~L414, latejoin).
- CSL drift re-homed: `code/datums/components/native_drift.dm` (`/datum/component/native_drift` —
  drift-to-native at low sanity on `COMSIG_MOB_SAY`, re-strip Solbind on `COMSIG_SPECIES_GAIN`).
- Defines: `MAX_KNOWN_LANGUAGES 3`, `LANGUAGE_FLUENCY_*`, `GLOB.language_fluency_levels` in
  `code/__DEFINES/language.dm`. Source tag reused: `LANGUAGE_MULTILINGUAL`.
- TGUI: `tgui/.../PreferencesMenu/LanguagesPage.tsx` (new), wired into `CharacterPreferenceWindow.tsx`
  (Page enum / switch / tab button); types in `PreferencesMenu/data.ts` (`Language`, `LanguageInfo`,
  `AlternateLanguage`, `RequiredLanguage`, added to `ServerData` + `PreferencesMenuData`).
- **Removed:** `code/datums/traits/bilingual.dm`, `code/datums/traits/csl.dm`,
  `code/modules/client/preferences/entries/character/quirks/multilingual.dm`, and the TGUI
  `.../features/character_preferences/language.tsx`, plus their `beestation.dme` includes.

**Old saves:** the removed quirk names are dropped gracefully by `SSquirks.filter_invalid_quirks`;
there is **no migration of prior bilingual/CSL picks** (players re-pick — accepted tradeoff).

---

## 3. CEFR-style comprehension floor & ceiling

**Why:** the engine already weights comprehension by English word frequency, but even "yes/no" was a
coin-flip at low fluency, and plot words could leak. We added a guaranteed floor and a protective
ceiling, framed loosely on CEFR.

**Locked decisions:** floor **+** jargon ceiling; keep the 3 player tiers with CEFR as the conceptual
backbone; an **explicit no-leak tactical set** so antags aren't outed for free.

**How it works** (in `/datum/language/proc/scramble_sentence`, `code/modules/language/_language.dm`):
per word, before the existing frequency roll —
- **Survival floor:** if you have *any* grasp (>0%) of the language, words in
  `GLOB.language_survival_words` always come through (yes/no/run/danger/medbay/numbers/function
  words…). A totally-unknown language still leaks nothing (floor requires a foothold).
- **Tactical ceiling:** words in `GLOB.language_tactical_words` (kill/bomb/traitor/syndicate/…) never
  come through below `LANGUAGE_TACTICAL_UNDERSTANDING_THRESHOLD` (75). Full speakers bypass scrambling
  entirely; high-mutual-intelligibility pairs (Solbind↔Aurin 85) still catch them.

**Key files:** word lists `strings/language/survival_words.txt` + `strings/language/tactical_words.txt`
(plain text, `#` comments, hot-tunable); loaded by `init_language_wordset()` →
`GLOB.language_survival_words` / `GLOB.language_tactical_words` in
`code/_globalvars/lists/mobs.dm`; threshold define in `code/__DEFINES/language.dm`.

---

## 4. Gesture / line-of-sight reliance  *(Ashic & Draconic carry on the body)*

**Why:** the lore says Ashic is "half hiss, half posture" and Draconic "shed the gestures." This
mechanizes that: such tongues partly travel through *sight*, so they're degraded over comms and to
anyone who can't see the speaker — and they reach the deaf / across a vacuum *visually*.

**Locked decisions:** drop the player sign-language toggle and **repurpose** its plumbing; **soft cap
= audible fraction** over comms (not a hard block); **factor the signer's hands/restraints**.

**Model** (`code/modules/language/gesture.dm`): a per-language `gestural_reliance` (0–100; **Ashic
70, Draconic 25**, others 0) drives a dual-channel comprehension cap:
`cap = (can hear them ? 100−reliance : 0) + (can see them gesture ? reliance × speaker_capacity : 0)`.
- `/mob/living/proc/gesture_comprehension_cap(speaker, dialect, can_hear_them, can_see_them)`.
- `/mob/living(/carbon)/proc/get_gesture_capacity()` — hands/cuffs/restraints → 0 / 50 / 100 (ported
  from the old sign-language `check_signables_state`).
- `/mob/living/proc/sound_reaches_from(speaker)` — vacuum carries the voice only one tile.

**Say-pipeline integration** (`code/modules/mob/living/living_say.dm` `Hear()` +
`code/game/say.dm`):
- `translate_language(...)` now takes a `comprehension_cap` and applies `min(understanding, cap)`
  **even for fully-fluent listeners** (so a native Ashic speaker is still capped over comms).
- `Hear()` computes `can_hear_them` / `can_see_them` once, caps comprehension, and **delivers the
  real message through the visual channel** to non-hearers who can see (deaf, or sound can't reach —
  uses `show_message`'s built-in audible→visual fallback).
- `say()`'s vacuum range-clamp is **skipped for gesture languages**, so they reach the whole room on
  sight; the per-listener cap zeroes the audible fraction for anyone the silent voice can't reach.
- **Per-listener say verb:** a listener who received it by sight sees `visual_say_mod` ("gestures")
  instead of the spoken `say_mod` ("hisses"). `visual_say_mod` is a `/datum/language` var.

**Removed (repurposed):** the freshly-ported player sign-language feature — `sign_language` action,
granter, and component — and the now-orphaned `TRAIT_SIGN_LANG` define, plus their `.dme` includes.

**Net behavior (Ashic 70 / Draconic 25):** face-to-face = full; over comms ≈ 30% / 75%;
blind-but-hearing = audible fraction; deaf-but-seeing = visual fraction (reads "gestures"); in
vacuum it carries on sight; a cuffed/full-handed lizard's visual fraction drops.

---

## 5. Quick file index

| Area | Files |
|---|---|
| Language datums | `code/modules/language/{common,uncommon,aurin,indolic,dredge,driftspeak,draconic,ashic}.dm`, base `_language.dm` (`gestural_reliance`, `visual_say_mod`) |
| Comprehension engine | `_language.dm::scramble_sentence`; `strings/language/{survival,tactical}_words.txt`; `code/_globalvars/lists/mobs.dm` (loaders + GLOB sets) |
| Gesture/LOS | `code/modules/language/gesture.dm`; `code/game/say.dm::translate_language`; `code/modules/mob/living/living_say.dm` (`say()` + `Hear()`) |
| Loadout storage/UI | `preferences.dm`, `serialization/preferences_database.dm`, `middleware/languages.dm`, `tgui/.../LanguagesPage.tsx`, `tgui/.../data.ts`, `CharacterPreferenceWindow.tsx` |
| CSL behavior | `code/datums/components/native_drift.dm` |
| Spawn hooks | `controllers/subsystem/ticker.dm`, `mob/dead/new_player/new_player.dm` |
| Defines | `code/__DEFINES/language.dm`, `code/__DEFINES/preferences.dm` |
| Tongue/holder gating | `code/modules/surgery/organs/tongue.dm`, `code/modules/language/_language_holder.dm` |
| SQL | `SQL/beestation_schema.sql`, `SQL/intrinsic_languages_migration_2026-06-27.sql` |
| Tests | `code/modules/unit_tests/language_web.dm` |
| Docs | `language_design_compendium.md` (design/lore), this handoff |

---

## 6. Known caveats, deferred work & gotchas

- **Phase 2 — `/datum/culture` + age dial (not built):** origins (Tellune core / Auri frontier /
  Indol / Ceti / Unope / colony-Vraksa / Ashwalker) → forced + selectable language sets, with **age
  as an assimilation slider** (heritage ↔ standard fluency). The loadout pipeline (§2) is the seam:
  only the *source* of the required set + pool changes. Design detail in the compendium.
- **DB migration required on DB-backed servers:** the new `alternate_languages` column must exist
  (schema file updated + migration provided). The schema version was **not** bumped — the repo's
  code/schema versions were already inconsistent (code 7.7 vs schema INSERT 7.6) and the mismatch is
  only a soft warning. In-memory / no-DB / unit-test runs are unaffected.
- **No save-migration of old bilingual/CSL picks** (players re-pick).
- **Cosmetic:** a *hearing* listener across a vacuum gets a gesture message delivered through the
  audible channel (`show_message` routes by ears, not medium); the *verb* correctly says "gestures"
  and comprehension is correct — only the delivery styling is imperfect.
- **Gesture verb is flat** — no tone variation ("gestures questioningly") and not species-specific.
  Cleanest future hook: a per-tongue/species `visual_say_mod` override layered over the language
  default.
- **Icons:** several new languages use placeholder `icon_state = "unknown"`; real sprites needed in
  `icons/ui/chat/language.dmi`.
- **Species name:** lizardperson still displays as "Lizard" in-game; "Vraksa" lives only in
  lore/`desc` strings.
- **Other species** (moth/ethereal/apid/psyphoza/diona/etc.) are **not yet grounded** in lore or
  given culture-appropriate language sets.
- **Unit-test build is pre-broken (not ours):** `code/modules/unit_tests/language_transfer.dm`
  references a nonexistent `/datum/species/lizard/silverscale` and only fails under
  `UNIT_TESTS`/`CIBUILDING`. The normal build is clean. No new automated tests were added for the
  loadout-apply path (prefs/client/mob spawn coupling) or the CEFR/gesture mechanics — verify these
  in-game.

---

## 7. How to verify

- **DM:** `/home/boneyards/bin/DreamMaker beestation.dme` → expect `0 errors, 2 warnings`.
- **TGUI:** `cd tgui && yarn tgui:tsc` (types) and `yarn prettier --write <files>` (format). Full
  bundle: `yarn tgui:build`.
- **In-game spot checks:**
  - Every character shows the **Languages** tab; a human can learn 2 extras, a lizard 1 (cap counts
    required).
  - Sertan@Basic ≈ catch ~25% (common words) — and the survival floor always lands ("RUN!", numbers).
  - Solbind set below Native + a non-Solbind native ⇒ reproduces CSL, including drift-to-native at low
    sanity.
  - Ashic over comms ≈ unreadable; Draconic over comms ≈ usable; deaf crewmate watching an Ashic
    speaker reads "gestures, …"; in vacuum it carries on sight.

---

# ════════════════ SESSION 3 ADDENDUM — 2026-06-28 ════════════════

> Continues `lang-dispersal`. Everything below compiles clean: **DM `0 errors, 2 warnings`**, and
> **TGUI `yarn tgui:tsc` + `yarn eslint` both exit 0**. This addendum is the **current source of
> truth** wherever it conflicts with §0–7 above. It was built incrementally with the user confirming
> each design fork, so the *decisions* are as important as the code — they're recorded here too.

## A. Supersessions — what in §0–7 is now outdated

- **Draconic** is the colony lizards' **in-group / kin tongue**, *not* a "contact-creole." Lizards
  speak lizard-inflected **Aurin** with outsiders and switch to Draconic (`,o`) for kin. Its
  `mutual_understanding` is now `{ashic 45, aurin 20}` (was `{ashic 45, common 20}`).
- **"Ashic" → display name "Vraksh"** (the holdouts' autonym). **Typepath stays `/datum/language/ashic`**
  (and the file is still `ashic.dm`) — a full rename was deliberately *not* done. Code comments in
  `gesture.dm`, `tongue.dm`, `living_say.dm`, `ashic.dm` were updated to say "Vraksh."
- **Colony lizards now speak Aurin, not Solbind.** `/datum/language_holder/lizard` grants **Aurin +
  Draconic** (was Solbind + Draconic). Aurin↔Solbind is ~85% both ways (`common.dm` ↔ `aurin.dm`), so
  they stay mutually intelligible with standard speakers; the species-required budget is still 2.
- **`common.dm` dropped its vestigial `draconic = 10`** — Solbind is the suits' standard and no longer
  leaks an in-group lizard tongue; humans reach Draconic via the lizard-flavored Aurin instead.
- **Aurin** is now the **working-class / cross-species contact dialect** — desc rewritten, hiss/loanword
  syllables added, `mutual_understanding` gained `draconic = 15`.
- **Indolic** is now **the academy tongue of Indol** (universities/academies → the educated professions'
  register). Desc rewritten; mechanics unchanged.
- **The "no per-job language" principle is reversed.** Languages now flow from a per-character
  **origin/background** (and the assigned job as a fallback). See §D.
- **Fluency tier rename:** `LANGUAGE_FLUENCY_NATIVE` → **`LANGUAGE_FLUENCY_FLUENT`** ("Fluent"). The §2
  table's "Native" tier is now "Fluent." (The TGUI reads `fluency_levels[0]` as the top tier, so it
  followed automatically.)
- **Comprehension display var rename:** `chargen_comprehend_note` → **`chargen_comprehend_audience`**
  (now a bare noun phrase like `"the blind"`, not a full sentence — see §B).

## B. Two-axis language gates  *(the engine model for "who can speak / who can understand")*

**Why:** the old body-gate was incoherent — the base tongue's `get_possible_languages()` lists almost
everything, so nothing actually stopped, e.g., a lizard from being granted Slimic and speaking it. We
added an explicit, declarative two-axis model. **Locked decision:** gates live on the **language**
(it checks the speaker/listener — a tongue, wings, blindness, …), *not* on the tongue organ, because a
tongue can't express "needs wings" or "needs blindness."

**Defines** (`code/__DEFINES/language.dm`): `LANGUAGE_SPEECH_{OPEN,SOFT,HARD}`,
`LANGUAGE_COMPREHEND_{OPEN,REQUIRE,FORBID}`.

**On `/datum/language`** (`_language.dm`): `speech_req`, `soft_speech_quality` (default 40),
`comprehend_req`, plus display vars `chargen_speech_note` (anatomy noun, e.g. `"a slime tongue"`),
`chargen_comprehend_audience` (e.g. `"the blind"`), `chargen_comprehend_icon`. Four hook procs:
- `production_quality(speaker)` → 0–100; **0 = can't physically produce** (HARD without the anatomy),
  `<100` = degraded (SOFT without it).
- `has_speech_anatomy(speaker)` — **default rule: "is this language native to the speaker's tongue"**
  (reuses `tongue.languages_native`), which covers slime/draconic/calcic/machine/voltaic/moffic/sonus
  with zero per-language code. Override only for non-tongue gates.
- `listener_can_comprehend(listener)` + `meets_comprehension_condition(listener)` — the REQUIRE/FORBID
  axis.

**Wiring (3 hot-path touches):**
- HARD speech gate → `/datum/language_holder/can_speak_language` also requires `production_quality > 0`
  (omnitongue bypasses). `code/modules/language/_language_holder.dm`.
- SOFT penalty → folded into the `comprehension_cap` already computed in `Hear()`
  (`code/modules/mob/living/living_say.dm`) — degraded speech ⇒ everyone understands less.
- Comprehension veto → in `translate_language` (`code/game/say.dm`), scoped to **living** listeners so
  ghosts keep universal understanding.

**Per-language assignments:** Slimic SOFT (slime tongue), Draconic SOFT (lizard tongue), Calcic HARD
(bone), Moffic HARD (moth/"wings"), Machine/EAL HARD (synthetic), Voltaic HARD (ethereal), Sonus HARD
(psyphoza) **+ REQUIRE blind**, Monkey speech OPEN **+ REQUIRE monkey** (so transform-to-monkey can
speak it, but only monkeys understand it). The **psyphoza tongue** got its missing
`languages_native = list(/datum/language/sonus)` (`tongue.dm`).

**Deferred:** the **insect merge** (moffic + buzzwords + apidite → one wing-gated language) — buzzwords
& apidite are still OPEN/ungated; their tongue mapping is tangled and the user wants them consolidated
as a separate content pass. Also: the permissive base `get_possible_languages()` was *not* trimmed (the
two-axis gate makes it moot, but a future cleanup could).

## C. The chargen language picker — grouping, exclusion, gate badges  *(all in the Languages tab)*

`tgui/.../PreferencesMenu/LanguagesPage.tsx` was heavily reworked (card rows, fixed control columns so
they align, inline descriptions, a grouped "Learn a language" browse panel). Server side
(`code/modules/client/preferences/middleware/languages.dm` + `data.ts` types):

- **Grouping + exclusion:** `/datum/language` gained `chargen_category` (`LANGUAGE_CATEGORY_HUMAN /
  LIZARD / OTHER`; **`null` = never offered**, which is how `metalanguage` and debug langs are excluded)
  and `chargen_priority` (higher = nearer the top of its family). Family order =
  `GLOB.language_chargen_category_order`. `is_selectable()` rejects null-category langs even via a
  crafted action. Prevalence set so Aurin tops the human family, Draconic tops Lizard.
- **Per-species gate badges:** `get_language_gates()` / `describe_gate()` resolve the *currently
  selected species'* tongue (via `initial(species.mutanttongue)` → `languages_native`) and emit
  display-ready badges `{icon, color, tooltip}` + a `speakable` tint (`fine/degraded/unspeakable`). The
  UI renders Font-Awesome icons + name tinting next to every language, so a plasmaman sees Calcic as
  red "Can't be spoken without a plasma or bone tongue — understood only," a human sees Draconic as
  yellow "Spoken unclearly without a lizard's tongue," etc. **Tooltip phrasing is standardized**: speech
  badges read `"<effect> without <anatomy>"`, comprehension badges `"Only <audience> can understand
  it."` — only the noun phrase varies per language.

## D. Character **origin / background** + per-job origin language  *(the Bay-style "culture" layer)*

**The decision chain (all user-confirmed):** (1) origin language should be a property of the
**character**, not the round's job — a persistent identity (Bay attaches languages to *Culture*, not
job; its `occupation.dm` has none). (2) Keep the per-job grant as a **fallback**. Result is a
lightweight one-dropdown origin picker, not Bay's full Culture/Residence/Faction sprawl.

- **`/datum/preference/choiced/origin`** (`code/modules/client/preferences/entries/character/origin.dm`,
  `db_key = "origin"`) — a real datumized character pref, so it **auto-persists per-slot with no DB
  column / migration** (unlike the older `alternate_languages`, which needed a column). Choices +
  language map live in `__DEFINES/language.dm`: `LANGUAGE_ORIGIN_{AUTO,AURI,TELLUNE,INDOL,CETI,OLDEARTH,
  SPACER}`, `GLOB.language_origin_choices`, `GLOB.language_origin_languages`. Default = **AUTO**.
- **`/datum/job/origin_language`** (`_job.dm`, default `/datum/language/aurin`) — the role's heritage
  tongue; ~17 overrides on the job datums (Captain/HoP→Solbind; all Science + Medical + Lawyer +
  Curator + Brig-Physician→Indolic; Shaft Miner→Dredge; Exploration→Driftspeak; Chaplain→Sertan; the
  rest inherit Aurin). Silicons untouched (skipped — not human).
- **Spawn resolution** — `/datum/job/proc/grant_origin_language(human)`, called once in the central
  equip path (`code/controllers/subsystem/job.dm`, right after `after_spawn`, so it covers roundstart
  **and** latejoin and isn't bypassed by per-job `after_spawn` overrides). It reads the **character
  origin pref first**; if AUTO, falls back to **this job's** `origin_language`. Grants it
  `SPOKEN|UNDERSTOOD` (source `LANGUAGE_JOB`) and makes it the **default spoken tongue**
  (`set_active_language`). Humans keep their species Solbind as the universal baseline; origin just sets
  what they *default to speaking*. Body-gate is graceful (a plasmaman Doctor granted Indolic simply
  fails over to Calcic via `set_active_language`).
- **Picker display:** the "Known from your origin" section now has an **Origin dropdown** (middleware
  `set_origin` action via `update_preference`), shows species rows tagged `from your species` /
  `… · understood only`, and a read-only **origin row** tagged `from your origin · <Origin>` (explicit)
  or `from your role · <Job>` (AUTO fallback), with a `spoken default` tag. Resolved by
  `get_origin_display()` the same way spawn resolves it (one source of truth). **Important:** the
  origin/job language is a *free* grant — it is sent as a separate `origin_language` field and is **NOT**
  in `get_required_languages()`, so it does **not** consume a chargen slot.

## E. The department / origin → language map  *(reference — the lore that drives §D)*

Origin = where the character was raised/trained (employer ≈ recruiting base ≈ tongue):

| Language | Origin / who |
|---|---|
| **Solbind** (`common`) | Tellune core / corporate **management** — Captain, HoP *(opt-in for other humans; see Session 4)* |
| **Indolic** | **Indol academies** → the **educated professions** — Science, Medical, Lawyer, Curator, Brig Physician |
| **Aurin** | **Auri frontier labor** (the default + human species primary) — Sec, Engi, Service, Civilian, **QM** |
| **Dredge** | Ceti→Auri **extraction** — Shaft Miner **+ Cargo Tech** |
| **Driftspeak** | long-haul **spacers** — Exploration Crew |
| **Sertan** (`uncommon`) | **Old-Earth heritage** — Chaplain (its one job home; otherwise ancestral) |

Heads split nicely by role: CMO/RD→Indolic, HoS/CE→Aurin, Captain/HoP→Solbind. Lizards (Aurin+Draconic
from species, **Draconic primary**) slot straight into the worker class.

> **⚠ Session 4 reworked the species primaries + the AUTO default — read the Session 4 addendum at the
> bottom; it supersedes this section where they conflict.**

## F. Per-slot persistence & the **no-DB gotcha**  *(verified, important)*

Both the origin pref (datumized) and the `alternate_languages` loadout (undatumized, in the per-slot
column set alongside `job_preferences`) are **per-slot — but only with a DB.** Slot swap does
`save_character()` → `load_character(new_slot)`, which `qdel`s + reloads the character holder.
**With no DB, none of it persists across slots** — `query_data()` returns early on `!SSdbcore.IsConnected()`
and `load_character` returns `IGNORE`, so the target slot comes up randomized/default and the slot you
left isn't saved. The framework says so itself: *"Only the current slot is valid"*
(`preferences_character.dm`). **This is framework-wide (occupation, species, appearance all behave the
same) — not specific to languages/origin.** To test "different role per slot," point it at a DB.

## G. New / changed files (Session 3)

| Area | Files |
|---|---|
| Two-axis gates | `_language.dm` (vars+procs), `_language_holder.dm` (`can_speak_language`), `living_say.dm` (`Hear` cap), `game/say.dm` (`translate_language` veto), `tongue.dm` (psyphoza native), per-language: `slime/draconic/calcic/moffic/machine/voltaic/sonus/monkey.dm` |
| Picker grouping/badges | `middleware/languages.dm`, `LanguagesPage.tsx`, `PreferencesMenu/data.ts`, `__DEFINES/language.dm` |
| Origin / background | `entries/character/origin.dm` *(new)* + `.dme` include, `__DEFINES/language.dm` (origin defines+GLOBs), `middleware/languages.dm` (`set_origin`, `get_origin_display`) |
| Per-job origin | `jobs/job_types/_job.dm` (`origin_language` var + `grant_origin_language`), `controllers/subsystem/job.dm` (call site), ~17 `jobs/job_types/*.dm` overrides, `__DEFINES/language.dm` (`LANGUAGE_JOB`) |
| Lizard rework | `draconic.dm`, `ashic.dm`, `aurin.dm`, `indolic.dm`, `common.dm`, `_language_holder.dm` (lizard holder) |

## H. Still open / not done (carry-over for the next session)

- **CI blocker (pre-existing, unfixed):** `code/modules/unit_tests/language_transfer.dm` references
  `/datum/species/lizard/silverscale`, which exists nowhere. The normal build is clean, but under
  `CIBUILDING`→`UNIT_TESTS` it's a compile error. Came in on an earlier branch commit (#11971), not the
  overhaul — but it ships in this PR and will fail CI. **Fix before opening the PR.**
- **Insect merge** (moffic/buzzwords/apidite) — deferred (see §B).
- **Compendium (`language_design_compendium.md`) is stale** — still describes Draconic as a creole, calls
  the hearth-tongue "Ashic," and states the "no per-job" principle. Not yet refreshed.
- **DB column / schema version** for `alternate_languages` still unbumped (origin needs none). **Icons:**
  new languages still use placeholder `icon_state = "unknown"`. **Species name:** lizard still shows
  "Lizard," not "Vraksa."
- **No-DB multi-slot** persistence is a framework limitation, not fixable here (see §F).

---

# ════════════════ SESSION 4 ADDENDUM — 2026-06-29 ════════════════

> Continues `lang-dispersal`. **Goal of this session:** turn the language layer into a soft deterrent
> against "metastatic" single-character play (one self-insert character used for *every* role). Built
> from the user's role↔language spec (`Language-doc.txt`). **Entice, not punish** — no new mechanical
> penalties; the friction is intrinsic (register distance) and now *legible* (a chargen fit cue).
> Compiles clean: **DM `0 errors, 2 warnings`**, **TGUI `yarn tgui:tsc` exit 0**. This addendum is the
> current source of truth wherever it conflicts with §0–H above.

## The core idea
A character's spoken default is now an **identity** (species + chosen origin), never a chameleon that
conforms to the round's job. Each department speaks a different register, those registers are
mechanically far apart, and the 3-language cap forbids being fluent in all of them — so a one-character
build sounds foreign in most departments, and the chargen panel now *says so*. The reward for a
role-appropriate character is intrinsic (you fit the room); the nudge is toward dedicated, per-slot
characters.

## Supersessions — what changed vs Sessions 1–3
- **AUTO origin no longer resolves to the job's register.** It now resolves to the character's **species
  primary tongue** (human → Aurin, lizard → Draconic, ash-lizard → Vraksh). New
  `var/datum/language/primary_language` on `/datum/language_holder` + helper `/proc/species_primary_language(holder_type)`
  (falls back to first spoken). `grant_origin_language` (`_job.dm`) and `get_origin_display`/
  `resolved_origin_language` (`middleware/languages.dm`) both read it, kept in lockstep.
- **`/datum/job/origin_language` is no longer granted to anyone.** Recharacterized as **the department's
  register** — reference data for the chargen "fit" cue + the §E lore. Var name + the ~17 overrides kept.
- **Human species primary is now Aurin, not Solbind.** `human_basic` grants Aurin (free). Solbind is
  **opt-in**: still selectable in the chargen pool (no longer stripped in
  `generate_selectable_species_and_languages`), and Command gets it from their origin. Humans still
  follow Solbind ~85% through Aurin, so broadcasts land. Budget unchanged (humans = 2 learnable slots).
- **Lizard species primary is now Draconic** (the kin tongue) — the holder still grants Aurin+Draconic.
- **Solbind is now the asymmetric "main language."** `common`'s own `mutual_understanding` of other
  tongues was lowered (45/25/20/20/15) and the inverse raised in each other file (indolic→common 70,
  driftspeak→common 55, uncommon→common 60) so Solbind is widely *understood* but its speakers understand
  little. All values **tunable** (`Language-doc.txt` flags the matrix as rough). *Caveat:* because every
  human now carries Aurin (→Solbind 85), this mostly shapes non-human Solbind-speakers + pure-corporate
  outsiders; the anti-metastatic friction itself rides on **Aurin's** distance to the specialist
  registers (aurin→indolic 20, →dredge 40, →driftspeak 30, →uncommon 15).
- **Cargo Tech → Dredge** (dock/extraction underclass); QM stays Aurin.

## New — the chargen "fit" cue (the enticement)
`get_origin_fit()` (`middleware/languages.dm`) compares the character's resolved spoken-default register
against their highest-priority job's department register (via the spoken language's `mutual_understanding`)
and grades it **native / passable / foreign** (thresholds `LANGUAGE_FIT_{NATIVE,PASSABLE}_THRESHOLD` =
70/40 in `__DEFINES/language.dm`). Sent as `origin_fit`; `LanguagesPage.tsx` renders a colored line in
the origin section ("You default to speaking Aurin, but the Science department speaks Indolic — you'll
sound foreign here."). **Display-only — no mechanical effect.**

## Collateral from the Aurin-primary switch (audited + fixed)
- **`native_drift` (CSL drift)** was hardcoded to Solbind; generalized to the **downgraded standard
  tongue** (vars `standard_language`/`standard_strength`; `apply_character_languages` now tracks
  `standard_path`). Keeps the "drift to native under stress" feature working with Aurin as the standard.
- **`foreigner` quirk** now blocks **Aurin** (+ Solbind) — blocking only Solbind no longer isolated a
  foreigner since the crew speaks Aurin. Text updated.
- `create_pref_language_perk` (`_species.dm`) now naturally shows humans speaking **Aurin** (cosmetic,
  correct). Other `/datum/language/common` refs are non-human mobs, forced cult/clock invocations, or
  name-gen weights — unaffected.

## New / changed files (Session 4)
| Area | Files |
|---|---|
| AUTO → species primary | `_language_holder.dm` (`primary_language`, `species_primary_language`, human/lizard holders), `_job.dm` (`grant_origin_language`, `origin_language` recomment), `middleware/languages.dm` (`resolved_origin_language`, `get_origin_display`) |
| Human primary = Aurin / Solbind opt-in | `_language_holder.dm` (`human_basic`), `_species.dm` (`generate_selectable_species_and_languages`) |
| Solbind asymmetric matrix | `common.dm`, `indolic.dm`, `driftspeak.dm`, `uncommon.dm` |
| Cargo Tech register | `jobs/job_types/cargo_technician.dm` |
| Chargen fit cue | `middleware/languages.dm` (`get_origin_fit`), `__DEFINES/language.dm` (thresholds), `LanguagesPage.tsx`, `PreferencesMenu/data.ts` (`OriginFit`) |
| CSL/foreigner collateral | `components/native_drift.dm`, `middleware/languages.dm` (`apply_character_languages`), `traits/foreigner.dm` |

## Still open after Session 4
- **Intelligibility numbers are first-pass** — tune in-game (the spec's addendum expects it).
- **`language_transfer.dm`** still the pre-existing CI blocker (silverscale species); it also asserts a
  dummy understands `common`, which the Aurin switch may now contradict — revisit when that test is
  un-broken for CI.
- Deferred from the spec: **Vraksh reliance ↑**, **Draconic radio privacy**, **Sertan as
  hostile-species primary**, "concepts with no word in some tongues." Compendium still stale.

---

# ════════════════ SESSION 5 ADDENDUM — 2026-06-29 ════════════════

> Continues `lang-dispersal` (same day as Session 4, separate working session). This session moved from
> design into a **phased build**: a fresh hole-analysis of the whole system, then correctness fixes
> (Phase 0), the keystone **comprehension-gated content** feature + **awareness gate** + **limp-through**
> register grant (Phase 1), a **document-tagging pass**, and an honest, **species-aware origin** chargen
> layer (Phase 2). Everything compiles clean: **DM `0 errors, 2 warnings`**, **TGUI `yarn tgui:tsc` exit
> 0**. This addendum is the **current source of truth** wherever it conflicts with §0–H and the Session
> 3/4 addenda. Decisions were confirmed with the user at each fork and are recorded alongside the code.

## The hole that reframed everything
The Session 4 anti-metastatic premise ("departments speak mechanically-distant registers") was found to be
**unbacked**: `/datum/job/origin_language` is granted to *no one*, so an all-AUTO crew (the lazy default,
and every roundstart NPC) speaks **Aurin to each other with zero friction** in every department. The
register map was fiction with no speaker behind it.

**The fix is not making NPCs speak registers — it's gating *content*.** Some consoles/printed documents are
legible only in the right technical/academic register, so "not speaking Indolic doesn't work" becomes a
**concrete in-game barrier** independent of how players talk, and it retroactively makes the origin layer
load-bearing. This is the user's intended direction; the friction is now a hard mechanical gate (entice via
investment, limp-through if you didn't), not a soft social cue.

## Supersessions — what changed vs Sessions 1–4
- **`/datum/job/origin_language` is granted again — but only as a weak, understand-only limp-through.**
  Recharacterized once more: at spawn every human gets `LANGUAGE_JOB_REGISTER_PARTIAL` (**40%**)
  understand-only of their assigned job's register (`grant_job_register`), so they can *limp through* their
  own department's gated content (garbled) without having invested. Real fluency (origin/learning) reads it
  clean; OTHER departments stay gated. (Session 4 said it was granted to nobody — superseded.)
- **AUTO spoken-default resolution is now `explicit origin pref > player-marked native > species primary`**
  (was `origin > species primary`). The loadout "native" marker finally drives the *spoken default*, not
  just display — so a Draconic-RP lizard who marks Draconic native actually spawns speaking it. Shared
  helper `character_marked_native_language()` keeps spawn (`grant_origin_language`) and chargen
  (`resolved_origin_language`) in lockstep.
- **The origin picker is species-aware.** Lizards are offered **Colony Vraksa → Draconic** and **Ashwalker
  Holdout → Vraksh** (plus frontier/academy paths); humans never see lizard origins and vice-versa. The
  origin pref validates against the full union so no save breaks; only what's *shown/settable* is filtered.
- **The chargen "fit" cue was rebuilt.** It now grades the character's **actual comprehension of their
  department register** across their *full* language set + the limp-through floor (`chargen_comprehension()`),
  not the single spoken-default register one-directionally. This kills the "lizard always foreign" bug (a
  lizard worker in an Aurin dept now reads as **native**, since they speak Aurin from species). The cue text
  is now about *reading the department's consoles/documents*, tied to the gate.
- **`LANGUAGE_JOB_REGISTER_PARTIAL` = 40**, deliberately equal to `LANGUAGE_FIT_PASSABLE_THRESHOLD`, so your
  own department always reads at least "passable" (you can always limp through your own consoles; "foreign"
  is reserved for content outside your assignment).
- **The Session 4 budget/holder restructure was considered and REJECTED (user chose "keep current
  holders").** Aurin still comes from the *species* holder for both humans and lizards; budget unchanged
  (human 2 learnable / lizard 1). The "species grants kin, origin grants the human tongue" model is
  conceptual, not literal — players can't tell, and a free slot per character was judged to cut against the
  anti-metastatic goal right as gating goes live.

## Phase 0 — correctness fixes (holes the earlier sessions missed)
- **Self-hearing scramble fixed** (`living_say.dm` `Hear`): the speaker is now exempt (`speaker != src`)
  from both the gesture cap and the SOFT-production cap, so you always fully understand your own speech.
- **Apply-path re-validation** (`apply_character_languages`): the edit-time `is_selectable()` guard wasn't
  authoritative once the loadout was stored. The apply loop now rejects null-category/non-pool languages and
  caps learned grants — stale/hand-edited saves can't inject arbitrary or over-budget tongues.
- **native_drift guard** (`native_drift.dm` `translate_parts`): won't force a tongue that isn't in
  `spoken_languages` (e.g. a Basic/understand-only language the player marked "native"), which previously
  produced gibberish under stress.

## Phase 1 — awareness gate + comprehension-gated content + limp-through
- **Comprehension-gated documents (the keystone).** New `written_language` var on `/obj/item/paper`
  (**null = universal/plainly legible**, the default, so ordinary player paper is untouched and the hot path
  is free). `reader_legibility()` + `scramble_for_reader()` reuse the **exact speech model**
  (`scramble_paragraph`, per-word, frequency-weighted, survival-floor/tactical-ceiling) — gating is a
  *gradient* (your comprehension %), not a binary cliff. Applied per-reader in `ui_static_data`;
  ghosts/observers read all; photocopies stay gated (`copy()` propagates it).
- **Limp-through register grant** (`grant_job_register`, see Supersessions) — called in `job.dm` right after
  `grant_origin_language`.
- **Awareness gate.** New per-character pref `languages_confirmed` (toggle, default FALSE, in `origin.dm`).
  `/mob/dead/new_player/proc/languages_reviewed_or_warn()` fires a click-through alert
  (**Review / Proceed Anyway**) on **readyup** and **latejoin** if never confirmed; "Proceed Anyway" sets
  the flag (one warning per character — awareness, not a hard block; intentional one-language RP is allowed).
  No in-menu confirm button was added — the readyup alert *is* the confirm (simpler).
- **Consoles deferred** (the tgui-side gate) — the comprehension plumbing exists; only the per-console
  application is left.

## Phase 1.5 — document-tagging pass
Tagged the professional-knowledge prose documents in `paper_premade.dm` to **Indolic** (the Science/Medical/
Legal academy register): the **Legal SOP "Crash Course"**, **Chemical Information**, and the **Hippocratic
Oath**. Deliberately left universal: safety/operational guides (SOP, range, labor camp, hydroponics),
public notices & forms, safety-critical command docs (vault/nuke memos), the HTML blood-type table (render
risk), CentCom bulletins (event friction), and flavor/joke notes. **Dredge/Driftspeak/Solbind/Sertan have
no clean premade homes** — those registers get gated content when map-placed or new lore documents are
tagged (`written_language = /datum/language/dredge`, etc.).

## Phase 2 — species-aware origin + honest fit cue (see Supersessions for the behaviour)
2c (species-aware origins) + 2d (spoken-default resolution) + 2a (fit-cue rework). Together these complete
the locked lizard model end-to-end and make the chargen origin layer legible and correct.

## New / changed files (Session 5)
| Area | Files |
|---|---|
| Phase 0 fixes | `mob/living/living_say.dm` (`Hear` self-exempt), `client/preferences/middleware/languages.dm` (`apply_character_languages` re-validation), `datums/components/native_drift.dm` (`translate_parts` guard) |
| Limp-through grant | `__DEFINES/language.dm` (`LANGUAGE_JOB_REGISTER_PARTIAL`), `jobs/job_types/_job.dm` (`grant_job_register`), `controllers/subsystem/job.dm` (call site) |
| Document gate | `paperwork/paper.dm` (`written_language`, `reader_legibility`, `scramble_for_reader`, `ui_static_data`, `copy`), `paperwork/paper_premade.dm` (3 docs → Indolic) |
| Awareness gate | `preferences/entries/character/origin.dm` (`languages_confirmed` pref), `mob/dead/new_player/new_player.dm` (`languages_reviewed_or_warn`, ready + latejoin hooks) |
| Species-aware origin | `__DEFINES/language.dm` (Colony/Ashwalker origins, `_human`/`_lizard`/union choice lists, language map), `middleware/languages.dm` (`character_marked_native_language`, `origins_for_species`, `resolved_origin_language`, `set_origin`, `get_ui_data`), `_job.dm` (`grant_origin_language`) |
| Honest fit cue | `middleware/languages.dm` (`chargen_comprehension`, `get_origin_fit`), `__DEFINES/language.dm` (partial=40), `tgui/.../PreferencesMenu/LanguagesPage.tsx`, `data.ts` (`OriginFit`, `origin_choices`) |

## Still open after Session 5
- **Console gate** (tgui-side) — deferred; coarse panel-level first ("the interface is in Indolic").
- **More document tagging** — Dredge/Driftspeak/Solbind/Sertan content; map-placed docs. Solbind's intended
  home is **command/bureaucratic documents** (§3b) — none tagged yet.
- **Phase 4 hygiene (not started):** the pre-existing `language_transfer.dm` **CI `silverscale` blocker**
  (will fail testmerge CI — fix before PR); automated tests for the gate + loadout-apply paths; the
  **compendium is still stale**; DB column/schema bump for `alternate_languages`; placeholder icons.
- **In-game verification (none done — DM/TS only):** `languages_confirmed` toggle persistence across
  sessions; gated-document markdown rendering (HTML tags like `<BR>` scramble too → run-on gibberish, which
  is the intended "unreadable," but eyeball that tgui handles stray `<`/`>`); tune
  `LANGUAGE_JOB_REGISTER_PARTIAL` vs the cross-register intelligibility matrix (own-dept 40 vs cross-dept
  ~20 is a small gap).
- **Fit-cue minor inaccuracies (display only):** with limp-through = passable threshold, the **"foreign"
  tier never fires for the player's top job** (by design — you always limp through your own); and a required
  tongue **downgraded** to Working/Basic (the CSL case) is still counted as fully-understood in the estimate,
  so it can read slightly high.

---

# ════════════════ SESSION 6 ADDENDUM — 2026-06-30 ════════════════

> Continues `lang-dispersal`. This session ran a fresh **hole-analysis** of the whole shipped system,
> then landed three phased builds: **quick-wins** (correctness/honesty fixes), **matrix regularization**,
> and the parked **content-gating keystone** (paper authoring). Everything compiles clean: **DM `0 errors,
> 2 warnings`**, **TGUI `yarn tgui:tsc` exit 0**. The work was planned with the user confirming each fork;
> the live plan lives at `~/.claude/plans/put-together-a-plan-glimmering-conway.md` (Phases 1–3). This
> addendum is the **current source of truth** wherever it conflicts with §0–H and Sessions 3–5.

## The hole-analysis that framed the session
Nine issues surfaced; the load-bearing ones: a **silently-defeated CSL downgrade** (correctness bug); the
**awareness alert over-promised** consoles/docs that don't exist; the **compendium contradicts the shipped
code**; **Ashic was handed out free** via the origin picker (violating its own "earned" tier); the **matrix
had no written-down model**; gated documents **leaked their form fields**; and the keystone **content gate
had no payoff** — players couldn't author a gated document. Big structural items (#1 consoles, #2 matrix,
#5 non-lizard species) were triaged; the user picked the order and scope at each step.

## A. Phase 1 — quick-wins (correctness + honesty)
- **CSL downgrade fix (the real bug).** Spawn order is `grant_origin_language` (grants the origin
  `SPOKEN|UNDERSTOOD` via `LANGUAGE_JOB`) → `apply_character_languages`. The CSL downgrade branch only
  stripped `LANGUAGE_SPECIES`/`LANGUAGE_ATOM` understood, so an AUTO human downgrading their species-primary
  (Aurin) had it **re-granted full by the surviving `LANGUAGE_JOB` source** — the downgrade did nothing.
  Fixed in `middleware/languages.dm`: the downgrade now `remove_language(lang, UNDERSTOOD_LANGUAGE,
  LANGUAGE_ALL)` (SPOKEN untouched — stays speakable).
- **Ashwalker origin gated (lore tier enforced).** Split a new `language_origin_choices_lizard_ash` (with
  `LANGUAGE_ORIGIN_ASHWALKER`) and **removed Ashwalker from the normal-lizard list**
  (`__DEFINES/language.dm`); `origins_for_species` checks the `/datum/language_holder/lizard/ash` holder
  **first**; `grant_origin_language` now **re-validates** the stored pref against
  `origins_for_species(H.dna?.species?.type)` so a stale Ashwalker pick on a normal lizard can't grant Vraksh.
  Net: a normal lizard never sees "Ashwalker Holdout"; only the Ashwalker *species* unlocks it.
- **Gated documents stop leaking their fields.** `paper.dm::ui_static_data` now also runs each
  `raw_field_input` field's text through `scramble_for_reader` when `legibility < 100` (was scrambling only
  `raw_text_input`) — **signatures stay legible** (`is_signature` skipped: an identity/accountability marker).
- **Awareness-alert text softened** (`new_player.dm::languages_reviewed_or_warn`): dropped the
  "technical consoles … will be unreadable" over-promise (consoles aren't gated) → "some technical documents
  may be hard to read."
- **Compendium refreshed (`language_design_compendium.md`).** It self-describes as a *verbatim historical
  aggregation*, so rather than rewrite the history we added a prominent top **"⚠ SUPERSEDED" banner** + three
  inline markers (the "Draconic — contact-creole" heading, the Part-1 "no per-job" note, the "Future: culture
  layer" header). Part 2 (Bay reference) left alone — its "no per-job" box correctly describes *Bay*.
- **Robustness guards — investigated, NOT added.** The chargen-side loadout iterators use typed
  `for(var/list/entry in …)` loops, which DM already filters to list elements (only `apply_character_languages`
  uses `as anything`, hence its explicit `islist` guard). The "corrupt save runtimes" premise was wrong — no
  dead-code guards were added.

## B. Phase 2 — intelligibility-matrix regularization (#2)
**Decision: regularize + document + test (minimal gameplay swing), not a rebalance.** The audit found the
numbers were already largely lore-coherent for the *spoken* web; the defects were a missing model and
misattributing comments.
- **The model, written down.** Anchor comment above `common.dm`'s `mutual_understanding`; one-line **band
  tags** on every entry across the 8 web files; compendium matrix table refreshed to live values + a band
  legend. **Core principle: comprehension ≈ modest structural overlap + a large Solbind broadcast-exposure
  bonus** (explains why everyone understands Solbind well but it understands little back, and why Aurin's
  ~85% closeness to Solbind doesn't propagate to others).
- **One deliberate value change (lore-driven, from a linguistics review):** **removed the Draconic↔Aurin
  bridge** both ways. Draconic's web is now `{ashic 45}`; the lizard tongues are an **isolated kin island**
  (no human-web intelligibility). Harmless to lizards (their holder grants full Aurin); the only effect is
  **humans no longer passively catch 15% of Draconic** — the intended in-group privacy.
- **Lore reframes (descs + compendium):** Draconic is a **distinct lizard-family language, sister to Vraksh**
  (a diglossia pair), *not* a contact-creole; **Aurin = Solbind + frontier jargon** (lexical, not structural
  drift); the 23-yr window is too short for a real dialect (generations of early-colonial separation);
  lung-graft is breathing, not speech (oral anatomy carries the body-gate). Fixed the misattributing
  `uncommon.dm` Sertan→Aurin comment.
- **Locked with a test.** New defines `LANGUAGE_WEB_BROADCAST_FLOOR 50` / `LANGUAGE_WEB_MAX 85`; new
  `/datum/unit_test/language_web_model` (kept the basic `language_web` test untouched) asserts: dialect
  ceiling, every human register meets the broadcast floor, the broadcast-asymmetry direction, the reciprocal
  in-band lizard kin pair, and **lizard isolation** (no lizard tongue understands a human tongue — catches
  anyone re-adding a Draconic↔human bridge). Verified it compiles under `UNIT_TESTS` (only the pre-existing
  `silverscale` errors remain).

## C. Phase 3 — content gating: paper authoring (#1, paper-only)
**The keystone gap closed.** Phase 1 (Session 5) built the *reader* gate (`written_language` +
`reader_legibility`/`scramble_for_reader`), but `written_language` was only ever set on premade docs —
players couldn't author a gated document, so the whole origin/register layer had ~3 documents of payoff.
Modeled on Baystation's legacy `paper.dm` (dropped in as reference at `code/modules/language/paper.dm`).
**Decisions: auto-tag + change selector · add `has_written_form` · paper-only (consoles deferred).**
- **`has_written_form` flag** on `/datum/language` (default TRUE; FALSE on **ashic/Vraksh** (gesture),
  **machine/EAL** (tonal), **sonus** (psychic), **monkey**, **metalanguage**). Antag tongues are excluded by
  their null `chargen_category`.
- **Auto-tag + lock at first write** (`paper.dm::ui_act` `add_text`): the first body write on a *blank* sheet
  stamps `written_language` with the writer's language and locks it (premade/universal sheets — content set
  in `Initialize`, not `add_text` — are untouched). Resolution via new helpers `language_is_writable()`,
  `writable_known_languages()`, `default_write_language()` (active spoken tongue if writable, else first
  known writable, else null = stays universal).
- **`set_written_language` ui_act** (selector backend): rejects once content exists (locked); validates the
  language is real, **writable**, and one the writer **understands** (no crafted-action escapes).
- **Per-viewer `ui_data`** fields: `can_set_language`, `write_language`/`write_language_path`,
  `writable_languages`, `is_language_gated`, `reader_language_name` (named only if the viewer fully reads it).
- **tgui** (`PaperSheet.tsx`): a `PaperLanguageBar` — a "Writing in: ⟨▼⟩" dropdown while blank, a "Written in
  X" tag once locked, and a read-side "Written in ⟨X / an unfamiliar language⟩" label for gated docs
  (universal docs show nothing). Added `PaperContext` fields + `WritableLanguage` type + `Dropdown` import.
- **Reader side reused unchanged** — auto-tagging simply makes the existing gradient gate (incl. Phase-1's
  field scrambling) fire for player paperwork.

## D. New / changed files (Session 6)
| Area | Files |
|---|---|
| Phase 1 fixes | `client/preferences/middleware/languages.dm` (CSL `LANGUAGE_ALL`, Ashwalker `origins_for_species`), `__DEFINES/language.dm` (`language_origin_choices_lizard_ash`), `jobs/job_types/_job.dm` (`grant_origin_language` re-validate), `paperwork/paper.dm` (field scramble), `mob/dead/new_player/new_player.dm` (alert text), `language_design_compendium.md` (supersession banner + markers) |
| Phase 2 matrix | `language/{common,aurin,uncommon,indolic,dredge,driftspeak,draconic,ashic}.dm` (band tags + Draconic↔Aurin removal + reframes), `__DEFINES/language.dm` (`LANGUAGE_WEB_*`), `unit_tests/language_web.dm` (`language_web_model`), `language_design_compendium.md` (matrix + legend + lizard tables) |
| Phase 3 authoring | `language/_language.dm` (`has_written_form`), `language/{ashic,machine,sonus,monkey,metalanguage}.dm` (flag FALSE), `paperwork/paper.dm` (helpers + `add_text` auto-tag + `set_written_language` + `ui_data`), `tgui/.../interfaces/PaperSheet.tsx` (`PaperLanguageBar` + types) |

## E. Still open after Session 6 (carry-over for the next session)
- **#1 console gate — still deferred.** Only realistic at the **coarse panel level** ("the interface is in
  Indolic"): consoles have no shared tgui text chokepoint (each has bespoke `ui_data` + template). A hard-ish
  wall vs. the document gradient — needs a UX decision (suggest a ~40% limp-through to stay on-philosophy).
- **#1 document tagging (Phase-3 §6 NOT done).** Picking which premade/map docs get which register is lore
  judgment, left for the user. Note the gate only meaningfully bites for **Indolic** (academic) and the
  **lizard registers** — Solbind is broadcast-universal, Dredge ~passable to all humans (Aurin→Dredge 40).
- **#5 non-lizard species origins — parked.** Moth/Ethereal/Plasmaman/**IPC** are funneled into the *human*
  origin list, and `grant_origin_language`'s `ishuman` gate **fires on IPCs** (`/datum/species/ipc` is a
  carbon human). Needs per-species lore + a synthetic skip.
- **`language_transfer.dm` `silverscale` CI blocker — still unfixed.** Fails the `UNIT_TESTS`/CI build (the
  normal build is clean). **Fix before opening the PR.** The new `language_web_model` test is clean.
- **23-yr-window desc sweep** (optional lore pass — many descs still cite it); placeholder language icons;
  DB column/schema bump for `alternate_languages` (origin needs none).
- **In-game verification (none done — DM/TS compile only):** Phase-3 paper authoring end-to-end (blank human
  sheet → auto-Aurin, readable by humans; selector → Indolic gibberish to non-scientists; lizard Draconic
  unreadable to humans; Vraksh absent from the selector; lock after first ink; photocopy stays gated). Plus
  the Session-5 carry-overs (gated-doc markdown rendering, `languages_confirmed` persistence).

---

# ════════════════ SESSION 7 ADDENDUM — 2026-06-30 ════════════════

> Continues `lang-dispersal`. **Closes the #1 hole from the latest hole-analysis:** the Session 4
> Solbind→Aurin switch was only applied to humans + lizards, so every *other* roundstart-playable species
> still anchored on Solbind and understood the now-Aurin-speaking crew at only **common→aurin = 45%** — a
> silent, unchosen, asymmetric half-deafness for ~⅔ of the playable species. Fix mirrors the lizard model
> (species keeps its own tongue, learns **Aurin** as the full-fluency contact dialect). DM compiles clean:
> **0 errors, 2 warnings**. This addendum is current source of truth where it conflicts with §0–H / Sessions 3–6.

## Decision (user-confirmed)
- **Full lizard parity:** each own-language species **defaults to *speaking* its own tongue** (`primary_language`),
  and learns **Aurin** at full fluency for the crew. So they're mutually intelligible with the Aurin majority
  *once speaking Aurin*, but — exactly like a lizard defaulting to Draconic — their default tongue is **not**
  understood by the human crew (one-way "switch to `,2` Aurin to be heard" friction is intended, not a bug).
- **IPCs join the Aurin in-group** (drop the vestigial Sertan grant). Synthetics default to beeping **Machine**.

## What changed (`_language_holder.dm`)
Each holder dropped the redundant **Solbind** (now understood ~85% via Aurin) and gained **Aurin** + a
`primary_language`:

| Holder (species) | Now grants | `primary_language` (spoken default) |
|---|---|---|
| `moth` | aurin + moffic | Moffic |
| `ethereal` | aurin + voltaic | Voltaic |
| `oozeling` | aurin + slime | Slime |
| `apid` | aurin + apidite | Apidite |
| `skeleton` (Plasmaman, Skeleton) | aurin + calcic | Calcic |
| `diona` (Diona, Pumpkin, nymph) | aurin + sylvan | Sylvan |
| `psyphoza` | aurin + sonus + sylvan | Sonus |
| **new** `synthetic/ipc` (IPC) | aurin + machine | Machine |

- **`synthetic/ipc` is a NEW subtype** — the **base `synthetic` holder is the `initial_language_holder` for
  actual silicons (AI, cyborgs, bots)** and was left untouched (they keep Solbind, don't beep by default). Only
  the IPC *species* points at the subtype; it stays a `/synthetic` subtype so `names.dm`'s `istype()` synthetic
  name-gen still fires. Android (not roundstart) deliberately left on base `synthetic`.
- Plasmaman/Calcic and IPC/Machine still resolve their spoken default through the body gate (bone tongue can't
  form Aurin; that's fine — Aurin is *understood*, comprehension is what the fix restores).
- **Lizards/Humans/Felinids unchanged** — already on this model (the reference).

## Lock + verify
- New `/datum/unit_test/species_crew_intelligibility` (`unit_tests/language_web.dm`): every
  roundstart-eligible species must comprehend Aurin ≥ `LANGUAGE_FIT_NATIVE_THRESHOLD` (70) — catches any future
  holder edit that re-opens the 45% wall. Tests the *outcome* (Aurin comprehension), not the mechanism.
- IPC species → `species_language_holder = /datum/language_holder/synthetic/ipc` (`species_types/IPC.dm`).

## Still open after Session 7

**▶ Next session — start here (two follow-ups raised this session, deferred by choice, not yet done):**
1. **Restore Psyphoza's learnable slot** — they have 3 required tongues (aurin+sonus+sylvan) ⇒ **zero learnable
   chargen slots** (hole #3). Drop Sylvan from `/datum/language_holder/psyphoza` (`_language_holder.dm`) if they
   should keep a slot, like every other species. It's a real capability change (lose plant-speak), so it was left
   for a deliberate call. (IPC already dropped to 2, so IPC is fine.)
2. **Synthetic-only origin list** — fixes hole #6. AUTO IPCs now correctly default to Machine, but IPCs are still
   offered the *human* origin list (`origins_for_species`, `middleware/languages.dm`), so an explicit pick (e.g.
   Indol→Indolic) makes a robot default-speak a human tongue. Add a synthetic origin list (just AUTO) +
   branch in `origins_for_species`, and/or a synthetic skip in `grant_origin_language` (`_job.dm`).
- **Auto-tagged handwriting tax (hole #2) is now broader, by design:** with non-humans defaulting to their own
  tongue, a hand-written note auto-tags to that tongue (Moffic/Voltaic/…), so cross-species paperwork is
  unreadable unless written in a shared tongue. This is the intended parity friction, but watch for complaints.
- Lore: descs for these species don't yet mention Aurin (placeholder, like the lizard rework). `speaking_machine`
  (vending machines) still grants the kin-only Draconic. In-game verification of the new defaults not yet done.
