import { ParsedInboundResource } from './fhir-parser.types';
import { readResourceType } from './fhir-parser.utils';
import { parseConditionResource } from './condition.parser';
import { parseEncounterResource } from './encounter.parser';
import { parseImmunizationResource } from './immunization.parser';
import { parseMedicationRequestResource } from './medication-request.parser';
import { parseObservationResource } from './observation.parser';
import { parsePatientResource } from './patient.parser';
import { parseProcedureResource } from './procedure.parser';

export function parseInboundResource(resource: unknown): ParsedInboundResource {
  const resourceType = readResourceType(resource);

  switch (resourceType) {
    case 'Patient':
      return parsePatientResource(resource);
    case 'Condition':
      return parseConditionResource(resource);
    case 'Procedure':
      return parseProcedureResource(resource);
    case 'Immunization':
      return parseImmunizationResource(resource);
    case 'Encounter':
      return parseEncounterResource(resource);
    case 'Observation':
      return parseObservationResource(resource);
    case 'MedicationRequest':
      return parseMedicationRequestResource(resource);
    default:
      const exhaustiveCheck: never = resourceType;
      return exhaustiveCheck;
  }
}

export function isParsedPatientResource(
  value: ParsedInboundResource,
): value is Extract<ParsedInboundResource, { kind: 'patient' }> {
  return value.kind === 'patient';
}
