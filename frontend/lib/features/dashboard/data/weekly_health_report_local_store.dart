import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/weekly_health_report_calculator.dart';

class WeeklyHealthReportLocalStore {
  WeeklyHealthReportLocalStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyPrefix = 'dashboard.weekly-health-report';
  final FlutterSecureStorage _storage;

  Future<WeeklyHealthReport?> read({required String cacheKey}) async {
    final normalizedKey = cacheKey.trim();
    if (normalizedKey.isEmpty) {
      return null;
    }

    final rawValue = await _storage.read(key: _storageKeyFor(normalizedKey));
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return _weeklyHealthReportFromJson(decoded);
    } on FormatException {
      return null;
    } on Object {
      return null;
    }
  }

  Future<void> write({
    required String cacheKey,
    required WeeklyHealthReport report,
  }) async {
    final normalizedKey = cacheKey.trim();
    if (normalizedKey.isEmpty) {
      return;
    }

    await _storage.write(
      key: _storageKeyFor(normalizedKey),
      value: jsonEncode(_weeklyHealthReportToJson(report)),
    );
  }

  String _storageKeyFor(String cacheKey) => '$_keyPrefix.$cacheKey';
}

Map<String, dynamic> _weeklyHealthReportToJson(WeeklyHealthReport report) {
  return <String, dynamic>{
    'bmi': _metricSummaryToJson(report.bmi),
    'bloodPressure': _metricSummaryToJson(report.bloodPressure),
    'temperature': _metricSummaryToJson(report.temperature),
  };
}

Map<String, dynamic> _metricSummaryToJson(WeeklyHealthMetricSummary summary) {
  return <String, dynamic>{
    'value': summary.value,
    'unit': summary.unit,
    'hasData': summary.hasData,
    'entryCount': summary.entryCount,
  };
}

WeeklyHealthReport _weeklyHealthReportFromJson(Map<String, dynamic> json) {
  final bmi = _metricSummaryFromJson(
    json['bmi'],
    fallbackUnit: 'kg/m²',
  );
  final bloodPressure = _metricSummaryFromJson(
    json['bloodPressure'],
    fallbackUnit: 'mmHg',
  );
  final temperature = _metricSummaryFromJson(
    json['temperature'],
    fallbackUnit: '°C',
  );

  return WeeklyHealthReport(
    bmi: bmi,
    bloodPressure: bloodPressure,
    temperature: temperature,
  );
}

WeeklyHealthMetricSummary _metricSummaryFromJson(
  Object? rawValue, {
  required String fallbackUnit,
}) {
  if (rawValue is! Map<String, dynamic>) {
    return WeeklyHealthMetricSummary.empty(unit: fallbackUnit);
  }

  final unit = _readString(rawValue['unit']);
  final normalizedUnit = unit.trim().isEmpty ? fallbackUnit : unit;

  return WeeklyHealthMetricSummary(
    value: _readString(rawValue['value'], fallback: '--'),
    unit: normalizedUnit,
    hasData: _readBool(rawValue['hasData']),
    entryCount: _readInt(rawValue['entryCount']),
  );
}

String _readString(Object? value, {String fallback = ''}) {
  if (value is! String) {
    return fallback;
  }
  final normalized = value.trim();
  if (normalized.isEmpty) {
    return fallback;
  }
  return normalized;
}

bool _readBool(Object? value) => value is bool ? value : false;

int _readInt(Object? value) => value is int ? value : 0;
