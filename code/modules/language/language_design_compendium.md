# BeeStation Language System — Design & Lore Compendium

> Aggregated 2026-06-27. This single document is a **verbatim, uncompressed** concatenation of every
> planning / lore / reference markdown that existed for the language overhaul, gathered here so
> there is one place to read. Nothing has been summarised or edited; each section below is the
> exact content of its original file, under a banner naming that file. Internal cross-links that
> used to point between these files (e.g. `[language_assignment.md](language_assignment.md)`) now
> simply refer to the corresponding **SOURCE** section within this compendium.
>
> Layout: Part 1 is BeeStation's own design + lore (what we built). Part 2 is the Baystation
> reference docs that were used as *inspiration only* (codebase-agnostic descriptions of Bay's
> system; we did not copy them).

## Contents
- Part 1 — BeeStation design & lore
  - SOURCE: code/modules/language/human_languages_lore.md
  - SOURCE: code/modules/language/language_assignment.md
  - SOURCE: code/modules/keybindings/naming_guidelines.md
- Part 2 — Baystation reference (inspiration, not copied)
  - SOURCE: code/modules/keybindings/language_system_overview.md
  - SOURCE: code/modules/keybindings/language_lore.md
  - SOURCE: code/modules/keybindings/language_assignment.md
  - SOURCE: code/modules/keybindings/language_picker_ui.md

---

> # ⚠ SUPERSEDED IN PLACES — READ THIS FIRST
> This compendium is a **verbatim historical aggregation** of the early planning docs, kept for the
> fiction and rationale. Sessions 3–5 (recorded in
> [LANGUAGE_OVERHAUL_HANDOFF.md](LANGUAGE_OVERHAUL_HANDOFF.md), which is the **current source of
> truth**) reversed several things below. Where they conflict, the handoff wins:
>
> - **Draconic is the colony lizards' in-group / kin tongue, NOT a "contact-creole."** Lizards speak
>   lizard-inflected **Aurin** with outsiders and switch to Draconic for kin. (Affects the "Setting in
>   one paragraph", the "diglossia" frame, and the "Draconic — the contact-creole" heading below.)
> - **The hearth-tongue's in-game display name is "Vraksh"** (the holdouts' autonym). The typepath is
>   still `/datum/language/ashic` and the file is still `ashic.dm`, so the doc's "Ashic" still names the
>   right datum — just read it as the codename, not the displayed name.
> - **The "no per-job language" principle is REVERSED.** Languages now flow from a per-character
>   **origin/background** pref (explicit pick) or the **species primary** (AUTO), with the assigned
>   job's *register* as reference data + a weak understand-only "limp-through" grant. (Affects §1's
>   pipeline note and the "no per-job language list" key points.)
> - **The `/datum/culture` + age-dial "Future" sections are superseded** by the shipped origin pref
>   (`/datum/preference/choiced/origin`) — a lightweight one-dropdown background picker, not a Culture
>   data layer. The lore in those sections still drives the origin → language map.
> - **STILL TRUE and now enforced:** "Ashic earned-not-bought protects its holdout meaning" (§5). The
>   Ashwalker origin is offered only to the Ashwalker species, not to every lizard.

---


# ════════════════ PART 1 — BeeStation design & lore ════════════════



===============================================================================
  SOURCE FILE: code/modules/language/human_languages_lore.md
===============================================================================

# Human & Lizard Languages — Lore

A lore companion for the BeeStation language web. It covers the human "common" family and the
two lizard tongues, the fiction behind each, and the mutual-intelligibility links between them.

> **Status:** proposed / tweakable. Most of the underlying setting is itself flagged "not yet
> intended for game content" on the wiki, so names here are placeholders open to change. The
> *mechanics* (which datum partially understands which, and by how much) are independent of the
> names, so the fiction can be revised without touching code beyond `desc` strings.

All percentages below use the engine's convention: **"if you know language X, you understand
language Y at N%"** (stored on X's `mutual_understanding`, taken as the best available source,
then weighted per-word by how common each English word is — so you reliably catch common
connective words and lose the rare nouns).

---

## Setting in one paragraph

Humanity's home is the **Geminae** system (homeworld **Tellune** / "Earth"; its moon **Seta**
seats the **Tellune Government**). **Auri** is a remote frontier system orbiting Geminae, reachable
only through a transit window that opens **once every ~23 years** — so the Auri colonies, and the
volcanic world **Cinis ("Lavaland")** where the station sits, develop in long isolation under
corporate rule (**Nanotrasen**, **Auri Private Security**, **Acrux Medical**, **Nakamura
Engineering**, and the cargo monopoly **Eclipse Express**). That 23-year isolation is the engine
of linguistic drift on the human side; on the lizard side, the divide between integrated and
feral tribes does the same work.

**Timescale matters for consistency.** Geminae is the old, settled core — Tellune and its many
tongues, the *oldest* colony **Indol**, the long-worked gas-rigs of **Ceti** — so its languages run
deep (Solbind, Sertan, Indolic, Dredge). Auri is a *recent* gold-rush frontier, so its human
speech (**Aurin**, the Auri mines) is young and only lightly drifted, and the lizard creole
**Draconic** is a fast colonial creole barely a generation or two old. The only *old* thing on
Cinis is the lizards themselves and their unbroken hearth-tongue, **Ashic**.

---

## The human family

A constructed standard, a drifted frontier dialect, two natural regionals, and two pidgins —
inspired by the structure of older SS13 language sets but grounded in BeeStation's own places.

### Solbind — the standard (`/datum/language/common`, key `,0`)
The standardised tongue of Tellune and its government; humanity's administrative and trade
lingua franca, carried to every colony and out to the frontier. If a human speaks one language,
it is this. *(English/Mandarin-derived syllables, inherited from the old "Galactic Common".)*

### Aurin — the frontier dialect (`/datum/language/aurin`, key `,2`)
Solbind as it drifted across the Auri colonies during the long gaps between transit windows.
Clipped and quick, full of station and dock jargon, but still **~85% mutually intelligible with
Solbind both ways** — a true dialect, not a separate language.

### Sertan — Old-Earth heritage (`/datum/language/uncommon`, key `,!`)
A naturally-evolved tongue that survived Solbind's standardisation back on Tellune, still **widely
spoken** across the homeworld's billions. Moderately related to Solbind (~20%). *(Name is a
placeholder.)*

### Indolic — the oldest colony (`/datum/language/indolic`, key `,3`)
The conservative dialect of **Indol**, humanity's first off-world foothold. It diverged early
during Indol's pioneer isolation and kept heavier, older forms; being a *colony dialect* of human
speech it sits closer to Solbind (~30%) than the foreign Sertan does.

### Dredge — the miners' cant (`/datum/language/dredge`, key `,5`)
A rough working pidgin grown on the long-worked gas-rigs of **Ceti** (Geminae core), then carried
out to the **Auri** mines by migrant crews on the transfer fleet. Built off Solbind, so it's broadly
understood, but speaking it marks you as a hand, not a suit. Because Ceti draws labour from across
Geminae, it also picks up scraps of Sertan and Indolic. Its speakers track the standard better
(Dredge→Solbind 70) than standard speakers track it (Solbind→Dredge 25).

### Driftspeak — the spacer fallback (`/datum/language/driftspeak`, key `,7`)
The bare-bones pidgin of the long-haul spacer crews who ride out the 23-year transfer windows —
Eclipse Express cargo runs, contract haulers, and the mixed crews of the transit fleet. Deliberately
tiny and regular, it grants a flat ~25% understanding to every proper human tongue (and 35% to
Dredge) — the last resort when two spacers share no language and have no autotranslator.

### Beachtongue (`/datum/language/beachbum`)
Unchanged drug-induced oddity; retained for gameplay. Knowing it grants partial Solbind (50)
and Sertan (33).

### Human intelligibility matrix (know ↓ → understand →)

> **Current (live) values — supersedes the first-pass table that used to sit here.** The design
> contract is the **band model** anchored in `common.dm` (and enforced by
> `/datum/unit_test/language_web_model`). Core principle: **comprehension ≈ modest structural overlap
> plus a large Solbind broadcast-exposure bonus** — which is why every register understands Solbind well
> while Solbind understands little back, and why Aurin's ~85% structural closeness to Solbind does
> *not* let Sertan/Driftspeak speakers catch Aurin (they lack the broadcast exposure).

| know ↓ \ understand → | Solbind | Aurin | Sertan | Indolic | Dredge | Drift |
|---|---|---|---|---|---|---|
| **Solbind** | — | 45 | 15 | 20 | 25 | 20 |
| **Aurin** | 85 | — | — | 20 | 40 | 30 |
| **Sertan** | 60 | 15 | — | 10 | 20 | 25 |
| **Indolic** | 70 | 20 | 10 | — | 20 | 25 |
| **Dredge** | 70 | 40 | 25 | 25 | — | 35 |
| **Driftspeak** | 55 | 25 | 25 | 25 | 35 | — |

**Bands:** dialect→standard 85 (Aurin→Solbind) · broadcast inbound 55–70 (any register→Solbind) ·
broadcast outbound 15–45 (Solbind→a register) · adjacent register 35–40 (same social stratum, e.g.
Aurin↔Dredge frontier-labour) · distant register ~20 (cross-stratum, e.g. academy↔mine) · foreign
heritage 10–15 (Sertan↔non-Solbind) · pidgin flat-bridge (Driftspeak out) flat 25 / +10 sibling
Dredge / 55 Solbind.

