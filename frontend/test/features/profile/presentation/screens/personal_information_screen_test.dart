import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/app/app_routes.dart';
import 'package:frontend/app/app_router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/interoperability/data/interoperability_api_client.dart';
import 'package:frontend/features/interoperability/domain/interoperability_models.dart';
import 'package:frontend/features/interoperability/presentation/screens/sync_records_wizard_screen.dart';
import 'package:frontend/features/profile/presentation/screens/personal_information_screen.dart';

class _FakeInteroperabilityClient implements InteroperabilityClient {
  @override
  Future<List<InteroperabilityProviderSummary>> getProviders() async {
    return const <InteroperabilityProviderSummary>[
      InteroperabilityProviderSummary(
        id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        name: 'WAH for Clinics',
        type: 'clinic',
        facilityCode: 'WAH4C',
        location: 'Tarlac City',
        isActive: true,
      ),
    ];
  }

  @override
  Future<SyncRequestPreview> prepareSyncRequest({
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  }) async {
    return SyncRequestPreview(
      canSubmit: true,
      requesterId: '550e8400-e29b-41d4-a716-446655440000',
      targetProvider: const InteroperabilityProviderSummary(
        id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        name: 'WAH for Clinics',
        type: 'clinic',
        facilityCode: 'WAH4C',
        location: 'Tarlac City',
        isActive: true,
      ),
      patientIdentifiers: [
        SyncRequestIdentifier(system: identifierSystem, value: identifierValue),
      ],
      resourceType: 'Patient',
      gatewayUrl: 'https://wah4pc.echosphere.cfd',
      reason: reason,
      notes: notes,
    );
  }
}

void main() {
  setUp(() {
    AuthSession.clear();
  });

  testWidgets(
    'renders the expanded patient profile screen with completion guidance',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PersonalInformationScreen()),
      );

      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsWidgets);
      expect(find.text('Profile completion first'), findsNothing);
      expect(find.text('Sync records locked'), findsOneWidget);
      expect(find.text('Required profile details'), findsOneWidget);
      expect(find.text('PhilHealth ID or PhilSys ID'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Identifiers'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Optional details'), findsOneWidget);
      expect(find.text('WAH facility sync coming soon'), findsNothing);
      expect(find.text('Sync records'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      final syncButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Sync records'),
      );
      expect(syncButton.onPressed, isNull);
      final resetButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Reset'),
      );
      expect(
        resetButton.style?.backgroundColor?.resolve(<MaterialState>{}),
        AppColors.surface,
      );
      expect(
        resetButton.style?.foregroundColor?.resolve(<MaterialState>{}),
        AppColors.textPrimary,
      );
      expect(find.text('First name *'), findsOneWidget);
      expect(find.text('Last name *'), findsOneWidget);
      expect(find.text('Birth date *'), findsOneWidget);
      expect(find.text('Gender *'), findsOneWidget);
      expect(find.text('Phone number *'), findsOneWidget);
      expect(find.text('PhilHealth ID'), findsOneWidget);
      expect(find.text('PhilSys ID'), findsOneWidget);
      expect(find.text('Address line 1 *'), findsOneWidget);
      expect(find.text('City / municipality *'), findsOneWidget);
      expect(find.text('Province *'), findsOneWidget);
      expect(find.text('Postal code *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
      expect(find.text('Emergency contact phone'), findsOneWidget);
    },
  );

  testWidgets('opens the sync wizard when sync readiness is complete', (
    WidgetTester tester,
  ) async {
    AuthSession.setProfile(_readyProfile());

    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRoutes.personalInformation,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.syncRecords) {
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => SyncRecordsWizardScreen(
                apiClient: _FakeInteroperabilityClient(),
              ),
            );
          }

          return buildAppRoute(settings);
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Sync records'));
    await tester.pumpAndSettle();

    expect(find.text('Sync records'), findsWidgets);
    expect(find.text('Select patient identifier'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}

UserProfileSummary _readyProfile() {
  return const UserProfileSummary(
    givenNames: <String>['Juan'],
    familyName: 'Dela Cruz',
    displayName: 'Juan Dela Cruz',
    birthDate: '1990-01-01',
    gender: 'male',
    phoneNumber: '09171234567',
    communicationLanguage: 'Filipino',
    philHealthId: '12-345678901-2',
    philSysId: '',
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
    missingFields: <String>[],
  );
}
