import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/profile/presentation/widgets/patient_profile_form_widget.dart';

void main() {
  testWidgets('hydrates first and middle name fields from given names', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PatientProfileFormWidget(
              initialProfile: _profile(
                givenNames: <String>['Michael Christian', 'Aparicio'],
                familyName: 'Cecilio',
                displayName: 'Michael Christian Aparicio Cecilio',
              ),
              isSubmitting: false,
              onSave: (_) async {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Michael Christian',
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'Aparicio',
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(2))
          .controller!
          .text,
      'Cecilio',
    );
    expect(find.text('Second name'), findsNothing);
  });

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

    await tester.enterText(find.byType(TextFormField).at(4), '0917abc123');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(4))
          .controller!
          .text,
      '0917123',
    );

    await tester.enterText(find.byType(TextFormField).at(6), '12ab3456789012');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(6))
          .controller!
          .text,
      '123456789012',
    );

    await tester.enterText(find.byType(TextFormField).at(12), '11a00');
    await tester.pump();
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(12))
          .controller!
          .text,
      '1100',
    );
  });
}

UserProfileSummary _profile({
  List<String> givenNames = const <String>['Juan', 'Carlos'],
  String familyName = 'Dela Cruz',
  String displayName = 'Juan Carlos Dela Cruz',
}) {
  return UserProfileSummary(
    givenNames: givenNames,
    familyName: familyName,
    displayName: displayName,
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
