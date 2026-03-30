class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding1 = '/onboarding/1';
  static const String onboarding2 = '/onboarding/2';
  static const String onboarding3 = '/onboarding/3';
  static const String onboarding4 = '/onboarding/4';
  static const String onboardingComplete = '/onboarding/complete';
  static const String registration = '/registration';
  static const String registrationEmail = '/registration/email';
  static const String registrationVerification = '/registration/verification';
  static const String registrationDetails = '/registration/details';
  static const String registrationPassword = '/registration/password';
  static const String login = '/login';
  static const String mfaChallenge = '/login/mfa-challenge';
  static const String forgotPassword = '/login/forgot-password';
  static const String authPreview = '/auth/preview';
  static const String dashboard = '/dashboard';
  static const String healthRecords = '/dashboard/health-records';
  static const String medicalHistory = '/dashboard/health-records/history';
  static const String immunizationRecords =
      '/dashboard/health-records/immunizations';
  static const String medicalConsultations =
      '/dashboard/health-records/consultations';
  static const String laboratoryResults =
      '/dashboard/health-records/laboratory-results';
  static const String personalRecords = '/dashboard/personal-records';
  static const String bodyMassIndex = '/dashboard/personal-records/bmi';
  static const String bloodPressure =
      '/dashboard/personal-records/blood-pressure';
  static const String temperature = '/dashboard/personal-records/temperature';
  static const String medicineIntake =
      '/dashboard/personal-records/medicine-intake';
  static const String appointments = '/dashboard/appointments';
  static const String onsiteConsultation =
      '/dashboard/appointments/onsite-consultation';
  static const String teleconsultation =
      '/dashboard/appointments/teleconsultation';
  static const String medicationResupply = '/dashboard/medication-resupply';
  static const String medicationResupplyRequest =
      '/dashboard/medication-resupply/request';
  static const String medicationResupplyHistory =
      '/dashboard/medication-resupply/history';
  static const String calendar = '/calendar';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String securitySettings = '/profile/security';
  static const String totpSetup = '/profile/security/totp-setup';
  static const String mpinSetup = '/profile/security/mpin/setup';
  static const String mpinConfirm = '/profile/security/mpin/confirm';
  static const String mpinUnlock = '/lock/mpin';
  static const String personalInformation = '/profile/personal-information';
  static const String aboutUs = '/profile/about-us';
  static const String aboutApp = '/profile/about-app';
  static const String privacyStatement = '/legal/privacy-statement';
}
