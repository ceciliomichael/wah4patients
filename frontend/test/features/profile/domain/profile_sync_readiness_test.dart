import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/profile/domain/profile_sync_readiness.dart';

void main() {
  UserProfileSummary buildProfile({
    required bool isComplete,
    required List<String> missingFields,
    String philHealthId = '',
    String philSysId = '',
  }) {
    return UserProfileSummary(
      givenNames: const <String>['Juan'],
      familyName: 'Dela Cruz',
      displayName: 'Juan Dela Cruz',
      birthDate: '1990-05-15',
      gender: 'male',
      phoneNumber: '09171234567',
      communicationLanguage: 'Filipino',
      philHealthId: philHealthId,
      philSysId: philSysId,
      addressLine1: '123 Main Street',
      addressLine2: '',
      city: 'Quezon City',
      province: 'Metro Manila',
      postalCode: '1100',
      country: 'Philippines',
      maritalStatus: '',
      nationality: '',
      religion: '',
      occupation: '',
      genderIdentity: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
      isComplete: isComplete,
      missingFields: missingFields,
    );
  }

  test('marks profile ready when required completion and identifier exist', () {
    final readiness = evaluateProfileSyncReadiness(
      buildProfile(
        isComplete: true,
        missingFields: const <String>[],
        philHealthId: '12-345678901-2',
      ),
    );

    expect(readiness.isReady, isTrue);
    expect(readiness.missingRequirements, isEmpty);
  });

  test('requires at least one identifier for sync readiness', () {
    final readiness = evaluateProfileSyncReadiness(
      buildProfile(isComplete: true, missingFields: const <String>[]),
    );

    expect(readiness.isReady, isFalse);
    expect(
      readiness.missingRequirements,
      contains('PhilHealth ID or PhilSys ID'),
    );
  });

  test('formats backend missing fields into readable labels', () {
    final readiness = evaluateProfileSyncReadiness(
      buildProfile(
        isComplete: false,
        missingFields: const <String>[
          'birthDate',
          'phoneNumber',
          'addressLine1',
        ],
        philHealthId: '12-345678901-2',
      ),
    );

    expect(readiness.isReady, isFalse);
    expect(
      readiness.missingRequirements,
      containsAll(<String>['Birth date', 'Phone number', 'Address line 1']),
    );
    expect(
      readiness.missingRequirements,
      isNot(contains('PhilHealth ID or PhilSys ID')),
    );
  });
}
