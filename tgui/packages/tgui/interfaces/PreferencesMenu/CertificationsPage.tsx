import { useBackend } from '../../backend';
import { Box, Button, NoticeBox, Stack, Table } from '../../components';
import { PreferencesMenuData } from './data';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

export const CertificationsPage = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const age = data.character_preferences.non_contextual.age as number;
  const {
    certifications: picked = [],
    valid_certifications: held = [],
    certification_slots: slots,
  } = data;

  return (
    <ServerPreferencesFetcher
      render={(serverData) => {
        if (!serverData) {
          return <Box>Loading certifications...</Box>;
        }

        const { certifications, second_slot_age, third_slot_age } =
          serverData.certifications;
        const nextSlotAge =
          age < second_slot_age
            ? second_slot_age
            : age < third_slot_age
              ? third_slot_age
              : null;

        return (
          <Stack vertical>
            <Stack.Item>
              <NoticeBox info>
                Holding {held.length} of {slots}.
                {nextSlotAge && ` Another opens at age ${nextSlotAge}.`} Jobs
                that need a certification can only be taken by characters who
                hold it. Only a Medical License allows surgery without a waiver
                signed by the patient.
              </NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Table>
                {certifications.map((certification) => {
                  const isPicked = picked.includes(certification.id);
                  const isHeld = held.includes(certification.id);
                  const tooYoung = age < certification.minimum_age;
                  const full = held.length >= slots;

                  let status = '';
                  if (isPicked && !isHeld) {
                    status = tooYoung
                      ? `Not held until age ${certification.minimum_age}`
                      : 'Not held, no free slot';
                  }

                  return (
                    <Table.Row key={certification.id} className="candystripe">
                      <Table.Cell bold collapsing>
                        {certification.name}
                      </Table.Cell>
                      <Table.Cell collapsing color="label">
                        Age {certification.minimum_age}+
                      </Table.Cell>
                      <Table.Cell>
                        {certification.description}
                        {status && (
                          <Box color="average" mt={0.5}>
                            {status}
                          </Box>
                        )}
                      </Table.Cell>
                      <Table.Cell collapsing>
                        {isPicked ? (
                          <Button
                            icon="minus"
                            onClick={() =>
                              act('remove_certification', {
                                certification: certification.id,
                              })
                            }
                          >
                            Drop
                          </Button>
                        ) : (
                          <Button
                            icon="plus"
                            disabled={tooYoung || full}
                            tooltip={
                              tooYoung
                                ? `Needs age ${certification.minimum_age}`
                                : full
                                  ? 'No free slot, drop one first'
                                  : undefined
                            }
                            onClick={() =>
                              act('give_certification', {
                                certification: certification.id,
                              })
                            }
                          >
                            Pick
                          </Button>
                        )}
                      </Table.Cell>
                    </Table.Row>
                  );
                })}
              </Table>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
};
