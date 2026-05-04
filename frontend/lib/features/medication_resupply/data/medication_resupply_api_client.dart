import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';

class MedicationResupplyApiException implements Exception {
  const MedicationResupplyApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class MedicationResupplyHistoryRecordResponse {
  const MedicationResupplyHistoryRecordResponse({
    required this.id,
    required this.profileId,
    required this.medicationName,
    required this.dosage,
    required this.status,
    required this.note,
    required this.requestedAt,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final String medicationName;
  final String dosage;
  final String status;
  final String note;
  final String requestedAt;
  final int displayOrder;
  final String createdAt;
  final String updatedAt;

  factory MedicationResupplyHistoryRecordResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return MedicationResupplyHistoryRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      medicationName: _readString(json['medicationName']),
      dosage: _readString(json['dosage']),
      status: _readString(json['status']),
      note: _readString(json['note']),
      requestedAt: _readString(json['requestedAt']),
      displayOrder: _readInt(json['displayOrder']),
      createdAt: _readString(json['createdAt']),
      updatedAt: _readString(json['updatedAt']),
    );
  }
}

class MedicationResupplyHistoryResponse {
  const MedicationResupplyHistoryResponse({required this.records});

  final List<MedicationResupplyHistoryRecordResponse> records;

  factory MedicationResupplyHistoryResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const MedicationResupplyHistoryResponse(
        records: <MedicationResupplyHistoryRecordResponse>[],
      );
    }

    return MedicationResupplyHistoryResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(MedicationResupplyHistoryRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class MedicationResupplyApiClient {
  MedicationResupplyApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final MedicationResupplyApiClient instance =
      MedicationResupplyApiClient();

  final http.Client _httpClient;

  Future<MedicationResupplyHistoryResponse> getHistoryRecords({
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/medication-resupply/history',
      bearerToken: accessToken,
    );
    return MedicationResupplyHistoryResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    required String bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const MedicationResupplyApiException(
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
      throw const MedicationResupplyApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const MedicationResupplyApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw MedicationResupplyApiException(
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
