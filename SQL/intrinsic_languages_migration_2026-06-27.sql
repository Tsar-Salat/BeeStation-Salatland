/*

Intrinsic languages migration (2026-06-27)

Adds the `alternate_languages` column to `SS13_characters`, which stores each character's
intrinsic language loadout (the player-picked extra languages + per-entry fluency/native flags)
that replaces the old "Bilingual" and "Common Second Language" quirks.

Safe to run more than once (uses ADD COLUMN IF NOT EXISTS). Take a backup first anyway.

The old quirk-backed columns (`quirk_multilingual_language` and any `language_skill` /
`language_speakable` / `csl_strength`) are simply left orphaned - the game stops querying them,
so no removal is required. You may drop them later once you have verified nothing needs them.

Replace the table prefix (`SS13_`) if your install uses a different one.

*/

ALTER TABLE `SS13_characters`
    ADD COLUMN IF NOT EXISTS `alternate_languages` MEDIUMTEXT COLLATE 'utf8mb4_general_ci' NULL AFTER `randomize`;
