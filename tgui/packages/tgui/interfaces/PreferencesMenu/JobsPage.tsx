import { classes } from 'common/react';
import { sortBy } from 'es-toolkit';
import { PropsWithChildren, ReactNode } from 'react';
import { Dropdown } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Box, Button, Flex, Stack, Tooltip } from '../../components';
import {
  CareerPanel,
  CareerStatus,
  getCareerStatus,
  useUndoableCareerChanges,
} from './CareerPanel';
import {
  createSetPreference,
  Job,
  JOB_PRIORITY_NAMES,
  JoblessRole,
  JobPriority,
  PreferencesMenuData,
  ServerData,
} from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const sortJobs = (entries: [string, Job][], head?: string) =>
  sortBy(entries, [([key, _]) => (key === head ? -1 : 1), ([key, _]) => key]);

const PriorityButton = (props: {
  name: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
}) => {
  const className = `PreferencesMenu__Jobs__departments__priority`;

  return (
    <Flex.Item grow height="100%">
      <Button
        height="100%"
        verticalAlignContent="middle"
        className={classes([
          className,
          !props.enabled && `${className}--disabled`,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        fluid
        content={props.name}
        onClick={props.onClick}
        textAlign="center"
      />
    </Flex.Item>
  );
};

type CreateSetPriority = (priority: JobPriority | null) => () => void;

const createSetPriorityCache: Record<string, CreateSetPriority> = {};

const createCreateSetPriorityFromName = (
  jobName: string,
): CreateSetPriority => {
  if (createSetPriorityCache[jobName] !== undefined) {
    return createSetPriorityCache[jobName];
  }

  const perPriorityCache: Map<JobPriority | null, () => void> = new Map();

  const createSetPriority = (priority: JobPriority | null) => {
    const existingCallback = perPriorityCache.get(priority);
    if (existingCallback !== undefined) {
      return existingCallback;
    }

    const setPriority = () => {
      const { act } = useBackend<PreferencesMenuData>();

      act('set_job_preference', {
        job: jobName,
        level: priority,
      });
    };

    perPriorityCache.set(priority, setPriority);
    return setPriority;
  };

  createSetPriorityCache[jobName] = createSetPriority;

  return createSetPriority;
};

const PriorityButtons = (props: {
  createSetPriority: CreateSetPriority;
  priority: JobPriority;
}) => {
  const { createSetPriority, priority } = props;

  return (
    <Flex
      style={{
        alignItems: 'center',
        justifyContent: 'flex-end',
        height: '100%',
        border: '1px solid rgba(0, 0, 0, 0.4)',
      }}
    >
      <>
        <PriorityButton
          name="Off"
          modifier="off"
          enabled={!priority}
          onClick={createSetPriority(null)}
        />

        <PriorityButton
          name={JOB_PRIORITY_NAMES[JobPriority.Low]}
          modifier="low"
          enabled={priority === JobPriority.Low}
          onClick={createSetPriority(JobPriority.Low)}
        />

        <PriorityButton
          name={JOB_PRIORITY_NAMES[JobPriority.Medium]}
          modifier="medium"
          enabled={priority === JobPriority.Medium}
          onClick={createSetPriority(JobPriority.Medium)}
        />

        <PriorityButton
          name={JOB_PRIORITY_NAMES[JobPriority.High]}
          modifier="high"
          enabled={priority === JobPriority.High}
          onClick={createSetPriority(JobPriority.High)}
        />
      </>
    </Flex>
  );
};

const JobRow = (props: {
  className?: string;
  job: Job;
  name: string;
  status: CareerStatus;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const careerChanges = useUndoableCareerChanges();
  const { className, job, name, status } = props;

  const priority = data.job_preferences[name];

  const createSetPriority = createCreateSetPriorityFromName(name);

  const experienceNeeded =
    data.job_required_experience && data.job_required_experience[name];
  const daysLeft = data.job_days_left ? data.job_days_left[name] : 0;
  const lockReason = job.lock_reason;

  let rightSide: ReactNode;
  let note: ReactNode;

  if (lockReason) {
    note = lockReason;
  } else if (experienceNeeded) {
    const { experience_type, required_playtime } = experienceNeeded;
    const hoursNeeded = Math.ceil(required_playtime / 60);

    note = (
      <>
        <b>{hoursNeeded}h</b> as {experience_type}
      </>
    );
  } else if (daysLeft > 0) {
    note = (
      <>
        <b>{daysLeft}</b> day{daysLeft === 1 ? '' : 's'} left
      </>
    );
  } else if (data.job_bans && data.job_bans.indexOf(name) !== -1) {
    note = <b>Banned</b>;
  } else if (status.kind === 'available') {
    rightSide = (
      <PriorityButtons
        createSetPriority={createSetPriority}
        priority={priority}
      />
    );
  } else if (status.kind === 'add') {
    rightSide = (
      <Stack align="center" height="100%" px="3px">
        <Stack.Item grow style={{ minWidth: '0' }}>
          <Button
            fluid
            className="PreferencesMenu__Jobs__add"
            tooltip={status.qualification.description}
            onClick={() =>
              act('give_qualification', {
                qualification: status.qualification.id,
              })
            }
          >
            <Stack>
              <Stack.Item grow className="PreferencesMenu__ellipsis">
                + {status.qualification.name}
              </Stack.Item>
              <Stack.Item opacity={0.75}>
                {status.qualification.training_years} yrs
              </Stack.Item>
            </Stack>
          </Button>
        </Stack.Item>
      </Stack>
    );
  } else if (status.kind === 'full') {
    note = `Needs ${status.missing.map((missing) => missing.name).join(' and ')}`;
  } else if (status.kind === 'too_late') {
    note = 'Too late to train';
  } else if (status.kind === 'locked') {
    note = 'Not qualified';
  } else {
    let fix: { text: string; tooltip: string; handleClick: () => void };
    switch (status.kind) {
      case 'move_first':
        fix = {
          text: 'Move qualification first',
          tooltip: `Train for the ${status.qualification.name} before your other qualifications`,
          handleClick: () => careerChanges.moveFirst(status.qualification.id),
        };
        break;
      case 'unlocks_at':
        fix = {
          text: `Set age to ${status.age}`,
          tooltip: `${name} unlocks at age ${status.age}`,
          handleClick: () => careerChanges.setAge(status.age),
        };
        break;
      case 'fits_at':
        fix = {
          text: `Set age to ${status.age}`,
          tooltip: `By age ${status.age} there's time to train for the ${status.qualification.name}`,
          handleClick: () => careerChanges.setAge(status.age),
        };
        break;
    }

    rightSide = (
      <Stack align="center" height="100%" px="3px">
        <Stack.Item grow style={{ minWidth: '0' }}>
          <Button
            fluid
            ellipsis
            className="PreferencesMenu__Jobs__fix"
            icon="chevron-right"
            iconPosition="right"
            tooltip={fix.tooltip}
            onClick={fix.handleClick}
          >
            {fix.text}
          </Button>
        </Stack.Item>
      </Stack>
    );
  }

  if (note) {
    rightSide = (
      <Stack align="center" height="100%" pr={1}>
        <Stack.Item
          grow
          textAlign="right"
          className="PreferencesMenu__ellipsis"
        >
          {note}
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack.Item className={className} height="100%" mt={0}>
      <Stack fill align="center">
        <Tooltip
          content={
            <>
              {job.description}
              {job.requirements && (
                <Box mt={0.5} bold>
                  Requires {job.requirements}
                </Box>
              )}
            </>
          }
          position="bottom-start"
        >
          <Stack.Item
            className="job-name"
            width="50%"
            style={{
              paddingLeft: '0.3em',
            }}
          >
            {name}
          </Stack.Item>
        </Tooltip>

        <Stack.Item grow className="options" style={{ minWidth: '0' }}>
          {rightSide}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const Department = (props: { department: string } & PropsWithChildren) => {
  const { data: uiData } = useBackend<PreferencesMenuData>();
  const { children, department: name } = props;
  const className = `PreferencesMenu__Jobs__departments--${name}`;

  return (
    <ServerPreferencesFetcher
      render={(data: ServerData) => {
        if (!data) {
          return null;
        }

        const { departments, jobs } = data.jobs;
        const department = departments[name];

        // This isn't necessarily a bug, it's like this
        // so that you can remove entire departments without
        // having to edit the UI.
        // This is used in events, for instance.
        if (!department) {
          return null;
        }

        const jobsForDepartment = sortJobs(
          Object.entries(jobs).filter(([_, job]) => job.department === name),
          department.head,
        );

        return (
          <Box>
            <Stack vertical fill>
              {jobsForDepartment.map(([name, job]) => (
                <JobRow
                  className={classes([
                    className,
                    name === department.head && 'head',
                  ])}
                  key={name}
                  job={job}
                  name={name}
                  status={getCareerStatus(name, job, uiData, data)}
                />
              ))}
            </Stack>

            {children}
          </Box>
        );
      }}
    />
  );
};

// *Please* find a better way to do this, this is RIDICULOUS.
// All I want is for a gap to pretend to be an empty space.
// But in order for everything to align, I also need to add the 0.2em padding.
// But also, we can't be aligned with names that break into multiple lines!
const Gap = (props: { amount: number }) => {
  // 0.2em comes from the padding-bottom in the department listing
  return <Box height={`calc(${props.amount}px + 0.2em)`} />;
};

const JoblessRoleDropdown = (props) => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const selected = data.character_preferences.misc.joblessrole;

  const options = [
    {
      displayText: `Join as ${data.overflow_role}`,
      value: JoblessRole.BeOverflow,
    },
    {
      displayText: 'Join as a random job',
      value: JoblessRole.BeRandomJob,
    },
    {
      displayText: 'Return to lobby',
      value: JoblessRole.ReturnToLobby,
    },
  ];

  const selection = options?.find(
    (option) => option.value === selected,
  )!.displayText;

  return (
    <Dropdown
      width="100%"
      selected={selection}
      onSelected={createSetPreference(act, 'joblessrole')}
      options={options}
    />
  );
};

const ClearJobsButton = (_) => {
  const { act } = useBackend<PreferencesMenuData>();
  return (
    <Button.Confirm
      content="Clear job priorities"
      onClick={() => act('clear_job_preferences')}
    />
  );
};

export const JobsPage = () => {
  return (
    <>
      <CareerPanel />
      <Stack align="center" className="section-background" p={0.5} mb={1}>
        <Stack.Item color="label">If no job is free</Stack.Item>
        <Stack.Item width="16em">
          <JoblessRoleDropdown />
        </Stack.Item>
        <Stack.Item grow />
        <Stack.Item>
          <ClearJobsButton />
        </Stack.Item>
      </Stack>

      <Stack vertical fill className="section-background" p={1}>
        <Stack.Item>
          <Stack fill className="PreferencesMenu__Jobs">
            <Stack.Item mr={1}>
              <Department department="Assistant">
                <Gap amount={6} />
              </Department>

              <Department department="Engineering">
                <Gap amount={6} />
              </Department>

              <Department department="Medical" />
            </Stack.Item>

            <Stack.Item mr={1}>
              <Department department="Captain">
                <Gap amount={6} />
              </Department>

              <Department department="Civilian">
                <Gap amount={6} />
              </Department>

              <Department department="Service">
                <Gap amount={6} />
              </Department>

              <Department department="Cargo" />
            </Stack.Item>

            <Stack.Item>
              <Department department="Science">
                <Gap amount={6} />
              </Department>

              <Department department="Security">
                <Gap amount={6} />
              </Department>

              <Department department="Silicon" />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </>
  );
};
