class RegistrationPasswordArguments {
  const RegistrationPasswordArguments({
    required this.email,
    required this.registrationToken,
  });

  final String email;
  final String registrationToken;
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
  const TotpSetupScreenArguments({
    this.allowSkip = false,
  });

  final bool allowSkip;
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
  const TotpSetupVerifyResult({
    required this.message,
    required this.recoveryCodes,
  });

  final String message;
  final List<String> recoveryCodes;

  factory TotpSetupVerifyResult.fromJson(Map<String, dynamic> json) {
    final recoveryCodesValue = json['recoveryCodes'];
    final recoveryCodes = recoveryCodesValue is List
        ? recoveryCodesValue.whereType<String>().toList(growable: false)
        : <String>[];

    return TotpSetupVerifyResult(
      message: _readString(json['message']),
      recoveryCodes: recoveryCodes,
    );
  }
}

class DisableTotpResult {
  const DisableTotpResult({required this.message});

  final String message;

  factory DisableTotpResult.fromJson(Map<String, dynamic> json) {
    return DisableTotpResult(message: _readString(json['message']));
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

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};
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
    );
  }
}

String _readString(Object? value) {
  return value is String ? value : '';
}

int _readInt(Object? value) {
  return value is int ? value : 0;
}
