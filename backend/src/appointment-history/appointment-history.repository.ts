import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database, Json } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import {
  AppointmentHistoryDetailResponse,
  AppointmentHistoryRecordResponse,
  AppointmentHistoryResponse,
  AppointmentHistoryRowShape,
} from './appointment-history.types';

type AppointmentHistoryRecordRow =
  Database['public']['Tables']['appointment_history_records']['Row'];
type AppointmentHistoryRecordInsert =
  Database['public']['Tables']['appointment_history_records']['Insert'];

const LIST_LIMIT = 100;

@Injectable()
export class AppointmentHistoryRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listHistoryRecords(
    profileId: string,
  ): Promise<AppointmentHistoryResponse> {
    const { data, error } = await this.supabaseService.adminClient
      .from('appointment_history_records')
      .select('*')
      .eq('profile_id', profileId)
      .order('display_order', { ascending: true })
      .order('recorded_at', { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to read appointment history records',
      );
    }

    const rows = (data as AppointmentHistoryRecordRow[] | null) ?? [];
    return {
      records: rows.map((row) => this.toHistoryRecordResponse(row)),
    };
  }

  private toHistoryRecordResponse(
    row: AppointmentHistoryRowShape,
  ): AppointmentHistoryRecordResponse {
    return {
      id: row.id,
      gatewayTransactionId: row.gateway_transaction_id,
      profileId: row.profile_id,
      title: row.title,
      subtitle: row.subtitle,
      summaryLabel: row.summary_label,
      summaryValue: row.summary_value,
      filterValue: row.filter_value,
      statusLabel: row.status_label,
      statusColorKey: row.status_color_key,
      accentColorKey: row.accent_color_key,
      iconKey: row.icon_key,
      details: this.parseDetails(row.details_json),
      recordedAt: row.recorded_at,
      displayOrder: row.display_order,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  async insertPendingAppointmentHistoryRecord(
    payload: AppointmentHistoryRecordInsert,
  ): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('appointment_history_records')
      .insert(payload as never);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to store appointment history record',
      );
    }
  }

  async markAppointmentHistoryApprovedByTransactionId(
    gatewayTransactionId: string,
  ): Promise<boolean> {
    const { data: rows, error: listError } = await this.supabaseService.adminClient
      .from('appointment_history_records')
      .select('id')
      .eq('gateway_transaction_id', gatewayTransactionId)
      .limit(1);

    if (listError !== null) {
      throw new InternalServerErrorException(
        'Unable to load appointment history record for status update',
      );
    }

    if (rows === null || rows.length === 0) {
      return false;
    }

    const { error } = await this.supabaseService.adminClient
      .from('appointment_history_records')
      .update({
        filter_value: 'Approved',
        status_label: 'Approved',
        status_color_key: 'success',
        accent_color_key: 'secondary',
        icon_key: 'check_circle',
      } as never)
      .eq('gateway_transaction_id', gatewayTransactionId);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to update appointment history status',
      );
    }

    return true;
  }

  private parseDetails(detailsJson: Json): AppointmentHistoryDetailResponse[] {
    if (!Array.isArray(detailsJson)) {
      return [];
    }

    return detailsJson.flatMap((item) => {
      if (item === null || typeof item !== 'object' || Array.isArray(item)) {
        return [];
      }

      const label = item.label;
      const value = item.value;
      if (typeof label !== 'string' || typeof value !== 'string') {
        return [];
      }

      const trimmedLabel = label.trim();
      const trimmedValue = value.trim();
      if (trimmedLabel.length === 0 || trimmedValue.length === 0) {
        return [];
      }

      return [{ label: trimmedLabel, value: trimmedValue }];
    });
  }
}
