import { InternalRecordInsert, MedicationResupplyInsert } from '../fhir-sync.mapper';
import { FhirPatientResource, GatewayResourceType } from '../fhir-sync.types';

export interface ParsedPatientResource {
  kind: 'patient';
  resourceType: 'Patient';
  profile: string;
  resource: FhirPatientResource;
}

export interface ParsedClinicalResource<
  TResourceType extends Exclude<GatewayResourceType, 'Patient'> = Exclude<GatewayResourceType, 'Patient'>,
> {
  kind: 'clinical';
  resourceType: TResourceType;
  profile: string;
  resource: Record<string, unknown>;
  insert: InternalRecordInsert | MedicationResupplyInsert;
}

export type ParsedInboundResource = ParsedPatientResource | ParsedClinicalResource;
