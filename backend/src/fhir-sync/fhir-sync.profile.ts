import { BadRequestException } from '@nestjs/common';

const PH_CORE_PROFILE_SUFFIXES = {
  Patient: '/phcore/StructureDefinition/ph-core-patient',
  Immunization: '/phcore/StructureDefinition/ph-core-immunization',
  Encounter: '/phcore/StructureDefinition/ph-core-encounter',
  Observation: '/phcore/StructureDefinition/ph-core-observation',
  Condition: '/phcore/StructureDefinition/ph-core-condition',
  Procedure: '/phcore/StructureDefinition/ph-core-procedure',
  MedicationRequest: '/phcore/StructureDefinition/ph-core-medicationrequest',
} as const;

export type SupportedPhCoreProfileResourceType = keyof typeof PH_CORE_PROFILE_SUFFIXES;

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function readProfileList(resource: Record<string, unknown>): string[] {
  if (!isRecord(resource['meta']) || !Array.isArray(resource['meta']['profile'])) {
    return [];
  }

  return resource['meta']['profile'].filter((profile): profile is string => typeof profile === 'string');
}

export function requirePhCoreProfile(
  resource: Record<string, unknown>,
  resourceType: SupportedPhCoreProfileResourceType,
): string {
  const expectedSuffix = PH_CORE_PROFILE_SUFFIXES[resourceType];
  const profiles = readProfileList(resource);
  const matchedProfile = profiles.find((profile) => profile.endsWith(expectedSuffix));

  if (matchedProfile === undefined) {
    throw new BadRequestException(
      `Expected PH Core profile ending with "${expectedSuffix}" for ${resourceType} payload.`,
    );
  }

  return matchedProfile;
}
