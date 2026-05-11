import { BadRequestException } from '@nestjs/common';
import { GatewayResourceType } from '../fhir-sync.types';
import { SupportedPhCoreProfileResourceType } from '../fhir-sync.profile';

const SUPPORTED_RESOURCE_TYPES: GatewayResourceType[] = [
  'Patient',
  'Condition',
  'Procedure',
  'Immunization',
  'Encounter',
  'Observation',
  'MedicationRequest',
];

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function readProfileList(resource: Record<string, unknown>): string[] {
  if (!isRecord(resource['meta']) || !Array.isArray(resource['meta']['profile'])) {
    return [];
  }

  return resource['meta']['profile'].filter((profile): profile is string => typeof profile === 'string');
}

export function readResourceType(value: unknown): GatewayResourceType {
  if (!isRecord(value) || typeof value['resourceType'] !== 'string') {
    throw new BadRequestException('Missing required field: resourceType');
  }

  const resourceType = value['resourceType'].trim();
  if (!SUPPORTED_RESOURCE_TYPES.includes(resourceType as GatewayResourceType)) {
    throw new BadRequestException(`Unsupported resource type: ${resourceType}`);
  }

  return resourceType as GatewayResourceType;
}

export function assertResourceRecord<TExpected extends GatewayResourceType>(
  value: unknown,
  expectedResourceType: TExpected,
): Record<string, unknown> {
  if (!isRecord(value)) {
    throw new BadRequestException(`Invalid ${expectedResourceType} payload.`);
  }

  const resourceType = readResourceType(value);
  if (resourceType !== expectedResourceType) {
    throw new BadRequestException(
      `Expected ${expectedResourceType} payload, received ${resourceType}.`,
    );
  }

  return value;
}

export function readStrictPhCoreProfile(
  resource: Record<string, unknown>,
  resourceType: SupportedPhCoreProfileResourceType,
): string {
  const expectedSuffix = `/phcore/StructureDefinition/ph-core-${resourceType.toLowerCase()}`;
  const profiles = readProfileList(resource);
  const matchedProfile = profiles.find((profile) => profile.endsWith(expectedSuffix));

  if (matchedProfile === undefined) {
    throw new BadRequestException(
      `Expected PH Core profile ending with "${expectedSuffix}" for ${resourceType} payload.`,
    );
  }

  return matchedProfile;
}
