import { parseClinicalResource } from './clinical.parser';

export function parseEncounterResource(resource: unknown) {
  return parseClinicalResource(resource, 'Encounter');
}
