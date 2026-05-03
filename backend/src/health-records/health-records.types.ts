import { Json } from '../supabase/database.types';

export type HealthRecordTableName =
  | 'medical_history_records'
  | 'immunization_records'
  | 'medical_consultation_records'
  | 'laboratory_result_records';

export type HealthRecordSection =
  | 'medical-history'
  | 'immunizations'
  | 'consultations'
  | 'laboratory-results';

export interface HealthRecordDetailResponse {
  label: string;
  value: string;
}

export interface HealthRecordResponse {
  id: string;
  profileId: string;
  title: string;
  subtitle: string;
  summaryLabel: string;
  summaryValue: string;
  filterValue: string;
  statusLabel: string;
  statusColorKey: string;
  accentColorKey: string;
  iconKey: string;
  details: HealthRecordDetailResponse[];
  recordedAt: string;
  displayOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface HealthRecordsResponse {
  records: HealthRecordResponse[];
}

export interface HealthRecordRowShape {
  id: string;
  profile_id: string;
  title: string;
  subtitle: string;
  summary_label: string;
  summary_value: string;
  filter_value: string;
  status_label: string;
  status_color_key: string;
  accent_color_key: string;
  icon_key: string;
  details_json: Json;
  recorded_at: string;
  display_order: number;
  created_at: string;
  updated_at: string;
}
