class RegistrationPersonalDetailsArguments {
  const RegistrationPersonalDetailsArguments({
    required this.email,
    required this.registrationToken,
  });

  final String email;
  final String registrationToken;
}

class RegistrationProfileDraft {
  const RegistrationProfileDraft({
    required this.firstName,
    required this.secondName,
    required this.middleName,
    required this.lastName,
  });

  final String firstName;
  final String secondName;
  final String middleName;
  final String lastName;

  List<String> get givenNames {
    final values = <String>[firstName, secondName, middleName]
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return values;
  }
}

class RegistrationPasswordArguments {
  const RegistrationPasswordArguments({
    required this.email,
    required this.registrationToken,
    required this.profileDraft,
  });

  final String email;
  final String registrationToken;
  final RegistrationProfileDraft profileDraft;
}

class MfaChallengeArguments {
  const MfaChallengeArguments({
    required this.email,
    required this.mfaChallengeToken,
  });

  final String email;
  final String mfaChallengeToken;
}

class LoginScreenArguments {
  const LoginScreenArguments({
    required this.initialEmail,
    this.promptTwoFactorSetup = false,
  });

  final String initialEmail;
  final bool promptTwoFactorSetup;
}

class TotpSetupScreenArguments {
  const TotpSetupScreenArguments({this.allowSkip = false});

  final bool allowSkip;
}

class MpinConfirmArguments {
  const MpinConfirmArguments({
    required this.initialMpin,
    this.securityVerificationToken,
  });

  final String initialMpin;
  final String? securityVerificationToken;
}

class MpinSetupArguments {
  const MpinSetupArguments({this.securityVerificationToken});

  final String? securityVerificationToken;
}

class MpinLoginArguments {
  const MpinLoginArguments({
    required this.email,
    required this.mfaChallengeToken,
  });

  final String email;
  final String mfaChallengeToken;
}

class UserProfileSummary {
  const UserProfileSummary({
    required this.givenNames,
    required this.familyName,
    required this.displayName,
  });

  final List<String> givenNames;
  final String familyName;
  final String displayName;

  factory UserProfileSummary.fromJson(Map<String, dynamic> json) {
    final givenNamesValue = json['givenNames'];
    final givenNames = givenNamesValue is List
        ? givenNamesValue.whereType<String>().toList(growable: false)
        : <String>[];

    return UserProfileSummary(
      givenNames: givenNames,
      familyName: _readString(json['familyName']),
      displayName: _readString(json['displayName']),
    );
  }
}

class ProfileResult {
  const ProfileResult({
    required this.userId,
    required this.userEmail,
    required this.profile,
  });

  final String userId;
  final String userEmail;
  final UserProfileSummary profile;

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final profile = userMap['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : <String, dynamic>{};

    return ProfileResult(
      userId: _readString(userMap['id']),
      userEmail: _readString(userMap['email']),
      profile: UserProfileSummary.fromJson(profileMap),
    );
  }
}

class RequestPasswordResetOtpResult {
  const RequestPasswordResetOtpResult({
    required this.message,
    required this.cooldownSeconds,
  });

  final String message;
  final int cooldownSeconds;

  factory RequestPasswordResetOtpResult.fromJson(Map<String, dynamic> json) {
    return RequestPasswordResetOtpResult(
      message: _readString(json['message']),
      cooldownSeconds: _readInt(json['cooldownSeconds']),
    );
  }
}

class VerifyPasswordResetOtpResult {
  const VerifyPasswordResetOtpResult({
    required this.message,
    required this.passwordResetToken,
    required this.expiresInSeconds,
  });

  final String message;
  final String passwordResetToken;
  final int expiresInSeconds;

  factory VerifyPasswordResetOtpResult.fromJson(Map<String, dynamic> json) {
    return VerifyPasswordResetOtpResult(
      message: _readString(json['message']),
      passwordResetToken: _readString(json['passwordResetToken']),
      expiresInSeconds: _readInt(json['expiresInSeconds']),
    );
  }
}

class CompletePasswordResetResult {
  const CompletePasswordResetResult({required this.message});

  final String message;

  factory CompletePasswordResetResult.fromJson(Map<String, dynamic> json) {
    return CompletePasswordResetResult(message: _readString(json['message']));
  }
}

class TotpSetupStartResult {
  const TotpSetupStartResult({
    required this.otpauthUrl,
    required this.manualEntryKey,
  });

