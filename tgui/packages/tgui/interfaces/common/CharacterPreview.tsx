import { ByondUi } from '../../components';

export const CharacterPreview = (props: {
  height: string;
  id: string;
  width?: string;
}) => {
  return (
    <ByondUi
      followScroll
      width={props.width || '220px'}
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
