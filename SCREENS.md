# WAH4P Screen Inventory

Source of truth: `C:\Users\Administrator\Desktop\ibugs\wah_for_patients_wah4p\frontend`

This document lists the screens present in the original frontend and the route flow defined in `lib/router/app_router.dart`.

## Launch Flow

The app starts at:

1. `/splash` -> `SplashScreen`
2. `/onboarding/1` -> `OnboardingScreen1`
3. `/onboarding/2` -> `OnboardingScreen2`
4. `/onboarding/3` -> `OnboardingScreen3`
5. `/onboarding/4` -> `MedicationOnboardingScreen`

`SplashScreen` redirects to `/dashboard` when the user is authenticated and has remember-me state; otherwise it sends the user to `/onboarding/1`.

## Route-Backed Screens

### Splash and Onboarding

| Route | Screen class | File |
| --- | --- | --- |
| `/splash` | `SplashScreen` | `lib/features/splash/presentation/splash_screen.dart` |
| `/onboarding/1` | `OnboardingScreen1` | `lib/features/onboarding/presentation/screen/onboarding_screen_1.dart` |
| `/onboarding/2` | `OnboardingScreen2` | `lib/features/onboarding/presentation/screen/onboarding_screen_2.dart` |
| `/onboarding/3` | `OnboardingScreen3` | `lib/features/onboarding/presentation/screen/onboarding_screen_3.dart` |
| `/onboarding/4` | `MedicationOnboardingScreen` | `lib/features/onboarding/presentation/screen/onboarding_screen_4.dart` |

### Authentication

| Route | Screen class | File |
| --- | --- | --- |
| `/registration` | `RegistrationScreen` | `lib/features/auth/registration/presentation/registration_screen.dart` |
| `/registration/email` | `EmailRegistrationScreen` | `lib/features/auth/registration/presentation/email_registration_screen.dart` |
| `/registration/email-verification` | `VerifyEmailRegistrationScreen` | `lib/features/auth/registration/presentation/email_verification_screen.dart` |
| `/registration/password` | `PasswordRegistrationScreen` | `lib/features/auth/registration/presentation/password_registration_screen.dart` |
| `/login` | `LoginScreen` | `lib/features/auth/login/presentation/screen/login_screen.dart` |
| `/sync-code` | `SyncCodeScreen` | `lib/features/auth/sync_code/presentation/screen/sync_code_screen.dart` |
| `/forgot-password` | `ForgotPasswordScreen` | `lib/features/auth/password_reset/presentation/screen/forgot_password_screen.dart` |
| `/reset-password` | `ResetPasswordScreen` | `lib/features/auth/password_reset/presentation/screen/reset_password_screen.dart` |
| `/new-password` | `NewPasswordScreen` | `lib/features/auth/password_reset/presentation/screen/new_password_screen.dart` |

### Patient Record Linking

| Route | Screen class | File |
| --- | --- | --- |
| `/link-record-intro` | `LinkRecordIntroScreen` | `lib/features/patient_record_linking/presentation/screens/link_record_intro_screen.dart` |
| `/patient-identifier` | `PatientIdentifierScreen` | `lib/features/patient_record_linking/presentation/screens/patient_identifier_screen.dart` |
| `/facility-selection` | `FacilitySelectionScreen` | `lib/features/patient_record_linking/presentation/screens/facility_selection_screen.dart` |

### Dashboard

| Route | Screen class | File |
| --- | --- | --- |
| `/dashboard` | `DashboardScreen` | `lib/features/dashboard/presentation/screen/dashboard_screen.dart` |

### Profile

| Route | Screen class | File |
| --- | --- | --- |
| `/profile` | `ProfileScreen` | `lib/features/profile/presentation/profile_screen.dart` |
| `/profile/personal-information` | `PersonalInformationScreen` | `lib/features/profile/presentation/personal_information_screen.dart` |
| `/profile/about-us` | `AboutUsScreen` | `lib/features/profile/presentation/about_us_screen.dart` |
| `/profile/about-app` | `AboutAppScreen` | `lib/features/profile/presentation/about_app_screen.dart` |