The lizard tongues (Draconic/Vraksh) are an **isolated kin island** — no human tongue partially
understands them and they understand no human tongue. Lizards function in the human web purely via
**Aurin, learned as a full second language**, not via shared intelligibility.

---

## The lizard tongues

The lizardpeople call themselves the **Vraksa** ("ash-crossers"); humans just say "lizard". They are
**native to Cinis (Lavaland)** — they evolved there; there is no off-world lizard empire. All Vraksa
clans are communal and nomadic by nature; the divide between them is over the outsider, not
temperament. When Tellune scouts arrived, the **open, trusting clans** engaged, took the lung-graft
to breathe station air, and were absorbed into the colony; the **wary clans** refused and stayed in
the ashfields. The company files the holdouts as **"Ashwalkers"** — a flat rendering of *vraksa* —
and the speech split the same way the people did.

> **Real-world frame:** the two tongues are a **diglossia** — a hearth-tongue and a contact-creole.
> *Ashic : Draconic ≈ a conservative, intact heritage language : a simplified, deferential
> contact-creole* (the conservative-vs-simplified axis of **Icelandic vs. mainland Scandinavian**,
> with the creole's flattening read through colonial-contact pidgins). Ashic kept the archaic grammar,
> the clan-honorifics, and the body-gesture component; Draconic shed the gestures, **collapsed the
> honorific system into one deferential register**, and took on Solbind loanwords.

### Draconic — the contact-creole (`/datum/language/draconic`, key `,o`)
> **SUPERSEDED (see top banner):** Draconic is now a **distinct lizard-family language, sister to Vraksh**
> (the everyday/kin half of the lizard diglossia), **not** a contact-creole and **not** sharing words with
> any human tongue. It understands no human language; the Vraksa reach outsiders through **Aurin learned as
> a second language**. Its `mutual_understanding` is just `{ashic 45}` (lizard kin).

The tongue of the absorbed Vraksa clans: simplified, oxygen-breather-friendly, mostly vocal, heavy
with Solbind loanwords. Its clan-honorifics collapsed into a single flattened deferential register —
the tone you take toward humans and superiors — and its gestures fell away on the cramped colony
decks. It is the lizard language players normally use, and the one that carries a quiet internalised
shame: speaking the hearth-tongue marks you as a holdout, so it is kept for kin. Knowing it grants
partial **Vraksh** (45) — its kin tongue — and nothing of the human tongues.

### Ashic — the hearth-tongue (`/datum/language/ashic`, key `,c`)
The unbroken Cinis tongue of the wary, isolated clans (the "Ashwalkers"): old grammar and vocabulary,
honorific-saturated, **half hiss and half posture** — every word carries clan-standing in particle and
gesture at once. "Ashic" is only the company's file-name for it; the speakers are *vraksa* like all
lizardpeople, just the ones who never took the graft. Isolated from human contact — knowing it grants
partial Draconic (40) and nothing of the human tongues.

**Body-based gating:** speaking Ashic correctly requires lizard anatomy (frill, tail, posture),
so it is restricted to the lizard tongue organ — non-lizards physically cannot form it. (The full
gesture/line-of-sight component is only approximated; the engine has no non-verbal language
concept yet.)

| | Draconic | Vraksh |
|---|---|---|
| **Draconic** | — | 45 |
| **Vraksh** | 40 | — |

The lizard tongues form an isolated kin island: neither understands any human tongue (and no human
tongue understands them). Lizards reach the crew through Aurin, learned as a full second language.

---

## Species associations (body vs. tongue)

| Species | Speaks | Understands | Note |
|---|---|---|---|
| Human | Solbind (+ regional) | Solbind | culture/heritage chooses the regional (future) |
| Felinid (Unope) | Solbind | Solbind | culturally human; cat-tongue accent |
| Slimeperson / Oozeling | Solbind + Slime | Solbind + Slime | culturally human, keeps its own melodic tongue |
| **Plasmaman** | **Calcic only** | Solbind + Calcic | **body-based**: understands the standard but its plasma-bone teeth can only clack |
| **Vraksa** (absorbed) | Solbind + Draconic | both (+ partial Ashic) | open clans; took the lung-graft, joined the colony |
| **Vraksa** (Ashwalker) | **Ashic** | Ashic (+ partial Draconic) | wary holdouts; **body-based + isolated**; blocked from Solbind |

Plasmamen and Ashwalkers are the two body-based showcases: what they *understand* (their language
holder) and what they can physically *speak* (their tongue organ) deliberately differ.

---

## Future: culture layer

> **SUPERSEDED (see top banner):** this shipped as the lightweight **origin** pref
> (`/datum/preference/choiced/origin`) + the per-character language loadout, not a `/datum/culture`
> data layer. The origin → language fiction below still drives that map; the *implementation* differs.

Today these are granted by species + the Bilingual/CSL quirks. The intended next step is a
`/datum/culture` heritage datum that grants a starting language set by origin (e.g. a Tellune-born
human gets Solbind + Sertan; an Auri-frontier human gets Aurin + Dredge; an Indol colonist gets
Indolic). The web above is independent of *how* languages are granted, so the culture layer can
drop in without changing any of this fiction or the intelligibility values.



===============================================================================
  SOURCE FILE: code/modules/language/language_assignment.md
===============================================================================

# Language Assignment & Acquisition (BeeStation)

How a mob ends up knowing the languages it knows on **this** codebase: what's wired today, and
the planned **per-character loadout** model that replaces the bilingual/CSL quirks. Companion to
[human_languages_lore.md](human_languages_lore.md) (the languages and their web) — read that for
*what* the tongues are; this is *how characters get them*.

> **Status:** Sections 1 (current) is real. Sections 2-9 (the loadout model + `/datum/culture`)
> are a **design spec**, not built yet. The good news, called out throughout: the *runtime engine*
> already supports all of it — the missing work is a data layer (cultures) and a chargen UI.

---

## 1. The pipeline today

Languages **stack** from several sources, each tagged with a provenance `source` so it can be
added/removed independently (this is Bee's big advantage — see the `LANGUAGE_*` source defines):

1. **Species baseline** — `species_language_holder` (a `/datum/language_holder` preset) grants the
   default understood/spoken/blocked set (e.g. `/datum/language_holder/lizard` = Solbind + Draconic;
   `/lizard/ash` = Ashic, Solbind blocked). Source: `LANGUAGE_ATOM`/`LANGUAGE_SPECIES`.
2. **Body gate (the tongue organ)** — `get_possible_languages()` decides what you can *physically
   speak*, `languages_native` what you speak without an accent, `say_mod`/`modify_speech` the verb
   and accent. This is Bee's equivalent of Bay's `assisted_langs` / `can_speak_special` /
   `only_species_language`, but per-organ and in one place. (It's how Ashic is lizard-only and
   Plasmamen are Calcic-only.)
3. **Quirks (player extras, today)** — `bilingual` grants one extra language with a chosen
   **fluency** and a **speak/understand** toggle; `csl` makes Solbind a partially-understood second
   language that you **drift out of toward your native tongue under stress**. Source: `LANGUAGE_QUIRK`.
4. **Job / antag / role grants** — granted at equip via `grant_language(..., source = LANGUAGE_CULTIST/…)`.
   Bee has no per-job language list (a Captain and an Assistant of the same origin start the same),
   matching the "no per-job" principle. *(**SUPERSEDED — see top banner:** there is now a per-character
   **origin** pref and a per-job **register** that grants a weak understand-only "limp-through.")*
5. **Runtime** — language manuals ([_language_manuals.dm](_language_manuals.dm)), holoparasites,
   reagents, EMP, mind transfer, etc., each with its own source so it cleans up correctly.

The selectable pool for (3) is `GLOB.uncommon_roundstart_languages`, auto-built from species holders
+ a seeded human-web list (`generate_selectable_species_and_languages()` in `_species.dm`).

---

## 2. The planned model: a per-character language loadout

Replace the bilingual/CSL quirks with language knowledge on **every** character, assembled from:

- **Native set (free, forced)** — from **species** (body baseline + tongue gate) + **culture/origin**
  (your heritage tongue + the imposed standard) + **age** (see §4). Granted at full fluency unless
  age/culture says otherwise.
- **Learned set (player-picked)** — a few extra tongues, **each at a fluency the player chooses**,
  within a budget, drawn only from the *buyable* tier (§5).

Everything routes through the existing `grant_language()` / `grant_partial_language()` with
`source = LANGUAGE_CULTURE`. The pipeline order becomes:
**species → culture (main driver, age-modified) → player-picked learned → job/antag → runtime**,
with a never-languageless safety net at the end.

---

## 3. Partial fluency is first-class (already supported)

Bee scrambles speech **per word, weighted by how common the word is**, so partial knowledge is a
real spectrum, not binary. "Basic human dialect" genuinely means *catch the common words, lose the
nuance*. The primitives all exist today:

- `grant_partial_language(lang, amount, source)` — know a language at any 0–100%.
- fluency tiers already in prefs: `100 / 75 / 50 / 33 / 25 / 10`.
- `language_speakable` toggle — "I can follow it but can't speak it."

So *"a lizard who holds a job on broken Solbind"* = `grant_partial_language(common, 25)`. No new
runtime needed.

---

## 4. Age as an assimilation dial

Age slides a character along the **heritage ↔ standard** fluency gradient — assimilation is
generational, which *is* the colonial lore made mechanical:

- **Young** colony-Vraksa (born after contact): Draconic native **+ near-fluent Solbind**, heritage
  **Ashic fading** (partial).
- **Old** colony-Vraksa (gene-modded as an adult): Draconic native **+ basic Solbind (~25–33)** — the
  "holds a job on broken human dialect" character — but **stronger roots**.
- Same axis for humans (an elder Old-Earth/Sertan speaker who learned Solbind late vs. a Solbind-native kid).

Mechanically, age becomes a modifier on the culture's grants (bumping/cutting the Solbind vs.
heritage fluency).

---

## 5. Gating tiers (keep the barriers)

If everyone could buy partial everything, the language-as-gate gameplay (antag opsec, species
in-groups) collapses. So the language universe is tiered:

| Tier | How you get it | Examples |
|---|---|---|
| **Free / native** | species + culture + age (auto) | your heritage tongue, Solbind |
| **Buyable (learned)** | player-picked at chosen fluency, within budget | the human web (Aurin, Sertan, Indolic, Dredge, Driftspeak), integrated **Draconic**, select alien *trade* tongues |
| **Body-gated** | anatomy via the tongue organ (maybe understood, not speakable) | **Ashic**, **Calcic**, EAL/machine, buzzwords |
| **Role-gated** | granted by role/antag only, never bought | Codespeak, Nar'Sian, Ratvarian, hive tongues |

Keeping **Ashic** earned-not-bought protects its "holdout hearth-tongue" meaning.

---

## 6. Cultures → language sets

The `/datum/culture` data layer (Phase 2). Each declares native/default + a selectable pool:

| Culture / origin | Native (default) | Learnable pool offered |
|---|---|---|
| Tellune Core | Solbind | Sertan |
| Old-Earth / heritage | Sertan (+ Solbind) | Solbind, regionals |
| Indol colonist | Solbind | Indolic |
| Auri frontier-born | Aurin (≈Solbind) | Dredge, Driftspeak |
| Ceti / spacer-stock | Solbind | Dredge, Driftspeak |
| Unope (Felinid) | Solbind | (no heritage tongue) |
| Colony Vraksa | Draconic + Solbind | (Ashic withheld — must be reclaimed) |
| Ashwalker Vraksa | Ashic (blocks Solbind) | basic Draconic |

(Other species — moths/ethereals/apids/psyphoza/diona — each need a culture too, pending their
lore pass.)

---

## 7. What to preserve when the quirks are absorbed

- **CSL's drift-to-native-under-stress** (`translate_parts` at low sanity) — generalise it: anyone
  whose native ≠ Solbind *and* whose Solbind is below a threshold slips into their heritage tongue
  when rattled.
- **understand-only acquisition** — keep as a fluency option (very common in real bilingualism).
- The **never-languageless safety net** — hand the universal fallback if a mob somehow knows nothing
  (Solbind by default; **Driftspeak** is the lore-fit "you've got nothing" pidgin if we want it to
  have a job).

---

## 8. Already built vs. new work

- **Already built (runtime):** partial fluency + frequency-weighted comprehension, the fluency
  tiers, speak/understand toggle, drift-to-native, the sources system, body-gating via the tongue,
  role/antag grants, runtime manuals.
- **New work:** a `/datum/culture` data layer (origins → language sets, age-modified), and a
  **chargen language panel** (the bulk of the effort). The bilingual/CSL prefs are the seed of that
  panel — they already do per-language fluency + speak/understand for one language.

---

## 9. Open decisions

1. **Budget shape** — fixed "N learned" slots vs. **point-buy** where higher fluency costs more
   (lets the lizard spend a little for basic Solbind). Point-buy fits the partial-fluency texture.
2. **Fluency granularity** — reuse the 100/75/50/33/25/10 tiers, or simplify to ~3 (Native /
   Working / Basic) for the chargen UI.
3. **Safety-net language** — Solbind (simple, current) vs. Driftspeak (gives it a role).
4. **Culture vs. species layering** — recommend culture *layers on top of* the species holder
   (species = biological baseline / what the body can do; culture = the cultural tongues), so
   body-swaps and surgery resolve sensibly.



===============================================================================
  SOURCE FILE: code/modules/keybindings/naming_guidelines.md
===============================================================================

This page provides the naming conventions that are enforced as part of the rules

Human and Felinid: Normal human names, the kind that won’t raise an eyebrow if you chose to name your child. This applies to all other races that reference human names. Human names should not include any prefixes nor suffixes.
Apid: Human First name that starts with B, Flower last name. Names that resemble clever bee-puns or names involving buzzing.
Ethereal: First name is any celestial body or name that sounds like one (look into Greek/Roman mythology for inspiration if nothing else), Last name is two capital letters.
IPC: Robotic Acronyms or Model identification numbers consisting of 4-10 Numbers, letters and hyphens. Human names are not appropriate for IPCs.
AIs and Borgs: Robotic Acronyms, Model identification numbers or simple Non-Acronym names provided they are computer or robot related. Human names are not appropriate for borgs or AI.
Lizard: Hyphenated names describing some action, or two part hyphenated names following Ashwalker naming conventions.
Oozeling: First name is almost any color, last name is any human surname ending in "son" (son of), "dottir" (daughter of), or "bur" (child of).
Moth: Latin (or psuedo-latin) species name OR a Single word object, concept or event of some special significance to the character. Names containing "Moth" or "Lamp" are not permitted.
Plasmaman: First name is or sounds like a periodic table element, last name is Roman Numerals.
Psyphoza: Latin first name and a mushroom species, preferable scientific, as the surname.
Dionae: A phrase describing a formative (I.E. spiritual or heavily emotional) action by the dionae.


# ════════════════ PART 2 — Baystation reference (inspiration only) ════════════════



===============================================================================
  SOURCE FILE: code/modules/keybindings/language_system_overview.md
===============================================================================

# Language System Overview

A codebase-agnostic description of how spoken/written languages work in this
BYOND/DM codebase. Written for someone who knows DM but has never seen this repo,
with the intent of comparing it against another codebase.

Primary files:

| File | Purpose |
|------|---------|
| `code/modules/mob/language/language.dm` | The `/datum/language` base type, scrambling, formatting, mob language helpers |
| `code/__defines/languages.dm` | Language name `#define`s and flag bitfields |
| `code/modules/mob/language/human/*.dm` | Human "common" languages |
| `code/modules/mob/language/alien/*.dm` | Xeno / synthetic / antag languages |
| `code/modules/mob/language/generic.dm` | Noise + sign language |
| `code/modules/mob/language/synthetic.dm` | Robot/drone/machine languages |
| `code/_helpers/global_lists.dm` | Builds the `all_languages` and `language_keys` global lookups |
| `code/modules/mob/hear_say.dm` | Listener-side display + scrambling decision |
| `code/modules/mob/say.dm` | `parse_language()`, `say_understands()` |
| `code/modules/mob/living/default_language.dm` | Per-mob default language picking |
| `code/modules/codex/categories/category_languages.dm` | In-game encyclopedia entries |
| `maps/torch/language/`, `packs/legion/legion_language.dm` | Per-map / per-pack overrides and additions |

---

## 1. The `/datum/language` type and its vars

Languages are **datums**, one singleton instance per language type, instantiated
at world init and stored in the global `all_languages` list keyed by `name`.

```dm
/datum/language
	var/name = "base language"        // Fluff/display name, also the lookup key
	var/desc = "..."                  // Long description shown in 'Check Languages' / Codex
	var/speech_verb = "says"          // verb for normal sentences
	var/ask_verb = "asks"             // verb when sentence ends in '?'
	var/exclaim_verb = "exclaims"     // verb when sentence ends in '!'
	var/whisper_verb                  // optional; falls back to speech_verb + "quietly/softly"
	var/list/signlang_verb = list("signs", "gestures") // emotes for NONVERBAL / SIGNLANG langs
	var/colour = "body"               // CSS class applied to the spoken text in chat
	var/key = ""                      // single character used to select the language, e.g. ',o'
	var/flags = 0                     // bitfield, see below
	var/native                        // if set, non-native speakers have trouble speaking it
	var/list/syllables                // pool of fake syllables used to scramble speech
	var/list/space_chance = 55        // % chance of a space between scrambled syllables
	var/machine_understands = 1       // whether machines can parse/understand it
	var/shorthand = "???"             // short tag shown in chat, e.g. 'ZAC'
	var/list/partial_understanding    // name => % per-word comprehension (mutual intelligibility)
	var/warning = ""                  // shown in setup UI (e.g. "auto-given if no languages")
	var/hidden_from_codex             // if set, no Codex entry
	var/category = /datum/language    // root type; instances whose type == category are abstract
	var/has_written_form = FALSE      // whether the language can be written (paper, etc.)
	var/list/scramble_cache = list()  // per-language LRU cache of scrambled words
```

Key procs on the datum:

- `scramble(input, list/known_languages)` — turns a sentence into gibberish for a
  listener who doesn't understand it. **This is where mutual intelligibility is
  applied** (see §3).
- `scramble_word(input)` — produces a fake word of roughly the same length from
  `syllables`; falls back to `stars()` (censor-style `****`) if no syllables.
  Results are cached (`SCRAMBLE_CACHE_LEN = 20`) so the same word scrambles
  consistently within a short window.
- `format_message / format_message_plain / format_message_radio` — wrap the text
  in `<span>` CSS classes (`colour`) and the speech verb for display.
- `get_spoken_verb(msg_end)` — picks speech/ask/exclaim verb based on trailing
  punctuation.
- `get_random_name(...)` — generates a species-appropriate random name from
  `syllables` (overridden by many languages, e.g. Diona poetic names, AI names).
- `broadcast(...)` — used by HIVEMIND languages to message all understanders
  regardless of distance.
- `can_speak_special(mob)` / `check_special_condition(mob)` — hooks for languages
  that require an organ or condition (e.g. Vox needs a hindtongue organ).

### Mob-side vars (`mob_defines.dm`)

```dm
var/list/languages = list()    // language datums this mob knows
var/species_language = null    // species' fallback default
var/only_species_language = 0  // if set, mob can only *speak* its species language
```

Living mobs additionally have `var/datum/language/default_language` — the language
used when the player doesn't prefix a specific one.

---

## 2. Language flags

Defined in `code/__defines/languages.dm` as a bitfield:

```dm
#define WHITELISTED  1   // Only selectable if the player is whitelisted for it
#define RESTRICTED   2   // Only via spawning or admin (never freely selectable)
#define NONVERBAL    4   // Significant non-verbal component; garbled without line-of-sight
#define SIGNLANG     8   // Fully non-verbal; shown as emotes to those who understand
#define HIVEMIND     16  // Broadcast to all mobs who know it, any distance
#define NONGLOBAL    32  // Not added to the general selectable languages list
#define INNATE       64  // Everyone understands/speaks it (used for audible emotes)
#define NO_TALK_MSG  128 // Suppress "X talks into the radio" message
#define NO_STUTTER   256 // Immune to stutter/slur/speech-impediment effects
#define ALT_TRANSMIT 512 // Not sound- or vision-based (intended for Rootspeak; partly TODO)

#define MAX_LANGUAGES 3  // Max *selectable* extra languages a character can pick in setup
```

---

## 3. Mutual intelligibility

Two distinct, independent mechanisms exist.

### A. Full comprehension (binary)

A mob understands a language fully if any of the following are true
(`say_understands()` in `say.dm`):

- the mob is **dead** (ghosts/observers understand everything),
- the mob has `universal_speak` / `universal_understand`,
- the language has the **INNATE** flag,
- the language datum is in the mob's `languages` list.

If understood, the real text is shown. If not, `hear_say.dm` calls
`language.scramble()` to render gibberish.

### B. Partial understanding (`partial_understanding`)

Each language may list other languages it can *partially* decode, as
`name => percent`. This is the "mutual intelligibility" system and it is
**per-word and probabilistic**, applied inside `scramble()`:

```dm
/datum/language/proc/scramble(input, list/known_languages)
	var/understand_chance = 0
	for(var/datum/language/L in known_languages)
		if(LAZYACCESS(partial_understanding, L.name))
			understand_chance += partial_understanding[L.name]
	// for each word: if !prob(understand_chance) -> replace with a fake word
```

Important properties:

- The percentages are summed across **every language the listener knows** that
  appears in the spoken language's `partial_understanding` list. So knowing
  several related languages stacks comprehension.
- It is evaluated **per word**, so a partially-understood sentence comes through
  with some real words and some gibberish words mixed together.
- It is **directional/asymmetric**: the list lives on the *spoken* language and
  references the *listener's* known languages. Pairs are not guaranteed
  symmetric (though many are roughly reciprocal).
- It only matters when the listener does **not** fully understand the language
  (full understanding short-circuits before scrambling).

### Which languages have mutual intelligibility

Only the human/common family and the two Unathi dialects define
`partial_understanding`. Values below are "% per-word comprehension granted to a
listener who knows the row language, when the column language is spoken"
— read as **spoken language → (listener knows) → chance**.

Human common languages (`partial_understanding` on the *spoken* language):

| Spoken ↓ \ Listener knows → | ZAC (Euro) | Yangyu | PSA (Arabic) | Dehlavi | Iberian | Pan-Slavic | Selenian | Gutter | Spacer |
|---|---|---|---|---|---|---|---|---|---|
| **Zurich Accord Common** | — | 5 | 5 | 5 | 30 | 5 | 85 | — | 20 |
| **Yangyu** | 5 | — | 5 | 5 | — | — | 10 | — | 20 |
| **Prototype Std Arabic** | 5 | 5 | — | 10 | — | — | 5 | — | 20 |
| **New Dehlavi** | 5 | 5 | 10 | — | — | — | 5 | — | 20 |
| **Iberian** | 30 | — | — | — | — | — | 15 | — | 20 |
| **Pan-Slavic** | 5 | — | — | — | — | — | 10 | — | 20 |
| **Selenian** | 85 | 15 | 5 | 25 | 15 | 5 | — | — | 20 |
| **Gutter** | 75 | 20 | 10 | 10 | 30 | 30 | 15 | — | 35 |
| **Spacer** | 25 | 25 | 25 | 25 | 25 | 25 | 25 | 35 | — |

Notable takeaways:
- **Selenian ↔ Zurich Accord Common** are near-mutually-intelligible (85% each
  way) — Selenian is an informal dialect of ZAC.
- **Iberian ↔ ZAC** are moderately intelligible (30% each way).
- **Gutter** (a pidgin) leans heavily on ZAC (75%) and picks up bits of
  everything else.
- **Spacer** is a fallback pidgin: 25% to every human common + 35% to Gutter,
  designed so two humans with no shared language can still half-communicate.

Non-human pairs:

| Spoken | Listener knows | Chance |
|--------|----------------|--------|
| Sinta'unathi | Yeosa'unathi | 20% |
| Yeosa'unathi | Sinta'unathi | 20% |

No other languages (Skrellian, Vox, EAL, cult, hivemind langs, etc.) define any
partial understanding — they are all-or-nothing.

---

## 4. How languages are displayed

### Selecting a language to speak

A speaker prefixes their message with the **language prefix key** (default `,`)
plus the language's single-character `key`. E.g. `,o Hello` speaks Sinta'unathi
(key `"o"`). `parse_language()` in `say.dm` reads this prefix; the audible-emote
prefix maps to the special `Noise` language. Lookup tables:

- `all_languages` — `name => datum`
- `language_keys` — `key char => datum` (built in `global_lists.dm`, skips NONGLOBAL)

If no prefix is given, the mob's `default_language` (or species default) is used.

### Listener-side rendering (`hear_say.dm` + `format_message`)

1. If the listener doesn't understand and the language is known, the text is
   scrambled; if there's no language at all, it's `stars()`'d.
2. Deaf/blind/no-line-of-sight conditions can further degrade or block it
   (NONVERBAL needs line of sight; SIGNLANG is shown as emotes via
   `say_signlang`).
3. The verb shown depends on the player's `language_display` client preference:
   - **OFF** — just the verb (`says, "..."`)
   - **SHORTHAND** — `says (ZAC), "..."`
   - **FULL** — `says in Zurich Accord Common, "..."`
   (The hint is auto-suppressed when the listener speaks the language as their
   own default, and for ghosts via their own ghost prefs.)
4. `format_message()` wraps the quote in CSS spans using the language's `colour`
   class, so each language can be visually color-coded in chat. `noise` and
   radio variants format differently (`format_message_radio`, etc.).

### Checking known languages

`/mob/verb/check_languages()` ("Check Known Languages", IC verb) shows a browser
window listing each non-NONGLOBAL known language with its name, shorthand, the
key to type it, and description. The living-mob override also lets the player set
or reset their default language via topic links.

### Codex

`category_languages.dm` auto-generates an in-game encyclopedia entry per language
(unless `hidden_from_codex`), including the key, behavioral flags, shorthand, and
a **scrambled example sentence** so players can see what it "sounds" like.

---

## 5. How a mob acquires languages

- **Character setup / culture**: `02_language.dm` builds the selectable set from
  the character's chosen cultures. A culture's `get_spoken_languages()` are
  *free* (auto-granted); its `secondary_langs` are *selectable*; plus any
  `WHITELISTED` language the player is whitelisted for. `MAX_LANGUAGES` caps how
  many extra ones can be chosen.
- **Species**: `species_language` provides a fallback default; `assisted_langs`
  on a species lists languages it can only speak with a special organ (e.g. a
  translator/tongue). `only_species_language` restricts a mob to speaking just
  its own.
- **Runtime**: `add_language(name)` / `remove_language(name)` add/remove datums
  from `mob.languages`; `transfer_languages(source, target, except_flags)` copies
  them (used for mind transfers, etc.). Some equipment (translator implants,
  headsets for binary) grants languages.

---

## 6. Full language catalogue

Names are the `#define`s from `code/__defines/languages.dm`. "Key" is the
character typed after the language prefix.

### Human "common" languages (selectable, WHITELISTED where noted)

| Language (`#define`) | Name | Key | Shorthand | Notes / lore |
|---|---|---|---|---|
| `LANGUAGE_HUMAN_EURO` | Zurich Accord Common | `1` | ZAC | WHITELISTED. Constructed lingua franca of Sol, from a 2119 Zurich conference of European & African universities; default common tongue of the SCG. Written form. |
| `LANGUAGE_HUMAN_CHINESE` | Yangyu | `2` | YngYu | Simplified Mandarin in Latin script; trade language across Asia & parts of Africa. Written form. |
| `LANGUAGE_HUMAN_ARABIC` | Prototype Standard Arabic | `4` | PSA | "Prototype Standard Arabic," a constructed replacement for regional Modern Standard dialects, popularized by Pan-Arab space exploration. Written form. |
| `LANGUAGE_HUMAN_INDIAN` | New Dehlavi | `3` | Dehv | Latin-script reunification of Hindi & Urdu; rapid popular adoption. Written form. |
| `LANGUAGE_HUMAN_IBERIAN` | Iberian | `5` | Iber | Naturally evolved (late 21st c.) from Spanish/Portuguese closeness. Written form. |
| `LANGUAGE_HUMAN_RUSSIAN` | Pan-Slavic | `r` | Slav | Official language of the Independent Colonial Confederation of Gilgamesh (orig. United Slavic Confederation, 2122). Written form. |
| `LANGUAGE_HUMAN_SELENIAN` | Selenian | `7` | Sel | Informal dialect of Zurich Common from Luna's first city; `space_chance = 100`. Near-intelligible with ZAC. Written form. |

### Human misc (pidgins/fallbacks)

| Language | Name | Key | Shorthand | Notes |
|---|---|---|---|---|
| `LANGUAGE_GUTTER` | Gutter | `t` | GT | Crude Pluto pidgin (`speech_verb = "growls"`); leans on ZAC. Written form. |
| `LANGUAGE_SPACER` | Spacer | `j` | Spc | Fallback pidgin auto-given to mobs spawning with no languages (except on the Torch map, where Euro is given). Written form. |
| `LANGUAGE_PRIMITIVE` | Primitive | (none) | Ook | Monkey/primate speech ("Ook ook ook"); hidden from Codex. Subtype of `/datum/language/human`. |

### Alien / xeno languages (mostly WHITELISTED)

| Language | Name | Key | Shorthand | Notes / lore |
|---|---|---|---|---|
| `LANGUAGE_UNATHI_SINTA` | Sinta'unathi | `o` | UT | Common tongue of Moghes; sibilant hisses. WHITELISTED. Partial w/ Yeosa (20%). Written form. |
| `LANGUAGE_UNATHI_YEOSA` | Yeosa'unathi | `h` | YU | Moghes spoken-word + gesture language; official tongue of the Yeosa clans. WHITELISTED. Partial w/ Sinta (20%). Written form. |
| `LANGUAGE_SKRELLIAN` | Skrellian | `k` | SK | Melodic Skrell language of Qerrbalak; some notes inaudible to humans (`warbles`). WHITELISTED. Written form. |
| `LANGUAGE_ROOTLOCAL` | Local Rootspeak | `q` | RT | Diona instinct language via modulated radio waves, short range. RESTRICTED; `machine_understands = FALSE`. Poetic random names. |
| `LANGUAGE_ROOTGLOBAL` | Global Rootspeak | `w` | N/A | Long-range, low-frequency Diona variant. RESTRICTED + HIVEMIND. |
| `LANGUAGE_ADHERENT` | Protocol | `p` | VP | The Vigil/Adherent's formal "wind chime tone" language; syllables are musical notes; `space_chance = 0`. WHITELISTED. |
| `LANGUAGE_NABBER` | Serpentid | `n` | SD | Giant Armoured Serpentid language understood by both sound and the motion making it. WHITELISTED + SIGNLANG + NONVERBAL + NO_STUTTER. |
| `LANGUAGE_VOX` | Vox-pidgin | `x` | Vox | Common tongue of the Vox Shoal; sounds like shrieking. WHITELISTED; requires a working hindtongue organ (`can_speak_special`); `machine_understands = 0`. Written form. |
| `LANGUAGE_EAL` | Encoded Audio Language | `6` | EAL | Tonal beep/boop language of synthetics & cyborgs; only synthetics may speak it (`can_speak_special`). |

### Synthetic / machine languages

| Language | Name | Key | Shorthand | Notes |
|---|---|---|---|---|
| `LANGUAGE_ROBOT_GLOBAL` | Robot Talk | `b` | N/A | Binary comms net for synthetics. RESTRICTED + HIVEMIND; custom `broadcast()` (cyborgs hear it, others hear "beep beep beep"); consumes cell power on cyborgs. |
| `LANGUAGE_DRONE_GLOBAL` | Drone Talk | `d` | N/A | Drone-only encoded damage-control stream. RESTRICTED + HIVEMIND. |

### Antagonist / special hivemind languages (RESTRICTED)

| Language | Name | Key | Shorthand | Notes |
|---|---|---|---|---|
| `LANGUAGE_CULT` | Cult | `f` | CT | Occult chant language; `space_chance = 100`; `machine_understands = 0`; hidden from Codex. Written form. |
| `LANGUAGE_CULT_GLOBAL` | Occult | `y` | N/A | Cult telepathy. RESTRICTED + HIVEMIND; hidden. |
| `LANGUAGE_ALIUM` | Alium | `c` | AL | Xenomorph-style language; random `speech_verb` chosen at init; hidden. Written form. |
| `LANGUAGE_CHANGELING_GLOBAL` | Changeling | `g` | N/A | Changeling commune; RESTRICTED + HIVEMIND; broadcasts under the changeling's ID. |
| `LANGUAGE_BORER_GLOBAL` | Cortical Link | `z` | N/A | Cortical-borer hivemind; RESTRICTED + HIVEMIND; drains host nutrition to relay. |
| `LANGUAGE_LEGION_GLOBAL` | Nexus Link | `l` | LGN | Long-range Legion link (defined in `packs/legion/`). RESTRICTED + HIVEMIND. |

### Generic / utility languages

| Language | Name | Key | Notes |
|---|---|---|---|
| (`/datum/language/noise`) | Noise | (audible-emote prefix) | Used for audible emotes; RESTRICTED + NONGLOBAL + INNATE + NO_TALK_MSG + NO_STUTTER; hidden. Custom formatting (no quotes). |
| `LANGUAGE_SIGN` | Sign Language | `s` | Deaf/mute sign language; SIGNLANG + NO_STUTTER + NONVERBAL; shown as gestures. Shorthand HS. |

### Abstract root types (not directly speakable)

- `/datum/language/human` — "proto-sapien", the human root (`category = /datum/language/human`).
  Instances whose `type == category` are filtered out of the Codex and treated as
  abstract parents.

---

## 7. Map / pack overrides

Languages can be patched per-map or per-content-pack by re-opening the type:

- `maps/torch/language/human/euro.dm` — overrides Euro's `warning` to note it's
  auto-given when spawning on the Torch.
- `maps/torch/language/human/misc/spacer.dm` — overrides Spacer's warning
  accordingly (Spacer is the no-language fallback *except* on the Torch).
- `packs/legion/legion_language.dm` — adds the Legion "Nexus Link" language.

---

## 8. Lore summary

The fiction divides languages into a few families:

- **Human commons** are mostly *constructed* 21st–22nd century lingua francas
  built to unify regional Earth languages, with **Zurich Accord Common** as the
  Sol-wide standard. Selenian (Luna), Gutter (Pluto pidgin), and Spacer
  (last-resort pidgin) are derivative/informal tongues, which is reflected
  mechanically by their high partial-understanding with ZAC.
- **Alien languages** are tied to species and biology: Unathi hisses
  (two dialects, Sinta/Yeosa), Skrell melodic warbles with inaudible notes,
  Diona radio-wave Rootspeak (local vs. global range), Adherent musical chimes,
  Vox shrieking (needs a special organ), Serpentid combined sound+motion, and
  the synthetic EAL beeps.
- **Synthetic networks** (Robot Talk, Drone Talk) are encoded hivemind comms
  protocols rather than spoken tongues.
- **Antagonist languages** (Cult/Occult, Changeling, Cortical Link, Legion Nexus,
  Alium) are RESTRICTED hiveminds or ritual tongues, granted by role rather than
  chosen, and generally hidden from the Codex.



===============================================================================
  SOURCE FILE: code/modules/keybindings/language_lore.md
===============================================================================

# Languages & Lore

A lore-focused companion to [language_system_overview.md](language_system_overview.md).
This document walks through each language in the setting, what it sounds/looks like
in play, the in-universe fiction behind it, and which peoples/cultures speak it.

All quoted text is the verbatim in-game `desc` from the language datum. Culture
associations come from `code/modules/culture_descriptor/culture/`, where each
culture sets a primary `language`, `additional_langs` (auto-granted), and
`secondary_langs` (selectable).

---

## The human "Great Commons"

In the setting, humanity never settled on one Earth tongue naturally. Instead, a
handful of **constructed** lingua francas were engineered in the 21st–22nd
centuries to unify regional languages, and these spread across Sol with
colonization. They are mechanically grouped as `/datum/language/human` and are
the only family (with the Unathi dialects) that has graded mutual intelligibility.

### Zurich Accord Common — `LANGUAGE_HUMAN_EURO`

> "A constructed language established by a conference of European and African
> research universities convening in Zurich, Switzerland starting in 2119, later
> adopted with little controversy as the lingua franca of the entirety of Sol
> space following the establishment of the SCG."

The setting's **default common tongue**. Shorthand "ZAC", key `1`. On the Torch
map it is the language auto-granted to anyone spawning without one (elsewhere that
fallback is Spacer). Nearly every alien culture lists it as a secondary language —
it is the bridge tongue of known space. Its syllable pool is drawn from real
English/French/German frequency tables, so scrambled ZAC reads like garbled
European text.

### Yangyu — `LANGUAGE_HUMAN_CHINESE`

> "A simplified version of Mandarin written in the Latin script, Yangyu steadily
> rose to prominence as a trade language in the continent, Japan, Korea, as well
> as parts of Africa."

A trade tongue (shorthand "YngYu", key `2`). Latinized Mandarin; its syllables are
pinyin. Lore-wise it is the commercial language of the East-Asian sphere.

### Prototype Standard Arabic — `LANGUAGE_HUMAN_ARABIC`

> "'Prototype Standard Arabic', as it was known during its development as a
> world-wide replacement for the myriad regional dialects of Modern Standard, was
> mostly ignored on Earth until co-operative Pan-Arab space exploration made its
> use attractive. Its use as a liturgical language remains limited."

Shorthand "PSA", key `4`. A constructed standard that only caught on once
Pan-Arab spaceflight made it useful — a recurring theme that these languages
succeed in space rather than on Earth.

### New Dehlavi — `LANGUAGE_HUMAN_INDIAN`

> "Billed as a reunification of the Hindustani languages of Hindi and Urdu in the
> Latin script, New Dehlavi enjoyed very rapid adoption rates among the common
> populace, compared to the other great Earth commons."

Shorthand "Dehv", key `3`. The "people's" common — the one that spread fastest
among ordinary populations rather than by decree.

### Iberian — `LANGUAGE_HUMAN_IBERIAN`

> "One of the few great common Earth languages to come about naturally, this
> language developed in the late 21st century during a historic period of
> closeness between Spain, Portugal and their former colonies."

Shorthand "Iber", key `5`. Explicitly flagged as one of the *few that evolved
naturally* rather than being engineered, born from Spanish/Portuguese/colonial
convergence. Mechanically it retains ~30% mutual intelligibility with ZAC.

### Pan-Slavic — `LANGUAGE_HUMAN_RUSSIAN`

> "The official language of the Independent Colonial Confederation of Gilgamesh,
> originally established in 2122 by the short-lived United Slavic Confederation on
> Earth."

Shorthand "Slav", key `r`. Tied to a specific polity: the Independent Colonial
Confederation of Gilgamesh. The Earth-side state that created it ("United Slavic
Confederation") didn't last, but the language outlived it in the colonies. Many
human cultures in `cultures_human.dm` default to it.

### Selenian — `LANGUAGE_HUMAN_SELENIAN`

> "An informal dialect of Zurich Common that arose from the close confines, mixed
> population, and technical focus of the moon's first city."

Shorthand "Sel", key `7`. A **Lunar dialect of ZAC** — and it shows mechanically:
85% mutual intelligibility with Zurich Accord Common in both directions, plus
bits of every other common (its syllable pool deliberately mixes ZAC, Hindi, and
techno-legalese fragments like "accord", "caveat", "pledge", "pro", "bono").
`space_chance = 100` makes it read as clipped, spaced-out speech.

---

## Human pidgins & fallbacks

### Gutter — `LANGUAGE_GUTTER`

> "This crude pidgin tongue developed on Pluto during its busier days. It is
> common among the lower classes of Pluto... It is considered a crude language by
> many that are 'upper class'."

Shorthand "GT", key `t`. Spoken with a `growls` speech verb. A class-marked Pluto
pidgin — understood broadly (75% off ZAC, plus scraps of everything) because it's
*built* from the commons, but socially looked down on.

### Spacer — `LANGUAGE_SPACER`

> "A rough, informal language used infrequently by humans as a last resort when
> attempts to establish dialogue in more proper languages fail and no
> autotranslators are available."

Shorthand "Spc", key `j`. The **universal human fallback**: it grants a flat 25%
partial understanding to *every* human common (plus 35% to Gutter), so two humans
with no shared proper language can still half-communicate. It is auto-assigned to
any mob spawning with no languages (except on the Torch, which uses ZAC). Almost
every culture lists it as a secondary.

### Primitive — `LANGUAGE_PRIMITIVE`

> "Ook ook ook."

The speech of monkeys/primates (`chimpers`/`screeches`). Hidden from the Codex; a
gameplay/transformation language rather than a cultural one.

---

## Unathi (Moghes)

Two dialects of the reptilian Unathi homeworld, with ~20% mutual intelligibility
between them. Both are `WHITELISTED` and have written forms. Every Unathi culture
(Diamond Peaks, Polar, Desert, Savannah, Salt Swamp, Space, etc.) speaks
Sinta'unathi primary with Yeosa, Sign, ZAC, and Spacer available.

### Sinta'unathi — `LANGUAGE_UNATHI_SINTA`

> "The common language of Moghes, composed of sibilant hisses and rattles. Spoken
> natively by Unathi."

Shorthand "UT", key `o`. Verbs are `hisses`/`roars`. The dominant Moghes tongue;
its syllables are heavy on sibilants (za/az/sh/ss) to read as hissing.

### Yeosa'unathi — `LANGUAGE_UNATHI_YEOSA`

> "A language of Moghes consisting of a combination of spoken word and
> gesticulation. While it is uncommonly spoken in the drier regions, it enjoys
> popular usage as the official tongue of the Yeosa clans."

Shorthand "YU", key `h`. A spoken-plus-gesture language; the official tongue of
the Yeosa clans, regionally tied to wetter areas.

---

## Skrell (Qerrbalak)

### Skrellian — `LANGUAGE_SKRELLIAN`

> "A melodic and complex language spoken by the Skrell of Qerrbalak. Some of the
> notes are inaudible to humans."

Shorthand "SK", key `k`, `WHITELISTED`. Verb `warbles`. The "inaudible notes"
fiction is reflected in its syllables (qr/qrr/xuq/zaoo plus literal `*` and `!`).
Spoken across all the Skrell sub-cultures (Qerr, Malish, Kanin, Talum,
Raskinta...), with Sign/ZAC/Spacer as secondaries.

---

## Diona (Rootspeak)

A non-vocal plant-mind language transmitted as modulated radio waves, split into
two range bands. Diona get poetic auto-generated names (e.g. "To Sleep Beneath the
Void"). The Diona culture speaks Local Rootspeak primary, Global as an additional
language, with ZAC/Spacer/Sign selectable.

### Local Rootspeak — `LANGUAGE_ROOTLOCAL`

> "A complex language known instinctively by Dionaea, 'spoken' by emitting
> modulated radio waves. This version uses high frequency waves for quick
> communication at short ranges."

Shorthand "RT", key `q`. `RESTRICTED`; `machine_understands = FALSE` (it's radio,
not parseable speech). Verbs: `creaks and rustles`.

### Global Rootspeak — `LANGUAGE_ROOTGLOBAL`

> "...This version uses low frequency waves for slow communication at long ranges."

Key `w`, `RESTRICTED | HIVEMIND` — a planet-wide low-bandwidth Diona network: any
Diona who knows it hears it regardless of distance.

---

## Adherents / The Vigil

### Protocol — `LANGUAGE_ADHERENT`

> "The mellifluous wind chime tones of the Vigil's formal shared language."

Shorthand "VP", key `p`, `WHITELISTED`. Verbs `chimes`/`rings`/`peals`. Its
syllables are literal musical-note tokens (`[Ab]`, `[C#]`, `[harmonic]`,
`[choral]`) and `space_chance = 0`, so it renders as an unbroken stream of notes —
a synthetic crystalline people communicating in music.

---

## Serpentid (Giant Armoured Serpentid / "Nabbers")

### Serpentid — `LANGUAGE_NABBER`

> "A strange language that can be understood both by the sounds made and by the
> movement needed to create those sounds."

Shorthand "SD", key `n`, `WHITELISTED | SIGNLANG | NONVERBAL | NO_STUTTER`.
Because it is simultaneously sound and motion, it functions as a sign language
(displayed via emotes: "chitters", "grinds its mouthparts"). Notably it appears in
many *other* species' `assisted_langs` — i.e. you need a special organ to speak it
if you aren't a Serpentid.

---

## Vox (the Shoal)

### Vox-pidgin — `LANGUAGE_VOX`

> "The common tongue of the various Vox ships making up the Shoal. It sounds like
> chaotic shrieking to everyone else."

Shorthand "Vox", key `x`, `WHITELISTED`; `machine_understands = 0`. Verbs
`shrieks`/`creels`/`SHRIEKS`. Mechanically it **requires a working hindtongue
organ** (`can_speak_special` checks `BP_HINDTONGUE`) — humans literally cannot
form it without the organ. Spoken across the Vox Arkship/Salvager/Raider cultures,
who also pick up ZAC, Spacer, Gutter, and Sign for dealing with outsiders.

---

## Synthetics & machines

### Encoded Audio Language (EAL) — `LANGUAGE_EAL`

> "An efficient language of encoded tones developed by synthetics and cyborgs."

Shorthand "EAL", key `6`. Verbs `whistles`/`chirps`. Only synthetics may speak it
(`can_speak_special` -> `isSynthetic()`). Syllables are beeps/boops/hisses with a
low `space_chance` (10) for a dense tonal stream. IPC/synthetic random names look
like "PBU-432".

### Robot Talk — `LANGUAGE_ROBOT_GLOBAL`

> "Most human facilities support free-use communications protocols and routing
> hubs for synthetic use."

Key `b`, `RESTRICTED | HIVEMIND`. A networked binary channel: it has a custom
`broadcast()` so synthetics/cyborgs hear the real message anywhere on the station,
while nearby non-synthetics only hear "beep beep beep". Using it drains a cyborg's
power cell. Lore-wise it's the open machine comms infrastructure of human
facilities.

### Drone Talk — `LANGUAGE_DRONE_GLOBAL`

> "A heavily encoded damage control coordination stream."

Key `d`, `RESTRICTED | HIVEMIND`, drone-only. A subtype of Robot Talk restricted
to maintenance drones for coordinating repairs.

---

## Antagonist & hidden languages

These are granted by role (spawning/admin), not chosen in setup, and are mostly
hidden from the Codex.

### Cult — `LANGUAGE_CULT`

> "The chants of the occult, the incomprehensible."

Key `f`, `RESTRICTED`. Verbs `intones`/`chants`; `space_chance = 100` and
`machine_understands = 0`. Its huge syllable pool ("nahlizet", "d'raggathnor",
"kla'atu barada nikto"...) is deliberate mock-occult Latin/Lovecraftian chanting.

### Occult — `LANGUAGE_CULT_GLOBAL`

> "The initiated can share their thoughts by means defying all reason."

Key `y`, `RESTRICTED | HIVEMIND`. The cult's telepathic network for initiated
members.

### Alium — `LANGUAGE_ALIUM`

Xenomorph-style language (no in-game desc). Key `c`, `RESTRICTED`. Picks a random
speech verb at init ("hisses"/"growls"/"whistles"...) and builds short random
names from its syllables — chaotic, individualized creature noise.

### Changeling — `LANGUAGE_CHANGELING_GLOBAL`

> "Although they are normally wary and suspicious of each other, changelings can
> commune over a distance."

Key `g`, `RESTRICTED | HIVEMIND`. Broadcasts under the speaker's secret
changeling ID rather than their name, reflecting their mutual paranoia.

### Cortical Link — `LANGUAGE_BORER_GLOBAL`

> "Cortical borers possess a strange link between their tiny minds."

Key `z`, `RESTRICTED | HIVEMIND`. Verb `sings`. Relaying a message **drains the
host's nutrition**, and a weak/unconscious host can't relay at all — a lore-driven
cost baked into the broadcast code.

### Nexus Link — `LANGUAGE_LEGION_GLOBAL`

> "A long-range link between Legion units."

Key `l`, `RESTRICTED | HIVEMIND`. Defined in the Legion content pack
(`packs/legion/legion_language.dm`); the shared network of Legion units.

---

## Utility languages

### Sign Language — `LANGUAGE_SIGN`

> "A sign language commonly used for those who are deaf or mute."

Key `s`, `SIGNLANG | NO_STUTTER | NONVERBAL`. Shown via gesture emotes to those
who can see and understand. Offered as a secondary by nearly every culture, human
and alien alike.

### Noise (`/datum/language/noise`)

Not a spoken language but the carrier for **audible emotes** (screams, laughs).
`RESTRICTED | NONGLOBAL | INNATE | NO_TALK_MSG | NO_STUTTER`, INNATE so everyone
"understands" it. Hidden from Codex.

---

## Lore-to-mechanics cross-reference

| Fiction | Mechanical expression |
|---|---|
| ZAC is the universal bridge tongue | Every alien culture lists it as a secondary; Torch's no-language fallback |
| Selenian is a Lunar dialect of ZAC | 85% mutual intelligibility both ways |
| Spacer/Gutter are pidgins built from the commons | Flat partial understanding across all human commons |
| Skrell notes are inaudible to humans | Syllables include literal `*`/`!`; melodic `warbles` verb |
| Vox can't be spoken without the right anatomy | `can_speak_special` requires the hindtongue organ |
| EAL/Rootspeak aren't true "speech" | `machine_understands = FALSE`; Rootspeak is radio-wave |
| Adherents speak in music | Syllables are musical-note tokens, `space_chance = 0` |
| Serpentid is sound *and* motion | `SIGNLANG | NONVERBAL`; appears in others' `assisted_langs` |
| Borers tax their host to commune | `broadcast()` drains host nutrition |
| Hiveminds (cult, ling, drone, Diona-global, Legion) | `HIVEMIND` flag → range-independent broadcast |
| Restricted/antag tongues aren't player-pickable | `RESTRICTED` flag + `hidden_from_codex` |



===============================================================================
  SOURCE FILE: code/modules/keybindings/language_assignment.md
===============================================================================

# Language Assignment & Role Access

A codebase-agnostic description of **how a mob ends up knowing the languages it
knows**, what each role/species starts with, and which languages are gated.
Companion to [language_system_overview.md](language_system_overview.md) and
[language_lore.md](language_lore.md).

---

## 1. The assignment pipeline

Languages are not assigned from one place — they **stack** from several sources as
a character is built and spawned. Understanding the order matters, because later
steps can override the default and a final safety net guarantees everyone can
speak *something*.

```
Species baseline  ──►  Culture (main driver)  ──►  Player-selected extras
        │                                                   │
        └──────────────►  Job override  ◄──────────────────┘
                               │
                               ▼
                     Antagonist override
                               │
                               ▼
                  Runtime acquisition (implants, transforms, equipment)
```

### Step 1 — Species baseline

A species supplies a *default* cultural profile (which in turn supplies the
default language, see Step 2) and may mark languages as **assist-only** —
speakable only with a special organ:

```dm
/datum/species
	// Languages this species can't speak without an assisted organ (e.g. a tongue/translator)
	var/assisted_langs = list()
```

### Step 2 — Culture (the main driver)

Each character has one or more **cultures**. A culture datum declares the
languages tied to it:

```dm
/singleton/cultural_info
	var/language            // primary language of the culture
	var/name_language       // language used to generate random names
	var/default_language    // what the mob speaks by default (falls back to `language`)
	var/list/additional_langs  // auto-granted on top of the primary
	var/list/secondary_langs   // NOT granted — only made *selectable* in setup
```

At spawn the engine walks the character's cultures and grants the free set, while
also choosing the default language. `secondary_langs` are deliberately excluded
here — they are merely *options*:

```dm
/mob/proc/update_languages()
	var/list/free_languages    = list()
	var/list/default_languages = list()

	for(var/culture in cultural_info)
		if(culture.default_language)
			free_languages    |= all_languages[culture.default_language]
			default_languages |= all_languages[culture.default_language]
		if(culture.language)
			free_languages |= all_languages[culture.language]
		if(culture.name_language)
			free_languages |= all_languages[culture.name_language]
		for(var/lang in culture.additional_langs)
			free_languages |= all_languages[lang]
		// secondary_langs are gathered only as "permitted/selectable", not granted

	// Strip languages the character is no longer allowed (unless whitelisted)…
	// …then grant every free language:
	for(var/lang in free_languages)
		add_language(lang.name)

	// Pick a default from the culture(s) if none is set yet:
	if(length(default_languages) && isnull(default_language))
		default_language = default_languages[1]
```

### Step 3 — Player-selected extras

In character setup the player may add a limited number of **alternate
languages**. The selectable pool is built from *(cultures' free + secondary
langs)* **plus** any `WHITELISTED` language the player is personally whitelisted
for. `RESTRICTED` languages are never offered here.

```dm
#define MAX_LANGUAGES 3   // cap on player-chosen extra languages

// Building the selectable pool:
for(var/culture in cultural_info)
	for(var/lang in culture.get_spoken_languages())  // primary + default + additional
		free_languages[lang]    = TRUE
		allowed_languages[lang] = TRUE
	for(var/lang in culture.secondary_langs)
		allowed_languages[lang] = TRUE                // selectable, not free

for(var/lang in all_languages)
	if(player.has_admin_rights() || (!(lang.flags & RESTRICTED) && (lang.flags & WHITELISTED) && is_alien_whitelisted(player, lang)))
		allowed_languages[lang.name] = TRUE

// Applied to the spawned mob:
for(var/lang in alternate_languages)
	character.add_language(lang)
```

### Step 4 — Job override + safety net

A job may force a language as the mob's default. Crucially, this is also where the
**"never languageless" guarantee** lives: if the mob still knows nothing, it is
handed the universal fallback pidgin.

```dm
/datum/job
	var/required_language     // optional; most jobs leave this null

/datum/job/proc/equip(mob/living/carbon/human/H, ...)
	if(required_language)
		H.add_language(required_language)
		H.set_default_language(all_languages[required_language])

	if(!length(H.languages))                 // <-- safety net
		H.add_language(LANGUAGE_SPACER)      // (some maps use ZAC/Common instead)
		H.set_default_language(all_languages[LANGUAGE_SPACER])
```

### Step 5 — Antagonist override

An antag role can likewise force a language and make it the default (e.g. an
"outsider" actor forced to Common, or a cultist granted the Cult tongue):

```dm
/datum/antagonist
	var/datum/language/required_language = null

// On equip / on species change:
if(antag.required_language)
	player.add_language(antag.required_language)
	player.set_default_language(all_languages[antag.required_language])
```

### Step 6 — Runtime acquisition

Languages can also be gained mid-round:

```dm
// "Babel"/translator implant: learns a language after hearing it enough times.
/obj/item/implant/translator
	var/learning_threshold = 20   // times the language must be heard
	var/max_languages = 5

/obj/item/implant/translator/hear_talk(mob/M, msg, verb, datum/language/speaking)
	languages[speaking.name]++
	if(!imp_in.say_understands(M, speaking) && languages[speaking.name] > learning_threshold)
		imp_in.add_language(speaking.name)   // now understood
```

Other runtime sources: binary-capable headsets (grant Robot Talk), and species
transformations (zombie/changeling/construct) injecting their hivemind tongues.

---

## 2. What each role knows by default

| Role | Default languages | Source |
|------|-------------------|--------|
| **Standard crew (human jobs)** | Whatever the chosen **culture** grants — almost always one human "common" as default + a fallback pidgin and sign as options — plus any player-selected extras. | Culture, not job |
| **Silicons (AI / cyborg)** | Hardcoded: the human common tongue; cyborgs additionally get the robot binary net + the synthetic tonal language. | Mob `New()` |
| **Non-human species** | Their species/culture default (reptilian hiss, melodic warble, plant radio-speak, vox shriek, etc.), with the human common + pidgin + sign as cross-species options. | Culture |
| **Antagonists** | Their normal set **plus** the role tongue (cult/occult, changeling commune, etc.). | `required_language` |

> **Key point:** there is generally **no per-job language list**. A job only
> influences languages through the optional `required_language` field, which most
> jobs leave unset. A Captain and an Assistant of the same culture start with the
> same languages.

---

## 3. Is any role locked out by language?

**No role is gated by *knowing* a language.** The dependency runs the other way:
certain *languages* are gated, which restricts **who may use them** — but every
mob is guaranteed at least the fallback pidgin, so no one is ever mute.

| Gate | Mechanism | Effect |
|------|-----------|--------|
| `WHITELISTED` flag | `is_alien_whitelisted()` check | Not selectable without the relevant whitelist (most alien tongues). |
| `RESTRICTED` flag | flag check in setup | Never player-selectable; only via spawn / admin / antag grant (cult, hiveminds, plant-global, etc.). |
| **Organ / body requirement** | `can_speak_special(mob)` | You physically can't *speak* it without the right anatomy even if it's in your list. |
| **Species assist requirement** | `assisted_langs` species var | Species can only speak the listed language with an assist organ. |
| `only_species_language` | mob var | Restricts the mob to *speaking* only its species tongue (understanding is unaffected). |

Example of an anatomical gate — the language is "known" but unspeakable without
the organ:

```dm
/datum/language/vox/can_speak_special(mob/speaker)
	if(!ishuman(speaker))
		return FALSE
	var/obj/item/organ/internal/hindtongue/tongue = speaker.internal_organs_by_name[BP_HINDTONGUE]
	if(!istype(tongue) || !tongue.is_usable())
		to_chat(speaker, SPAN_WARNING("You are not capable of speaking [name]!"))
		return FALSE
	return TRUE

/datum/language/machine/can_speak_special(mob/living/speaker)
	return speaker.isSynthetic()   // only synthetics can speak the tonal machine language
```

### Summary

- The practical "lockout" is **anatomical or whitelist-based, not job-based**:
  e.g. a human can't speak the vox tongue without a transplanted hindtongue, and
  a non-synthetic can never speak the synthetic machine language.
- The **fallback pidgin** (Step 4) exists precisely so that no mob is ever left
  unable to communicate at all.



===============================================================================
  SOURCE FILE: code/modules/keybindings/language_picker_ui.md
===============================================================================

# Language Picker UI & Slot Counts

A codebase-agnostic description of **where** characters choose extra languages,
**how the picker is formatted**, and **how many languages they may pick** based on
their backgrounds. Companion to [language_assignment.md](language_assignment.md),
[language_system_overview.md](language_system_overview.md), and
[language_lore.md](language_lore.md).

---

## 1. Where the UI lives

The language picker is a **character-setup** screen, not an in-round window. It is
a "background" setup item:

```dm
/datum/category_item/player_setup_item/background/languages
	name = "Languages"
	sort_order = 2            // 2nd item in the Background category, after Culture
	var/list/allowed_languages   // everything the character may select or already has free
	var/list/free_languages      // culture-granted languages (shown as "required")
```

In game the player reaches it through **Setup Character → Background tab →
"Languages."** It renders as an HTML list (with `add` / `Remove` hyperlinks)
inside the character-generation menu. The selection is stored on the preferences
datum and applied to the mob at spawn:

```dm
/datum/preferences
	var/list/alternate_languages   // the player's chosen extra languages
```

---

## 2. Exact formatting of the picker

### 2a. The list body

The picker's body is built one line at a time. Free (culture-granted) languages
are printed as non-removable `(required)` entries; player-added languages get a
`Remove` link and show the language's warning text in red; finally, if there are
free slots left, an `add` link shows the remaining count.

```dm
/datum/category_item/player_setup_item/background/languages/proc/get_language_text()
	sanitize_alt_languages()
	if(LAZYLEN(pref.alternate_languages))
		for(var/i = 1 to length(pref.alternate_languages))
			var/lang = pref.alternate_languages[i]
			if(free_languages[lang])
				LAZYADD(., "- [lang] (required).<br>")
			else
				LAZYADD(., "- [lang] <a href='byond://?src=\ref[src];remove_language=[i]'>Remove.</a> <span style='color:#ff0000;font-style:italic;'>[all_languages[lang].warning]</span><br>")
	if(length(pref.alternate_languages) < MAX_LANGUAGES)
		var/remaining_langs = MAX_LANGUAGES - length(pref.alternate_languages)
		LAZYADD(., "- <a href='byond://?src=\ref[src];add_language=1'>add</a> ([remaining_langs] remaining)<br>")
```

### 2b. The section wrapper

`content()` wraps that list under a bold header, or prints a fallback line when
the character's background offers no choices:

```dm
/datum/category_item/player_setup_item/background/languages/content()
	. = list()
	. += "<b>Languages</b><br>"
	var/list/show_langs = get_language_text()
	if(LAZYLEN(show_langs))
		for(var/lang in show_langs)
			. += lang
	else
		. += "Your current species, faction or home system selection does not allow you to choose additional languages.<br>"
	. = jointext(.,null)
```

### 2c. What the player actually sees

For a Lunar human (one free language, two open slots), the rendered HTML reads
roughly:

```
Languages
- Selenian (required).
- Tradeband Yangyu  Remove.   <(warning text, if any, in red italics)>
- add (1 remaining)
```

For a generic human culture (no fixed language, three open slots) with nothing
picked yet:

```
Languages
- add (3 remaining)
```

When a background grants no selectable languages at all:

```
Languages
Your current species, faction or home system selection does not allow you to choose additional languages.
```

### 2d. The "add" interaction

Clicking **add** validates the cap, then opens a native dropdown of the still-
available languages (everything allowed minus what is already free):

```dm
else if(href_list["add_language"])
	if(length(pref.alternate_languages) >= MAX_LANGUAGES)
		alert(user, "You have already selected the maximum number of languages!")
		return
	sanitize_alt_languages()
	var/list/available_languages = allowed_languages - free_languages
	if(!LAZYLEN(available_languages))
		alert(user, "There are no additional languages available to select.")
	else
		var/new_lang = input(user, "Select an additional language", "Character Generation", null) as null|anything in available_languages
		if(new_lang)
			pref.alternate_languages |= new_lang
			return TOPIC_REFRESH
```

Clicking a **Remove** link drops that entry by index:

```dm
if(href_list["remove_language"])
	var/index = text2num(href_list["remove_language"])
	pref.alternate_languages.Cut(index, index+1)
	return TOPIC_REFRESH
```

---

## 3. How many languages a character may pick

The hard cap is **3 total slots**:

```dm
#define MAX_LANGUAGES 3
```

The key nuance: **culture-granted "free" languages occupy those same 3 slots.**
During sanitize, every free language is inserted at the front of the list and the
list is then truncated to the cap:

```dm
/datum/category_item/player_setup_item/background/languages/proc/sanitize_alt_languages()
	...
	if(LAZYLEN(free_languages))
		for(var/lang in free_languages)
			pref.alternate_languages -= lang
			pref.alternate_languages.Insert(1, lang)   // free langs pushed to the front
	pref.alternate_languages = uniquelist(pref.alternate_languages)
	if(length(pref.alternate_languages) > MAX_LANGUAGES)
		pref.alternate_languages.Cut(MAX_LANGUAGES + 1)  // truncate to the cap
```

So the count of **player-choosable** slots is:

> **choosable = MAX_LANGUAGES − (number of free languages from your backgrounds)**

| Background's free languages | Slots shown as "(required)" | Player may still pick |
|---|---|---|
| 0 (e.g. generic human culture: only `secondary_langs`, no fixed `language`) | 0 | up to **3** |
| 1 (e.g. Lunar cultures set `language = Selenian`) | 1 | up to **2** |
| 2 | 2 | up to **1** |
| 3+ | capped at 3 | **0** |

### Where "free" and "allowed" come from

The picker rebuilds two sets every time it sanitizes, looping over **all** of the
character's cultural tokens (culture, homeworld/faction, religion, …):

```dm
/datum/category_item/player_setup_item/background/languages/proc/rebuild_language_cache(mob/user)
	allowed_languages = list()
	free_languages = list()

	for(var/thing in pref.cultural_info)
		var/singleton/cultural_info/culture = SSculture.get_culture(pref.cultural_info[thing])
		if(istype(culture))
			for(var/checklang in culture.get_spoken_languages())   // primary + default + additional
				free_languages[checklang]    = TRUE                // auto-granted, counts as "required"
				allowed_languages[checklang] = TRUE
			for(var/checklang in culture.secondary_langs)          // optional menu choices
				allowed_languages[checklang] = TRUE

	for(var/thing in all_languages)
		var/datum/language/lang = all_languages[thing]
		// Admins may pick any non-restricted language; players need the whitelist.
		if(user.has_admin_rights() || (!(lang.flags & RESTRICTED) && (lang.flags & WHITELISTED) && is_alien_whitelisted(user, lang)))
			allowed_languages[thing] = TRUE
```

- **free_languages** = each culture's `get_spoken_languages()` (its `language` +
  `default_language` + `additional_langs`). These are auto-granted and printed as
  `(required)`.
- **allowed_languages** = free languages **+** every culture's `secondary_langs`
  **+** any `WHITELISTED` language the player is whitelisted for (admins: any
  non-`RESTRICTED` language).
- The dropdown offered on **add** is `allowed_languages - free_languages`.

`RESTRICTED` languages are never offered in this UI; they are granted only by
spawning, admin action, or antagonist role.

### Worked examples

- **Generic human culture** — no fixed `language`, `secondary_langs` lists the six
  human commons + the fallback pidgin + sign. Result: 0 required, **pick any 3**
  of those options.
- **Lunar human** — `language = Selenian`. Result: Selenian pre-filled as
  required, **pick 2 more** from the allowed pool.
