import 'dart:async';
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
  AuthApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

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

  Future<RequestPasswordResetOtpResult> requestPasswordResetOtp({
    required String email,
  }) async {
    final response = await _post(
      path: '/auth/password-reset/request-otp',
      body: <String, dynamic>{'email': email},
    );

    return RequestPasswordResetOtpResult.fromJson(response);
  }

  Future<RequestPasswordResetOtpResult> resendPasswordResetOtp({
    required String email,
  }) async {
    final response = await _post(
      path: '/auth/password-reset/resend-otp',
      body: <String, dynamic>{'email': email},
    );

    return RequestPasswordResetOtpResult.fromJson(response);
  }

  Future<VerifyPasswordResetOtpResult> verifyPasswordResetOtp({
    required String email,
    required String otpCode,
  }) async {
    final response = await _post(
      path: '/auth/password-reset/verify-otp',
      body: <String, dynamic>{'email': email, 'otpCode': otpCode},
    );

    return VerifyPasswordResetOtpResult.fromJson(response);
  }

  Future<CompletePasswordResetResult> completePasswordReset({
    required String email,
    required String password,
    required String passwordResetToken,
  }) async {
    final response = await _post(
      path: '/auth/password-reset/complete',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'passwordResetToken': passwordResetToken,
      },
    );

    return CompletePasswordResetResult.fromJson(response);
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

  Future<LoginResult> verifyMfaChallenge({
    required String mfaChallengeToken,
    required String code,
  }) async {
    final response = await _post(
      path: '/auth/2fa/challenge/verify',
      body: <String, dynamic>{
        'mfaChallengeToken': mfaChallengeToken,
        'code': code,
      },
    );

    return LoginResult.fromJson(response);
  }

  Future<LoginResult> verifyMfaBackupCode({
    required String mfaChallengeToken,
    required String backupCode,
  }) async {
    final response = await _post(
      path: '/auth/2fa/challenge/verify-backup-code',
      body: <String, dynamic>{
        'mfaChallengeToken': mfaChallengeToken,
        'backupCode': backupCode,
      },
    );

    return LoginResult.fromJson(response);
  }

  Future<TotpSetupStartResult> startTotpSetup({
    required String accessToken,
  }) async {
    final response = await _post(
      path: '/auth/2fa/setup/start',
      body: const <String, dynamic>{},
      bearerToken: accessToken,
    );

    return TotpSetupStartResult.fromJson(response);
  }

  Future<TotpSetupVerifyResult> verifyTotpSetup({
    required String accessToken,
    required String code,
  }) async {
    final response = await _post(
      path: '/auth/2fa/setup/verify',
      body: <String, dynamic>{'code': code},
      bearerToken: accessToken,
    );

    return TotpSetupVerifyResult.fromJson(response);
  }

  Future<DisableTotpResult> disableTotp({
    required String accessToken,
    required String password,
    required String code,
  }) async {
    final response = await _post(
      path: '/auth/2fa/disable',
      body: <String, dynamic>{
        'password': password,
        'code': code,
      },
      bearerToken: accessToken,
    );

    return DisableTotpResult.fromJson(response);
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const AuthApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = _buildUri(path);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.backendApiKey.trim(),
    };

    final trimmedBearerToken = bearerToken?.trim() ?? '';
    if (trimmedBearerToken.isNotEmpty) {
      headers['authorization'] = 'Bearer $trimmedBearerToken';
    }

    late final http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const AuthApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const AuthApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

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
