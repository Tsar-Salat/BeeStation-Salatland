import { clamp } from 'common/math';
import { classes } from 'common/react';
import { storage } from 'common/storage';
import { range } from 'es-toolkit';
import { useEffect, useRef, useState } from 'react';

import { useBackend, useLocalState } from '../../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  Stack,
  Tooltip,
} from '../../components';
import { CharacterPreview } from '../common/CharacterPreview';
import {
  createSetPreference,
  Job,
  JOB_PRIORITY_NAMES,
  PreferencesMenuData,
  Qualification,
  ServerData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const EXPANDED_KEY = 'career_expanded';

const getQualificationsById = (serverData: ServerData) =>
  Object.fromEntries(
    serverData.qualifications.qualifications.map((qualification) => [
      qualification.id,
      qualification,
    ]),
  );

export type CareerStatus =
  | { kind: 'available' }
  | { kind: 'add'; qualification: Qualification }
  | { kind: 'move_first'; qualification: Qualification }
  | { kind: 'unlocks_at'; age: number }
  | { kind: 'fits_at'; age: number; qualification: Qualification }
  | { kind: 'full'; missing: Qualification[] }
  | { kind: 'too_late' }
  // The server says it's locked, but nothing here would unlock it
  | { kind: 'locked' };

export const getCareerStatus = (
  title: string,
  job: Job,
  data: PreferencesMenuData,
  serverData: ServerData,
): CareerStatus => {
  if (!data.jobs_locked_by_career.includes(title)) {
    return { kind: 'available' };
  }

  const { career = [] } = data;
  const age = data.character_preferences.non_contextual.age as number;
  const { max_qualifications, career_start_age, max_age } =
    serverData.qualifications;
  const byId = getQualificationsById(serverData);
  const order = career.map((stage) => stage.id);

  const missing = job.qualifications
    .filter((required) => !order.includes(required.id))
    .map((required) => byId[required.id]);
  if (missing.length) {
    if (order.length + missing.length > max_qualifications) {
      return { kind: 'full', missing };
    }
    const next = missing[0];
    const lastEarned = career.length
      ? career[career.length - 1].earned
      : career_start_age;
    const fitsAge = lastEarned + next.training_years;
    if (fitsAge > max_age) {
      return { kind: 'too_late' };
    }
    return fitsAge > age
      ? { kind: 'fits_at', age: fitsAge, qualification: next }
      : { kind: 'add', qualification: next };
  }

  const unlock = (ids: string[]) => {
    const earned: Record<string, number> = {};
    let finished = career_start_age;
    for (const id of ids) {
      finished += byId[id].training_years;
      earned[id] = finished;
    }
    const last = job.qualifications.reduce((latest, required) =>
      earned[required.id] + required.years > earned[latest.id] + latest.years
        ? required
        : latest,
    );
    return { age: earned[last.id] + last.years, last };
  };

  const current = unlock(order);
  if (age >= current.age) {
    return { kind: 'locked' };
  }
  const movedAge = unlock([
    current.last.id,
    ...order.filter((id) => id !== current.last.id),
  ]).age;
  if (
    order[0] !== current.last.id &&
    (movedAge <= age || (current.age > max_age && movedAge < current.age))
  ) {
    return { kind: 'move_first', qualification: byId[current.last.id] };
  }
  return current.age <= max_age
    ? { kind: 'unlocks_at', age: current.age }
    : { kind: 'too_late' };
};

const getJobPicks = (data: PreferencesMenuData, serverData: ServerData) =>
  Object.entries(data.job_preferences)
    .filter(([title, priority]) => priority && serverData.jobs.jobs[title])
    .sort((a, b) => b[1] - a[1])
    .map(([title, priority]) => ({
      title,
      priority,
      available: !data.jobs_locked_by_career.includes(title),
    }));

export const LockedJobsWarning = () => {
  const { data } = useBackend<PreferencesMenuData>();

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return null;
        }
        const locked = getJobPicks(data, serverData).filter(
          (pick) => !pick.available,
        ).length;
        if (!locked) {
          return null;
        }
        return (
          <Tooltip
            content={`Your career locks ${locked} job${locked === 1 ? '' : 's'} you picked`}
          >
            <Box inline ml={1}>
              <Icon name="exclamation-triangle" /> {locked}
            </Box>
          </Tooltip>
        );
      }}
    />
  );
};

type CareerChange =
  | { kind: 'age'; slot: number; from: number; to: number }
  | { kind: 'move'; slot: number; id: string; from: number; order: string };

const useCareerChange = () =>
  useLocalState<CareerChange | null>('career_change', null);

