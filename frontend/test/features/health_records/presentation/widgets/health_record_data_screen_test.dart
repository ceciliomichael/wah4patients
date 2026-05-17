import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/domain/models/auth_api_models.dart';
import 'package:frontend/features/health_records/data/health_records_api_client.dart';
import 'package:frontend/features/health_records/data/health_records_repository.dart';
import 'package:frontend/features/health_records/presentation/models/health_record_models.dart';
import 'package:frontend/features/health_records/presentation/widgets/health_record_data_screen.dart';

void main() {
  testWidgets(
    'keeps cached records visible when the background refresh returns no new items',
    (WidgetTester tester) async {
      addTearDown(AuthSession.clear);
      AuthSession.setFromLoginResult(
        LoginResult(
          mfaRequired: false,
          mfaChallengeToken: '',
          mfaChallengeExpiresInSeconds: 0,
          accessToken: 'token-001',
          refreshToken: 'refresh-001',
          expiresIn: 3600,
          tokenType: 'Bearer',
          userId: 'user-001',
          userEmail: 'patient@example.com',
          profile: UserProfileSummary.empty(),
        ),
      );

      final cachedRecord = _buildRecord(
        id: 'med-001',
        title: 'Type 2 Diabetes',
        subtitle: 'Chronic condition',
        summaryLabel: 'Status',
        summaryValue: 'Active',
        filterValue: 'Active',
        statusLabel: 'Confirmed',
        statusColorKey: 'success',
        accentColorKey: 'primary',
        iconKey: 'medical_history',
      );

      final repository = FakeHealthRecordsRepository(
        cachedRecords: <HealthRecordResponse>[cachedRecord],
        networkRecords: const <HealthRecordResponse>[],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HealthRecordDataScreen(
            section: HealthRecordSection.medicalHistory,
            content: _emptyContent,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Type 2 Diabetes'), findsOneWidget);
      expect(find.text('No matching medical history'), findsNothing);
      expect(find.text('Unable to load health records'), findsNothing);
    },
  );
}

class FakeHealthRecordsRepository extends HealthRecordsRepository {
  FakeHealthRecordsRepository({
    required this.cachedRecords,
    required this.networkRecords,
  });

  final List<HealthRecordResponse>? cachedRecords;
  final List<HealthRecordResponse> networkRecords;

  @override
  Future<List<HealthRecordResponse>?> loadCachedRecords({
    required String cacheKey,
    required HealthRecordSection section,
  }) async {
    return cachedRecords;
  }

  @override
  Future<List<HealthRecordResponse>> loadRecords({
    required String accessToken,
    required String cacheKey,
    required HealthRecordSection section,
  }) async {
    return networkRecords;
  }
}

const HealthRecordScreenContent _emptyContent = HealthRecordScreenContent(
  title: 'Medical History',
  searchHint: 'Search medical history',
  filterOptions: <String>['All', 'Active', 'Confirmed'],
  helpTitle: 'Medical History Help',
  helpMessages: <String>['Review diagnoses and records.'],
  emptyTitle: 'No matching medical history',
  emptyMessage: 'Try a different search term or status filter.',
  entries: <HealthRecordEntry>[],
);

HealthRecordResponse _buildRecord({
  required String id,
  required String title,
  required String subtitle,
  required String summaryLabel,
  required String summaryValue,
  required String filterValue,
  required String statusLabel,
  required String statusColorKey,
  required String accentColorKey,
  required String iconKey,
}) {
  final now = DateTime.parse('2026-01-08T00:00:00Z');
  return HealthRecordResponse(
    id: id,
    profileId: 'profile-001',
    title: title,
    subtitle: subtitle,
    summaryLabel: summaryLabel,
    summaryValue: summaryValue,
    filterValue: filterValue,
    statusLabel: statusLabel,
    statusColorKey: statusColorKey,
    accentColorKey: accentColorKey,
    iconKey: iconKey,
    details: const <HealthRecordDetailResponse>[
      HealthRecordDetailResponse(label: 'Note', value: 'Cached locally'),
    ],
    recordedAt: now,
    displayOrder: 1,
    createdAt: now,
    updatedAt: now,
  );
}
