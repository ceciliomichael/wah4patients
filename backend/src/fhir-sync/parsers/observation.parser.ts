import { parseClinicalResource } from './clinical.parser';

export function parseObservationResource(resource: unknown) {
  return parseClinicalResource(resource, 'Observation');
}
