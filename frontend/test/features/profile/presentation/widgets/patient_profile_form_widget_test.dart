import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/profile/domain/marital_status_formatter.dart';
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
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Michael Christian',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'Aparicio',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(2))
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
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Juan',
    );

    await tester.enterText(find.byType(TextFormField).at(4), '0917abc123');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(4))
          .controller!
          .text,
      '0917123',
    );

    await tester.enterText(find.byType(TextFormField).at(6), '12ab3456789012');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(6))
          .controller!
          .text,
      '123456789012',
    );

    await tester.enterText(find.byType(TextFormField).at(12), '11a00');
    await tester.pump();
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(12))
          .controller!
          .text,
      '1100',
    );
  });

  testWidgets('hydrates marital status code as a readable label', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PatientProfileFormWidget(
              initialProfile: _profile(maritalStatus: 'S'),
              isSubmitting: false,
              onSave: (_) async {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final maritalStatusField = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .firstWhere((field) => field.controller?.text == 'Single');
    expect(maritalStatusField.controller!.text, 'Single');
    expect(displayMaritalStatusLabel('M'), 'Married');
  });

  testWidgets('locked profile summary hides empty fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PatientProfileFormWidget(
              initialProfile: _profile(
                birthDate: '',
                gender: '',
                addressLine2: '',
                region: '',
                barangay: '',
                philSysId: '',
                indigenousPeople: true,
                indigenousGroup: '',
              ),
              isSubmitting: false,
              isReadOnly: true,
              onSave: (_) async {},
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final lockedFields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList(growable: false);
    expect(lockedFields, isNotEmpty);
    expect(lockedFields.every((field) => field.controller == null), isTrue);
    expect(find.text('Save Changes'), findsNothing);
    expect(find.text('Birth date'), findsNothing);
    expect(find.text('Gender'), findsNothing);
    expect(find.text('Address line 2'), findsNothing);
    expect(find.text('Region'), findsNothing);
    expect(find.text('Barangay'), findsNothing);
    expect(find.text('Indigenous group'), findsNothing);
    expect(find.text('First name *'), findsOneWidget);
    expect(find.text('Juan'), findsOneWidget);
    expect(find.text('Indigenous people member *'), findsOneWidget);
    expect(find.text('Yes'), findsWidgets);

    final lockedField = find.byType(TextFormField).first;
    await tester.ensureVisible(lockedField);
    await tester.tap(lockedField, warnIfMissed: false);
    await tester.pump();
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .every((editableText) => !editableText.focusNode.hasFocus),
      isTrue,
    );
  });

  testWidgets('toggles indigenous group field with the yes/no choice', (
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

    await tester.pumpAndSettle();

    expect(find.text('Indigenous group'), findsNothing);

    final indigenousField = find.byType(BottomSheetSelectFormField<bool>);
    await tester.ensureVisible(indigenousField);
    await tester.tap(indigenousField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes').last);
    await tester.pumpAndSettle();

    expect(find.text('Indigenous group'), findsOneWidget);

    await tester.ensureVisible(indigenousField);
    await tester.tap(indigenousField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();

    expect(find.text('Indigenous group'), findsNothing);
  });

  testWidgets('saves canonical indigenous membership state', (
    WidgetTester tester,
  ) async {
    PatientProfileDraft? savedDraft;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PatientProfileFormWidget(
              initialProfile: _profile(),
              isSubmitting: false,
              onSave: (draft) async {
                savedDraft = draft;
              },
              onReset: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final indigenousField = find.byType(BottomSheetSelectFormField<bool>);
    await tester.ensureVisible(indigenousField);
    await tester.tap(indigenousField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes').last);
    await tester.pumpAndSettle();

    final indigenousGroupField = find.widgetWithText(
      TextFormField,
      'Indigenous group',
    );
    await tester.ensureVisible(indigenousGroupField);
    await tester.enterText(indigenousGroupField, 'Blaan');
    await tester.pump();

    await tester.ensureVisible(indigenousField);
    await tester.tap(indigenousField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedDraft, isNotNull);
    expect(savedDraft!.indigenousPeople, isFalse);
    expect(savedDraft!.indigenousGroup, isEmpty);
  });
}

UserProfileSummary _profile({
  List<String> givenNames = const <String>['Juan', 'Carlos'],
  String familyName = 'Dela Cruz',
  String displayName = 'Juan Carlos Dela Cruz',
  String birthDate = '1990-01-01',
  String gender = 'male',
  String addressLine2 = '',
  String region = '',
  String barangay = '',
  String philSysId = '',
  String maritalStatus = 'Single',
  bool indigenousPeople = false,
  String indigenousGroup = '',
}) {
  return UserProfileSummary(
    givenNames: givenNames,
    familyName: familyName,
    displayName: displayName,
    birthDate: birthDate,
    gender: gender,
    phoneNumber: '09171234567',
    communicationLanguage: 'Filipino',
    philHealthId: '12-345678901-2',
    philSysId: philSysId,
    addressLine1: '123 Main Street',
    addressLine2: addressLine2,
    city: 'Quezon City',
    province: 'Metro Manila',
    region: region,
    barangay: barangay,
    postalCode: '1100',
    country: 'Philippines',
    maritalStatus: maritalStatus,
    nationality: 'Filipino',
    religion: 'Catholic',
    occupation: 'Teacher',
    genderIdentity: 'Male',
    indigenousPeople: indigenousPeople,
    indigenousGroup: indigenousGroup,
    emergencyContactName: 'Maria Dela Cruz',
    emergencyContactPhone: '09179876543',
    isSyncLocked: false,
    isComplete: true,
    missingFields: <String>[],
  );
}
