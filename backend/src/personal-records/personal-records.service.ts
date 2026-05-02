import { BadRequestException, Injectable } from '@nestjs/common';
import { AuthSupportService } from '../auth/auth-support.service';
import { CreateBmiRecordDto } from './dto/create-bmi-record.dto';
import { CreateBloodPressureRecordDto } from './dto/create-blood-pressure-record.dto';
import { CreateMedicationIntakeRecordDto } from './dto/create-medication-intake-record.dto';
import { CreateTemperatureRecordDto } from './dto/create-temperature-record.dto';
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
import { PersonalRecordsRepository } from './personal-records.repository';

@Injectable()
export class PersonalRecordsService {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly personalRecordsRepository: PersonalRecordsRepository,
  ) {}

  async getBmiRecords(
    authorizationHeader: string | undefined,
  ): Promise<BmiRecordsResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.personalRecordsRepository.listBmiRecords(authenticatedUser.id);
  }

  async createBmiRecord(
    authorizationHeader: string | undefined,
    dto: CreateBmiRecordDto,
  ): Promise<BmiRecordResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const input: CreateBmiRecordInput = {
      weightValue: dto.weightValue,
      heightValue: dto.heightValue,
      measurementSystem: dto.measurementSystem,
      manualBmiValue: dto.manualBmiValue ?? null,
      notes: this.normalizeNullableText(dto.notes),
    };

    return this.personalRecordsRepository.createBmiRecord(
      authenticatedUser.id,
      input,
    );
  }

  async getBloodPressureRecords(
    authorizationHeader: string | undefined,
  ): Promise<BloodPressureRecordsResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.personalRecordsRepository.listBloodPressureRecords(
      authenticatedUser.id,
    );
  }

  async createBloodPressureRecord(
    authorizationHeader: string | undefined,
    dto: CreateBloodPressureRecordDto,
  ): Promise<BloodPressureRecordResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const input: CreateBloodPressureRecordInput = {
      systolicMmHg: dto.systolicMmHg,
      diastolicMmHg: dto.diastolicMmHg,
      pulseRate: dto.pulseRate ?? null,
      measurementPosition: dto.measurementPosition ?? null,
      measurementMethod: this.normalizeNullableText(dto.measurementMethod),
      notes: this.normalizeNullableText(dto.notes),
    };

    return this.personalRecordsRepository.createBloodPressureRecord(
      authenticatedUser.id,
      input,
    );
  }

  async getTemperatureRecords(
    authorizationHeader: string | undefined,
  ): Promise<TemperatureRecordsResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.personalRecordsRepository.listTemperatureRecords(
      authenticatedUser.id,
    );
  }

  async createTemperatureRecord(
    authorizationHeader: string | undefined,
    dto: CreateTemperatureRecordDto,
  ): Promise<TemperatureRecordResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const input: CreateTemperatureRecordInput = {
      temperatureValue: dto.temperatureValue,
      temperatureUnit: dto.temperatureUnit,
      measurementMethod: this.normalizeNullableText(dto.measurementMethod),
      notes: this.normalizeNullableText(dto.notes),
    };

    return this.personalRecordsRepository.createTemperatureRecord(
      authenticatedUser.id,
      input,
    );
  }

  async getMedicationIntakeRecords(
    authorizationHeader: string | undefined,
  ): Promise<MedicationIntakeRecordsResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.personalRecordsRepository.listMedicationIntakeRecords(
      authenticatedUser.id,
    );
  }

  async createMedicationIntakeRecord(
    authorizationHeader: string | undefined,
    dto: CreateMedicationIntakeRecordDto,
  ): Promise<MedicationIntakeRecordResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    const input: CreateMedicationIntakeRecordInput = {
      prescriptionId: this.normalizeNullableText(dto.prescriptionId),
      medicationReference: this.normalizeNullableText(dto.medicationReference),
      medicationNameSnapshot: this.normalizeRequiredText(
        dto.medicationNameSnapshot,
      ),
      scheduledAt: dto.scheduledAt,
      takenAt: this.normalizeNullableText(dto.takenAt),
      status: dto.status,
      quantityValue: dto.quantityValue ?? null,
      quantityUnit: this.normalizeNullableText(dto.quantityUnit),
      notes: this.normalizeNullableText(dto.notes),
    };

    return this.personalRecordsRepository.createMedicationIntakeRecord(
      authenticatedUser.id,
      input,
    );
  }

  private normalizeNullableText(value: string | null | undefined): string | null {
    const normalized = value?.trim() ?? '';
    return normalized.length > 0 ? normalized : null;
  }

  private normalizeRequiredText(value: string): string {
    const normalized = value.trim();
    if (normalized.length === 0) {
      throw new BadRequestException('medicationNameSnapshot cannot be blank');
    }

    return normalized;
  }
}
