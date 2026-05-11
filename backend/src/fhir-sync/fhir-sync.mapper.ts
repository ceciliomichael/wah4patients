import { Json } from '../supabase/database.types';
import {
  FhirBundleResource,
  FhirHumanName,
  FhirOperationOutcome,
  FhirPatientProfilePatch,
  FhirPatientResource,
  GatewayIdentifier,
  GatewayResourceType,
  GatewayWebhookStatus,
  NormalizedIdentifier,
} from './fhir-sync.types';

export interface PreparedFhirCallbackPayload {
  transactionId: string;
  status: GatewayWebhookStatus;
  data: unknown;
}

export interface InternalRecordDetail {
  label: string;
  value: string;
}

export interface InternalRecordInsert {
  title: string;
  subtitle: string;
  summaryLabel: string;
  summaryValue: string;
  filterValue: string;
  statusLabel: string;
  statusColorKey: string;
  accentColorKey: string;
  iconKey: string;
  detailsJson: Json;
  recordedAt: string;
  displayOrder: number;
}

export interface MedicationResupplyInsert {
  medicationName: string;
  dosage: string;
  status: 'pending' | 'approved' | 'rejected' | 'cancelled';
  note: string;
  requestedAt: string;
  displayOrder: number;
}

const PHILHEALTH_IDENTIFIER_SYSTEM = 'http://philhealth.gov.ph';
const PHILSYS_IDENTIFIER_SYSTEM = 'http://philsys.gov.ph/fhir/Identifier/philsys-id';

export function normalizeIdentifier(value: unknown): NormalizedIdentifier | null {
  if (!isRecord(value)) {
    return null;
  }

  const system = typeof value['system'] === 'string' ? value['system'].trim() : '';
  const identifierValue =
    typeof value['value'] === 'string' ? value['value'].trim() : '';
  if (system.length === 0 || identifierValue.length === 0) {
    return null;
  }

  return { system, value: identifierValue };
}

export function extractIdentifiersFromPatient(
  patient: FhirPatientResource,
): NormalizedIdentifier[] {
  return (patient.identifier ?? [])
    .map((identifier) => normalizeIdentifier(identifier))
    .filter((identifier): identifier is NormalizedIdentifier => identifier !== null);
}

export function extractPatientProfilePatch(
  patient: FhirPatientResource,
): FhirPatientProfilePatch {
  const name = firstValue(patient.name);
  const givenNames = name?.given?.map((value) => value.trim()).filter(Boolean) ?? [];
  const familyName = name?.family?.trim() ?? '';

  return {
    givenNames,
    familyName,
    patientProfile: {
      birthDate: patient.birthDate ?? null,
      gender: patient.gender ?? null,
      telecom: (patient.telecom ?? []).map((entry) => ({
        system: entry.system ?? null,
        value: entry.value ?? null,
        use: entry.use ?? null,
      })),
      address: (patient.address ?? []).map((entry) => ({
        text: entry.text ?? null,
        line: entry.line ?? [],
        city: entry.city ?? null,
        state: entry.state ?? null,
        postalCode: entry.postalCode ?? null,
        country: entry.country ?? null,
      })),
      identifier: extractIdentifiersFromPatient(patient).map((identifier) => ({
        system: identifier.system,
        value: identifier.value,
      })),
    } as Json,
  } satisfies FhirPatientProfilePatch;
}

export function extractIdentifiersFromUnknownResource(resource: unknown): NormalizedIdentifier[] {
  if (!isRecord(resource)) {
    return [];
  }

  if (resource['resourceType'] === 'Patient') {
    return extractIdentifiersFromPatient(resource as unknown as FhirPatientResource);
  }

  const patient = extractNestedPatient(resource);
  if (patient !== null) {
    return extractIdentifiersFromPatient(patient);
  }

  const directIdentifier = normalizeIdentifier(resource['identifier']);
  if (directIdentifier !== null) {
    return [directIdentifier];
  }

  const subjectIdentifier = normalizeIdentifier(
    isRecord(resource['subject']) ? resource['subject']['identifier'] : undefined,
  );
  if (subjectIdentifier !== null) {
    return [subjectIdentifier];
  }

  const patientIdentifier = normalizeIdentifier(
    isRecord(resource['patient']) ? resource['patient']['identifier'] : undefined,
  );
  if (patientIdentifier !== null) {
    return [patientIdentifier];
  }

  const participantIdentifiers = extractParticipantIdentifiers(resource['participant']);
  if (participantIdentifiers.length > 0) {
    return participantIdentifiers;
  }

  return [];
}

