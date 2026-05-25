import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';
import '../../auth/domain/auth_session.dart';

class AppointmentRequestApiException implements Exception {
  const AppointmentRequestApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class AppointmentRequestResult {
  const AppointmentRequestResult({
    required this.message,
    required this.transactionId,
    required this.correlationId,
  });

  final String message;
  final String transactionId;
  final String correlationId;

  factory AppointmentRequestResult.fromJson(Map<String, dynamic> json) {
    return AppointmentRequestResult(
      message: _readString(json['message']),
      transactionId: _readString(json['transactionId']),
      correlationId: _readString(json['correlationId'] ?? json['correlation_id']),
    );
  }
}

class AppointmentRequestApiClient {
  AppointmentRequestApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final AppointmentRequestApiClient instance =
      AppointmentRequestApiClient();

  final http.Client _httpClient;

  Future<AppointmentRequestResult> requestAppointment({
    required String providerId,
    required String appointmentMode,
    required String appointmentType,
    required String scheduledAt,
    required int durationMinutes,
    required String locationOrPlatform,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  }) async {
    final userId = AuthSession.userId?.trim() ?? '';
    if (userId.isEmpty) {
      throw const AppointmentRequestApiException(
        'Sign in again so the app can send the appointment request.',
      );
    }

    final response = await _post(
      path: '/interoperability/appointments/request',
      body: <String, dynamic>{
        'targetProviderId': providerId,
        'appointmentMode': appointmentMode,
        'appointmentType': appointmentType,
        'scheduledAt': scheduledAt,
        'durationMinutes': durationMinutes,
        'locationOrPlatform': locationOrPlatform,
        'identifierSystem': identifierSystem,
        'identifierValue': identifierValue,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      headers: <String, String>{
        'x-user-id': userId,
      },
    );

    return AppointmentRequestResult.fromJson(response);
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const AppointmentRequestApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = Uri.parse('${AppEnvironment.normalizedBackendBaseUrl}$path');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.backendApiKey.trim(),
      ...headers,
    };

    late final http.Response response;
    try {
      response = await _httpClient
          .post(uri, headers: requestHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const AppointmentRequestApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const AppointmentRequestApiException(
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

    throw AppointmentRequestApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeResponseBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{};
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
