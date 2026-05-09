import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/ui/buttons/primary_button_widget.dart';
import 'package:frontend/core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/interoperability/data/interoperability_api_client.dart';
import 'package:frontend/features/interoperability/domain/interoperability_models.dart';
import 'package:frontend/features/interoperability/presentation/screens/sync_records_wizard_screen.dart';

class FakeInteroperabilityClient implements InteroperabilityClient {
  FakeInteroperabilityClient({required this.providers});

  final List<InteroperabilityProviderSummary> providers;
  int prepareSyncRequestCalls = 0;

  @override
  Future<List<InteroperabilityProviderSummary>> getProviders() async {
    return providers;
  }

  @override
  Future<SyncRequestPreview> prepareSyncRequest({
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  }) async {
    prepareSyncRequestCalls += 1;
    final selectedProvider = providers.firstWhere(
      (provider) => provider.id == providerId,
      orElse: () => providers.first,
    );

    return SyncRequestPreview(
      canSubmit: true,
      requesterId: '550e8400-e29b-41d4-a716-446655440000',
      targetProvider: selectedProvider,
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

  testWidgets('walks through identifier and provider selection', (
    WidgetTester tester,
  ) async {
    AuthSession.setProfile(_readyProfile());
    final apiClient = FakeInteroperabilityClient(
      providers: const <InteroperabilityProviderSummary>[
        InteroperabilityProviderSummary(
          id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
          name: 'WAH for Clinics',
          type: 'clinic',
          facilityCode: 'WAH4C',
          location: 'Tarlac City',
          isActive: true,
        ),
        InteroperabilityProviderSummary(
          id: '1f3b6c40-1aa1-4e76-b8fd-fb1f430d4a42',
          name: 'Provincial Medical Center',
          type: 'hospital',
          facilityCode: 'PMC-002',
          location: 'Pampanga',
          isActive: true,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: SyncRecordsWizardScreen(apiClient: apiClient)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sync records'), findsOneWidget);
    expect(find.text('Select an identifier'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is BottomSheetSelectFormField<String>,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('PhilHealth ID'), findsWidgets);
    expect(find.text('PhilSys ID'), findsWidgets);

    await tester.tap(find.text('PhilSys ID').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PrimaryButtonWidget, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Select provider'), findsWidgets);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is BottomSheetSelectFormField<String>,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('WAH for Clinics'), findsWidgets);
    expect(find.text('Provincial Medical Center'), findsWidgets);

    await tester.tap(find.text('Provincial Medical Center').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PrimaryButtonWidget, 'Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Review sync request'), findsWidgets);
    expect(find.text('Identifier'), findsWidgets);
    expect(find.text('Provider'), findsWidgets);

    final prepareRequestButton = find.widgetWithText(
      PrimaryButtonWidget,
      'Prepare request',
    );
    await tester.scrollUntilVisible(prepareRequestButton, 200);
    await tester.tap(prepareRequestButton);
    await tester.pumpAndSettle();

    expect(apiClient.prepareSyncRequestCalls, 1);
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
    philSysId: '1234-1234567-1',
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
