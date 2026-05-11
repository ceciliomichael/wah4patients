import { parseClinicalResource } from './clinical.parser';

export function parseMedicationRequestResource(resource: unknown) {
  return parseClinicalResource(resource, 'MedicationRequest');
}
