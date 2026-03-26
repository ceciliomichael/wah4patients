import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';
import '../domain/models/auth_api_models.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class AuthApiClient {
  AuthApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  static final AuthApiClient instance = AuthApiClient();

  final http.Client _httpClient;

  Future<void> requestRegistrationOtp({required String email}) async {
    await _post(
      path: '/auth/register/request-otp',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<void> resendRegistrationOtp({required String email}) async {
    await _post(
      path: '/auth/register/resend-otp',
      body: <String, dynamic>{'email': email},
    );
  }

  Future<String> verifyRegistrationOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _post(
      path: '/auth/register/verify-otp',
      body: <String, dynamic>{'email': email, 'otpCode': otpCode},
    );

    final token = response['registrationToken'];
    if (token is! String || token.trim().isEmpty) {
      throw const AuthApiException(
        'Registration token was missing from verification response',
      );
    }

    return token;
  }

  Future<void> completeRegistration({
    required String email,
    required String password,
    required String registrationToken,
  }) async {
    await _post(
      path: '/auth/register/complete',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'registrationToken': registrationToken,
      },
    );
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      path: '/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
    );

    return LoginResult.fromJson(response);
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const AuthApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = _buildUri(path);
    final response = await _httpClient.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'x-api-key': AppEnvironment.backendApiKey.trim(),
      },
      body: jsonEncode(body),
    );

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw AuthApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Uri _buildUri(String path) {
    return Uri.parse('${AppEnvironment.normalizedBackendBaseUrl}$path');
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
      final firstMessage = message.firstWhere(
        (item) => item is String && item.trim().isNotEmpty,
        orElse: () => null,
      );
      if (firstMessage is String) {
        return firstMessage;
      }
    }

    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    return null;
  }
}
