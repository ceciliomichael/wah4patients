import { parseClinicalResource } from './clinical.parser';

export function parseImmunizationResource(resource: unknown) {
  return parseClinicalResource(resource, 'Immunization');
}
