import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models/auth_api_models.dart';

class AuthLocalStore {
  AuthLocalStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _sessionKey = 'auth.session';
  static const String _onboardingCompletedKey = 'app.onboarding.completed';
  static const String _profilePromptDismissedKey =
      'app.profile-completion-prompt.dismissed';
  static const String _registrationOtpEmailKey =
      'auth.registration.pending_otp_email';

  static Future<void> saveSession(LoginResult result) async {
    final payload = <String, dynamic>{
      'accessToken': result.accessToken.trim(),
      'refreshToken': result.refreshToken.trim(),
      'expiresIn': result.expiresIn,
      'tokenType': result.tokenType.trim(),
      'userId': result.userId.trim(),
      'userEmail': result.userEmail.trim(),
      'profile': result.profile.toJson(),
      'savedAt': DateTime.now().toUtc().toIso8601String(),
    };

    await _storage.write(key: _sessionKey, value: jsonEncode(payload));
  }

  static Future<AuthSessionData?> readSession() async {
    final rawValue = await _storage.read(key: _sessionKey);
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return AuthSessionData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateProfile(UserProfileSummary profile) async {
    final currentSession = await readSession();
    if (currentSession == null) {
      return;
    }

    await saveRawSession(currentSession.copyWith(profile: profile));
  }

  static Future<void> saveRawSession(AuthSessionData session) async {
    final payload = <String, dynamic>{
      'accessToken': session.accessToken.trim(),
      'refreshToken': session.refreshToken.trim(),
      'expiresIn': session.expiresIn,
      'tokenType': session.tokenType.trim(),
      'userId': session.userId.trim(),
      'userEmail': session.userEmail.trim(),
      'profile': session.profile.toJson(),
      'savedAt': session.savedAt.toUtc().toIso8601String(),
    };

    await _storage.write(key: _sessionKey, value: jsonEncode(payload));
  }

  static Future<void> clearSession() {
    return _storage.delete(key: _sessionKey);
  }

  static Future<bool> isOnboardingCompleted() async {
    final rawValue = await _storage.read(key: _onboardingCompletedKey);
    return rawValue == 'true';
  }

  static Future<void> setOnboardingCompleted(bool completed) {
    return _storage.write(
      key: _onboardingCompletedKey,
      value: completed ? 'true' : 'false',
    );
  }

  static Future<void> clearOnboardingCompleted() {
    return _storage.delete(key: _onboardingCompletedKey);
  }

  static Future<void> savePendingRegistrationOtpEmail(String email) async {
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      await clearPendingRegistrationOtpEmail();
      return;
    }

    await _storage.write(key: _registrationOtpEmailKey, value: normalizedEmail);
  }

  static Future<String?> readPendingRegistrationOtpEmail() async {
    final rawValue = await _storage.read(key: _registrationOtpEmailKey);
    final normalizedEmail = rawValue?.trim() ?? '';
    if (normalizedEmail.isEmpty) {
      return null;
    }

    return normalizedEmail;
  }

  static Future<void> clearPendingRegistrationOtpEmail() {
    return _storage.delete(key: _registrationOtpEmailKey);
  }

  static Future<bool> isProfileCompletionPromptDismissed() async {
    final rawValue = await _storage.read(key: _profilePromptDismissedKey);
    return rawValue == 'true';
  }

  static Future<void> setProfileCompletionPromptDismissed(bool dismissed) {
    return _storage.write(
      key: _profilePromptDismissedKey,
      value: dismissed ? 'true' : 'false',
    );
  }

  static Future<void> clearProfileCompletionPromptDismissed() {
    return _storage.delete(key: _profilePromptDismissedKey);
  }
}

class AuthSessionData {
  const AuthSessionData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.userId,
    required this.userEmail,
    required this.profile,
    required this.savedAt,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String userId;
  final String userEmail;
  final UserProfileSummary profile;
  final DateTime savedAt;

  DateTime get expiresAt => savedAt.add(Duration(seconds: expiresIn));

  bool get isExpired {
    return isExpiredAt();
  }

  bool isExpiredAt([DateTime? now]) {
    if (expiresIn <= 0) {
      return true;
    }

    final currentTime = (now ?? DateTime.now()).toUtc();
    return !currentTime.isBefore(expiresAt);
  }

  bool isExpiringSoon({
    Duration buffer = const Duration(minutes: 5),
    DateTime? now,
  }) {
    if (expiresIn <= 0) {
      return true;
    }

    if (buffer <= Duration.zero) {
      return isExpiredAt(now);
    }

    final currentTime = (now ?? DateTime.now()).toUtc();
    final refreshDeadline = expiresAt.subtract(buffer);
    return !currentTime.isBefore(refreshDeadline);
  }

  AuthSessionData copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
    String? userId,
    String? userEmail,
    UserProfileSummary? profile,
    DateTime? savedAt,
  }) {
    return AuthSessionData(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenType: tokenType ?? this.tokenType,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      profile: profile ?? this.profile,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  LoginResult toLoginResult() {
    return LoginResult(
      mfaRequired: false,
      mfaChallengeToken: '',
      mfaChallengeExpiresInSeconds: 0,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      tokenType: tokenType,
      userId: userId,
      userEmail: userEmail,
      profile: profile,
    );
  }

  factory AuthSessionData.fromJson(Map<String, dynamic> json) {
    final profileValue = json['profile'];
    final profileMap = profileValue is Map<String, dynamic>
        ? profileValue
        : <String, dynamic>{};

    final savedAtValue = json['savedAt'];
    final savedAt = savedAtValue is String
        ? DateTime.tryParse(savedAtValue)?.toUtc()
        : null;

    if (savedAt == null) {
      throw const FormatException('Missing session savedAt timestamp');
    }

    return AuthSessionData(
      accessToken: _readString(json['accessToken']),
      refreshToken: _readString(json['refreshToken']),
      expiresIn: _readInt(json['expiresIn']),
      tokenType: _readString(json['tokenType']),
      userId: _readString(json['userId']),
      userEmail: _readString(json['userEmail']),
      profile: UserProfileSummary.fromJson(profileMap),
      savedAt: savedAt,
    );
  }
}

String _readString(Object? value) {
  return value is String ? value : '';
}

int _readInt(Object? value) {
  return value is int ? value : 0;
}
