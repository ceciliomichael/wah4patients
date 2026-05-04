import { Json } from '../supabase/database.types';

export interface AppointmentHistoryDetailResponse {
  label: string;
  value: string;
}

export interface AppointmentHistoryRecordResponse {
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
  details: AppointmentHistoryDetailResponse[];
  recordedAt: string;
  displayOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface AppointmentHistoryResponse {
  records: AppointmentHistoryRecordResponse[];
}

export interface AppointmentHistoryRowShape {
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
