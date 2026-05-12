import { BadRequestException, Injectable, InternalServerErrorException } from '@nestjs/common';
import { existsSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import { resolve } from 'node:path';
import { AuthSupportService } from '../auth/auth-support.service';
import { FhirSyncService } from '../fhir-sync/fhir-sync.service';
import { GatewayResourceType, FhirBundleResource } from '../fhir-sync/fhir-sync.types';
import { SimulateSyncRequestDto } from './dto/simulate-sync-request.dto';
import {
  SimulatedSyncRequestResponse,
  SyncIdentifierPayload,
} from './integration.types';
import { IntegrationService } from './integration.service';

interface SimulationFixtureDefinition {
  readonly resourceType: GatewayResourceType;
  readonly fileName: string;
}

const SIMULATION_FIXTURES: readonly SimulationFixtureDefinition[] = [
  {
    resourceType: 'Patient',
    fileName: 'Patient-patient-single-example.json',
  },
  {
    resourceType: 'Immunization',
    fileName: 'Immunization-immunization-single-example.json',
  },
  {
    resourceType: 'Encounter',
    fileName: 'Encounter-encounter-single-example.json',
  },
  {
    resourceType: 'Observation',
    fileName: 'Observation-observation-bp-example.json',
  },
  {
    resourceType: 'Condition',
    fileName: 'Condition-condition-single-example.json',
  },
  {
    resourceType: 'Procedure',
    fileName: 'Procedure-procedure-single-example.json',
  },
  {
    resourceType: 'MedicationRequest',
    fileName: 'MedicationRequest-medicationrequest-single-example.json',
  },
] as const;

@Injectable()
export class SyncSimulationService {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly integrationService: IntegrationService,
    private readonly fhirSyncService: FhirSyncService,
  ) {}

  async simulateSyncRequest(
    authorizationHeader: string | undefined,
    userId: string | undefined,
    dto: SimulateSyncRequestDto,
  ): Promise<SimulatedSyncRequestResponse> {
    const preparedRequest = await this.integrationService.prepareSyncRequest(dto);
    const patientIdentifier = preparedRequest.patientIdentifiers[0];
    if (patientIdentifier === undefined) {
      throw new BadRequestException('Select a valid identifier before simulating sync.');
    }

    const profileId = await this.resolveProfileId(authorizationHeader, userId);
    const bundle = await this.buildSimulationBundle(patientIdentifier);
    const transactionId = `sim_${randomUUID()}`;

    await this.fhirSyncService.receiveResultsForProfile(profileId, {
      transactionId,
      status: 'SUCCESS',
      data: bundle,
    });

    return {
      message: 'Simulated PH Core bundle stored successfully.',
      transactionId,
      storedResourceTypes: SIMULATION_FIXTURES.map((fixture) => fixture.resourceType),
    };
  }

  private async buildSimulationBundle(
    identifier: { system: string; value: string },
  ): Promise<FhirBundleResource> {
    const resources = await Promise.all(
      SIMULATION_FIXTURES.map(async (fixture) => {
        const resource = await this.readFixture(fixture.fileName);
        if (fixture.resourceType === 'Patient') {
          this.applyIdentifier(resource, identifier);
        }

        return resource;
      }),
    );

    return {
      resourceType: 'Bundle',
      type: 'collection',
      entry: resources.map((resource) => ({ resource })),
    };
  }

  private async readFixture(fileName: string): Promise<Record<string, unknown>> {
    const filePath = this.resolveFixturePath(fileName);
    try {
      const fileContents = await readFile(filePath, 'utf8');
      const parsed = JSON.parse(fileContents) as unknown;
      if (!this.isRecord(parsed)) {
        throw new Error('Fixture is not an object.');
      }

      return parsed;
    } catch {
      throw new InternalServerErrorException(
        `Unable to parse the simulation fixture ${fileName}.`,
      );
    }
  }

  private resolveFixturePath(fileName: string): string {
    const candidates = [
      resolve(process.cwd(), 'simulation-files', fileName),
      resolve(process.cwd(), '..', 'simulation-files', fileName),
      resolve(process.cwd(), 'resources', 'examples', 'ph-core', fileName),
      resolve(process.cwd(), '..', 'resources', 'examples', 'ph-core', fileName),
      resolve(
        process.cwd(),
        '..',
        '..',
        'resources',
        'examples',
        'ph-core',
        fileName,
      ),
    ];

    for (const candidate of candidates) {
      if (existsSync(candidate)) {
        return candidate;
      }
    }

    throw new InternalServerErrorException(
      `Unable to locate the simulation fixture ${fileName}.`,
    );
  }

  private applyIdentifier(
    resource: Record<string, unknown>,
    identifier: SyncIdentifierPayload,
  ): void {
    resource['identifier'] = [
      {
        system: identifier.system,
        value: identifier.value,
      },
    ];
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
  }

  private async resolveProfileId(
    authorizationHeader: string | undefined,
    userId: string | undefined,
  ): Promise<string> {
    const trimmedUserId = userId?.trim() ?? '';
    if (trimmedUserId.length > 0) {
      return trimmedUserId;
    }

    const trimmedAuthorization = authorizationHeader?.trim() ?? '';
    if (trimmedAuthorization.length > 0) {
      const authenticatedUser =
        await this.authSupportService.getAuthenticatedUserFromHeader(
          trimmedAuthorization,
        );
      return authenticatedUser.id;
    }

    throw new BadRequestException('Missing authenticated account context.');
  }

  private readRequiredProfileId(userId: string | undefined): string {
    const trimmed = userId?.trim() ?? '';
    if (trimmed.length === 0) {
      throw new BadRequestException('Missing authenticated account context.');
    }

    return trimmed;
  }
}