  final String otpauthUrl;
  final String manualEntryKey;

  factory TotpSetupStartResult.fromJson(Map<String, dynamic> json) {
    return TotpSetupStartResult(
      otpauthUrl: _readString(json['otpauthUrl']),
      manualEntryKey: _readString(json['manualEntryKey']),
    );
  }
}

class TotpSetupVerifyResult {
  const TotpSetupVerifyResult({required this.message});

  final String message;

  factory TotpSetupVerifyResult.fromJson(Map<String, dynamic> json) {
    return TotpSetupVerifyResult(message: _readString(json['message']));
  }
}

class DisableTotpResult {
  const DisableTotpResult({required this.message});

  final String message;

  factory DisableTotpResult.fromJson(Map<String, dynamic> json) {
    return DisableTotpResult(message: _readString(json['message']));
  }
}

class RegisterMpinDeviceResult {
  const RegisterMpinDeviceResult({required this.message});

  final String message;

  factory RegisterMpinDeviceResult.fromJson(Map<String, dynamic> json) {
    return RegisterMpinDeviceResult(message: _readString(json['message']));
  }
}

class UnregisterMpinDeviceResult {
  const UnregisterMpinDeviceResult({required this.message});

  final String message;

  factory UnregisterMpinDeviceResult.fromJson(Map<String, dynamic> json) {
    return UnregisterMpinDeviceResult(message: _readString(json['message']));
  }
}

class SecuritySettingsStatusResult {
  const SecuritySettingsStatusResult({
    required this.isTotpEnabled,
    required this.isMpinConfigured,
    required this.isMpinDeviceRegistered,
  });

  final bool isTotpEnabled;
  final bool isMpinConfigured;
  final bool isMpinDeviceRegistered;

  factory SecuritySettingsStatusResult.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsStatusResult(
      isTotpEnabled: json['isTotpEnabled'] == true,
      isMpinConfigured: json['isMpinConfigured'] == true,
      isMpinDeviceRegistered: json['isMpinDeviceRegistered'] == true,
    );
  }
}

class VerifySecurityActionResult {
  const VerifySecurityActionResult({
    required this.message,
    required this.securityVerificationToken,
    required this.expiresInSeconds,
  });

  final String message;
  final String securityVerificationToken;
  final int expiresInSeconds;

  factory VerifySecurityActionResult.fromJson(Map<String, dynamic> json) {
    return VerifySecurityActionResult(
      message: _readString(json['message']),
      securityVerificationToken: _readString(json['securityVerificationToken']),
      expiresInSeconds: _readInt(json['expiresInSeconds']),
    );
  }
}

class VerifyMpinResult {
  const VerifyMpinResult({
    required this.message,
    required this.remainingAttempts,
    required this.lockedUntil,
  });

  final String message;
  final int remainingAttempts;
  final String lockedUntil;

  factory VerifyMpinResult.fromJson(Map<String, dynamic> json) {
    return VerifyMpinResult(
      message: _readString(json['message']),
      remainingAttempts: _readInt(json['remainingAttempts']),
      lockedUntil: _readString(json['lockedUntil']),
    );
  }
}

class LoginResult {
  const LoginResult({
    required this.mfaRequired,
    required this.mfaChallengeToken,
    required this.mfaChallengeExpiresInSeconds,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.userId,
    required this.userEmail,
    required this.profile,
  });

  final bool mfaRequired;
  final String mfaChallengeToken;
  final int mfaChallengeExpiresInSeconds;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String userId;
  final String userEmail;
  final UserProfileSummary profile;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final profile = userMap['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : <String, dynamic>{};
    final mfaRequired = json['mfaRequired'] == true;

    return LoginResult(
      mfaRequired: mfaRequired,
      mfaChallengeToken: _readString(json['mfaChallengeToken']),
      mfaChallengeExpiresInSeconds: _readInt(json['expiresInSeconds']),
      accessToken: _readString(json['accessToken']),
      refreshToken: _readString(json['refreshToken']),
      expiresIn: _readInt(json['expiresIn']),
      tokenType: _readString(json['tokenType']),
      userId: _readString(userMap['id']),
      userEmail: _readString(userMap['email']),
      profile: UserProfileSummary.fromJson(profileMap),
    );
  }
}

String _readString(Object? value) {
  return value is String ? value : '';
}

int _readInt(Object? value) {
  return value is int ? value : 0;
}
