import { GatewayResourceType } from '../fhir-sync/fhir-sync.types';

export interface GatewayProviderRecord {
  id: string;
  name: string;
  type: string;
  facility_code: string;
  location: string;
  isActive: boolean;
}

export interface InteroperabilityProviderSummary {
  id: string;
  name: string;
  type: string;
  facilityCode: string;
  location: string;
  isActive: boolean;
}

export interface InteroperabilityProvidersResponse {
  source: 'wah4pc';
  providers: InteroperabilityProviderSummary[];
}

export interface SyncIdentifierPayload {
  system: string;
  value: string;
}

export interface PrepareSyncRequestPayload {
  providerId: string;
  identifierSystem: string;
  identifierValue: string;
  resourceType?: string;
  reason?: string;
  notes?: string;
}

export interface PreparedSyncRequestResponse {
  canSubmit: true;
  requesterId: string;
  targetProvider: InteroperabilityProviderSummary;
  patientIdentifiers: SyncIdentifierPayload[];
  resourceType: string;
  gatewayUrl: string;
  reason?: string;
  notes?: string;
}

export interface SimulatedSyncRequestResponse {
  message: string;
  transactionId: string;
  storedResourceTypes: GatewayResourceType[];
}
