import { BadRequestException, Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import {
  GatewayIdentifier,
  GatewayResourceType,
  NormalizedIdentifier,
} from './fhir-sync.types';
import {
  InternalRecordInsert,
  MedicationResupplyInsert,
} from './fhir-sync.mapper';

type ProfileRow = Database['public']['Tables']['profiles']['Row'];
type PatientIdentifierInsert =
  Database['public']['Tables']['patient_identifiers']['Insert'];
type ImmunizationRecordRow =
  Database['public']['Tables']['immunization_records']['Row'];
type MedicalHistoryRecordRow =
  Database['public']['Tables']['medical_history_records']['Row'];
type MedicalConsultationRecordRow =
  Database['public']['Tables']['medical_consultation_records']['Row'];
type LaboratoryResultRecordRow =
  Database['public']['Tables']['laboratory_result_records']['Row'];
type MedicationResupplyHistoryRecordRow =
  Database['public']['Tables']['medication_resupply_history_records']['Row'];

const LIST_LIMIT = 100;
const PHILHEALTH_IDENTIFIER_SYSTEM =
  'http://philhealth.gov.ph/fhir/Identifier/philhealth-id';
const LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM = 'http://philhealth.gov.ph';
const PHILSYS_IDENTIFIER_SYSTEM = 'http://philsys.gov.ph/fhir/Identifier/philsys-id';
const PHILSYS_IDENTIFIER_SYSTEM_HTTPS = 'https://philsys.gov.ph/fhir/Identifier/philsys-id';

@Injectable()
export class FhirSyncRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findProfileIdByIdentifiers(
    identifiers: GatewayIdentifier[],
  ): Promise<string | null> {
    const normalizedIdentifiers = identifiers
      .map((identifier) => this.normalizeIdentifier(identifier))
      .filter((identifier): identifier is NormalizedIdentifier => identifier !== null);

    for (const identifier of normalizedIdentifiers) {
      for (const identifierSystem of this.getLookupSystems(identifier.system)) {
        const { data, error } = await this.supabaseService.adminClient
          .from('patient_identifiers')
          .select('profile_id')
          .eq('identifier_system', identifierSystem)
          .eq('identifier_value', identifier.value)
          .maybeSingle();

        if (error !== null) {
          throw new InternalServerErrorException('Unable to resolve patient identifiers');
        }

        if (data !== null) {
          return data.profile_id;
        }
      }
    }

    return null;
  }

  async upsertPatientIdentifiers(
    profileId: string,
    identifiers: GatewayIdentifier[],
  ): Promise<void> {
    const normalizedIdentifiers = identifiers
      .map((identifier) => this.normalizeIdentifier(identifier))
      .filter((identifier): identifier is NormalizedIdentifier => identifier !== null);

    if (normalizedIdentifiers.length === 0) {
      return;
    }

    const payload: PatientIdentifierInsert[] = normalizedIdentifiers.map(
      (identifier) => ({
        profile_id: profileId,
        identifier_system: identifier.system,
        identifier_value: identifier.value,
        verified_at: new Date().toISOString(),
      }),
    );

    const { error } = await this.supabaseService.adminClient
      .from('patient_identifiers')
      .upsert(payload, {
        onConflict: 'profile_id,identifier_system,identifier_value',
      });

    if (error !== null) {
      throw new InternalServerErrorException('Unable to store patient identifiers');
    }
  }

  async upsertSyncTransaction(input: {
    transactionId: string;
    profileId: string;
    requesterId: string;
    targetProviderId: string;
    resourceType: GatewayResourceType;
  }): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('fhir_sync_transactions')
      .upsert(
        {
          transaction_id: input.transactionId,
          profile_id: input.profileId,
          requester_id: input.requesterId,
          target_provider_id: input.targetProviderId,
          resource_type: input.resourceType,
        },
        {
          onConflict: 'transaction_id',
        },
      );

    if (error !== null) {
      throw new InternalServerErrorException('Unable to store sync transaction');
    }
  }

  async findProfileIdByTransactionId(
    transactionId: string,
  ): Promise<string | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('fhir_sync_transactions')
      .select('profile_id')
      .eq('transaction_id', transactionId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException('Unable to resolve sync transaction');
    }

    if (data === null) {
      return null;
    }

    return data.profile_id;
  }

  async getProfile(profileId: string): Promise<ProfileRow | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .select('*')
      .eq('id', profileId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException('Unable to load patient profile');
    }

    return (data as ProfileRow | null) ?? null;
  }

  async updateProfile(
    profileId: string,
    patch: {
      givenNames: string[];
      familyName: string;
      patientProfile: Database['public']['Tables']['profiles']['Row']['patient_profile'];
    },
  ): Promise<void> {
    const existingProfile = await this.getProfile(profileId);
    if (existingProfile === null) {
      throw new BadRequestException('The target patient profile does not exist yet.');
    }

    const { error } = await this.supabaseService.adminClient
      .from('profiles')
      .update({
        given_names: patch.givenNames,
        family_name: patch.familyName,
        patient_profile: patch.patientProfile,
      })
      .eq('id', profileId);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to update patient profile');
    }
  }

  async insertClinicalRecord(
    resourceType: GatewayResourceType,
    profileId: string,
    record: InternalRecordInsert,
  ): Promise<void> {
    const payload = {
      profile_id: profileId,
      title: record.title,
      subtitle: record.subtitle,
      summary_label: record.summaryLabel,
      summary_value: record.summaryValue,
      filter_value: record.filterValue,
      status_label: record.statusLabel,
      status_color_key: record.statusColorKey,
      accent_color_key: record.accentColorKey,
      icon_key: record.iconKey,
      details_json: record.detailsJson,
      recorded_at: record.recordedAt,
      display_order: record.displayOrder,
    };

    const tableName = this.resolveClinicalTableName(resourceType);
    const { error } = await this.supabaseService.adminClient
      .from(tableName)
      .insert(payload as never);

    if (error !== null) {
      throw new InternalServerErrorException(`Unable to store ${resourceType} record`);
    }
  }

  async insertMedicationResupplyRecord(
    profileId: string,
    record: MedicationResupplyInsert,
    metadata?: {
      gatewayTransactionId?: string;
      correlationId?: string;
    },
  ): Promise<void> {
    const { error } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .insert({
        profile_id: profileId,
        gateway_transaction_id: metadata?.gatewayTransactionId ?? '',
        correlation_id: metadata?.correlationId ?? '',
        medication_name: record.medicationName,
        dosage: record.dosage,
        status: record.status,
        note: record.note,
        requested_at: record.requestedAt,
        display_order: record.displayOrder,
      } as never);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to store medication request record');
    }
  }

  async updateMedicationResupplyGatewayTransactionIdByCorrelationId(
    correlationId: string,
    gatewayTransactionId: string,
  ): Promise<boolean> {
    return this.updateMedicationResupplyByColumn(
      'gateway_transaction_id',
      gatewayTransactionId,
      correlationId,
    );
  }

  async markMedicationResupplyApprovedByCorrelationId(
    correlationId: string,
  ): Promise<boolean> {
    const { data: rows, error: listError } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .select('id')
      .eq('correlation_id', correlationId)
      .limit(1);

    if (listError !== null) {
      throw new InternalServerErrorException(
        'Unable to load medication resupply history record for status update',
      );
    }

    if (rows === null || rows.length === 0) {
      return false;
    }

    const { error } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .update({
        status: 'approved',
      } as never)
      .eq('correlation_id', correlationId);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to update medication resupply status',
      );
    }

    return true;
  }

  async listRecords(profileId: string, resourceType: GatewayResourceType): Promise<unknown[]> {
    switch (resourceType) {
      case 'Patient':
        return this.listProfiles(profileId);
      case 'Immunization':
        return this.listTable('immunization_records', profileId);
      case 'Condition':
      case 'Procedure':
        return this.listTable('medical_history_records', profileId);
      case 'Encounter':
        return this.listTable('medical_consultation_records', profileId);
      case 'Observation':
        return this.listTable('laboratory_result_records', profileId);
      case 'MedicationRequest':
        return this.listMedicationResupply(profileId);
      default:
        return [];
    }
  }

  private async listProfiles(profileId: string): Promise<ProfileRow[]> {
    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .select('*')
      .eq('id', profileId)
      .limit(1);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to load patient profile');
    }

    return (data as ProfileRow[] | null) ?? [];
  }

  private async listMedicationResupply(profileId: string): Promise<MedicationResupplyHistoryRecordRow[]> {
    const { data, error } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .select('*')
      .eq('profile_id', profileId)
      .order('display_order', { ascending: true })
      .order('requested_at', { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException('Unable to load medication resupply history');
    }

    return (data ?? []) as MedicationResupplyHistoryRecordRow[];
  }

  private async listTable(
    tableName:
      | 'immunization_records'
      | 'medical_history_records'
      | 'medical_consultation_records'
      | 'laboratory_result_records',
    profileId: string,
  ): Promise<
    | ImmunizationRecordRow[]
    | MedicalHistoryRecordRow[]
    | MedicalConsultationRecordRow[]
    | LaboratoryResultRecordRow[]
  > {
    const { data, error } = await this.supabaseService.adminClient
      .from(tableName)
      .select('*')
      .eq('profile_id', profileId)
      .order('display_order', { ascending: true })
      .order('recorded_at', { ascending: false })
      .limit(LIST_LIMIT);

    if (error !== null) {
      throw new InternalServerErrorException(`Unable to load ${tableName.replaceAll('_', ' ')}`);
    }

    return (data ?? []) as
      | ImmunizationRecordRow[]
      | MedicalHistoryRecordRow[]
      | MedicalConsultationRecordRow[]
      | LaboratoryResultRecordRow[];
  }

  private resolveClinicalTableName(
    resourceType: GatewayResourceType,
  ):
    | 'immunization_records'
    | 'medical_history_records'
    | 'medical_consultation_records'
    | 'laboratory_result_records' {
    switch (resourceType) {
      case 'Immunization':
        return 'immunization_records';
      case 'Condition':
      case 'Procedure':
        return 'medical_history_records';
      case 'Encounter':
        return 'medical_consultation_records';
      case 'Observation':
        return 'laboratory_result_records';
      default:
        throw new BadRequestException(`Unsupported resource type for clinical storage: ${resourceType}`);
    }
  }

  private async updateMedicationResupplyByColumn(
    column: 'gateway_transaction_id',
    value: string,
    correlationId: string,
  ): Promise<boolean> {
    const { data: rows, error: listError } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .select('id')
      .eq('correlation_id', correlationId)
      .limit(1);

    if (listError !== null) {
      throw new InternalServerErrorException(
        'Unable to load medication resupply history record for transaction update',
      );
    }

    if (rows === null || rows.length === 0) {
      return false;
    }

    const { error } = await this.supabaseService.adminClient
      .from('medication_resupply_history_records')
      .update(
        {
          [column]: value,
        } as never,
      )
      .eq('correlation_id', correlationId);

    if (error !== null) {
      throw new InternalServerErrorException(
        'Unable to update medication resupply transaction id',
      );
    }

    return true;
  }

  private normalizeIdentifier(
    identifier: GatewayIdentifier,
  ): NormalizedIdentifier | null {
    const system = identifier.system.trim();
    const value = identifier.value.trim();
    if (system.length === 0 || value.length === 0) {
      return null;
    }

    return {
      system: this.normalizeIdentifierSystem(system),
      value,
    };
  }

  private getLookupSystems(system: string): string[] {
    if (system === PHILHEALTH_IDENTIFIER_SYSTEM) {
      return [PHILHEALTH_IDENTIFIER_SYSTEM, LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM];
    }

    if (system === LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM) {
      return [LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM, PHILHEALTH_IDENTIFIER_SYSTEM];
    }

    if (system === PHILSYS_IDENTIFIER_SYSTEM) {
      return [PHILSYS_IDENTIFIER_SYSTEM, PHILSYS_IDENTIFIER_SYSTEM_HTTPS];
    }

    if (system === PHILSYS_IDENTIFIER_SYSTEM_HTTPS) {
      return [PHILSYS_IDENTIFIER_SYSTEM_HTTPS, PHILSYS_IDENTIFIER_SYSTEM];
    }

    return [system];
  }

  private normalizeIdentifierSystem(system: string): string {
    if (system === LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM) {
      return PHILHEALTH_IDENTIFIER_SYSTEM;
    }

    if (system === PHILSYS_IDENTIFIER_SYSTEM_HTTPS) {
      return PHILSYS_IDENTIFIER_SYSTEM;
    }

    return system;
  }
}
