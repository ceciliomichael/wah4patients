import 'appointment_history_api_client.dart';

class AppointmentHistoryLocalCache {
  AppointmentHistoryLocalCache._();

  static final Map<String, List<AppointmentHistoryRecordResponse>> _recordsByProfileId =
      <String, List<AppointmentHistoryRecordResponse>>{};

  static void upsertPendingRecord(AppointmentHistoryRecordResponse record) {
    final profileId = record.profileId.trim();
    if (profileId.isEmpty) {
      return;
    }

    final records = _recordsByProfileId.putIfAbsent(
      profileId,
      () => <AppointmentHistoryRecordResponse>[],
    );
    records.removeWhere(
      (existing) =>
          existing.id == record.id ||
          existing.gatewayTransactionId == record.gatewayTransactionId,
    );
    records.insert(0, record);
  }

  static List<AppointmentHistoryRecordResponse> snapshotForProfile(
    String profileId,
  ) {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty) {
      return const <AppointmentHistoryRecordResponse>[];
    }

    return List<AppointmentHistoryRecordResponse>.unmodifiable(
      _recordsByProfileId[normalizedProfileId] ?? const <AppointmentHistoryRecordResponse>[],
    );
  }

  static void clearForProfile(String profileId) {
    final normalizedProfileId = profileId.trim();
    if (normalizedProfileId.isEmpty) {
      return;
    }

    _recordsByProfileId.remove(normalizedProfileId);
  }
}