export function extractBundlePatient(
  payload: FhirBundleResource | unknown,
): FhirPatientResource | null {
  if (!isRecord(payload) || payload['resourceType'] !== 'Bundle') {
    return null;
  }

  const entryValue = payload['entry'];
  if (!Array.isArray(entryValue)) {
    return null;
  }

  for (const entry of entryValue) {
    if (!isRecord(entry)) {
      continue;
    }

    const resource = entry['resource'];
    if (isRecord(resource) && resource['resourceType'] === 'Patient') {
      return resource as unknown as FhirPatientResource;
    }
  }

  return null;
}

export function extractBundleResources(
  payload: FhirBundleResource | unknown,
): Record<string, unknown>[] {
  if (!isRecord(payload) || payload['resourceType'] !== 'Bundle') {
    return [];
  }

  const entryValue = payload['entry'];
  if (!Array.isArray(entryValue)) {
    return [];
  }

  return entryValue.flatMap((entry) => {
    if (!isRecord(entry) || !isRecord(entry['resource'])) {
      return [];
    }

    return [entry['resource'] as Record<string, unknown>];
  });
}

export function buildOperationOutcome(message: string): FhirOperationOutcome {
  return {
    resourceType: 'OperationOutcome',
    issue: [
      {
        severity: 'error',
        code: 'processing',
        diagnostics: message,
      },
    ],
  };
}

export function buildSuccessProcessQueryData(
  resourceType: GatewayResourceType,
  patient: FhirPatientResource,
  resources: unknown[],
): unknown {
  if (resourceType === 'Patient') {
    return buildPatientResource(patient);
  }

  if (resourceType === 'Immunization') {
    return buildBundle(resources, 'Immunization');
  }

  if (resourceType === 'MedicationRequest') {
    return buildBundle(resources, 'MedicationRequest');
  }

  if (resourceType === 'Encounter') {
    return buildBundle(resources, 'Encounter');
  }

  if (resourceType === 'Observation') {
    return buildBundle(resources, 'Observation');
  }

  if (resourceType === 'Condition') {
    return buildBundle(resources, 'Condition');
  }

  if (resourceType === 'Procedure') {
    return buildBundle(resources, 'Procedure');
  }

  return buildBundle(resources, resourceType);
}

export function mapPatientResourceToRecordPatch(patient: FhirPatientResource): FhirPatientProfilePatch {
  return extractPatientProfilePatch(patient);
}

export function buildInternalRecordInsert(
  resourceType: GatewayResourceType,
  resource: Record<string, unknown>,
): InternalRecordInsert | MedicationResupplyInsert | null {
  switch (resourceType) {
    case 'Patient':
      return null;
    case 'Immunization':
      return mapImmunizationResource(resource);
    case 'MedicationRequest':
      return mapMedicationRequestResource(resource);
    case 'Encounter':
      return mapEncounterResource(resource);
    case 'Observation':
      return mapObservationResource(resource);
    case 'Condition':
      return mapConditionResource(resource, 'Condition');
    case 'Procedure':
      return mapConditionResource(resource, 'Procedure');
    default:
      return null;
  }
}

export function extractPatientResourceIdentifiersFromBundle(
  payload: FhirBundleResource | unknown,
): NormalizedIdentifier[] {
  const patient = extractBundlePatient(payload);
  if (patient === null) {
    return [];
  }

  return extractIdentifiersFromPatient(patient);
}

export function getResourceTypeLabel(resourceType: GatewayResourceType): string {
  return resourceType;
}

export function normalizeAllowedIdentifier(
  identifier: GatewayIdentifier,
): NormalizedIdentifier | null {
  const normalized = normalizeIdentifier(identifier);
  if (normalized === null) {
    return null;
  }

  if (
    normalized.system === PHILHEALTH_IDENTIFIER_SYSTEM ||
    normalized.system === PHILSYS_IDENTIFIER_SYSTEM
  ) {
    return normalized;
  }

  return normalized;
}

export function extractHumanNameText(name: FhirHumanName | undefined): string {
  if (name === undefined) {
    return '';
  }

  const givenNames = name.given?.map((value) => value.trim()).filter(Boolean) ?? [];
  const familyName = name.family?.trim() ?? '';
  return [...givenNames, familyName].filter(Boolean).join(' ').trim();
}

