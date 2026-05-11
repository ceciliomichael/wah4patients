import { FhirPatientResource } from '../fhir-sync.types';
import { requirePhCoreProfile } from '../fhir-sync.profile';
import { ParsedPatientResource } from './fhir-parser.types';
import { assertResourceRecord } from './fhir-parser.utils';

export function parsePatientResource(resource: unknown): ParsedPatientResource {
  const record = assertResourceRecord(resource, 'Patient');
  const profile = requirePhCoreProfile(record, 'Patient');

  return {
    kind: 'patient',
    resourceType: 'Patient',
    profile,
    resource: record as FhirPatientResource,
  };
}
