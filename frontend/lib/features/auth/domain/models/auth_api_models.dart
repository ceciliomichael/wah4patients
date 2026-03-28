class RegistrationPasswordArguments {
  const RegistrationPasswordArguments({
    required this.email,
    required this.registrationToken,
  });

  final String email;
  final String registrationToken;
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

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.tokenType,
    required this.userId,
    required this.userEmail,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final String tokenType;
  final String userId;
  final String userEmail;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map<String, dynamic> ? user : <String, dynamic>{};

    return LoginResult(
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