function buildPatientResource(patient: FhirPatientResource): unknown {
  return {
    resourceType: 'Patient',
    id: patient.id ?? 'patient',
    identifier: patient.identifier ?? [],
    name: patient.name ?? [],
    birthDate: patient.birthDate,
    gender: patient.gender,
  };
}

function buildBundle(resources: unknown[], resourceType: string): unknown {
  return {
    resourceType: 'Bundle',
    type: 'collection',
    entry: resources
      .filter((resource) => isRecord(resource))
      .map((resource) => ({ resource: buildResourceSnapshot(resource, resourceType) })),
  };
}

function buildResourceSnapshot(
  resource: Record<string, unknown>,
  resourceType: string,
): Record<string, unknown> {
  return {
    resourceType,
    id: readString(resource['id']) || `${resourceType.toLowerCase()}-record`,
    ...resource,
  };
}

function mapImmunizationResource(resource: Record<string, unknown>): InternalRecordInsert {
  const vaccineName = readCodeableConceptText(resource['vaccineCode'], 'Immunization');
  const status = readString(resource['status']) || 'completed';
  const administeredAt = readString(resource['occurrenceDateTime']) || new Date().toISOString();
  const site = readCodeableConceptDisplay(resource['site']);
  const route = readCodeableConceptDisplay(resource['route']);
  const lotNumber = readString(resource['lotNumber']);
  const expirationDate = readString(resource['expirationDate']);
  const doseQuantity = readQuantity(resource['doseQuantity']);
  const performer = readImmunizationPerformer(resource['performer']);
  const notes = readNote(resource['note']);
  const fundingSource = readCodeableConceptText(resource['fundingSource'], 'unknown');

  return {
    title: vaccineName,
    subtitle: [status, administeredAt, site].filter(Boolean).join(' • '),
    summaryLabel: 'Vaccine',
    summaryValue: vaccineName,
    filterValue: [status, vaccineName, site, route, lotNumber]
      .filter(Boolean)
      .join(' ')
      .toLowerCase(),
    statusLabel: toTitleCase(status),
    statusColorKey: 'success',
    accentColorKey: 'secondary',
    iconKey: 'vaccines',
    detailsJson: [
      detailJson('Administered', administeredAt),
      detailJson('Site', site),
      detailJson('Route', route),
      detailJson('Lot number', lotNumber),
      detailJson('Expiration date', expirationDate),
      detailJson('Dose', doseQuantity),
      detailJson('Performer', performer),
      detailJson('Notes', notes),
      detailJson('Funding source', fundingSource),
      detailJson('Primary source', readBoolean(resource['primarySource']) ? 'Yes' : 'No'),
    ].filter((detail): detail is Json => detail !== null) as Json,
    recordedAt: administeredAt,
    displayOrder: 0,
  };
}

function mapMedicationRequestResource(resource: Record<string, unknown>): MedicationResupplyInsert {
  const medicationName =
    readCodeableConceptText(resource['medicationCodeableConcept'], 'Medication request') ||
    readString(resource['medicationReference']) ||
    'Medication request';
  const dosage = readDosageText(resource['dosageInstruction']);
  const status = normalizeMedicationResupplyStatus(readString(resource['status']));
  const requestedAt =
    readString(resource['authoredOn']) || readString(resource['recordedDate']) || new Date().toISOString();
  const note = readNote(resource['note']) || readString(resource['reasonCode']) || '';

  return {
    medicationName,
    dosage,
    status,
    note,
    requestedAt,
    displayOrder: 0,
  };
}

function mapEncounterResource(resource: Record<string, unknown>): InternalRecordInsert {
  const encounterType = readCodeableConceptText(resource['type'], 'Encounter');
  const status = readString(resource['status']) || 'finished';
  const recordedAt = readPeriodStart(resource['period']) || new Date().toISOString();
  const reason = readCodeableConceptText(resource['reasonCode'], 'Reason not provided');
  const provider = readReferenceDisplay(resource['participant']);
  const location = readReferenceDisplay(resource['location']);
  const notes = readNote(resource['note']);

  return {
    title: encounterType,
    subtitle: [status, recordedAt, provider].filter(Boolean).join(' • '),
    summaryLabel: 'Consultation',
    summaryValue: encounterType,
    filterValue: [status, encounterType, provider, location, reason]
      .filter(Boolean)
      .join(' ')
      .toLowerCase(),
    statusLabel: toTitleCase(status),
    statusColorKey: 'primary',
    accentColorKey: 'primary',
    iconKey: 'medical_services',
    detailsJson: [
      detailJson('Provider', provider),
      detailJson('Location', location),
      detailJson('Reason', reason),
      detailJson('Notes', notes),
    ].filter((detail): detail is Json => detail !== null) as Json,
    recordedAt,
    displayOrder: 0,
  };
}

