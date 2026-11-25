import { ReactNode } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const KEY_REGEX =
  /^(\[[\d:]+\]) ([\S\s]+?)\/\(([\S\s]+?)\) \(([\s\S]+?) \((\d+, \d+, \d+)\)\) \(Event #(\d+)\)$/;

type Data = {
  key_enabled: BooleanLike;
  key: string;
  ip_enabled: BooleanLike;
  ip: string;
  cid_enabled: BooleanLike;
  cid: string;
  applies_to_admins: BooleanLike;
  target_is_admin: BooleanLike;
  can_supress: BooleanLike;
  suppressed: BooleanLike;
  duration_type: string;
  ban_duration: number;
  time_units: string;
  playtime_source: string;
  playtime_sources: string[];
  ban_type: string;
  force_cryo_after: BooleanLike;
  use_last_connection: BooleanLike;
  roles: Record<string, string[]>;
  selected_roles: string[];
  selected_groups: string[];
};

export function BanningPanel(props) {
  const { act, data } = useBackend<Data>();
  const {
    key_enabled,
    key,
    ip_enabled,
    ip,
    cid_enabled,
    cid,
    applies_to_admins,
    target_is_admin,
    can_supress,
    suppressed,
    duration_type,
    ban_duration,
    time_units,
    playtime_source,
    playtime_sources,
    ban_type,
    force_cryo_after, // Rest in piss, forever miss
    use_last_connection,
  } = data;

  // The anti-moderator death grinder
  const hasValidKey = key_enabled && key && key.trim() !== '';
  const hasValidIp = ip_enabled && ip && ip.trim() !== '';
  const hasValidCid = cid_enabled && cid && cid.trim() !== '';
  const canSubmit = hasValidKey || hasValidIp || hasValidCid;
  const blockedAdminBan = !!target_is_admin && !applies_to_admins;
  const isPlaytime = duration_type === 'Playtime';
  const unitsMapping = isPlaytime ? playtimeUnitsMapping : timeUnitsMapping;

  return (
    <Window theme="admin" title="Banning Panel" width={750} height={800}>
      <Window.Content>
        {blockedAdminBan && (
          <NoticeBox danger style={{ whiteSpace: 'normal' }}>
            This CKEY belongs to an ADMIN. You may not ban another admin unless
            you tick &quot;Applies to admins&quot;.
          </NoticeBox>
        )}
        <Section title="Player Information">
          <Stack>
            <Flex direction="column">
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="Key"
                      checked={key_enabled}
                      onClick={() => act('toggle_key')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="CKEY"
                      value={key}
                      onChange={(e, value) => act('update_key', { key: value })}
                      style={
                        key_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="IP"
                      checked={ip_enabled}
                      onClick={() => act('toggle_ip')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="IP"
                      value={ip}
                      onChange={(e, value) => act('update_ip', { ip: value })}
                      style={
                        ip_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Flex.Item>
                <Flex direction="row">
                  <Flex.Item>
                    <Button.Checkbox
                      content="CID"
                      checked={cid_enabled}
                      onClick={() => act('toggle_cid')}
                      minWidth="55px"
                    />
                  </Flex.Item>
                  <Flex.Item grow={1}>
                    <Input
                      fluid
                      placeholder="CID"
                      value={cid}
                      onChange={(e, value) => act('update_cid', { cid: value })}
                      style={
                        cid_enabled ? { display: 'block' } : { display: 'none' }
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Flex.Item>
              <Button.Checkbox
                content="Use IP and CID from last connection of key"
                checked={use_last_connection}
                onClick={() => act('toggle_use_last_connection')}
              />
            </Flex>
            <Stack direction="column" mx="10px">
              <Flex mb={1}>
                <Button.Checkbox
                  content="Force Cryo After"
                  checked={force_cryo_after}
                  onClick={() => act('toggle_cryo')}
                />
                <Button.Checkbox
                  content="Applies to admins"
                  checked={applies_to_admins}
                  onClick={() => act('toggle_applies_to_admins')}
                />

                <Box
                  style={
                    can_supress ? { display: 'flex' } : { display: 'none' }
                  }
                >
                  <Button.Checkbox
                    content="Enable suppression"
                    color="bad"
                    checked={suppressed}
                    onClick={() => act('toggle_suppressed')}
                  />
                </Box>
              </Flex>
              <Stack.Item>
                <LabeledList>
                  <LabeledList.Item
                    label="Duration Type"
                    verticalAlign="middle"
                  >
                    <Flex>
                      <Dropdown
                        selected={duration_type}
                        options={['Permanent', 'Temporary', 'Playtime']}
                        onSelected={(selected) =>
                          act('set_duration_type', { type: selected })
                        }
                      />
                      <Box
                        style={
                          duration_type !== 'Permanent'
                            ? { display: 'flex' }
                            : { display: 'none' }
                        }
                      >
                        <NumberInput
                          value={ban_duration}
                          animated
                          minValue={1}
                          maxValue={+Infinity}
                          step={1}
                          onChange={(value) =>
                            act('update_duration', { duration: value })
                          }
                        />
                        <Dropdown
                          selected={Object.keys(unitsMapping).find(
                            (unit) => unitsMapping[unit] === time_units,
                          )}
                          options={Object.keys(unitsMapping)}
                          onSelected={(selected) =>
                            act('set_time_units', {
                              units: unitsMapping[selected],
                            })
                          }
                        />{' '}
                      </Box>
                    </Flex>
                  </LabeledList.Item>
                  {isPlaytime && (
                    <LabeledList.Item
                      label="Playtime Source"
                      verticalAlign="middle"
                    >
                      <Dropdown
                        selected={playtime_source}
                        options={playtime_sources}
                        onSelected={(selected) =>
                          act('set_playtime_source', { source: selected })
                        }
                      />
                    </LabeledList.Item>
                  )}
                  <LabeledList.Item label="Ban Type" verticalAlign="middle">
                    <Dropdown
                      selected={ban_type}
                      options={['Server', 'Role']}
                      onSelected={(selected) =>
                        act('set_ban_type', { type: selected })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Stack>
          </Stack>
        </Section>
        <Section title="Ban Reason">
          <TextArea
            height="100px"
            onChange={(e, value) => act('update_reason', { reason: value })}
          />
        </Section>

        <Section
          title="Roles"
          style={
            ban_type === 'Role' ? { display: 'block' } : { display: 'none' }
          }
        >
          <Roles />
        </Section>
        <Button.Confirm
          content="Submit"
          onClick={() => act('submit_ban')}
          // Disabled if no key OR no IP OR no CID. Look at the checkbox too so some wiseguy doesn't fuck it up by inputting then unchecking either
          disabled={!canSubmit || blockedAdminBan}
          tooltip={
            blockedAdminBan
              ? 'Tick "Applies to admins" to ban an admin'
              : !canSubmit
                ? 'CKEY/IP/CID is required'
                : null
          }
          m={0.5}
          width={7}
          height={2}
          color="green"
          textAlign="center"
        />
      </Window.Content>
    </Window>
  );
}

function Roles(props) {
  const { act, data } = useBackend<Data>();
  const { roles, selected_roles, selected_groups } = data;

  return (
    <Stack direction="column">
      <CheckboxCollapsible
        title="Abstract"
        onClick={() => act('toggle_group', { group: 'abstract' })}
        checked={selected_groups.includes('abstract')}
      >
        <RolesInCategory roles={roles['abstract']} />
      </CheckboxCollapsible>

      <CheckboxCollapsible
        title="Command Roles"
        onClick={() => act('toggle_group', { group: 'command' })}
        color="blue"
        checked={selected_groups.includes('command')}
      >
        <RolesInCategory roles={roles['command']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Security Roles"
        onClick={() => act('toggle_group', { group: 'security' })}
        color="red"
        checked={selected_groups.includes('security')}
      >
        <RolesInCategory roles={roles['security']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Engineering Roles"
        onClick={() => act('toggle_group', { group: 'engineering' })}
        color="orange"
        checked={selected_groups.includes('engineering')}
      >
        <RolesInCategory roles={roles['engineering']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Medical Roles"
        onClick={() => act('toggle_group', { group: 'medical' })}
        color="teal"
        checked={selected_groups.includes('medical')}
      >
        <RolesInCategory roles={roles['medical']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Science Roles"
        color="purple"
        onClick={() => act('toggle_group', { group: 'science' })}
        checked={selected_groups.includes('science')}
      >
        <RolesInCategory roles={roles['science']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Supply Roles"
        color="brown"
        onClick={() => act('toggle_group', { group: 'supply' })}
        checked={selected_groups.includes('supply')}
      >
        <RolesInCategory roles={roles['supply']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Silicon Roles"
        color="yellow"
        onClick={() => act('toggle_group', { group: 'silicon' })}
        checked={selected_groups.includes('silicon')}
      >
        <RolesInCategory roles={roles['silicon']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Antagonist Positions"
        onClick={() => act('toggle_role', { selected_role: 'All Antagonists' })}
        color="black"
        checked={selected_roles.includes('All Antagonists')}
      >
        <RolesInCategory roles={roles['antagonist_positions']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Forced Antagonist Positions"
        onClick={() =>
          act('toggle_role', { selected_role: 'Forced Antagonists' })
        }
        color="bad"
        checked={selected_roles.includes('Forced Antagonists')}
      >
        <RolesInCategory roles={roles['forced_antagonist_positions']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Ghost Roles"
        onClick={() =>
          act('toggle_role', { selected_role: 'Non-Antagonist Ghost Roles' })
        }
        color="grey"
        checked={selected_roles.includes('Non-Antagonist Ghost Roles')}
      >
        <RolesInCategory roles={roles['ghost_roles']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Civilian"
        onClick={() => act('toggle_group', { group: 'civilian' })}
        color="grey"
        checked={selected_groups.includes('civilian')}
      >
        <RolesInCategory roles={roles['civilian']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Gimmick"
        onClick={() => act('toggle_group', { group: 'gimmick' })}
        color="pink"
        checked={selected_groups.includes('gimmick')}
      >
        <RolesInCategory roles={roles['gimmick']} />
      </CheckboxCollapsible>
      <CheckboxCollapsible
        title="Other"
        onClick={() => act('toggle_group', { group: 'other' })}
        checked={selected_groups.includes('other')}
      >
        <RolesInCategory roles={roles['other']} />
      </CheckboxCollapsible>
    </Stack>
  );
}

type CheckboxCollapsibleProps = {
  color?: string;
  title: string;
  onClick: () => void;
  checked: boolean;
  children: ReactNode;
};

function CheckboxCollapsible(props: CheckboxCollapsibleProps) {
  const { color, title, onClick, checked, children } = props;

  return (
    <Flex>
      <Button.Checkbox
        onClick={onClick}
        color={color}
        checked={checked}
        tooltip="Select all for this category"
        maxHeight="20px"
        verticalAlignContent="middle"
      />
      <Collapsible title={title} color={color} inline>
        {children}
      </Collapsible>
    </Flex>
  );
}

type RolesInCategoryProps = {
  roles: string[];
};

function RolesInCategory(props: RolesInCategoryProps) {
  const { roles } = props;
  const { act, data } = useBackend<Data>();
  const { selected_roles } = data;

  return (
    <Stack wrap width="600px">
      {roles.map((role) => {
        return (
          <Button.Checkbox
            content={role}
            key={role}
            onClick={() => act('toggle_role', { selected_role: role })}
            checked={selected_roles.includes(role)}
          />
        );
      })}
    </Stack>
  );
}

const timeUnitsMapping = {
  Seconds: 'SECOND',
  Minutes: 'MINUTE',
  Hours: 'HOUR',
  Days: 'DAY',
  Weeks: 'WEEK',
  Months: 'MONTH',
  Years: 'YEAR',
};

const playtimeUnitsMapping = {
  Minutes: 'MINUTE',
  Hours: 'HOUR',
};
