import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import {
  MedicationResupplyHistoryRecordResponse,
  MedicationResupplyHistoryResponse,
  MedicationResupplyHistoryRowShape,
} from './medication-resupply.types';

type MedicationResupplyHistoryRecordRow =
  Database['public']['Tables']['medication_resupply_history_records']['Row'];

const LIST_LIMIT = 100;

@Injectable()
export class MedicationResupplyRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listHistoryRecords(
    profileId: string,
  ): Promise<MedicationResupplyHistoryResponse> {
    const { data, error } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .select('*')
      .eq('profile_id', profileId)
      .order('display_order', { ascending: true })
      .order('requested_at', { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to read medication resupply history records',
      );
    }

    const rows = (data as MedicationResupplyHistoryRecordRow[] | null) ?? [];
    return {
      records: rows.map((row) => this.toHistoryRecordResponse(row)),
    };
  }

  private toHistoryRecordResponse(
    row: MedicationResupplyHistoryRowShape,
  ): MedicationResupplyHistoryRecordResponse {
    return {
      id: row.id,
      gatewayTransactionId: row.gateway_transaction_id,
      correlationId: row.correlation_id,
      profileId: row.profile_id,
      medicationName: row.medication_name,
      dosage: row.dosage,
      status: row.status,
      note: row.note,
      requestedAt: row.requested_at,
      displayOrder: row.display_order,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
