export type MedicationResupplyRequestStatus =
  | 'pending'
  | 'approved'
  | 'rejected'
  | 'cancelled';

export interface MedicationResupplyHistoryRecordResponse {
  id: string;
  gatewayTransactionId: string;
  correlationId: string;
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
  gateway_transaction_id: string;
  correlation_id: string;
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