export const useUndoableCareerChanges = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const [, setChange] = useCareerChange();
  const slot = data.active_slot;
  const ids = data.career.map((stage) => stage.id);

  return {
    setAge: (to: number) => {
      setChange({
        kind: 'age',
        slot,
        from: data.character_preferences.non_contextual.age as number,
        to,
      });
      createSetPreference(act, 'age')(to);
    },
    moveFirst: (id: string) => {
      setChange({
        kind: 'move',
        slot,
        id,
        from: ids.indexOf(id) + 1,
        order: [id, ...ids.filter((other) => other !== id)].join(),
      });
      act('move_qualification', { qualification: id, position: 1 });
    },
  };
};

const IconButton = (props: {
  icon: string;
  tooltip: string;
  color?: string;
  disabled?: boolean;
  onClick: () => void;
}) => (
  <Button
    className="PreferencesMenu__Career__icon-button"
    width="28px"
    height="28px"
    lineHeight="28px"
    textAlign="center"
    {...props}
  />
);

const Career = (props: { serverData: ServerData }) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const { serverData } = props;
  const [expanded, setExpanded] = useLocalState(EXPANDED_KEY, true);
  const [change, setChange] = useCareerChange();
  const { career = [] } = data;

  useEffect(() => {
    storage.get(EXPANDED_KEY).then((stored) => {
      if (typeof stored === 'boolean') {
        setExpanded(stored);
      }
    });
  }, []);

  const toggleExpanded = () => {
    storage.set(EXPANDED_KEY, !expanded);
    setExpanded(!expanded);
  };
  const age = data.character_preferences.non_contextual.age as number;
  const name = data.character_preferences.names[data.name_to_use];
  const { max_qualifications, career_start_age, max_age } =
    serverData.qualifications;
  const byId = getQualificationsById(serverData);

  const setAge = (value: number) =>
    createSetPreference(act, 'age')(clamp(value, career_start_age, max_age));
  const moveStage = (id: string, position: number) =>
    act('move_qualification', { qualification: id, position });

  const [sliderAge, setSliderAge] = useState<number | null>(null);
  const shownAge = sliderAge ?? age;
  const sliderRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    setSliderAge(null);
  }, [age]);

  // React's onChange fires on every step of a drag, but the native change event only once it's let go
  useEffect(() => {
    const slider = sliderRef.current;
    if (!slider) {
      return;
    }
    const sendAge = () => setAge(Number(slider.value));
    slider.addEventListener('change', sendAge);
    return () => slider.removeEventListener('change', sendAge);
  });

  const held = career.filter((stage) => stage.held);
  const training = career.find((stage) => !stage.held);
  const practicingFrom = held.length ? held[held.length - 1].earned : null;

  const span = max_age - career_start_age;
  const position = (atAge: number) =>
    `${((atAge - career_start_age) / span) * 100}%`;
  const length = (years: number) => `${(years / span) * 100}%`;
  const ticks = [career_start_age, ...range(25, max_age + 1, 5)];

  let sentence = `${name}, ${age}. `;
  sentence += held.length
    ? held
        .map(
          (stage, index) =>
            `${index ? 'then as' : 'Trained as'} ${byId[stage.id].practitioner} at ${stage.earned}`,
        )
        .join(', ') + '.'
    : 'No qualifications yet.';
  if (training) {
    sentence += ` Training as ${byId[training.id].practitioner} until ${training.earned}.`;
  }

  // Offered until something else changes the age or order it set
  const getUndo = () => {
    if (change?.slot !== data.active_slot) {
      return null;
    }
    if (change.kind === 'age' && change.to === age) {
      const { from } = change;
      return {
        text: `Age set to ${change.to} (was ${from})`,
        revert: () => setAge(from),
      };
    }
    if (
      change.kind === 'move' &&
      change.order === career.map((stage) => stage.id).join()
    ) {
      const { id, from } = change;
      return {
        text: `Moved ${byId[id].name} first`,
        revert: () => moveStage(id, from),
      };
    }
    return null;
  };
  const undo = getUndo();

  const picks = getJobPicks(data, serverData);
  const locked = picks.filter((pick) => !pick.available);
  const lockedText = locked
    .map((pick) => `${pick.title} (${JOB_PRIORITY_NAMES[pick.priority]})`)
    .join(', ');
  const cardJob = picks.find((pick) => pick.available)?.title || 'Unassigned';

  return (
    <Box className="section-background" p={1} mb={1}>
      <Stack>
        <Stack.Item grow basis={0} style={{ minWidth: '0' }}>
          <Stack vertical>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item grow className="PreferencesMenu__Career__title">
                  Career{' '}
                  <Tooltip
                    content={
                      <>
                        <Box>
                          Qualifications are trained for one after another from
                          age {career_start_age}, up to {max_qualifications} in
                          all.
                        </Box>
                        <Box mt={0.5}>
                          Each job needs its qualification, and senior jobs need
                          it held for some years.
                        </Box>
                        <Box mt={0.5}>
                          Your age decides how far along your career is, and the
                          order you trained in decides how long you&apos;ve held
                          each qualification.
                        </Box>
                      </>
                    }
                  >
                    <Icon name="question-circle" />
                  </Tooltip>
                </Stack.Item>
                <Stack.Item color="label">Age</Stack.Item>
                <Stack.Item>
                  <IconButton
                    icon="minus"
                    tooltip="One year younger"
                    disabled={age <= career_start_age}
                    onClick={() => setAge(age - 1)}
                  />
                </Stack.Item>
                <Stack.Item
                  width="2em"
                  textAlign="center"
                  fontSize="1.2em"
                  bold
                >
                  {shownAge}
                </Stack.Item>
                <Stack.Item>
                  <IconButton
                    icon="plus"
                    tooltip="One year older"
                    disabled={age >= max_age}
                    onClick={() => setAge(age + 1)}
                  />
                </Stack.Item>
                <Stack.Item color="label">
                  {career.length >= max_qualifications ? (
                    <Tooltip content="Remove one to add another">
                      <Box inline>
                        {career.length} of {max_qualifications} qualifications
                        (full)
                      </Box>
                    </Tooltip>
                  ) : (
                    `${career.length} of ${max_qualifications} qualifications`
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon={expanded ? 'chevron-up' : 'chevron-down'}
                    iconPosition="right"
                    height="28px"
                    lineHeight="28px"
                    onClick={toggleExpanded}
                  >
                    {expanded ? 'Hide details' : 'Show details'}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Box fontSize="1.3em" lineHeight={1.4} minHeight="2.8em">
                {sentence}
              </Box>
            </Stack.Item>

            <Stack.Item>
              <Stack align="center" height="1.667em">
                <Stack.Item grow basis={0} style={{ minWidth: '0' }}>
                  {locked.length ? (
                    <Tooltip content={lockedText}>
                      <Box className="PreferencesMenu__ellipsis">
                        <Icon name="exclamation-triangle" mr={0.5} />
                        <b>Locked now:</b> {lockedText}
                      </Box>
                    </Tooltip>
                  ) : (
                    <Box className="PreferencesMenu__ellipsis" color="label">
                      {picks.length
                        ? 'Your career allows every job you picked.'
                        : 'No job priorities set yet.'}
                    </Box>
                  )}
                </Stack.Item>
                {undo && (
                  <>
                    <Stack.Item color="label">{undo.text}</Stack.Item>
                    <Stack.Item>
                      <Button
                        compact
                        icon="undo"
                        onClick={() => {
                          setChange(null);
                          undo.revert();
                        }}
                      >
                        Undo
                      </Button>
                    </Stack.Item>
                  </>
                )}
              </Stack>
            </Stack.Item>

            {expanded && (
              <>
                <Stack.Item>
                  <Box className="PreferencesMenu__Career__timeline">
                    <Box
                      className="PreferencesMenu__Career__future"
                      style={{ left: position(shownAge) }}
                    />
                    {practicingFrom !== null && age > practicingFrom && (
                      <Box
                        className="PreferencesMenu__Career__practice"
                        style={{
                          left: position(practicingFrom),
                          width: length(age - practicingFrom),
                        }}
                      >
                        {age - practicingFrom >= 5 &&
                          `practicing ${age - practicingFrom} yrs`}
                      </Box>
                    )}
                    {career.map((stage, index) => (
                      <Box
                        key={stage.id}
                        className={classes([
                          'PreferencesMenu__Career__segment',
                          `PreferencesMenu__Career__segment--${byId[stage.id].department}`,
                          !stage.held &&
                            'PreferencesMenu__Career__segment--training',
                        ])}
                        style={{
                          left: position(stage.started),
                          width: length(stage.earned - stage.started),
                        }}
                      >
                        {index + 1}
                        {stage.earned - stage.started >= 5 &&
                          ` · ${byId[stage.id].training}`}
                      </Box>
                    ))}
                    <Box
                      className="PreferencesMenu__Career__now"
                      style={{ left: position(shownAge) }}
                    />
                  </Box>
                  <Box className="PreferencesMenu__Career__ticks">
                    {ticks.map((tick) => (
                      <Box key={tick} style={{ left: position(tick) }}>
                        {tick}
                      </Box>
                    ))}
                  </Box>
                  <input
                    ref={sliderRef}
                    type="range"
                    className="PreferencesMenu__Career__age-slider"
                    aria-label="Age"
                    min={career_start_age}
                    max={max_age}
                    value={shownAge}
                    onChange={(event) =>
                      setSliderAge(Number(event.target.value))
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Stack vertical>
                    {range(max_qualifications).map((index) => {
                      const stage = career[index];
                      const qualification = stage && byId[stage.id];

                      return (
                        <Stack.Item key={index}>
                          <Stack align="center" height="30px">
                            <Stack.Item>
                              <Box
                                className={classes([
                                  'PreferencesMenu__Career__badge',
                                  stage &&
                                    `PreferencesMenu__Career__badge--${byId[stage.id].department}`,
                                  stage &&
                                    !stage.held &&
                                    'PreferencesMenu__Career__badge--training',
                                ])}
                              >
                                {stage && index + 1}
                              </Box>
                            </Stack.Item>
                            <Stack.Item width="52px" color="label">
                              {stage && `${stage.started}–${stage.earned}`}
                            </Stack.Item>
                            <Stack.Item
                              width="190px"
                              className="PreferencesMenu__ellipsis"
                              color={stage ? undefined : 'label'}
                            >
                              {qualification
                                ? qualification.training
                                : 'Open slot'}
                            </Stack.Item>
                            <Stack.Item
                              width="210px"
                              className="PreferencesMenu__ellipsis"
                              bold
                            >
                              {qualification && (
                                <Tooltip content={qualification.description}>
                                  <Box inline>{qualification.name}</Box>
                                </Tooltip>
                              )}
                            </Stack.Item>
                            <Stack.Item
                              grow
                              basis={0}
                              className={classes([
                                'PreferencesMenu__ellipsis',
                                stage && 'PreferencesMenu__Career__status',
                              ])}
                              color={stage ? undefined : 'label'}
                            >
                              {!stage
                                ? 'Add a qualification from a job below'
                                : stage.held
                                  ? `Held ${age - stage.earned} year${age - stage.earned === 1 ? '' : 's'}`
                                  : `In training until age ${stage.earned}`}
                            </Stack.Item>
                            {qualification && (
                              <>
                                <Stack.Item>
                                  <IconButton
                                    icon="chevron-up"
                                    color="transparent"
                                    tooltip={`Train for the ${qualification.name} earlier`}
                                    disabled={index === 0}
                                    onClick={() => moveStage(stage.id, index)}
                                  />
                                </Stack.Item>
                                <Stack.Item>
                                  <IconButton
                                    icon="chevron-down"
                                    color="transparent"
                                    tooltip={`Train for the ${qualification.name} later`}
                                    disabled={index === career.length - 1}
                                    onClick={() =>
                                      moveStage(stage.id, index + 2)
                                    }
                                  />
                                </Stack.Item>
                                <Stack.Item>
                                  <IconButton
                                    icon="times"
                                    color="transparent"
                                    tooltip={`Remove ${qualification.name}`}
                                    onClick={() =>
                                      act('remove_qualification', {
                                        qualification: stage.id,
                                      })
                                    }
                                  />
                                </Stack.Item>
                              </>
                            )}
                          </Stack>
                        </Stack.Item>
                      );
                    })}
                  </Stack>
                </Stack.Item>
              </>
            )}
          </Stack>
        </Stack.Item>

        {expanded && (
          <Stack.Item width="300px" ml={1.5}>
            <Box className="PreferencesMenu__Career__caption" mb={0.5}>
              Your ID if you get your top pick
            </Box>
            <Box className="PreferencesMenu__Career__card">
              <Box
                className={classes([
                  'PreferencesMenu__Career__card-title',
                  'PreferencesMenu__ellipsis',
                ])}
              >
                {`${name}'s ID Card (${cardJob})`}
              </Box>
              <Stack p={1}>
                <Stack.Item>
                  <Box className="PreferencesMenu__Career__photo">
                    <CharacterPreview
                      id={data.character_preview_view}
                      width="96px"
                      height="120px"
                    />
                  </Box>
                </Stack.Item>
                <Stack.Item grow basis={0} style={{ minWidth: '0' }}>
                  <LabeledList>
                    <LabeledList.Item label="Name">{name}</LabeledList.Item>
                    <LabeledList.Item label="Age">{age}</LabeledList.Item>
                    <LabeledList.Item label="Job">{cardJob}</LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
              <Box px={1} pb={1}>
                <LabeledList>
                  <LabeledList.Item label="Qualifications">
                    {held.map((stage) => byId[stage.id].name).join(', ') ||
                      'None'}
                  </LabeledList.Item>
                </LabeledList>
              </Box>
            </Box>
          </Stack.Item>
        )}
      </Stack>
    </Box>
  );
};

export const CareerPanel = () => (
  <ServerPreferencesFetcher
    render={(serverData) =>
      serverData ? <Career serverData={serverData} /> : null
    }
  />
);
