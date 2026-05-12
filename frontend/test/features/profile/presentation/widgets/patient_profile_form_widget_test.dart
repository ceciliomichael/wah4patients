import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/profile/presentation/widgets/patient_profile_form_widget.dart';

void main() {
  testWidgets('blocks invalid typed characters in profile fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PatientProfileFormWidget(
              initialProfile: _profile(),
              isSubmitting: false,
              onSave: (_) async {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Juan123');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Juan',
    );

    await tester.enterText(find.byType(TextFormField).at(5), '0917abc123');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(5))
          .controller!
          .text,
      '0917123',
    );

    await tester.enterText(find.byType(TextFormField).at(7), '12ab3456789012');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(7))
          .controller!
          .text,
      '123456789012',
    );

    await tester.enterText(find.byType(TextFormField).at(13), '11a00');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(13))
          .controller!
          .text,
      '1100',
    );
  });
}

UserProfileSummary _profile() {
  return const UserProfileSummary(
    givenNames: <String>['Juan', 'Carlos'],
    familyName: 'Dela Cruz',
    displayName: 'Juan Carlos Dela Cruz',
    birthDate: '1990-01-01',
    gender: 'male',
    phoneNumber: '09171234567',
    communicationLanguage: 'Filipino',
    philHealthId: '12-345678901-2',
    philSysId: '',
    addressLine1: '123 Main Street',
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
    isSyncLocked: false,
    isComplete: true,
    missingFields: <String>[],
  );
}
