import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/models/auth_api_models.dart';

class AuthLocalStore {
  AuthLocalStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _sessionKey = 'auth.session';
  static const String _onboardingCompletedKey = 'app.onboarding.completed';

  static Future<void> saveSession(LoginResult result) async {
    final payload = <String, dynamic>{
      'accessToken': result.accessToken.trim(),
      'refreshToken': result.refreshToken.trim(),
      'expiresIn': result.expiresIn,
      'tokenType': result.tokenType.trim(),
      'userId': result.userId.trim(),
      'userEmail': result.userEmail.trim(),
      'givenNames': result.profile.givenNames,
      'familyName': result.profile.familyName.trim(),
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

    await saveRawSession(
      currentSession.copyWith(
        givenNames: profile.givenNames,
        familyName: profile.familyName.trim(),
      ),
    );
  }

  static Future<void> saveRawSession(AuthSessionData session) async {
    final payload = <String, dynamic>{
      'accessToken': session.accessToken.trim(),
      'refreshToken': session.refreshToken.trim(),
      'expiresIn': session.expiresIn,
      'tokenType': session.tokenType.trim(),
      'userId': session.userId.trim(),
      'userEmail': session.userEmail.trim(),
      'givenNames': session.givenNames,
      'familyName': session.familyName.trim(),
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
}

class AuthSessionData {
  const AuthSessionData({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.userId,
    required this.userEmail,
    required this.givenNames,
    required this.familyName,
    required this.savedAt,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String userId;
  final String userEmail;
  final List<String> givenNames;
  final String familyName;
  final DateTime savedAt;

  bool get isExpired {
    if (expiresIn <= 0) {
      return true;
    }

    final expiresAt = savedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().toUtc().isAfter(expiresAt);
  }

  AuthSessionData copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
    String? userId,
    String? userEmail,
    List<String>? givenNames,
    String? familyName,
    DateTime? savedAt,
  }) {
    return AuthSessionData(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenType: tokenType ?? this.tokenType,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      givenNames: givenNames ?? this.givenNames,
      familyName: familyName ?? this.familyName,
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
      profile: UserProfileSummary(
        givenNames: givenNames,
        familyName: familyName,
        displayName: '',
      ),
    );
  }

  factory AuthSessionData.fromJson(Map<String, dynamic> json) {
    final givenNamesValue = json['givenNames'];
    final givenNames = givenNamesValue is List
        ? givenNamesValue.whereType<String>().toList(growable: false)
        : <String>[];

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
      givenNames: givenNames,
      familyName: _readString(json['familyName']),
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
