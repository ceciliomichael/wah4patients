export type MedicationResupplyRequestStatus =
  | 'pending'
  | 'approved'
  | 'rejected'
  | 'cancelled';

export interface MedicationResupplyHistoryRecordResponse {
  id: string;
  profileId: string;
  medicationName: string;
  dosage: string;
  status: MedicationResupplyRequestStatus;
  note: string;
  requestedAt: string;
  displayOrder: number;
  createdAt: string;
  updatedAt: string;
}

export interface MedicationResupplyHistoryResponse {
  records: MedicationResupplyHistoryRecordResponse[];
}

export interface MedicationResupplyHistoryRowShape {
  id: string;
  profile_id: string;
  medication_name: string;
  dosage: string;
  status: MedicationResupplyRequestStatus;
  note: string;
  requested_at: string;
  display_order: number;
  created_at: string;
  updated_at: string;
}
