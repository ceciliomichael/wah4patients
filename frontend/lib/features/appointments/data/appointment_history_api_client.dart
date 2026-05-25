import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';
import '../../auth/domain/auth_session.dart';

class AppointmentHistoryApiException implements Exception {
  const AppointmentHistoryApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class AppointmentHistoryDetailResponse {
  const AppointmentHistoryDetailResponse({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  factory AppointmentHistoryDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppointmentHistoryDetailResponse(
      label: _readString(json['label']),
      value: _readString(json['value']),
    );
  }
}

class AppointmentHistoryRecordResponse {
  const AppointmentHistoryRecordResponse({
    required this.id,
    required this.gatewayTransactionId,
    required this.correlationId,
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
  final String gatewayTransactionId;
  final String correlationId;
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
  final List<AppointmentHistoryDetailResponse> details;
  final String recordedAt;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;

  factory AppointmentHistoryRecordResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final detailsJson = json['details'];
    final details = detailsJson is List
        ? detailsJson
              .whereType<Map<String, dynamic>>()
              .map(AppointmentHistoryDetailResponse.fromJson)
              .toList(growable: false)
        : const <AppointmentHistoryDetailResponse>[];

    return AppointmentHistoryRecordResponse(
      id: _readString(json['id']),
      gatewayTransactionId: _readString(
        json['gatewayTransactionId'] ?? json['gateway_transaction_id'],
      ),
      correlationId: _readString(json['correlationId'] ?? json['correlation_id']),
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
      recordedAt: _readString(json['recordedAt']),
      displayOrder: _readInt(json['displayOrder']),
      createdAt: _readString(json['createdAt']),
      updatedAt: _readString(json['updatedAt']),
    );
  }
}

class AppointmentHistoryResponse {
  const AppointmentHistoryResponse({required this.records});

  final List<AppointmentHistoryRecordResponse> records;

  factory AppointmentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const AppointmentHistoryResponse(
        records: <AppointmentHistoryRecordResponse>[],
      );
    }

    return AppointmentHistoryResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(AppointmentHistoryRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class AppointmentHistoryApiClient {
  AppointmentHistoryApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final AppointmentHistoryApiClient instance =
      AppointmentHistoryApiClient();

  final http.Client _httpClient;

  Future<AppointmentHistoryResponse> getHistoryRecords({
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/appointment-history/history',
      bearerToken: accessToken,
    );
    return AppointmentHistoryResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    required String bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const AppointmentHistoryApiException(
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
      throw const AppointmentHistoryApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const AppointmentHistoryApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      AuthSession.requireReauthentication();
    }

    throw AppointmentHistoryApiException(
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
  final parsed = int.tryParse(_readString(value));
  return parsed ?? 0;
}
