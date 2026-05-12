import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_api_client.dart';
import '../data/auth_local_store.dart';
import 'models/auth_api_models.dart';

class AuthSession {
  AuthSession._();

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static String? _accessToken;
  static String? _refreshToken;
  static int? _expiresIn;
  static String? _tokenType;
  static String? _userId;
  static String? _userEmail;
  static UserProfileSummary _profile = UserProfileSummary.empty();

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static int? get expiresIn => _expiresIn;
  static String? get tokenType => _tokenType;
  static String? get userId => _userId;
  static String? get userEmail => _userEmail;
  static List<String> get givenNames => List.unmodifiable(_profile.givenNames);
  static String get familyName => _profile.familyName;
  static String get displayName => _profile.displayName;
  static String get shortDisplayName =>
      _composeShortDisplayName(_profile.givenNames, _profile.familyName);
  static String get greetingName =>
      _composeGreetingName(_profile.givenNames, _profile.familyName);
  static UserProfileSummary get profile => _profile;
  static bool get isPatientProfileComplete => _profile.isComplete;
  static List<String> get missingPatientProfileFields =>
      List.unmodifiable(_profile.missingFields);
  static bool get isAuthenticated =>
      (_accessToken?.trim().isNotEmpty ?? false) &&
      (_userId?.trim().isNotEmpty ?? false);

  static Future<void> restoreFromStorage() async {
    final storedSession = await AuthLocalStore.readSession();
    if (storedSession == null || storedSession.isExpired) {
      await AuthLocalStore.clearSession();
      clear();
      return;
    }

    _accessToken = storedSession.accessToken.trim();
    _refreshToken = storedSession.refreshToken.trim();
    _expiresIn = storedSession.expiresIn;
    _tokenType = storedSession.tokenType.trim();
    _userId = storedSession.userId.trim();
    _userEmail = storedSession.userEmail.trim();
    _profile = storedSession.profile;
    _notifyChanged();
  }

  static Future<bool> refreshIfNeeded() async {
    final storedSession = await AuthLocalStore.readSession();
    if (storedSession == null) {
      clear();
      return false;
    }

    if (!storedSession.isExpired) {
      await restoreFromStorage();
      return true;
    }

    final refreshToken = storedSession.refreshToken.trim();
    if (refreshToken.isEmpty) {
      await AuthLocalStore.clearSession();
      clear();
      return false;
    }

    try {
      final refreshed = await AuthApiClient.instance.refreshSession(
        refreshToken: refreshToken,
      );
      await AuthLocalStore.saveSession(refreshed);
      setFromLoginResult(refreshed);
      return true;
    } on AuthApiException {
      await AuthLocalStore.clearSession();
      clear();
      return false;
    }
  }

  static Future<void> persist(LoginResult result) async {
    setFromLoginResult(result);
    await AuthLocalStore.saveSession(result);
  }

  static Future<void> clearPersistedSession() {
    return AuthLocalStore.clearSession();
  }

  static void setFromLoginResult(LoginResult result) {
    _accessToken = result.accessToken.trim();
    _refreshToken = result.refreshToken.trim();
    _expiresIn = result.expiresIn;
    _tokenType = result.tokenType.trim();
    _userId = result.userId.trim();
    _userEmail = result.userEmail.trim();
    _profile = result.profile;
    _notifyChanged();
  }

  static void setProfile(UserProfileSummary profile) {
    _profile = profile;
    _notifyChanged();

    unawaited(AuthLocalStore.updateProfile(profile));
  }

  static Future<bool> refreshProfileFromBackend() async {
    final accessToken = _accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      return false;
    }

    try {
      final result = await AuthApiClient.instance.getMyProfile(
        accessToken: accessToken,
      );
      _profile = result.profile;
      _notifyChanged();
      await AuthLocalStore.updateProfile(result.profile);
      return true;
    } on AuthApiException {
      return false;
    }
  }

  static void clear() {
    _accessToken = null;
    _refreshToken = null;
    _expiresIn = null;
    _tokenType = null;
    _userId = null;
    _userEmail = null;
    _profile = UserProfileSummary.empty();
    _notifyChanged();

    unawaited(AuthLocalStore.clearSession());
  }

  static String _composeGreetingName(
    List<String> givenNames,
    String familyName,
  ) {
    String? firstName;
    for (final value in givenNames) {
      final trimmedValue = value.trim();
      if (trimmedValue.isNotEmpty) {
        firstName = trimmedValue;
        break;
      }
    }
    final trimmedFamilyName = familyName.trim();

    final parts = <String>[
      if (firstName != null) firstName,
      if (trimmedFamilyName.isNotEmpty) trimmedFamilyName,
    ];

    return parts.join(' ');
  }

  static String _composeShortDisplayName(
    List<String> givenNames,
    String familyName,
  ) {
    String? firstName;
    for (final value in givenNames) {
      final trimmedValue = value.trim();
      if (trimmedValue.isNotEmpty) {
        firstName = trimmedValue;
        break;
      }
    }

    final trimmedFamilyName = familyName.trim();
    final parts = <String>[
      if (firstName != null) firstName,
      if (trimmedFamilyName.isNotEmpty) trimmedFamilyName,
    ];

    return parts.join(' ');
  }

  static void _notifyChanged() {
    notifier.value++;
  }
}
