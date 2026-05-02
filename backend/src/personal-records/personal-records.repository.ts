import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import {
  BmiRecordResponse,
  BmiRecordsResponse,
  BloodPressureRecordResponse,
  BloodPressureRecordsResponse,
  CreateBmiRecordInput,
  CreateBloodPressureRecordInput,
  CreateMedicationIntakeRecordInput,
  CreateTemperatureRecordInput,
  MedicationIntakeRecordResponse,
  MedicationIntakeRecordsResponse,
  TemperatureRecordResponse,
  TemperatureRecordsResponse,
} from './personal-records.types';

type BmiRecordRow = Database['public']['Tables']['bmi_records']['Row'];
type BloodPressureRecordRow =
  Database['public']['Tables']['blood_pressure_records']['Row'];
type TemperatureRecordRow =
  Database['public']['Tables']['temperature_records']['Row'];
type MedicationIntakeRecordRow =
  Database['public']['Tables']['medication_intake_records']['Row'];

type BmiRecordInsert = Database['public']['Tables']['bmi_records']['Insert'];
type BloodPressureRecordInsert =
  Database['public']['Tables']['blood_pressure_records']['Insert'];
type TemperatureRecordInsert =
  Database['public']['Tables']['temperature_records']['Insert'];
type MedicationIntakeRecordInsert =
  Database['public']['Tables']['medication_intake_records']['Insert'];

const LIST_LIMIT = 100;

