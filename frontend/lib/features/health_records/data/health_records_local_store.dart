import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'health_records_api_client.dart';

class HealthRecordsLocalStore {
  HealthRecordsLocalStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyPrefix = 'health-records.section';
  final FlutterSecureStorage _storage;

  Future<List<HealthRecordResponse>?> readSection({
    required String cacheKey,
    required HealthRecordSection section,
  }) async {
    final key = _storageKey(cacheKey: cacheKey, section: section);
    if (key == null) {
      return null;
    }

    final raw = await _storage.read(key: key);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final records = decoded['records'];
      if (records is! List) {
        return null;
      }

      return records
          .whereType<Map<String, dynamic>>()
          .map(HealthRecordResponse.fromJson)
          .toList(growable: false);
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }

  Future<void> writeSection({
    required String cacheKey,
    required HealthRecordSection section,
    required List<HealthRecordResponse> records,
  }) async {
    final key = _storageKey(cacheKey: cacheKey, section: section);
    if (key == null) {
      return;
    }

    final payload = <String, dynamic>{
      'records': records.map((record) => record.toJson()).toList(growable: false),
    };
    await _storage.write(key: key, value: jsonEncode(payload));
  }

  Future<void> clearSection({
    required String cacheKey,
    required HealthRecordSection section,
  }) async {
    final key = _storageKey(cacheKey: cacheKey, section: section);
    if (key == null) {
      return;
    }
    await _storage.delete(key: key);
  }

  String? _storageKey({
    required String cacheKey,
    required HealthRecordSection section,
  }) {
    final normalized = cacheKey.trim();
    if (normalized.isEmpty) {
      return null;
    }
    return '$_keyPrefix.${section.pathSegment}.$normalized';
  }
}
