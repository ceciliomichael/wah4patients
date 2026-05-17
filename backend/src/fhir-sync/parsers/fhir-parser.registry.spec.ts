import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { BadRequestException } from '@nestjs/common';
import { parseInboundResource } from './fhir-parser.registry';

function readFixture(fileName: string): Record<string, unknown> {
  const filePath = join(__dirname, '../../../../resources/examples/ph-core', fileName);
  return JSON.parse(readFileSync(filePath, 'utf8')) as Record<string, unknown>;
}

describe('FHIR inbound parsers', () => {
  it('parses the PH Core patient fixture strictly', () => {
    const patient = parseInboundResource(readFixture('Patient-patient-single-example.json'));
    if (patient.kind !== 'patient') {
      throw new Error('Expected patient parser output.');
    }

    expect(patient.kind).toBe('patient');
    expect(patient.resourceType).toBe('Patient');
    expect(patient.profile).toContain('/phcore/StructureDefinition/ph-core-patient');
    expect(patient.resource.identifier).toEqual([
      {
        system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        value: '63-584789845-5',
      },
    ]);
  });

  it.each([
    ['Immunization', 'Immunization-immunization-single-example.json', 'title', 'Influenza H5N1-1203 Vaccine'],
    ['Encounter', 'Encounter-encounter-single-example.json', 'title', 'ambulatory'],
    ['Observation', 'Observation-observation-bp-example.json', 'title', 'Blood pressure systolic & diastolic'],
    ['Condition', 'Condition-condition-single-example.json', 'title', 'Type 2 Diabetes Mellitus'],
    ['Procedure', 'Procedure-procedure-single-example.json', 'title', 'Laparoscopic appendectomy'],
    ['MedicationRequest', 'MedicationRequest-medicationrequest-single-example.json', 'medicationName', 'Twinact 40mg/5mg tablet'],
  ])('parses PH Core %s fixtures', (_resourceType, fileName, expectedKey, expectedValue) => {
    const parsed = parseInboundResource(readFixture(fileName));
    if (parsed.kind !== 'clinical') {
      throw new Error('Expected clinical parser output.');
    }

    expect(parsed.kind).toBe('clinical');
    expect(parsed.resourceType).toBe(_resourceType);
    expect(parsed.profile).toContain('/phcore/StructureDefinition/ph-core-');
    expect(parsed.insert).toEqual(expect.objectContaining({ [expectedKey]: expectedValue }));

    if ('filterValue' in parsed.insert) {
      expect(parsed.insert.filterValue.length).toBeLessThanOrEqual(80);
    }
  });

  it('accepts gateway Condition payloads that declare the base FHIR Condition profile', () => {
    const condition = readFixture('Condition-condition-single-example.json');
    condition.meta = {
      profile: ['http://hl7.org/fhir/StructureDefinition/Condition'],
    };

    const parsed = parseInboundResource(condition);
    if (parsed.kind !== 'clinical') {
      throw new Error('Expected clinical parser output.');
    }

    expect(parsed.resourceType).toBe('Condition');
    expect(parsed.profile).toBe('http://hl7.org/fhir/StructureDefinition/Condition');
    expect(parsed.insert).toEqual(
      expect.objectContaining({
        title: 'Type 2 Diabetes Mellitus',
        recordedAt: '2020-03-15T10:30:00Z',
      }),
    );
  });

  it('rejects resources that do not declare the required PH Core profile', () => {
    const patient = readFixture('Patient-patient-single-example.json');
    delete patient.meta;

    expect(() => parseInboundResource(patient)).toThrow(BadRequestException);
  });
});
