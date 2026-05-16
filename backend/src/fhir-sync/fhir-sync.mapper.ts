import { Json } from '../supabase/database.types';
import {
  FhirBundleResource,
  FhirAddress,
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

const PHILHEALTH_IDENTIFIER_SYSTEM =
  'http://philhealth.gov.ph/fhir/Identifier/philhealth-id';
const LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM = 'http://philhealth.gov.ph';
const PHILSYS_IDENTIFIER_SYSTEM = 'http://philsys.gov.ph/fhir/Identifier/philsys-id';
const PHILSYS_IDENTIFIER_SYSTEM_HTTPS = 'https://philsys.gov.ph/fhir/Identifier/philsys-id';

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
  const normalizedIdentifiers = extractIdentifiersFromPatient(patient);
  const phoneNumber = extractPreferredTelecomValue(patient.telecom, 'phone');
  const firstAddress = firstValue(patient.address);
  const firstAddressExtensions = firstAddress?.extension ?? [];
  const province = extractAddressExtensionDisplay(
    firstAddressExtensions,
    'province',
  );
  const region = extractAddressExtensionDisplay(firstAddressExtensions, 'region');
  const cityFromExtension = extractAddressExtensionDisplay(
    firstAddressExtensions,
    'city-municipality',
  );
  const barangay = extractAddressExtensionDisplay(firstAddressExtensions, 'barangay');
  const maritalStatus = extractCodeableConceptDisplay(patient.maritalStatus);
  const indigenousPeople = extractBooleanExtension(
    patient.extension,
    'indigenous-people',
  );
  const indigenousGroup = extractPatientExtensionDisplay(
    patient.extension,
    'indigenous-group',
  );
  const race = extractPatientExtensionDisplay(patient.extension, 'race');
  const educationalAttainment = extractPatientExtensionDisplay(
    patient.extension,
    'educational-attainment',
  );
  const sexAtBirth = extractPatientExtensionDisplay(patient.extension, 'recordedSexOrGender');
  const pwd = extractPwdDisability(patient.extension);
  const philHealthId = extractIdentifierValueBySystem(
    normalizedIdentifiers,
    PHILHEALTH_IDENTIFIER_SYSTEM,
  );
  const philSysId = extractIdentifierValueBySystem(
    normalizedIdentifiers,
    PHILSYS_IDENTIFIER_SYSTEM,
  );

  return {
    givenNames,
    familyName,
    patientProfile: {
      birthDate: patient.birthDate ?? '',
      gender: patient.gender ?? '',
      phoneNumber,
      communicationLanguage: '',
      philHealthId,
      philSysId,
      addressLine1: extractAddressLine(firstAddress),
      addressLine2: '',
      city: cityFromExtension.length > 0 ? cityFromExtension : (firstAddress?.city ?? ''),
      province: province.length > 0 ? province : (firstAddress?.state ?? ''),
      region,
      barangay,
      postalCode: firstAddress?.postalCode ?? '',
      country: firstAddress?.country ?? '',
      maritalStatus,
      nationality: '',
      religion: extractPatientExtensionDisplay(patient.extension, 'religion'),
      occupation: extractPatientExtensionDisplay(patient.extension, 'occupation'),
      genderIdentity: '',
      indigenousPeople,
      indigenousGroup,
      race,
      educationalAttainment,
      sexAtBirth,
      pwdIdNumber: pwd.idNumber,
      pwdDisabilityType: pwd.disabilityType,
      pwdIdExpirationDate: pwd.idExpirationDate,
      pwdIssuingLgu: pwd.issuingLgu,
      emergencyContactName: '',
      emergencyContactPhone: '',
      syncLocked: true,
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
      identifier: normalizedIdentifiers.map((identifier) => ({
        system: identifier.system,
        value: identifier.value,
      })),
    } as Json,
  } satisfies FhirPatientProfilePatch;
}

function extractAddressExtensionDisplay(
  extensions: Array<Record<string, unknown>>,
  sliceToken: string,
): string {
  for (const extension of extensions) {
    const url = typeof extension['url'] === 'string' ? extension['url'] : '';
    if (!url.includes(sliceToken)) {
      continue;
    }
    const coding = asRecord(extension['valueCoding']);
    if (coding !== null && typeof coding['display'] === 'string') {
      return coding['display'].trim();
    }
  }
  return '';
}

