import { Body, Controller, Get, Headers, Post } from '@nestjs/common';
import { CreateBmiRecordDto } from './dto/create-bmi-record.dto';
import { CreateBloodPressureRecordDto } from './dto/create-blood-pressure-record.dto';
import { CreateMedicationIntakeRecordDto } from './dto/create-medication-intake-record.dto';
import { CreateTemperatureRecordDto } from './dto/create-temperature-record.dto';
import {
  BmiRecordResponse,
  BmiRecordsResponse,
  BloodPressureRecordResponse,
  BloodPressureRecordsResponse,
  MedicationIntakeRecordResponse,
  MedicationIntakeRecordsResponse,
  TemperatureRecordResponse,
  TemperatureRecordsResponse,
} from './personal-records.types';
import { PersonalRecordsService } from './personal-records.service';

@Controller('phr')
export class PersonalRecordsController {
  constructor(
    private readonly personalRecordsService: PersonalRecordsService,
  ) {}

  @Get('bmi-records')
  getBmiRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<BmiRecordsResponse> {
    return this.personalRecordsService.getBmiRecords(authorizationHeader);
  }

  @Post('bmi-records')
  createBmiRecord(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Body() dto: CreateBmiRecordDto,
  ): Promise<BmiRecordResponse> {
    return this.personalRecordsService.createBmiRecord(
      authorizationHeader,
      dto,
    );
  }

  @Get('blood-pressure-records')
  getBloodPressureRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<BloodPressureRecordsResponse> {
    return this.personalRecordsService.getBloodPressureRecords(
      authorizationHeader,
    );
  }

  @Post('blood-pressure-records')
  createBloodPressureRecord(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Body() dto: CreateBloodPressureRecordDto,
  ): Promise<BloodPressureRecordResponse> {
    return this.personalRecordsService.createBloodPressureRecord(
      authorizationHeader,
      dto,
    );
  }

  @Get('temperature-records')
  getTemperatureRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<TemperatureRecordsResponse> {
    return this.personalRecordsService.getTemperatureRecords(
      authorizationHeader,
    );
  }

  @Post('temperature-records')
  createTemperatureRecord(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Body() dto: CreateTemperatureRecordDto,
  ): Promise<TemperatureRecordResponse> {
    return this.personalRecordsService.createTemperatureRecord(
      authorizationHeader,
      dto,
    );
  }

  @Get('medication-intake-records')
  getMedicationIntakeRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<MedicationIntakeRecordsResponse> {
    return this.personalRecordsService.getMedicationIntakeRecords(
      authorizationHeader,
    );
  }

  @Post('medication-intake-records')
  createMedicationIntakeRecord(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Body() dto: CreateMedicationIntakeRecordDto,
  ): Promise<MedicationIntakeRecordResponse> {
    return this.personalRecordsService.createMedicationIntakeRecord(
      authorizationHeader,
      dto,
    );
  }
}
