import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database, Json } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import {
  HealthRecordDetailResponse,
  HealthRecordResponse,
  HealthRecordRowShape,
  HealthRecordsResponse,
  HealthRecordTableName,
} from './health-records.types';

type MedicalHistoryRecordRow =
  Database['public']['Tables']['medical_history_records']['Row'];
type ImmunizationRecordRow =
  Database['public']['Tables']['immunization_records']['Row'];
type MedicalConsultationRecordRow =
  Database['public']['Tables']['medical_consultation_records']['Row'];
type LaboratoryResultRecordRow =
  Database['public']['Tables']['laboratory_result_records']['Row'];
type HealthRecordRow =
  | MedicalHistoryRecordRow
  | ImmunizationRecordRow
  | MedicalConsultationRecordRow
  | LaboratoryResultRecordRow;

const LIST_LIMIT = 100;

@Injectable()
export class HealthRecordsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listRecords(
    tableName: HealthRecordTableName,
    profileId: string,
  ): Promise<HealthRecordsResponse> {
    const { data, error } = await this.supabaseService.adminClient
      .from(tableName)
      .select('*')
      .eq('profile_id', profileId)
      .order('display_order', { ascending: true })
      .order('recorded_at', { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException(
        `Unable to read ${tableName.replaceAll('_', ' ')} records`,
      );
    }

    const rows = (data as HealthRecordRow[] | null) ?? [];
    return { records: rows.map((row) => this.toHealthRecordResponse(row)) };
  }

  private toHealthRecordResponse(row: HealthRecordRowShape): HealthRecordResponse {
    return {
      id: row.id,
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

  private parseDetails(detailsJson: Json): HealthRecordDetailResponse[] {
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