function extractPatientExtensionDisplay(
  extensions: Array<Record<string, unknown>> | undefined,
  sliceToken: string,
): string {
  if (extensions == null) {
    return '';
  }
  for (const extension of extensions) {
    const url = typeof extension['url'] === 'string' ? extension['url'] : '';
    if (!url.includes(sliceToken)) {
      continue;
    }
    const directValue = extractExtensionDisplayValue(extension);
    if (directValue.length > 0) {
      return directValue;
    }

    const nestedExtensions = Array.isArray(extension['extension'])
      ? extension['extension'].filter(isRecord)
      : [];
    for (const nestedExtension of nestedExtensions) {
      const nestedValue = extractExtensionDisplayValue(nestedExtension);
      if (nestedValue.length > 0) {
        return nestedValue;
      }
    }
  }
  return '';
}

function extractExtensionDisplayValue(extension: Record<string, unknown>): string {
  const coding = asRecord(extension['valueCoding']);
  if (coding !== null && typeof coding['display'] === 'string') {
    return coding['display'].trim();
  }

  const concept = asRecord(extension['valueCodeableConcept']);
  if (concept !== null) {
    const conceptValue = extractCodeableConceptDisplay({
      text: typeof concept['text'] === 'string' ? concept['text'] : undefined,
      coding: Array.isArray(concept['coding'])
        ? concept['coding']
            .filter(isRecord)
            .map((entry) => ({
              display: typeof entry['display'] === 'string' ? entry['display'] : undefined,
              code: typeof entry['code'] === 'string' ? entry['code'] : undefined,
            }))
        : undefined,
    });
    if (conceptValue.length > 0) {
      return conceptValue;
    }
  }

  if (typeof extension['valueString'] === 'string') {
    return extension['valueString'].trim();
  }

  return '';
}

function extractBooleanExtension(
  extensions: Array<Record<string, unknown>> | undefined,
  sliceToken: string,
): boolean {
  if (extensions == null) {
    return false;
  }
  for (const extension of extensions) {
    const url = typeof extension['url'] === 'string' ? extension['url'] : '';
    if (url.includes(sliceToken) && extension['valueBoolean'] === true) {
      return true;
    }
  }
  return false;
}

function extractCodeableConceptDisplay(
  concept: { text?: string; coding?: Array<{ display?: string; code?: string }> } | undefined,
): string {
  if (concept == null) {
    return '';
  }
  if ((concept.text?.trim().length ?? 0) > 0) {
    return concept.text!.trim();
  }
  for (const coding of concept.coding ?? []) {
    if ((coding.display?.trim().length ?? 0) > 0) {
      return coding.display!.trim();
    }
    if ((coding.code?.trim().length ?? 0) > 0) {
      return coding.code!.trim();
    }
  }
  return '';
}

