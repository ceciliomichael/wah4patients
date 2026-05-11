import { parseClinicalResource } from './clinical.parser';

export function parseProcedureResource(resource: unknown) {
  return parseClinicalResource(resource, 'Procedure');
}
