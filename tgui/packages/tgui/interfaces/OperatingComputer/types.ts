import type { BooleanLike } from 'tgui-core/react';

import type { BodyZone } from '../common/BodyZoneSelector';

export type OperatingComputerData = {
  has_table: BooleanLike;
  patient?: PatientData;
  target_zone: BodyZone;
  // static data
  surgeries: OperationData[];
};

export type PatientData = {
  health: number;
  blood_type: string;
  stat: 'Conscious' | 'Unconscious' | 'Dead';
  statstate: 'good' | 'average' | 'bad';
  minHealth: number;
  maxHealth: number;
  bruteLoss: number;
  fireLoss: number;
  toxLoss: number;
  oxyLoss: number;
  blood_level: number;
  standard_blood_level: number;
  target_zone: BodyZone;
  surgery_state: string[];
  next_operations: string[];
  prep_operation?: OperationData;
};

export type OperationData = {
  name: string;
  desc: string;
  tool_rec: string;
  priority?: BooleanLike;
  mechanic?: BooleanLike;
  requirements?: string[][];
  // show operation in the full list
  show_in_list: BooleanLike;
};

export type damageType = {
  label: string;
  type: 'bruteLoss' | 'fireLoss' | 'toxLoss' | 'oxyLoss';
};

export const damageTypes: damageType[] = [
  {
    label: 'Brute',
    type: 'bruteLoss',
  },
  {
    label: 'Burn',
    type: 'fireLoss',
  },
  {
    label: 'Toxin',
    type: 'toxLoss',
  },
  {
    label: 'Respiratory',
    type: 'oxyLoss',
  },
];

export enum ComputerTabs {
  PatientState = 1,
  OperationCatalog = 2,
}
