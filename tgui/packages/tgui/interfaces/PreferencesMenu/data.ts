import { BooleanLike } from 'common/react';

import { sendAct } from '../../backend';
import { Gender } from './preferences/gender';

export enum Food {
  Alcohol = 'ALCOHOL',
  Breakfast = 'BREAKFAST',
  Bugs = 'BUGS',
  Cloth = 'CLOTH',
  Dairy = 'DAIRY',
  Fried = 'FRIED',
  Fruit = 'FRUIT',
  Gore = 'GORE',
  Grain = 'GRAIN',
  Gross = 'GROSS',
  Junkfood = 'JUNKFOOD',
  Meat = 'MEAT',
  Nuts = 'NUTS',
  Oranges = 'ORANGES',
  Pineapple = 'PINEAPPLE',
  Raw = 'RAW',
  Seafood = 'SEAFOOD',
  Stone = 'STONE',
  Sugar = 'SUGAR',
  Toxic = 'TOXIC',
  Vegetables = 'VEGETABLES',
}

export enum JobPriority {
  Low = 1,
  Medium = 2,
  High = 3,
}

export type Name = {
  can_randomize: BooleanLike;
  explanation: string;
  group: string;
};

export type Species = {
  name: string;
  desc: string;
  lore?: string[];
  icon: string;

  use_skintones: BooleanLike;
  sexes: BooleanLike;

  enabled_features: string[];
  selectable: BooleanLike;

  perks: {
    positive: Perk[];
    negative: Perk[];
    neutral: Perk[];
  };

  diet?: {
    liked_food: Food[];
    disliked_food: Food[];
    toxic_food: Food[];
  };
};

export type Perk = {
  ui_icon: string;
  name: string;
  description: string;
};

export type Department = {
  head?: string;
};

export type Job = {
  description: string;
  department: string;
  lock_reason: string;
};

export type Quirk = {
  description: string;
  icon?: string;
  name: string;
  value: number;
};

export type QuirkInfo = {
  max_positive_quirks: number;
  quirk_info: Record<string, Quirk>;
  quirk_blacklist: string[][];
};

export type Language = {
  path: string;
  name: string;
  desc: string;
  // Family header this language is offered under in the picker.
  category: string;
  // Higher = more prevalent = nearer the top of its family.
  priority: number;
};

// Constant data: the selectable language pool + chargen constants.
export type LanguageInfo = {
  languages: Record<string, Language>;
  max_languages: number;
  fluency_levels: string[];
  // The order families are shown in; unlisted categories are appended.
  category_order: string[];
  // The character-origin choices for the background picker (first is "Auto").
  origins: string[];
};

// A player-picked loadout entry. `language` is a language typepath as text.
export type AlternateLanguage = {
  language: string;
  fluency: string;
  understand_only: BooleanLike;
  native: BooleanLike;
};

// A species-granted language shown as "(required)" - counts against the cap.
export type RequiredLanguage = {
  path: string;
  name: string;
  desc: string;
  spoken: BooleanLike;
  // Why it's known - "species" today; source_label is the species name.
  source: string;
  source_label: string;
};

// The heritage language the character is granted at spawn (free, not budget-counted), from their
// chosen background or - failing that - their top job.
export type OriginLanguage = {
  path: string;
  name: string;
  desc: string;
  // True if it came from the chosen background; false if derived from the top job.
  from_background: BooleanLike;
  // The origin name (e.g. "Auri Frontier") or the job title.
  source_label: string;
};

// How well the character's spoken-default register matches their top job's department register.
// Display-only nudge: a character who "does every role" sees they'll sound foreign in most of them.
export type OriginFit = {
  // "native" | "passable" | "foreign".
  fit: string;
  // Estimated % comprehension of the department register (its gated consoles/documents).
  understanding: number;
  dept_name: string;
  job_title: string;
};

// A small icon + tooltip describing a speak/understand restriction (Font Awesome icon name).
export type LanguageBadge = {
  icon: string;
  color: string;
  tooltip: string;
};

// Per-language status for the currently-selected character's body.
export type LanguageGate = {
  speakable: 'fine' | 'degraded' | 'unspeakable';
  badges: LanguageBadge[];
};

