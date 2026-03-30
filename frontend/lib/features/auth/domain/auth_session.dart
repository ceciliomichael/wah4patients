import 'package:flutter/foundation.dart';

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
  static List<String> _givenNames = <String>[];
  static String _familyName = '';

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static int? get expiresIn => _expiresIn;
  static String? get tokenType => _tokenType;
  static String? get userId => _userId;
  static String? get userEmail => _userEmail;
  static List<String> get givenNames => List.unmodifiable(_givenNames);
  static String get familyName => _familyName;
  static String get displayName =>
      _composeDisplayName(_givenNames, _familyName);
  static String get greetingName =>
      _composeGreetingName(_givenNames, _familyName);
  static bool get isAuthenticated =>
      (_accessToken?.trim().isNotEmpty ?? false) &&
      (_userId?.trim().isNotEmpty ?? false);

  static void setFromLoginResult(LoginResult result) {
    _accessToken = result.accessToken.trim();
    _refreshToken = result.refreshToken.trim();
    _expiresIn = result.expiresIn;
    _tokenType = result.tokenType.trim();
    _userId = result.userId.trim();
    _userEmail = result.userEmail.trim();
    _givenNames = result.profile.givenNames;
    _familyName = result.profile.familyName.trim();
    _notifyChanged();
  }

  static void setProfile(UserProfileSummary profile) {
    _givenNames = profile.givenNames;
    _familyName = profile.familyName.trim();
    _notifyChanged();
  }

  static void clear() {
    _accessToken = null;
    _refreshToken = null;
    _expiresIn = null;
    _tokenType = null;
    _userId = null;
    _userEmail = null;
    _givenNames = <String>[];
    _familyName = '';
    _notifyChanged();
  }

  static String _composeDisplayName(
    List<String> givenNames,
    String familyName,
  ) {
    final parts = <String>[
      ...givenNames
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty),
      familyName.trim(),
    ].where((value) => value.isNotEmpty).toList(growable: false);

    return parts.join(' ');
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

  static void _notifyChanged() {
    notifier.value++;
  }
}