function mapObservationResource(resource: Record<string, unknown>): InternalRecordInsert {
  const observationName = readCodeableConceptText(resource['code'], 'Observation');
  const status = readString(resource['status']) || 'final';
  const recordedAt =
    readString(resource['effectiveDateTime']) || readPeriodStart(resource['effectivePeriod']) || new Date().toISOString();
  const value = readQuantity(resource['valueQuantity']) || readString(resource['valueString']) || '';
  const performer = readReferenceDisplay(resource['performer']);
  const notes = readNote(resource['note']);

  return {
    title: observationName,
    subtitle: [status, recordedAt, value].filter(Boolean).join(' • '),
    summaryLabel: 'Result',
    summaryValue: value || observationName,
    filterValue: [status, observationName, value, performer].filter(Boolean).join(' ').toLowerCase(),
    statusLabel: toTitleCase(status),
    statusColorKey: 'success',
    accentColorKey: 'primary_dark',
    iconKey: 'science',
    detailsJson: [
      detailJson('Performer', performer),
      detailJson('Value', value),
      detailJson('Notes', notes),
    ].filter((detail): detail is Json => detail !== null) as Json,
    recordedAt,
    displayOrder: 0,
  };
}

function mapConditionResource(
  resource: Record<string, unknown>,
  resourceLabel: 'Condition' | 'Procedure',
): InternalRecordInsert {
  const title = readCodeableConceptText(
    resourceLabel === 'Condition' ? resource['code'] : resource['code'],
    resourceLabel,
  );
  const status = readString(resource['clinicalStatus'] ?? resource['status']) || 'active';
  const recordedAt =
    readPeriodStart(resource['onsetPeriod']) || readPeriodStart(resource['performedPeriod']) || new Date().toISOString();
  const notes = readNote(resource['note']);
  const provider = readReferenceDisplay(resource['asserter'] ?? resource['performer']);

  return {
    title,
    subtitle: [status, recordedAt, provider].filter(Boolean).join(' • '),
    summaryLabel: resourceLabel,
    summaryValue: title,
    filterValue: [status, title, provider].filter(Boolean).join(' ').toLowerCase(),
    statusLabel: toTitleCase(status),
    statusColorKey: 'primary',
    accentColorKey: 'primary',
    iconKey: resourceLabel === 'Condition' ? 'history' : 'assignment',
    detailsJson: [
      detailJson('Provider', provider),
      detailJson('Notes', notes),
    ].filter((detail): detail is Json => detail !== null) as Json,
    recordedAt,
    displayOrder: 0,
  };
}

function readDosageText(dosage: unknown): string {
  if (!Array.isArray(dosage) || dosage.length === 0) {
    return '';
  }

  const first = dosage[0];
  if (!isRecord(first)) {
    return '';
  }

  const text = readString(first['text']);
  if (text.length > 0) {
    return text;
  }

  return readQuantity(first['doseAndRate']);
}

function readImmunizationPerformer(performer: unknown): string {
  if (!Array.isArray(performer) || performer.length === 0) {
    return '';
  }

  const first = performer[0];
  if (!isRecord(first)) {
    return '';
  }

  const actor = first['actor'];
  if (isRecord(actor)) {
    const display = readString(actor['display']);
    if (display.length > 0) {
      return display;
    }

    return readString(actor['reference']);
  }

  return '';
}

function readReferenceDisplay(value: unknown): string {
  if (Array.isArray(value) && value.length > 0) {
    const first = value[0];
    if (isRecord(first)) {
      const actor = first['actor'];
      if (isRecord(actor)) {
        return readString(actor['display']) || readString(actor['reference']);
      }

      return readString(first['display']) || readString(first['reference']);
    }
  }

  if (isRecord(value)) {
    return readString(value['display']) || readString(value['reference']);
  }

  return '';
}

function readPeriodStart(value: unknown): string {
  if (!isRecord(value)) {
    return '';
  }

  return readString(value['start']) || readString(value['date']) || '';
}