function extractPwdDisability(
  extensions: Array<Record<string, unknown>> | undefined,
): {
  idNumber: string;
  disabilityType: string;
  idExpirationDate: string;
  issuingLgu: string;
} {
  if (extensions == null) {
    return { idNumber: '', disabilityType: '', idExpirationDate: '', issuingLgu: '' };
  }

  const flatDisabilityType = extractPatientExtensionDisplay(extensions, 'pwd-disability-type');
  if (flatDisabilityType.length > 0) {
    return {
      idNumber: '',
      disabilityType: flatDisabilityType,
      idExpirationDate: '',
      issuingLgu: '',
    };
  }

  for (const extension of extensions) {
    const url = typeof extension['url'] === 'string' ? extension['url'] : '';
    if (!url.includes('ph-core-pwd-disability')) {
      continue;
    }
    const nested = Array.isArray(extension['extension'])
      ? extension['extension'].filter(isRecord)
      : [];
    let idNumber = '';
    let disabilityType = '';
    let idExpirationDate = '';
    let issuingLgu = '';
    for (const child of nested) {
      const childUrl = typeof child['url'] === 'string' ? child['url'] : '';
      if (childUrl == 'pwdIdNumber' && typeof child['valueString'] === 'string') {
        idNumber = child['valueString'].trim();
      }
      if (childUrl == 'disabilityType') {
        const concept = asRecord(child['valueCodeableConcept']);
        if (concept != null) {
          const codingList = concept['coding'];
          if (Array.isArray(codingList) && codingList.length > 0) {
            const firstCoding = codingList.find((item) => isRecord(item));
            if (firstCoding != null) {
              const display = firstCoding['display'];
              const code = firstCoding['code'];
              if (typeof display === 'string' && display.trim().length > 0) {
                disabilityType = display.trim();
              } else if (typeof code === 'string' && code.trim().length > 0) {
                disabilityType = code.trim();
              }
            }
          }
        }
      }
      if (childUrl == 'idExpirationDate' && typeof child['valueDate'] === 'string') {
        idExpirationDate = child['valueDate'].trim();
      }
      if (childUrl == 'issuingLGU') {
        const coding = asRecord(child['valueCoding']);
        if (coding != null && typeof coding['display'] === 'string') {
          issuingLgu = coding['display'].trim();
        }
      }
    }

    return { idNumber, disabilityType, idExpirationDate, issuingLgu };
  }

  return { idNumber: '', disabilityType: '', idExpirationDate: '', issuingLgu: '' };
}

function extractIdentifierValueBySystem(
  identifiers: NormalizedIdentifier[],
  targetSystem: string,
): string {
  const systemCandidates =
    targetSystem === PHILHEALTH_IDENTIFIER_SYSTEM
      ? [
          PHILHEALTH_IDENTIFIER_SYSTEM,
          LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM,
        ]
      : targetSystem === PHILSYS_IDENTIFIER_SYSTEM
        ? [PHILSYS_IDENTIFIER_SYSTEM, PHILSYS_IDENTIFIER_SYSTEM_HTTPS]
      : [targetSystem];

  for (const identifier of identifiers) {
    if (systemCandidates.includes(identifier.system)) {
      return identifier.value;
    }
  }

  return '';
}

function extractPreferredTelecomValue(
  telecom: FhirPatientResource['telecom'],
  system: string,
): string {
  if (telecom == null) {
    return '';
  }

  for (const entry of telecom) {
    const entrySystem = entry.system?.trim().toLowerCase() ?? '';
    const entryValue = entry.value?.trim() ?? '';
    if (entrySystem === system && entryValue.length > 0) {
      return entryValue;
    }
  }

  for (const entry of telecom) {
    const entryValue = entry.value?.trim() ?? '';
    if (entryValue.length > 0) {
      return entryValue;
    }
  }

  return '';
}

function extractAddressLine(address: FhirAddress | undefined): string {
  if (address == null) {
    return '';
  }

  const lines = (address.line ?? [])
    .map((value) => value.trim())
    .filter((value) => value.length > 0);
  if (lines.length > 0) {
    return lines.join(', ');
  }

  return address.text?.trim() ?? '';
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
    filterValue: buildFilterValue(status, vaccineName, site, route, lotNumber),
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
    filterValue: buildFilterValue(status, encounterType, provider, location, reason),
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
    filterValue: buildFilterValue(status, observationName, value, performer),
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
    filterValue: buildFilterValue(status, title, provider),
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
  if (Array.isArray(value) && value.length > 0) {
    return readCodeableConceptText(value[0], fallback);
  }

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
  if (Array.isArray(value) && value.length > 0) {
    return readCodeableConceptDisplay(value[0]);
  }

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

function asRecord(value: unknown): Record<string, unknown> | null {
  return isRecord(value) ? value : null;
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

function buildFilterValue(...parts: string[]): string {
  const normalizedParts = parts.map((part) => part.trim()).filter(Boolean);
  let value = '';

  for (const part of normalizedParts) {
    const candidate = value.length > 0 ? `${value} ${part}` : part;
    if (candidate.length <= 80) {
      value = candidate;
      continue;
    }

    if (value.length === 0) {
      value = part.slice(0, 80);
    }

    break;
  }

  return value.toLowerCase();
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