export type LoadoutInfo = {
  categories: LoadoutCategory[];
  purchased_gear: string[];
  equipped_gear: string[];
  metacurrency_name: string;
};

export type LoadoutGear = {
  id: string;
  display_name: string;
  skirt_display_name: string | null;
  description: string;
  skirt_description: string | null;
  donator: BooleanLike;
  cost: number;
  allowed_roles: string[] | null;
  is_equippable: BooleanLike;
  multi_purchase: BooleanLike;
};

export type LoadoutCategory = {
  name: string;
  gear: LoadoutGear[];
};

export type AntagonistData = {
  name: string;
  description: string;
  category: string;
  per_character: BooleanLike;
  path: string;
  icon_path: string;
  ban_key?: string;
};

export enum RandomSetting {
  AntagOnly = 1,
  Disabled = 2,
  Enabled = 3,
}

export enum JoblessRole {
  BeOverflow = 1,
  BeRandomJob = 2,
  ReturnToLobby = 3,
}

export enum GamePreferencesSelectedPage {
  Settings,
  Keybindings,
}

export const createSetPreference =
  (act: typeof sendAct, preference: string) => (value: unknown) => {
    act('set_preference', {
      preference,
      value,
    });
  };

export enum Window {
  Character = 0,
  Game = 1,
  Keybindings = 2,
}

export type PreferencesMenuData = {
  character_preview_view: string;
  character_profiles: (string | null)[];

  character_preferences: CharacterPreferencesData;

  content_unlocked: BooleanLike;

  job_bans?: string[];
  job_days_left?: Record<string, number>;
  job_required_experience?: Record<
    string,
    {
      experience_type: string;
      required_playtime: number;
    }
  >;
  job_preferences: Record<string, JobPriority>;

  keybindings: Record<string, string[]>;
  overflow_role: string;
  selected_quirks: string[];

  alternate_languages: AlternateLanguage[];
  required_languages: RequiredLanguage[];
  // The effective native tongue (typepath text); authoritative, computed server-side.
  native_language: string;
  // Per-language speak/understand status for the current character's body, keyed by typepath text.
  language_gates: Record<string, LanguageGate>;
  // The character's chosen origin/background key (e.g. "Auto (from your role)").
  origin: string;
  // The origin choices offered to the currently-selected species (species-filtered picker).
  origin_choices: string[];
  // The heritage language granted at spawn (display-only), from background or top job, or null.
  origin_language: OriginLanguage | null;
  // Spoken-default vs. department register fit for the top job (display-only), or null.
  origin_fit: OriginFit | null;

  purchased_gear: string[];
  equipped_gear: string[];
  metacurrency_balance: number;
  is_donator: BooleanLike;

  antag_bans?: string[];
  antag_living_playtime_hours_left?: Record<string, number>;
  enabled_global: string[];
  enabled_character: string[];

  active_slot: number;
  max_slot: number;
  name_to_use: string;
  save_in_progress: BooleanLike;
  is_guest: BooleanLike;
  is_db: BooleanLike;
  save_sucess: BooleanLike;

  window: Window;
};

export type CharacterPreferencesData = {
  clothing: Record<string, string>;
  features: Record<string, string>;
  game_preferences: Record<string, unknown>;
  non_contextual: {
    body_is_always_random: RandomSetting;
    [otherKey: string]: unknown;
  };
  secondary_features: Record<string, unknown>;
  supplemental_features: Record<string, unknown>;
  manually_rendered_features: Record<string, string>;

  names: Record<string, string>;

  misc: {
    gender: Gender;
    joblessrole: JoblessRole;
    species: string;
  };

  randomization: Record<string, RandomSetting>;
};

export type ServerData = {
  antags: {
    antagonists: AntagonistData[];
    categories: string[];
  };
  jobs: {
    departments: Record<string, Department>;
    jobs: Record<string, Job>;
  };
  names: {
    types: Record<string, Name>;
  };
  quirks: QuirkInfo;
  languages: LanguageInfo;
  loadout: LoadoutInfo;
  random: {
    randomizable: string[];
  };
  species: Record<string, Species>;
  [otheyKey: string]: unknown;
};
