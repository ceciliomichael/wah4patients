import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';
import '../domain/interoperability_models.dart';

class InteroperabilityApiException implements Exception {
  const InteroperabilityApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

abstract class InteroperabilityClient {
  Future<List<InteroperabilityProviderSummary>> getProviders();

  Future<SyncRequestPreview> prepareSyncRequest({
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  });

  Future<SyncSimulationResult> simulateSyncRequest({
    required String accessToken,
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  });
}

class InteroperabilityApiClient implements InteroperabilityClient {
  InteroperabilityApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final InteroperabilityApiClient instance = InteroperabilityApiClient();

  final http.Client _httpClient;

  @override
  Future<List<InteroperabilityProviderSummary>> getProviders() async {
    final response = await _get(path: '/interoperability/providers');
    final providersValue = response['providers'];
    if (providersValue is! List) {
      return const <InteroperabilityProviderSummary>[];
    }

    return providersValue
        .whereType<Map<String, dynamic>>()
        .map(InteroperabilityProviderSummary.fromJson)
        .toList(growable: false);
  }

  @override
  Future<SyncRequestPreview> prepareSyncRequest({
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  }) async {
    final response = await _post(
      path: '/interoperability/sync/prepare',
      body: <String, dynamic>{
        'providerId': providerId,
        'identifierSystem': identifierSystem,
        'identifierValue': identifierValue,
        'resourceType': 'Patient',
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );

    return SyncRequestPreview.fromJson(response);
  }

  @override
  Future<SyncSimulationResult> simulateSyncRequest({
    required String accessToken,
    required String providerId,
    required String identifierSystem,
    required String identifierValue,
    String? reason,
    String? notes,
  }) async {
    final response = await _post(
      path: '/interoperability/sync/simulate',
      body: <String, dynamic>{
        'providerId': providerId,
        'identifierSystem': identifierSystem,
        'identifierValue': identifierValue,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      headers: <String, String>{
        'authorization': 'Bearer ${accessToken.trim()}',
      },
    );

    return SyncSimulationResult.fromJson(response);
  }

  Future<Map<String, dynamic>> _get({required String path}) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const InteroperabilityApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = Uri.parse('${AppEnvironment.normalizedBackendBaseUrl}$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.backendApiKey.trim(),
    };

    late final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const InteroperabilityApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const InteroperabilityApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw InteroperabilityApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
    Map<String, String> headers = const <String, String>{},
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const InteroperabilityApiException(
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
      throw const InteroperabilityApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const InteroperabilityApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw InteroperabilityApiException(
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
