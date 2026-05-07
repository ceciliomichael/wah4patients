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

class PatientProfileDraft {
  const PatientProfileDraft({
    required this.firstName,
    required this.secondName,
    required this.middleName,
    required this.lastName,
    required this.birthDate,
    required this.gender,
    required this.phoneNumber,
    required this.communicationLanguage,
    required this.philHealthId,
    required this.philSysId,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.maritalStatus,
    required this.nationality,
    required this.religion,
    required this.occupation,
    required this.genderIdentity,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
  });

  final String firstName;
  final String secondName;
  final String middleName;
  final String lastName;
  final String birthDate;
  final String gender;
  final String phoneNumber;
  final String communicationLanguage;
  final String philHealthId;
  final String philSysId;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String maritalStatus;
  final String nationality;
  final String religion;
  final String occupation;
  final String genderIdentity;
  final String emergencyContactName;
  final String emergencyContactPhone;

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
    this.nextRouteAfterSuccess,
    this.nextRouteArguments,
  });

  final String email;
  final String mfaChallengeToken;
  final String? nextRouteAfterSuccess;
  final Object? nextRouteArguments;
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
    this.nextRouteAfterSave,
    this.nextRouteArguments,
  });

  final String initialMpin;
  final String? securityVerificationToken;
  final String? nextRouteAfterSave;
  final Object? nextRouteArguments;
}

class MpinSetupArguments {
  const MpinSetupArguments({
    this.securityVerificationToken,
    this.nextRouteAfterSave,
    this.nextRouteArguments,
  });

  final String? securityVerificationToken;
  final String? nextRouteAfterSave;
  final Object? nextRouteArguments;
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
    required this.birthDate,
    required this.gender,
    required this.phoneNumber,
    required this.communicationLanguage,
    required this.philHealthId,
    required this.philSysId,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    required this.maritalStatus,
    required this.nationality,
    required this.religion,
    required this.occupation,
    required this.genderIdentity,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.isComplete,
    required this.missingFields,
  });

  final List<String> givenNames;
  final String familyName;
  final String displayName;
  final String birthDate;
  final String gender;
  final String phoneNumber;
  final String communicationLanguage;
  final String philHealthId;
  final String philSysId;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String maritalStatus;
  final String nationality;
  final String religion;
  final String occupation;
  final String genderIdentity;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final bool isComplete;
  final List<String> missingFields;

  factory UserProfileSummary.fromJson(Map<String, dynamic> json) {
    final givenNamesValue = json['givenNames'];
    final givenNames = givenNamesValue is List
        ? givenNamesValue.whereType<String>().toList(growable: false)
        : <String>[];
    final missingFieldsValue = json['missingFields'];
    final missingFields = missingFieldsValue is List
        ? missingFieldsValue.whereType<String>().toList(growable: false)
        : <String>[];

    return UserProfileSummary(
      givenNames: givenNames,
      familyName: _readString(json['familyName']),
      displayName: _readString(json['displayName']),
      birthDate: _readString(json['birthDate']),
      gender: _readString(json['gender']),
      phoneNumber: _readString(json['phoneNumber']),
      communicationLanguage: _readString(json['communicationLanguage']),
      philHealthId: _readString(json['philHealthId']),
      philSysId: _readString(json['philSysId']),
      addressLine1: _readString(json['addressLine1']),
      addressLine2: _readString(json['addressLine2']),
      city: _readString(json['city']),
      province: _readString(json['province']),
      postalCode: _readString(json['postalCode']),
      country: _readString(json['country']),
      maritalStatus: _readString(json['maritalStatus']),
      nationality: _readString(json['nationality']),
      religion: _readString(json['religion']),
      occupation: _readString(json['occupation']),
      genderIdentity: _readString(json['genderIdentity']),
      emergencyContactName: _readString(json['emergencyContactName']),
      emergencyContactPhone: _readString(json['emergencyContactPhone']),
      isComplete: json['isComplete'] == true,
      missingFields: missingFields,
    );
  }

  static UserProfileSummary empty() {
    return const UserProfileSummary(
      givenNames: <String>[],
      familyName: '',
      displayName: '',
      birthDate: '',
      gender: '',
      phoneNumber: '',
      communicationLanguage: '',
      philHealthId: '',
      philSysId: '',
      addressLine1: '',
      addressLine2: '',
      city: '',
      province: '',
      postalCode: '',
      country: '',
      maritalStatus: '',
      nationality: '',
      religion: '',
      occupation: '',
      genderIdentity: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
      isComplete: false,
      missingFields: <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'givenNames': givenNames,
      'familyName': familyName,
      'displayName': displayName,
      'birthDate': birthDate,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'communicationLanguage': communicationLanguage,
      'philHealthId': philHealthId,
      'philSysId': philSysId,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'province': province,
      'postalCode': postalCode,
      'country': country,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'religion': religion,
      'occupation': occupation,
      'genderIdentity': genderIdentity,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'isComplete': isComplete,
      'missingFields': missingFields,
    };
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