@Injectable()
export class PersonalRecordsRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listBmiRecords(profileId: string): Promise<BmiRecordsResponse> {
    const rows = await this.listRows<BmiRecordRow>('bmi_records', profileId);
    return { records: rows.map((row) => this.toBmiResponse(row)) };
  }

  async createBmiRecord(
    profileId: string,
    input: CreateBmiRecordInput,
  ): Promise<BmiRecordResponse> {
    const payload: BmiRecordInsert = {
      profile_id: profileId,
      weight_kg: input.weightValue,
      height_cm: input.heightValue,
      bmi_value: this.calculateBmi(input.weightValue, input.heightValue),
      manual_bmi_value: input.manualBmiValue ?? null,
      bmi_source: input.manualBmiValue === undefined || input.manualBmiValue === null ? 'computed' : 'manual',
      measurement_system: input.measurementSystem,
      notes: this.normalizeNullableText(input.notes),
      recorded_at: new Date().toISOString(),
    };

    return this.insertRow<BmiRecordRow, BmiRecordInsert, BmiRecordResponse>(
      'bmi_records',
      payload,
      (row) => this.toBmiResponse(row),
    );
  }

  async listBloodPressureRecords(
    profileId: string,
  ): Promise<BloodPressureRecordsResponse> {
    const rows = await this.listRows<BloodPressureRecordRow>(
      'blood_pressure_records',
      profileId,
    );
    return {
      records: rows.map((row) => this.toBloodPressureResponse(row)),
    };
  }

  async createBloodPressureRecord(
    profileId: string,
    input: CreateBloodPressureRecordInput,
  ): Promise<BloodPressureRecordResponse> {
    const payload: BloodPressureRecordInsert = {
      profile_id: profileId,
      systolic_mm_hg: input.systolicMmHg,
      diastolic_mm_hg: input.diastolicMmHg,
      pulse_rate: input.pulseRate ?? null,
      measurement_position: input.measurementPosition ?? null,
      measurement_method: this.normalizeNullableText(input.measurementMethod),
      notes: this.normalizeNullableText(input.notes),
      recorded_at: new Date().toISOString(),
    };

    return this.insertRow<
      BloodPressureRecordRow,
      BloodPressureRecordInsert,
      BloodPressureRecordResponse
    >('blood_pressure_records',
      payload,
      (row) => this.toBloodPressureResponse(row),
    );
  }

  async listTemperatureRecords(
    profileId: string,
  ): Promise<TemperatureRecordsResponse> {
    const rows = await this.listRows<TemperatureRecordRow>(
      'temperature_records',
      profileId,
    );
    return { records: rows.map((row) => this.toTemperatureResponse(row)) };
  }

  async createTemperatureRecord(
    profileId: string,
    input: CreateTemperatureRecordInput,
  ): Promise<TemperatureRecordResponse> {
    const normalizedCelsius =
      input.temperatureUnit === 'celsius'
        ? input.temperatureValue
        : this.fahrenheitToCelsius(input.temperatureValue);

    const payload: TemperatureRecordInsert = {
      profile_id: profileId,
      temperature_value: input.temperatureValue,
      temperature_unit: input.temperatureUnit,
      normalized_celsius: normalizedCelsius,
      measurement_method: this.normalizeNullableText(input.measurementMethod),
      notes: this.normalizeNullableText(input.notes),
      recorded_at: new Date().toISOString(),
    };

    return this.insertRow<
      TemperatureRecordRow,
      TemperatureRecordInsert,
      TemperatureRecordResponse
    >('temperature_records',
      payload,
      (row) => this.toTemperatureResponse(row),
    );
  }

  async listMedicationIntakeRecords(
    profileId: string,
  ): Promise<MedicationIntakeRecordsResponse> {
    const rows = await this.listRows<MedicationIntakeRecordRow>(
      'medication_intake_records',
      profileId,
    );
    return {
      records: rows.map((row) => this.toMedicationIntakeResponse(row)),
    };
  }

  async createMedicationIntakeRecord(
    profileId: string,
    input: CreateMedicationIntakeRecordInput,
  ): Promise<MedicationIntakeRecordResponse> {
    const payload: MedicationIntakeRecordInsert = {
      profile_id: profileId,
      prescription_id: this.normalizeNullableText(input.prescriptionId),
      medication_reference: this.normalizeNullableText(input.medicationReference),
      medication_name_snapshot: input.medicationNameSnapshot,
      scheduled_at: input.scheduledAt,
      taken_at: input.takenAt ?? null,
      status: input.status,
      quantity_value: input.quantityValue ?? null,
      quantity_unit: this.normalizeNullableText(input.quantityUnit),
      notes: this.normalizeNullableText(input.notes),
    };

    return this.insertRow<
      MedicationIntakeRecordRow,
      MedicationIntakeRecordInsert,
      MedicationIntakeRecordResponse
    >('medication_intake_records',
      payload,
      (row) => this.toMedicationIntakeResponse(row),
    );
  }

  private async listRows<RowType extends { profile_id: string; created_at: string; recorded_at?: string }>(
    tableName:
      | 'bmi_records'
      | 'blood_pressure_records'
      | 'temperature_records'
      | 'medication_intake_records',
    profileId: string,
  ): Promise<RowType[]> {
    const orderColumn = tableName === 'medication_intake_records' ? 'created_at' : 'recorded_at';
    const { data, error } = await this.supabaseService.adminClient
      .from(tableName)
      .select('*')
      .eq('profile_id', profileId)
      .order(orderColumn, { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException(
        `Unable to read ${tableName.replaceAll('_', ' ')} records`,
      );
    }

    return (data as RowType[] | null) ?? [];
  }

  private async insertRow<
    RowType,
    InsertType extends Record<string, unknown>,
    ResponseType,
  >(
    tableName:
      | 'bmi_records'
      | 'blood_pressure_records'
      | 'temperature_records'
      | 'medication_intake_records',
    payload: InsertType,
    mapRow: (row: RowType) => ResponseType,
  ): Promise<ResponseType> {
    const { data, error } = await this.supabaseService.adminClient
      .from(tableName)
      .insert(payload as never)
      .select('*')
      .single();

    if (error !== null || data === null) {
      throw new InternalServerErrorException(
        `Unable to save ${tableName.replaceAll('_', ' ')} record`,
      );
    }

    return mapRow(data as RowType);
  }

  private toBmiResponse(row: BmiRecordRow): BmiRecordResponse {
    return {
      id: row.id,
      profileId: row.profile_id,
      weightKg: row.weight_kg,
      heightCm: row.height_cm,
      bmiValue: row.bmi_value,
      manualBmiValue: row.manual_bmi_value,
      bmiSource: row.bmi_source,
      measurementSystem: row.measurement_system,
      notes: row.notes,
      recordedAt: row.recorded_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  private toBloodPressureResponse(
    row: BloodPressureRecordRow,
  ): BloodPressureRecordResponse {
    return {
      id: row.id,
      profileId: row.profile_id,
      systolicMmHg: row.systolic_mm_hg,
      diastolicMmHg: row.diastolic_mm_hg,
      pulseRate: row.pulse_rate,
      measurementPosition: row.measurement_position,
      measurementMethod: row.measurement_method,
      notes: row.notes,
      recordedAt: row.recorded_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  private toTemperatureResponse(
    row: TemperatureRecordRow,
  ): TemperatureRecordResponse {
    return {
      id: row.id,
      profileId: row.profile_id,
      temperatureValue: row.temperature_value,
      temperatureUnit: row.temperature_unit,
      normalizedCelsius: row.normalized_celsius,
      measurementMethod: row.measurement_method,
      notes: row.notes,
      recordedAt: row.recorded_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  private toMedicationIntakeResponse(
    row: MedicationIntakeRecordRow,
  ): MedicationIntakeRecordResponse {
    return {
      id: row.id,
      profileId: row.profile_id,
      prescriptionId: row.prescription_id,
      medicationReference: row.medication_reference,
      medicationNameSnapshot: row.medication_name_snapshot,
      scheduledAt: row.scheduled_at,
      takenAt: row.taken_at,
      status: row.status,
      quantityValue: row.quantity_value,
      quantityUnit: row.quantity_unit,
      notes: row.notes,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }

  private normalizeNullableText(value: string | null | undefined): string | null {
    const normalized = value?.trim() ?? '';
    return normalized.length > 0 ? normalized : null;
  }

  private calculateBmi(weightKg: number, heightCm: number): number {
    const heightMeters = heightCm / 100;
    return Number((weightKg / (heightMeters * heightMeters)).toFixed(1));
  }

  private fahrenheitToCelsius(value: number): number {
    return Number((((value - 32) * 5) / 9).toFixed(1));
  }
}
