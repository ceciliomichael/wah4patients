import { parseClinicalResource } from './clinical.parser';

export function parseConditionResource(resource: unknown) {
  return parseClinicalResource(resource, 'Condition');
}