### PHR

| Route | Screen class | File |
| --- | --- | --- |
| `/phr/temperature` | `TemperatureScreen` | `lib/features/phr/temperature/presentation/screen/temperature_screen.dart` |
| `/phr/blood-pressure` | `BloodPressureScreen` | `lib/features/phr/blood_pressure/presentation/screen/blood_pressure_screen.dart` |
| `/phr/body-mass-index` | `BodyMassIndexScreen` | `lib/features/phr/body_mass_index/presentation/screen/body_mass_index_screen.dart` |
| `/phr/medicine-intake` | `MedicineIntakeScreen` | `lib/features/phr/medicine_intake/presentation/screen/medicine_intake_screen.dart` |

### EHR

| Route | Screen class | File |
| --- | --- | --- |
| `/ehr/medical-history` | `MedicalHistoryScreen` | `lib/features/ehr/medical_history/presentation/medical_history_screen.dart` |
| `/ehr/medical-consultations` | `MedicalConsultationsScreen` | `lib/features/ehr/medical_consultations/presentation/medical_consultations_screen.dart` |
| `/ehr/laboratory-test-results` | `LaboratoryTestResultsScreen` | `lib/features/ehr/laboratory_test_results/presentation/laboratory_test_results_screen.dart` |
| `/ehr/immunization-records` | `ImmunizationRecordsScreen` | `lib/features/ehr/immunization_records/presentation/immunization_records_screen.dart` |

### Medication Resupply

| Route | Screen class | File |
| --- | --- | --- |
| `/medication-resupply` | `MedicationResupplyScreen` | `lib/features/medication_resupply/presentation/screens/medication_resupply_screen.dart` |
| `/medication-resupply/active-prescriptions` | `ActivePrescriptionsScreen` | `lib/features/medication_resupply/presentation/screens/active_prescriptions_screen.dart` |
| `/medication-resupply/cart` | `CartScreen` | `lib/features/medication_resupply/presentation/screens/cart_screen.dart` |
| `/medication-resupply/request-form` | `ResupplyRequestFormScreen` | `lib/features/medication_resupply/presentation/screens/resupply_request_form_screen.dart` |
| `/medication-resupply/history` | `ResupplyHistoryScreen` | `lib/features/medication_resupply/presentation/screens/resupply_history_screen.dart` |
| `/medication-resupply/prescription-viewer` | `PrescriptionViewerScreen` | `lib/features/medication_resupply/presentation/screens/prescription_viewer_screen.dart` |

### Appointments

| Route | Screen class | File |
| --- | --- | --- |
| `/appointment/onsite` | `OnsiteConsultationScreen` | `lib/features/appointment/presentation/screen/onsite_consultation_screen.dart` |
| `/appointment/teleconsultation` | `TeleconsultationScreen` | `lib/features/appointment/presentation/screen/teleconsultation_screen.dart` |

## Screen Files Present But Not Routed

These files exist in the original frontend but are not currently registered in `app_router.dart`:

| Screen class | File | Notes |
| --- | --- | --- |
| `CalendarScreen` | `lib/features/calendar/presentation/screens/calendar_screen.dart` | Screen file exists, but there is no router entry yet. |
| `PrivacyStatementScreen` | `lib/features/legal/presentation/privacy_statement_screen.dart` | Screen file exists, but there is no router entry yet. |
| `NotificationTestScreen` | `lib/features/dashboard/presentation/screen/notification_test_screen.dart` | Test/demo screen file exists, but there is no router entry yet. |

## Notes For The Copy Task

The first implementation slice should only cover the splash flow up to the first visible onboarding screen. The rest of the app can be copied in later slices, using this inventory as the reference list.