function readCodeableConceptText(value: unknown, fallback: string): string {
  if (!isRecord(value)) {
    return fallback;
  }

  const text = readString(value['text']);
  if (text.length > 0) {
    return text;
  }

  const coding = value['coding'];
  if (Array.isArray(coding)) {
    for (const item of coding) {
      if (!isRecord(item)) {
        continue;
      }

      const display = readString(item['display']);
      if (display.length > 0) {
        return display;
      }

      const code = readString(item['code']);
      if (code.length > 0) {
        return code;
      }
    }
  }

  return fallback;
}

function readCodeableConceptDisplay(value: unknown): string {
  if (!isRecord(value)) {
    return '';
  }

  const text = readString(value['text']);
  if (text.length > 0) {
    return text;
  }

  const coding = value['coding'];
  if (Array.isArray(coding)) {
    for (const item of coding) {
      if (!isRecord(item)) {
        continue;
      }

      const display = readString(item['display']);
      if (display.length > 0) {
        return display;
      }

      const code = readString(item['code']);
      if (code.length > 0) {
        return code;
      }
    }
  }

  return '';
}

function readQuantity(value: unknown): string {
  if (!isRecord(value)) {
    return '';
  }

  const amount = value['value'];
  const unit = readString(value['code']) || readString(value['unit']);
  if (typeof amount === 'number') {
    return `${amount}${unit.length > 0 ? ` ${unit}` : ''}`.trim();
  }

  if (typeof amount === 'string' && amount.trim().length > 0) {
    return `${amount.trim()}${unit.length > 0 ? ` ${unit}` : ''}`.trim();
  }

  return '';
}

function readNote(value: unknown): string {
  if (!Array.isArray(value) || value.length === 0) {
    return '';
  }

  const first = value[0];
  if (!isRecord(first)) {
    return '';
  }

  return readString(first['text']);
}

function readString(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function readBoolean(value: unknown): boolean {
  return typeof value === 'boolean' ? value : false;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}

function firstValue<T>(values: T[] | undefined): T | undefined {
  if (values === undefined || values.length === 0) {
    return undefined;
  }

  return values[0];
}

function detail(label: string, value: string): InternalRecordDetail {
  return {
    label,
    value,
  };
}

function detailJson(label: string, value: string): Json | null {
  const trimmedLabel = label.trim();
  const trimmedValue = value.trim();
  if (trimmedLabel.length === 0 || trimmedValue.length === 0) {
    return null;
  }

  return {
    label: trimmedLabel,
    value: trimmedValue,
  };
}

function toTitleCase(value: string): string {
  if (value.trim().length === 0) {
    return '';
  }

  return value
    .trim()
    .split(/[-_\s]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1).toLowerCase())
    .join(' ');
}

function extractNestedPatient(resource: Record<string, unknown>): FhirPatientResource | null {
  const nestedPatient = resource['patient'];
  if (isRecord(nestedPatient) && nestedPatient['resourceType'] === 'Patient') {
    return nestedPatient as unknown as FhirPatientResource;
  }

  const subject = resource['subject'];
  if (isRecord(subject) && subject['resourceType'] === 'Patient') {
    return subject as unknown as FhirPatientResource;
  }

  return null;
}

function extractParticipantIdentifiers(value: unknown): NormalizedIdentifier[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value.flatMap((item) => {
    if (!isRecord(item)) {
      return [];
    }

    const actor = item['actor'];
    if (!isRecord(actor)) {
      return [];
    }

    const identifier = normalizeIdentifier(actor['identifier']);
    return identifier === null ? [] : [identifier];
  });
}

export function normalizeMedicationResupplyStatus(
  value: string,
): 'pending' | 'approved' | 'rejected' | 'cancelled' {
  switch (value.trim().toLowerCase()) {
    case 'completed':
    case 'active':
    case 'draft':
    case 'on-hold':
      return 'pending';
    case 'cancelled':
    case 'stopped':
      return 'cancelled';
    case 'entered-in-error':
    case 'rejected':
      return 'rejected';
    case 'accepted':
    case 'approved':
      return 'approved';
    default:
      return 'pending';
  }
}

export function buildPatientBundleEntry(
  patient: FhirPatientResource,
): Record<string, unknown> {
  return {
    resourceType: 'Patient',
    id: patient.id ?? 'patient',
    identifier: patient.identifier ?? [],
    name: patient.name ?? [],
    birthDate: patient.birthDate,
    gender: patient.gender,
    telecom: patient.telecom ?? [],
    address: patient.address ?? [],
  };
}

export function buildErrorPayload(message: string): PreparedFhirCallbackPayload {
  return {
    transactionId: '',
    status: 'ERROR',
    data: buildOperationOutcome(message),
  };
}
