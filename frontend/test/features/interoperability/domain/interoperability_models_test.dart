import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/interoperability/domain/interoperability_models.dart';

void main() {
  test(
    'buildSyncIdentifierOptions includes PhilHealth and PhilSys identifiers',
    () {
      final profile = _profile(
        philHealthId: '12-345678901-2',
        philSysId: '1234-1234567-1',
      );

      final options = buildSyncIdentifierOptions(profile);

      expect(options, hasLength(2));
      expect(options.first.fieldKey, 'philHealthId');
      expect(options.first.systemUri, philHealthIdentifierSystem);
      expect(options.first.value, '12-345678901-2');
      expect(options.last.fieldKey, 'philSysId');
      expect(options.last.systemUri, philSysIdentifierSystem);
      expect(options.last.value, '1234-1234567-1');
    },
  );

  test('buildSyncIdentifierOptions skips empty identifiers', () {
    final profile = _profile();

    final options = buildSyncIdentifierOptions(profile);

    expect(options, isEmpty);
  });
}

UserProfileSummary _profile({String philHealthId = '', String philSysId = ''}) {
  return UserProfileSummary(
    givenNames: const <String>['Juan'],
    familyName: 'Dela Cruz',
    displayName: 'Juan Dela Cruz',
    birthDate: '1990-01-01',
    gender: 'male',
    phoneNumber: '09171234567',
    communicationLanguage: 'Filipino',
    philHealthId: philHealthId,
    philSysId: philSysId,
    addressLine1: '123 Mabini St',
    addressLine2: '',
    city: 'Quezon City',
    province: 'Metro Manila',
    postalCode: '1100',
    country: 'Philippines',
    maritalStatus: 'Single',
    nationality: 'Filipino',
    religion: 'Catholic',
    occupation: 'Teacher',
    genderIdentity: 'Male',
    emergencyContactName: 'Maria Dela Cruz',
    emergencyContactPhone: '09179876543',
    isComplete: true,
    missingFields: const <String>[],
  );
}
