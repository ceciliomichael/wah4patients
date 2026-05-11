import { Json } from '../supabase/database.types';

export type GatewayResourceType =
  | 'Patient'
  | 'Condition'
  | 'Procedure'
  | 'Immunization'
  | 'Encounter'
  | 'Observation'
  | 'MedicationRequest';

export type GatewayWebhookStatus = 'SUCCESS' | 'REJECTED' | 'ERROR';

export interface GatewayIdentifier {
  system: string;
  value: string;
}

export interface GatewayProcessQueryRequest {
  transactionId: string;
  requesterId: string;
  identifiers: GatewayIdentifier[];
  resourceType: GatewayResourceType;
  gatewayReturnUrl: string;
  reason?: string;
  notes?: string;
}

export interface GatewayReceiveResultsRequest {
  transactionId: string;
  status: GatewayWebhookStatus;
  data: unknown;
}

export interface GatewayReceivePushRequest {
  transactionId: string;
  senderId: string;
  resourceType: GatewayResourceType;
  resource: unknown;
  reason?: string;
  notes?: string;
}

export interface FhirCoding {
  system?: string;
  code?: string;
  display?: string;
}

export interface FhirCodeableConcept {
  coding?: FhirCoding[];
  text?: string;
}

export interface FhirReference {
  reference?: string;
  display?: string;
  identifier?: GatewayIdentifier;
}

export interface FhirHumanName {
  family?: string;
  given?: string[];
  text?: string;
}

export interface FhirAddress {
  text?: string;
  line?: string[];
  city?: string;
  state?: string;
  postalCode?: string;
  country?: string;
}

export interface FhirTelecom {
  system?: string;
  value?: string;
  use?: string;
}

export interface FhirPatientResource {
  resourceType: 'Patient';
  id?: string;
  identifier?: GatewayIdentifier[];
  name?: FhirHumanName[];
  birthDate?: string;
  gender?: string;
  telecom?: FhirTelecom[];
  address?: FhirAddress[];
}

export interface FhirBundleEntry {
  resource?: Record<string, unknown>;
}

export interface FhirBundleResource {
  resourceType: 'Bundle';
  type?: string;
  entry?: FhirBundleEntry[];
}

export interface FhirResourceRecord {
  resourceType?: string;
  id?: string;
  [key: string]: unknown;
}

export interface FhirOutcomeIssue {
  severity: 'information' | 'warning' | 'error' | 'fatal';
  code: string;
  diagnostics?: string;
}

export interface FhirOperationOutcome {
  resourceType: 'OperationOutcome';
  issue: FhirOutcomeIssue[];
}

export interface FhirPatientProfilePatch {
  givenNames: string[];
  familyName: string;
  patientProfile: Json;
}

export interface NormalizedIdentifier {
  system: string;
  value: string;
}

export interface NormalizedPatientMatch {
  profileId: string;
  identifier: NormalizedIdentifier;
}

export interface FhirSyncAcknowledgement {
  message: string;
}
