import { BooleanLike } from 'common/react';
import { Dropdown } from 'tgui-core/components';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from '../../components';
import {
  AlternateLanguage,
  Language,
  LanguageGate,
  LanguageInfo,
  PreferencesMenuData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

// Fixed control-column widths, shared by both sections so the columns line up.
const FLUENCY_WIDTH = '7em';
const SPEECH_WIDTH = '9em';
const NATIVE_WIDTH = '7em';
const REMOVE_WIDTH = '2em';

type FluencyDropdownProps = {
  fluencyLevels: string[];
  selected: string;
  onSelected: (fluency: string) => void;
};

function FluencyDropdown(props: FluencyDropdownProps) {
  const { fluencyLevels, selected, onSelected } = props;
  return (
    <Dropdown
      width={FLUENCY_WIDTH}
      selected={selected}
      displayText={selected}
      options={fluencyLevels.map((level) => ({
        displayText: level,
        value: level,
      }))}
      onSelected={onSelected}
    />
  );
}

type NativeButtonProps = {
  isNative: boolean;
  onClick: () => void;
};

function NativeButton(props: NativeButtonProps) {
  const { isNative, onClick } = props;
  return (
    <Tooltip content="The tongue you slip back into when rattled. If this isn't your standard, lower that standard's fluency to make it a second language.">
      <Button
        icon="house"
        selected={isNative}
        onClick={onClick}
        width={NATIVE_WIDTH}
        textAlign="center"
      >
        {'Native'}
      </Button>
    </Tooltip>
  );
}

// Colour the language name by whether the current character could actually speak it.
function tintFor(gate?: LanguageGate): string | undefined {
  switch (gate?.speakable) {
    case 'unspeakable':
      return 'bad';
    case 'degraded':
      return 'average';
    default:
      return undefined;
  }
}

// The little speak/understand restriction icons next to a language name.
function LanguageBadges(props: { gate?: LanguageGate }) {
  const { gate } = props;
  if (!gate?.badges?.length) {
    return null;
  }
  return (
    <Box as="span" ml={1}>
      {gate.badges.map((b, i) => (
        <Tooltip key={i} content={b.tooltip}>
          <Box as="span" mr={0.5}>
            <Icon name={b.icon} color={b.color} />
          </Box>
        </Tooltip>
      ))}
    </Box>
  );
}

type LanguageRowProps = {
  name: string;
  desc?: string;
  /** A trailing "(required)" / "(understood)" hint shown after the name. */
  badge?: string;
  /** Per-character speak/understand status for this language (icons + name tint). */
  gate?: LanguageGate;
  fluency: string;
  fluencyLevels: string[];
  onFluency: (fluency: string) => void;
  isNative: boolean;
  onNative: () => void;
  /** Pass both to render the speak/understand toggle (learned languages only). */
  understandOnly?: BooleanLike;
  onUnderstandOnly?: () => void;
  /** Pass to render a remove button (learned languages only). */
  onRemove?: () => void;
};

function LanguageRow(props: LanguageRowProps) {
  const {
    name,
    desc,
    badge,
    gate,
    fluency,
    fluencyLevels,
    onFluency,
    isNative,
    onNative,
    understandOnly,
    onUnderstandOnly,
    onRemove,
  } = props;

  return (
    <Stack
      align="center"
      g={1}
      py={0.75}
      style={{ borderBottom: '1px solid rgba(255, 255, 255, 0.1)' }}
    >
      <Stack.Item grow style={{ minWidth: '0' }}>
        <Box bold color={tintFor(gate)}>
          {name}
          {badge && (
            <Box as="span" color="label" ml={1}>
              {badge}
            </Box>
          )}
          <LanguageBadges gate={gate} />
        </Box>
        {desc && (
          <Box color="label" fontSize="0.9em" mt={0.25}>
            {desc}
          </Box>
        )}
      </Stack.Item>

      <Stack.Item>
        <FluencyDropdown
          fluencyLevels={fluencyLevels}
          selected={fluency}
          onSelected={onFluency}
        />
      </Stack.Item>

      <Stack.Item>
        {onUnderstandOnly ? (
          <Tooltip content="If checked you can follow this language but not speak it.">
            <Button
              icon={understandOnly ? 'ear-listen' : 'comments'}
              selected={!!understandOnly}
              width={SPEECH_WIDTH}
              textAlign="center"
              onClick={onUnderstandOnly}
            >
              {understandOnly ? 'Hear' : 'Speak + Hear'}
            </Button>
          </Tooltip>
        ) : (
          <Box width={SPEECH_WIDTH} />
        )}
      </Stack.Item>

      <Stack.Item>
        <NativeButton isNative={isNative} onClick={onNative} />
      </Stack.Item>

      <Stack.Item>
        <Box width={REMOVE_WIDTH} textAlign="center">
          {onRemove && <Button icon="trash" color="bad" onClick={onRemove} />}
        </Box>
      </Stack.Item>
    </Stack>
  );
}

function nameFor(
  path: string,
  languageInfo: LanguageInfo,
  fallback?: string,
): string {
  return languageInfo.languages[path]?.name ?? fallback ?? path;
}

type LanguageBrowserProps = {
  available: Language[];
  categoryOrder: string[];
  gates: Record<string, LanguageGate>;
  onAdd: (path: string) => void;
};

// The "learn a language" panel: available languages under family headers (curated order first,
// any extras alphabetical), most-prevalent first within each family.
function LanguageBrowser(props: LanguageBrowserProps) {
  const { available, categoryOrder, gates, onAdd } = props;

  const groups: Record<string, Language[]> = {};
  for (const lang of available) {
    if (!groups[lang.category]) {
      groups[lang.category] = [];
    }
    groups[lang.category].push(lang);
  }

  const orderedCategories = [
    ...categoryOrder.filter((cat) => groups[cat]?.length),
    ...Object.keys(groups)
      .filter((cat) => !categoryOrder.includes(cat))
      .sort((a, b) => a.localeCompare(b)),
  ];

  return (
    <Box
      mt={1}
      p={1}
      style={{
        border: '1px solid rgba(255, 255, 255, 0.15)',
        borderRadius: '2px',
      }}
    >
      {orderedCategories.map((cat) => (
        <Box key={cat} mb={1}>
          <Box
            bold
            color="label"
            mb={0.5}
            style={{
              textTransform: 'uppercase',
              letterSpacing: '0.5px',
              borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
            }}
          >
            {cat}
          </Box>
          {groups[cat]
            .slice()
            .sort(
              (a, b) => b.priority - a.priority || a.name.localeCompare(b.name),
            )
            .map((lang) => (
              <Stack key={lang.path} align="center" g={1} py={0.5}>
                <Stack.Item>
                  <Button
                    icon="plus"
                    color="good"
                    onClick={() => onAdd(lang.path)}
                  />
                </Stack.Item>
                <Stack.Item grow style={{ minWidth: '0' }}>
                  <Box bold color={tintFor(gates[lang.path])}>
                    {lang.name}
                    <LanguageBadges gate={gates[lang.path]} />
                  </Box>
                  {lang.desc && (
                    <Box color="label" fontSize="0.9em">
                      {lang.desc}
                    </Box>
                  )}
                </Stack.Item>
              </Stack>
            ))}
        </Box>
      ))}
    </Box>
  );
}

export function LanguagesPage() {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [browseOpen, setBrowseOpen] = useLocalState(
    'languages_browse_open',
    false,
  );

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading languages...</Box>;
        }

        const languageInfo = serverData.languages;
        const { max_languages: maxLanguages, fluency_levels: fluencyLevels } =
          languageInfo;
        // The top tier is the server's "native" label; don't hardcode the string.
        const nativeFluency = fluencyLevels[0];

        const required = data.required_languages || [];
        const loadout = data.alternate_languages || [];
        const gates = data.language_gates || {};
        const originLang = data.origin_language;
        const originFit = data.origin_fit;
        const origins = data.origin_choices || languageInfo.origins || [];

        const fitColor: Record<string, string> = {
          native: 'good',
          passable: 'average',
          foreign: 'bad',
        };

        const requiredPaths = required.map((req) => req.path);
        const learned = loadout.filter(
          (entry) => !requiredPaths.includes(entry.language),
        );

        const slotsUsed = requiredPaths.length + learned.length;
        const remaining = maxLanguages - slotsUsed;

        const entryFor = (path: string): AlternateLanguage | undefined =>
          loadout.find((entry) => entry.language === path);

        // Descriptions can come from either the selectable pool or the required set.
        const descFor = (path: string): string | undefined =>
          languageInfo.languages[path]?.desc ??
          required.find((req) => req.path === path)?.desc;

        // The native tongue is resolved server-side; the panel just compares.
        const isNative = (path: string): boolean =>
          path === data.native_language;

        const setNative = (path: string) => {
          act('set_native', { language: isNative(path) ? '' : path });
        };

        const available = Object.values(languageInfo.languages).filter(
          (lang: Language) =>
            !requiredPaths.includes(lang.path) && !entryFor(lang.path),
        );

        const canAdd = remaining > 0 && available.length > 0;
        const addBlockedReason =
          remaining <= 0
            ? 'No slots remaining — lower a fluency or remove a language to free one up.'
            : 'You already know every available language.';

        return (
          <Stack vertical g={1}>
            <Stack.Item>
              <NoticeBox info>
                Your species and background already give you the languages
                below. You can know up to {maxLanguages} in total (these count),
                each at a fluency you choose — Working speaks it but misses the
                nuance, Basic only catches the common words. An icon by a
                language means your current body can&apos;t speak it cleanly —
                hover it for why.
              </NoticeBox>
            </Stack.Item>

            <Stack.Item>
              <Section
                title="Known from your origin"
                buttons={
                  <Tooltip content="Where your character is from. Sets your primary spoken tongue. 'Auto' uses your species' primary tongue — it won't conform to your role.">
                    <Dropdown
                      width="13em"
                      selected={data.origin}
                      displayText={data.origin}
                      options={origins.map((o) => ({
                        displayText: o,
                        value: o,
                      }))}
                      onSelected={(value) =>
                        act('set_origin', { origin: value })
                      }
                    />
                  </Tooltip>
                }
              >
                {originFit && (
                  <Box mb={1} color={fitColor[originFit.fit]}>
                    {originFit.fit === 'native'
                      ? `You'll read the ${originFit.job_title} department's consoles and documents (${originFit.dept_name}) without trouble.`
                      : originFit.fit === 'passable'
                        ? `You can limp through the ${originFit.job_title} department's materials (${originFit.dept_name}, ~${originFit.understanding}%), but they'll read garbled — learn ${originFit.dept_name} or take a matching origin to read them cleanly.`
                        : `The ${originFit.job_title} department's consoles and documents are in ${originFit.dept_name}, which you can barely read (~${originFit.understanding}%) — learn ${originFit.dept_name} or take a matching origin.`}
                  </Box>
                )}
                {required.length === 0 && !originLang ? (
                  <Box color="label">
                    Your species and background grant no languages.
                  </Box>
                ) : (
                  <>
                    {required.map((req) => (
                      <LanguageRow
                        key={req.path}
                        name={nameFor(req.path, languageInfo, req.name)}
                        desc={descFor(req.path)}
                        badge={
                          req.spoken
                            ? 'from your species'
                            : 'from your species · understood only'
                        }
                        gate={gates[req.path]}
                        fluency={entryFor(req.path)?.fluency ?? nativeFluency}
                        fluencyLevels={fluencyLevels}
                        onFluency={(value) =>
                          act('set_fluency', {
                            language: req.path,
                            fluency: value,
                          })
                        }
                        isNative={isNative(req.path)}
                        onNative={() => setNative(req.path)}
                      />
                    ))}

                    {originLang && (
                      <Stack
                        align="center"
                        g={1}
                        py={0.75}
                        style={{
                          borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
                        }}
                      >
                        <Stack.Item grow style={{ minWidth: '0' }}>
                          <Box bold color={tintFor(gates[originLang.path])}>
                            {originLang.name}
                            <Box as="span" color="label" ml={1}>
                              {originLang.from_background
                                ? 'from your origin · '
                                : 'from your role · '}
                              {originLang.source_label}
                            </Box>
                            <LanguageBadges gate={gates[originLang.path]} />
                          </Box>
                          {originLang.desc && (
                            <Box color="label" fontSize="0.9em" mt={0.25}>
                              {originLang.desc}
                            </Box>
                          )}
                        </Stack.Item>
                        <Stack.Item>
                          <Tooltip content="Granted at spawn and set as your default spoken tongue. It doesn't use a slot.">
                            <Box color="label" italic>
                              spoken default
                            </Box>
                          </Tooltip>
                        </Stack.Item>
                      </Stack>
                    )}
                  </>
                )}
              </Section>
            </Stack.Item>

            <Stack.Item>
              <Section
                title="Languages you've learned"
                buttons={
                  <Box color={remaining > 0 ? 'good' : 'bad'} mt={0.5}>
                    {remaining} of {maxLanguages} slots remaining
                  </Box>
                }
              >
                {learned.length === 0 && (
                  <Box color="label" mb={1}>
                    {"You haven't learned any extra languages yet."}
                  </Box>
                )}

                {learned.map((entry) => (
                  <LanguageRow
                    key={entry.language}
                    name={nameFor(entry.language, languageInfo)}
                    desc={descFor(entry.language)}
                    gate={gates[entry.language]}
                    fluency={entry.fluency}
                    fluencyLevels={fluencyLevels}
                    onFluency={(value) =>
                      act('set_fluency', {
                        language: entry.language,
                        fluency: value,
                      })
                    }
                    isNative={isNative(entry.language)}
                    onNative={() => setNative(entry.language)}
                    understandOnly={entry.understand_only}
                    onUnderstandOnly={() =>
                      act('set_understand_only', {
                        language: entry.language,
                        understand_only: !entry.understand_only,
                      })
                    }
                    onRemove={() =>
                      act('remove_language', { language: entry.language })
                    }
                  />
                ))}

                <Box mt={1.5}>
                  {canAdd ? (
                    <>
                      <Button
                        icon={browseOpen ? 'chevron-up' : 'plus'}
                        width="16em"
                        onClick={() => setBrowseOpen(!browseOpen)}
                      >
                        {browseOpen ? 'Close Selection' : 'Learn a language...'}
                      </Button>
                      {browseOpen && (
                        <LanguageBrowser
                          available={available}
                          categoryOrder={languageInfo.category_order || []}
                          gates={gates}
                          onAdd={(path) =>
                            act('add_language', { language: path })
                          }
                        />
                      )}
                    </>
                  ) : (
                    <Tooltip content={addBlockedReason}>
                      <Button icon="plus" disabled width="16em">
                        Learn a language...
                      </Button>
                    </Tooltip>
                  )}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
}
