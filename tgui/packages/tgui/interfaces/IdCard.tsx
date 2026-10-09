import { useBackend } from '../backend';
import { Box, Image, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type IdCardData = {
  name: string | null;
  job: string | null;
  age: number | null;
  gender: string | null;
  species: string | null;
  blood_type: string | null;
  qualifications: string[] | null;
  photo: string | null;
  card_icon: string;
};

export const IdCard = () => {
  const { data } = useBackend<IdCardData>();
  const {
    name,
    job,
    age,
    gender,
    species,
    blood_type,
    qualifications,
    photo,
    card_icon,
  } = data;

  return (
    <Window width={440} height={250}>
      <Window.Content>
        <Section
          fill
          title={
            <Stack align="center">
              <Stack.Item>
                <Image
                  src={`data:image/png;base64,${card_icon}`}
                  width="64px"
                  height="32px"
                  style={{
                    msInterpolationMode: 'nearest-neighbor',
                    imageRendering: 'pixelated',
                  }}
                />
              </Stack.Item>
              <Stack.Item>{job || 'Unassigned'}</Stack.Item>
            </Stack>
          }
        >
          <Stack fill>
            <Stack.Item>
              <Box
                width="128px"
                height="128px"
                backgroundColor="rgba(255, 255, 255, 0.08)"
                style={{ border: '1px solid rgba(255, 255, 255, 0.2)' }}
              >
                {photo ? (
                  <Image
                    src={`data:image/png;base64,${photo}`}
                    width="128px"
                    height="128px"
                    objectFit="contain"
                  />
                ) : (
                  <Box color="label" textAlign="center" pt="56px">
                    No photo
                  </Box>
                )}
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Name">
                  {name || 'Unknown'}
                </LabeledList.Item>
                <LabeledList.Item label="Age">
                  {age || 'Unknown'}
                </LabeledList.Item>
                <LabeledList.Item label="Gender">
                  {gender || 'Unknown'}
                </LabeledList.Item>
                <LabeledList.Item label="Species">
                  {species || 'Unknown'}
                </LabeledList.Item>
                <LabeledList.Item label="Blood Type">
                  {blood_type || '?'}
                </LabeledList.Item>
                <LabeledList.Item label="Qualifications">
                  {qualifications?.length ? qualifications.join(', ') : 'None'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
