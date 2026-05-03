import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';

class HealthRecordsApiException implements Exception {
  const HealthRecordsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

enum HealthRecordSection {
  medicalHistory('medical-history'),
  immunizations('immunizations'),
  consultations('consultations'),
  laboratoryResults('laboratory-results');

  const HealthRecordSection(this.pathSegment);

  final String pathSegment;
}

class HealthRecordDetailResponse {
  const HealthRecordDetailResponse({required this.label, required this.value});

  final String label;
  final String value;

  factory HealthRecordDetailResponse.fromJson(Map<String, dynamic> json) {
    return HealthRecordDetailResponse(
      label: _readString(json['label']),
      value: _readString(json['value']),
    );
  }
}

class HealthRecordResponse {
  const HealthRecordResponse({
    required this.id,
    required this.profileId,
    required this.title,
    required this.subtitle,
    required this.summaryLabel,
    required this.summaryValue,
    required this.filterValue,
    required this.statusLabel,
    required this.statusColorKey,
    required this.accentColorKey,
    required this.iconKey,
    required this.details,
    required this.recordedAt,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final String title;
  final String subtitle;
  final String summaryLabel;
  final String summaryValue;
  final String filterValue;
  final String statusLabel;
  final String statusColorKey;
  final String accentColorKey;
  final String iconKey;
  final List<HealthRecordDetailResponse> details;
  final DateTime recordedAt;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory HealthRecordResponse.fromJson(Map<String, dynamic> json) {
    final detailsJson = json['details'];
    final details = detailsJson is List
        ? detailsJson
              .whereType<Map<String, dynamic>>()
              .map(HealthRecordDetailResponse.fromJson)
              .toList(growable: false)
        : const <HealthRecordDetailResponse>[];

    return HealthRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      title: _readString(json['title']),
      subtitle: _readString(json['subtitle']),
      summaryLabel: _readString(json['summaryLabel']),
      summaryValue: _readString(json['summaryValue']),
      filterValue: _readString(json['filterValue']),
      statusLabel: _readString(json['statusLabel']),
      statusColorKey: _readString(json['statusColorKey']),
      accentColorKey: _readString(json['accentColorKey']),
      iconKey: _readString(json['iconKey']),
      details: details,
      recordedAt: _readDateTime(json['recordedAt']),
      displayOrder: _readInt(json['displayOrder']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }
}

class HealthRecordsResponse {
  const HealthRecordsResponse({required this.records});

  final List<HealthRecordResponse> records;

  factory HealthRecordsResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const HealthRecordsResponse(records: <HealthRecordResponse>[]);
    }

    return HealthRecordsResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(HealthRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class HealthRecordsApiClient {
  HealthRecordsApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final HealthRecordsApiClient instance = HealthRecordsApiClient();

  final http.Client _httpClient;

  Future<HealthRecordsResponse> getRecords({
    required HealthRecordSection section,
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/health-records/${section.pathSegment}',
      bearerToken: accessToken,
    );
    return HealthRecordsResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    required String bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const HealthRecordsApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = Uri.parse('${AppEnvironment.normalizedBackendBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.backendApiKey.trim(),
      'authorization': 'Bearer ${bearerToken.trim()}',
    };

    late final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const HealthRecordsApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const HealthRecordsApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw HealthRecordsApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String? _extractErrorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    if (message is List) {
      for (final item in message) {
        if (item is String && item.trim().isNotEmpty) {
          return item;
        }
      }
    }

    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    return null;
  }
}

String _readString(Object? value) {
  if (value is String) {
    return value;
  }
  return '';
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}

DateTime _readDateTime(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value)?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}
