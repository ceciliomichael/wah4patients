import { BadRequestException } from '@nestjs/common';
import { buildInternalRecordInsert } from '../fhir-sync.mapper';
import { GatewayResourceType } from '../fhir-sync.types';
import { requirePhCoreProfile } from '../fhir-sync.profile';
import { ParsedClinicalResource } from './fhir-parser.types';
import { assertResourceRecord } from './fhir-parser.utils';

export function parseClinicalResource<
  TResourceType extends Exclude<GatewayResourceType, 'Patient'>,
>(
  resource: unknown,
  resourceType: TResourceType,
): ParsedClinicalResource<TResourceType> {
  const record = assertResourceRecord(resource, resourceType);
  const profile = requirePhCoreProfile(record, resourceType);
  const insert = buildInternalRecordInsert(resourceType, record);

  if (insert === null) {
    throw new BadRequestException(`Unable to normalize ${resourceType} payload.`);
  }

  return {
    kind: 'clinical',
    resourceType,
    profile,
    resource: record,
    insert,
  };
}
