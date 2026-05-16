import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/auth_api_client.dart';
import '../data/auth_local_store.dart';
import 'models/auth_api_models.dart';

class AuthSession {
  AuthSession._();

  static const Duration _refreshBuffer = Duration(minutes: 5);
  static const Duration _transientRefreshRetryDelay = Duration(minutes: 1);

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static String? _accessToken;
  static String? _refreshToken;
  static int? _expiresIn;
  static String? _tokenType;
  static String? _userId;
  static String? _userEmail;
  static DateTime? _savedAt;
  static UserProfileSummary _profile = UserProfileSummary.empty();
  static Timer? _refreshTimer;

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
  static bool get isAccessTokenExpired {
    final savedAt = _savedAt;
    final expiresIn = _expiresIn;
    if (savedAt == null || expiresIn == null || expiresIn <= 0) {
      return true;
    }

    final expiresAt = savedAt.add(Duration(seconds: expiresIn));
    return !DateTime.now().toUtc().isBefore(expiresAt);
  }

  static Future<void> restoreFromStorage() async {
    final storedSession = await AuthLocalStore.readSession();
    if (storedSession == null) {
      await AuthLocalStore.clearSession();
      clear();
      return;
    }

    _setFromStoredSession(storedSession);
  }

  static Future<bool> refreshIfNeeded() async {
    final storedSession = await AuthLocalStore.readSession();
    if (storedSession == null) {
      clear();
      return false;
    }

    if (!storedSession.isExpiringSoon(buffer: _refreshBuffer)) {
      _setFromStoredSession(storedSession);
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
      _setFromLoginResult(refreshed);
      return true;
    } on AuthApiException catch (error) {
      final statusCode = error.statusCode;
      final shouldSignOut =
          statusCode == 400 || statusCode == 401 || statusCode == 403;
      if (shouldSignOut) {
        await AuthLocalStore.clearSession();
        clear();
        return false;
      }

      _setFromStoredSession(storedSession);
      _scheduleRefreshRetry();
      return true;
    }
  }

  static Future<void> persist(LoginResult result) async {
    _setFromLoginResult(result);
    await AuthLocalStore.saveSession(result);
  }

  static Future<void> clearPersistedSession() {
    return AuthLocalStore.clearSession();
  }

  static void setFromLoginResult(LoginResult result) {
    _setFromLoginResult(result);
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
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _accessToken = null;
    _refreshToken = null;
    _expiresIn = null;
    _tokenType = null;
    _userId = null;
    _userEmail = null;
    _savedAt = null;
    _profile = UserProfileSummary.empty();
    _notifyChanged();

    unawaited(AuthLocalStore.clearSession());
  }

  static void _setFromStoredSession(AuthSessionData storedSession) {
    _accessToken = storedSession.accessToken.trim();
    _refreshToken = storedSession.refreshToken.trim();
    _expiresIn = storedSession.expiresIn;
    _tokenType = storedSession.tokenType.trim();
    _userId = storedSession.userId.trim();
    _userEmail = storedSession.userEmail.trim();
    _savedAt = storedSession.savedAt.toUtc();
    _profile = storedSession.profile;
    _notifyChanged();
    _scheduleRefreshTimer(storedSession);
  }

  static void _setFromLoginResult(LoginResult result) {
    _accessToken = result.accessToken.trim();
    _refreshToken = result.refreshToken.trim();
    _expiresIn = result.expiresIn;
    _tokenType = result.tokenType.trim();
    _userId = result.userId.trim();
    _userEmail = result.userEmail.trim();
    _savedAt = DateTime.now().toUtc();
    _profile = result.profile;
    _notifyChanged();
    _scheduleRefreshTimer(_loginResultToSession(result));
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

  static AuthSessionData _loginResultToSession(LoginResult result) {
    return AuthSessionData(
      accessToken: result.accessToken.trim(),
      refreshToken: result.refreshToken.trim(),
      expiresIn: result.expiresIn,
      tokenType: result.tokenType.trim(),
      userId: result.userId.trim(),
      userEmail: result.userEmail.trim(),
      profile: result.profile,
      savedAt: DateTime.now().toUtc(),
    );
  }

  static void _scheduleRefreshTimer(AuthSessionData session) {
    _refreshTimer?.cancel();

    final delay = _timeUntilRefresh(session);
    if (delay == null) {
      return;
    }

    _refreshTimer = Timer(delay, () {
      unawaited(_refreshSilently());
    });
  }

  static Duration? _timeUntilRefresh(AuthSessionData session) {
    if (session.expiresIn <= 0) {
      return Duration.zero;
    }

    final refreshAt = session.expiresAt.subtract(_refreshBuffer);
    final now = DateTime.now().toUtc();
    if (!refreshAt.isAfter(now)) {
      return Duration.zero;
    }

    return refreshAt.difference(now);
  }

  static void _scheduleRefreshRetry() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(_transientRefreshRetryDelay, () {
      unawaited(_refreshSilently());
    });
  }

  static Future<void> _refreshSilently() async {
    try {
      await refreshIfNeeded();
    } catch (_) {
      // Keep the existing session state so the app can retry on the next
      // foreground/resume cycle instead of forcing a hard logout.
    }
  }
}
