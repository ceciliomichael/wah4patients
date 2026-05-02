export type MeasurementSystem = 'metric' | 'imperial';
export type BloodPressureMeasurementPosition =
  | 'sitting'
  | 'standing'
  | 'lying'
  | 'other';
export type TemperatureUnit = 'celsius' | 'fahrenheit';
export type MedicationIntakeStatus =
  | 'scheduled'
  | 'taken'
  | 'missed'
  | 'delayed'
  | 'skipped';

export interface BmiRecordResponse {
  id: string;
  profileId: string;
  weightKg: number;
  heightCm: number;
  bmiValue: number;
  manualBmiValue: number | null;
  bmiSource: 'computed' | 'manual';
  measurementSystem: MeasurementSystem;
  notes: string | null;
  recordedAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface BloodPressureRecordResponse {
  id: string;
  profileId: string;
  systolicMmHg: number;
  diastolicMmHg: number;
  pulseRate: number | null;
  measurementPosition: BloodPressureMeasurementPosition | null;
  measurementMethod: string | null;
  notes: string | null;
  recordedAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface TemperatureRecordResponse {
  id: string;
  profileId: string;
  temperatureValue: number;
  temperatureUnit: TemperatureUnit;
  normalizedCelsius: number;
  measurementMethod: string | null;
  notes: string | null;
  recordedAt: string;
  createdAt: string;
  updatedAt: string;
}

export interface MedicationIntakeRecordResponse {
  id: string;
  profileId: string;
  prescriptionId: string | null;
  medicationReference: string | null;
  medicationNameSnapshot: string;
  scheduledAt: string;
  takenAt: string | null;
  status: MedicationIntakeStatus;
  quantityValue: number | null;
  quantityUnit: string | null;
  notes: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface BmiRecordsResponse {
  records: BmiRecordResponse[];
}

export interface BloodPressureRecordsResponse {
  records: BloodPressureRecordResponse[];
}

export interface TemperatureRecordsResponse {
  records: TemperatureRecordResponse[];
}

export interface MedicationIntakeRecordsResponse {
  records: MedicationIntakeRecordResponse[];
}

export interface CreateBmiRecordInput {
  weightValue: number;
  heightValue: number;
  measurementSystem: MeasurementSystem;
  manualBmiValue?: number | null;
  notes?: string | null;
}

export interface CreateBloodPressureRecordInput {
  systolicMmHg: number;
  diastolicMmHg: number;
  pulseRate?: number | null;
  measurementPosition?: BloodPressureMeasurementPosition | null;
  measurementMethod?: string | null;
  notes?: string | null;
}

export interface CreateTemperatureRecordInput {
  temperatureValue: number;
  temperatureUnit: TemperatureUnit;
  measurementMethod?: string | null;
  notes?: string | null;
}

export interface CreateMedicationIntakeRecordInput {
  prescriptionId?: string | null;
  medicationReference?: string | null;
  medicationNameSnapshot: string;
  scheduledAt: string;
  takenAt?: string | null;
  status: MedicationIntakeStatus;
  quantityValue?: number | null;
  quantityUnit?: string | null;
  notes?: string | null;
}
