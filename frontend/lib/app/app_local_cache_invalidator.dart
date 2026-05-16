import '../features/dashboard/data/weekly_health_report_local_store.dart';
import '../features/health_records/data/health_records_api_client.dart';
import '../features/health_records/data/health_records_local_store.dart';

class AppLocalCacheInvalidator {
  AppLocalCacheInvalidator._();

  static final WeeklyHealthReportLocalStore _weeklyHealthReportLocalStore =
      WeeklyHealthReportLocalStore();
  static final HealthRecordsLocalStore _healthRecordsLocalStore =
      HealthRecordsLocalStore();

  static Future<void> clearUserScopedCaches(String cacheKey) async {
    final normalized = cacheKey.trim();
    if (normalized.isEmpty) {
      return;
    }

    await _weeklyHealthReportLocalStore.clear(cacheKey: normalized);
    for (final section in HealthRecordSection.values) {
      await _healthRecordsLocalStore.clearSection(
        cacheKey: normalized,
        section: section,
      );
    }
  }
}
