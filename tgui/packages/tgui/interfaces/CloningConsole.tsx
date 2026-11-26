import {
  Box,
  Button,
  Collapsible,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type DamageType = 'oxy' | 'burn' | 'tox' | 'brute';

type HealthData = Partial<Record<DamageType, string[]>>;

type DiskRecord = {
  name: string;
  id: string;
  UI: string;
  UE: string;
  blood_type: string;
  last_death: number;
  body_only: BooleanLike;
};

type CloneRecord = DiskRecord & {
  damages: HealthData | 0;
};

type Data = {
  temp: string;
  scanTemp: string;
  scannerLocked: BooleanLike;
  hasOccupant: BooleanLike;
  experimental: BooleanLike;
  diskette: BooleanLike;
  lacksMachine: string[];
  records: CloneRecord[];
  diskData: Partial<DiskRecord>;
};

const getDamage = (damages: HealthData, type: DamageType) =>
  Number(damages[type]?.[0]) / 100;

export function CloningConsole(props) {
  const { act, data } = useBackend<Data>();
  const { temp, scanTemp, scannerLocked, hasOccupant, experimental, diskette } =
    data;
  const lacksMachine = data.lacksMachine || [];
  const diskData = data.diskData || {};
  const records = data.records || [];

  return (
    <Window width={400} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Cloning Pod Status">
            <Box backgroundColor="#40638a" p="1px">
              <Box backgroundColor="black" color="white" p="5px">
                {temp}
              </Box>
            </Box>
          </Section>
          {!lacksMachine.length ? (
            <Section title="Scanner Functions">
              <Box backgroundColor="#40638a" p="1px">
                <Box backgroundColor="black" color="white" p="5px">
                  {scanTemp}
                </Box>
              </Box>
              <br />
              <Button
                icon="search"
                disabled={!hasOccupant}
                onClick={() => act('scan')}
              >
                Full Scan
              </Button>
              {!experimental && (
                <Button
                  disabled={!hasOccupant}
                  icon="search"
                  onClick={() => act('scan_body_only')}
                >
                  Body only
                </Button>
              )}
              <Button
                icon={scannerLocked ? 'lock' : 'lock-open'}
                disabled={!hasOccupant && !scannerLocked}
                onClick={() => act('toggle_lock')}
              >
                {scannerLocked ? 'Unlock Scanner' : 'Lock Scanner'}
              </Button>
            </Section>
          ) : (
            <Section title="Modules">
              {lacksMachine.map((machine) => (
                <Box key={machine} color="red">
                  {machine}
                  <br />
                </Box>
              ))}
            </Section>
          )}
          <Section>
            <Section title="Database Functions">
              <NoticeBox>
                <Collapsible title={`View Records (${records.length})`}>
                  <h2>Current Records: </h2>
                  {records.map((record) => (
                    <Section
                      backgroundColor="#191919"
                      color="white"
                      key={record.id}
                    >
                      <Collapsible
                        title={
                          record.name +
                          (record.body_only
                            ? ' (Body Only)'
                            : record.last_death < 0
                              ? ' (Presaved)'
                              : '')
                        }
                        color={
                          record.body_only
                            ? 'yellow'
                            : record.last_death < 0
                              ? 'green'
                              : 'blue'
                        }
                      >
                        <div
                          style={{
                            wordBreak: 'break-all',
                          }}
                        >
                          Scan ID {record.id}
                          <br />
                          <Button
                            icon="power-off"
                            disabled={
                              !record.body_only &&
                              record.last_death < 0 &&
                              !experimental
                            }
                            onClick={() =>
                              act('clone', {
                                target: record.id,
                              })
                            }
                          >
                            Clone
                          </Button>
                          <Button
                            icon="user-slash"
                            onClick={() =>
                              act('delrecord', {
                                target: record.id,
                              })
                            }
                          >
                            Delete Record
                          </Button>
                          <Button
                            icon="upload"
                            disabled={!diskette}
                            onClick={() =>
                              act('save', {
                                target: record.id,
                              })
                            }
                          >
                            Save to Disk
                          </Button>
                          <br />
                          {record.damages ? (
                            <>
                              Health Implant Data
                              <br />
                              <small>
                                Oxygen Deprivation Damage:
                                <br />
                                <ProgressBar
                                  color="blue"
                                  value={getDamage(record.damages, 'oxy')}
                                />
                                Fire Damage:
                                <br />
                                <ProgressBar
                                  color="orange"
                                  value={getDamage(record.damages, 'burn')}
                                />
                                Toxin Damage:
                                <br />
                                <ProgressBar
                                  color="green"
                                  value={getDamage(record.damages, 'tox')}
                                />
                                Brute Damage:
                                <br />
                                <ProgressBar
                                  color="red"
                                  value={getDamage(record.damages, 'brute')}
                                />
                              </small>
                              <br />
                            </>
                          ) : (
                            <>
                              Health implant data not available
                              <br />
                            </>
                          )}
                          Unique Identifier:
                          <br />
                          {record.UI}
                          <br />
                          Unique Enzymes:
                          <br />
                          {record.UE}
                          <br />
                          Blood Type:
                          <br />
                          {record.blood_type}
                          <br />
                        </div>
                      </Collapsible>
                    </Section>
                  ))}
                </Collapsible>
              </NoticeBox>
            </Section>
            <Section
              title="Disk"
              buttons={
                <Box>
                  <Button
                    icon="download"
                    disabled={!diskData.name}
                    onClick={() => act('load')}
                  >
                    Load
                  </Button>
                  <Button
                    icon="eject"
                    disabled={!diskette}
                    onClick={() => act('eject')}
                  >
                    Eject Disk
                  </Button>
                </Box>
              }
            >
              {diskette ? (
                <Collapsible
                  title={
                    diskData.name
                      ? diskData.name +
                        (diskData.body_only
                          ? ' (Body Only)'
                          : (diskData.last_death ?? 0) < 0
                            ? ' (Presaved)'
                            : '')
                      : 'Empty Disk'
                  }
                  color={
                    diskData.name
                      ? diskData.body_only
                        ? 'yellow'
                        : (diskData.last_death ?? 0) < 0
                          ? 'green'
                          : 'blue'
                      : 'grey'
                  }
                >
                  {diskData.id ? (
                    <Box
                      style={{
                        wordBreak: 'break-all',
                      }}
                    >
                      ID: {diskData.id}
                      <br />
                      UI: {diskData.UI}
                      <br />
                      UE: {diskData.UE}
                      <br />
                      Blood Type: {diskData.blood_type}
                      <br />
                    </Box>
                  ) : (
                    'No Data'
                  )}
                </Collapsible>
              ) : (
                'No Disk'
              )}
            </Section>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
}
