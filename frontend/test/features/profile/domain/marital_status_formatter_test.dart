import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/domain/marital_status_formatter.dart';

void main() {
  test('displayMaritalStatusLabel maps known marital status codes', () {
    expect(displayMaritalStatusLabel('S'), 'Single');
    expect(displayMaritalStatusLabel('M'), 'Married');
    expect(displayMaritalStatusLabel('D'), 'Divorced');
    expect(displayMaritalStatusLabel('W'), 'Widowed');
  });

  test('displayMaritalStatusLabel preserves unknown values', () {
    expect(displayMaritalStatusLabel('Partnered'), 'Partnered');
    expect(displayMaritalStatusLabel(''), '');
  });

  test('normalizeMaritalStatusValue maps labels back to canonical codes', () {
    expect(normalizeMaritalStatusValue('Single'), 'S');
    expect(normalizeMaritalStatusValue('married'), 'M');
    expect(normalizeMaritalStatusValue(' Divorced '), 'D');
    expect(normalizeMaritalStatusValue('Widowed'), 'W');
  });

  test('normalizeMaritalStatusValue preserves raw codes and unknown values', () {
    expect(normalizeMaritalStatusValue('S'), 'S');
    expect(normalizeMaritalStatusValue('Partnered'), 'Partnered');
    expect(normalizeMaritalStatusValue(''), '');
  });
}
