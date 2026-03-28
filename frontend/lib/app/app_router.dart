import 'package:flutter/material.dart';

import '../features/appointments/presentation/screens/onsite_consultation_screen.dart';
import '../features/appointments/presentation/screens/teleconsultation_screen.dart';
import '../features/auth/domain/models/auth_api_models.dart';
import '../features/auth/presentation/screens/auth_preview_screen.dart';
import '../features/auth/presentation/screens/email_registration_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/password_registration_screen.dart';
import '../features/auth/presentation/screens/registration_screen.dart';
import '../features/calendar/presentation/screens/calendar_route_screen.dart';
import '../features/dashboard/presentation/screens/appointments_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/dashboard/presentation/screens/health_records_screen.dart';
import '../features/dashboard/presentation/screens/medication_resupply_screen.dart';
import '../features/dashboard/presentation/screens/personal_records_screen.dart';
import '../features/health_records/presentation/screens/immunization_records_screen.dart';
import '../features/health_records/presentation/screens/laboratory_results_screen.dart';
import '../features/health_records/presentation/screens/medical_consultations_screen.dart';
import '../features/health_records/presentation/screens/medical_history_screen.dart';
import '../features/legal/presentation/privacy_statement_screen.dart';
import '../features/medication_resupply/presentation/screens/medication_resupply_history_screen.dart';
import '../features/medication_resupply/presentation/screens/medication_resupply_request_screen.dart';
import '../features/notification/presentation/screens/notification_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_1.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_2.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_3.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_4.dart';
import '../features/phr/body_mass_index/presentation/screen/body_mass_index_screen.dart';
import '../features/phr/blood_pressure/presentation/screen/blood_pressure_screen.dart';
import '../features/phr/medicine_intake/presentation/screen/medicine_intake_screen.dart';
import '../features/phr/temperature/presentation/screen/temperature_screen.dart';
import '../features/profile/presentation/screens/about_app_screen.dart';
import '../features/profile/presentation/screens/about_us_screen.dart';
import '../features/profile/presentation/screens/personal_information_screen.dart';
import '../features/profile/presentation/screens/profile_route_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

Route<dynamic>? buildAppRoute(RouteSettings settings) {
  final String? routeName = settings.name;

  switch (routeName) {
    case AppRoutes.splash:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const SplashScreen(),
      );
    case AppRoutes.onboarding1:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const OnboardingScreen1(),
      );
    case AppRoutes.onboarding2:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const OnboardingScreen2(),
      );
    case AppRoutes.onboarding3:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const OnboardingScreen3(),
      );
    case AppRoutes.onboarding4:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const OnboardingScreen4(),
      );
    case AppRoutes.onboardingComplete:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const OnboardingCompleteScreen(),
      );
    case AppRoutes.registration:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const RegistrationScreen(),
      );
    case AppRoutes.registrationEmail:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const EmailRegistrationScreen(),
      );
    case AppRoutes.registrationVerification:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) {
          final email = settings.arguments as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      );
    case AppRoutes.registrationPassword:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) {
          final args = settings.arguments;
          if (args is RegistrationPasswordArguments) {
            return PasswordRegistrationScreen(
              email: args.email,
              registrationToken: args.registrationToken,
            );
          }

          final email = args is String ? args : '';
          return PasswordRegistrationScreen(email: email, registrationToken: '');
        },
      );
    case AppRoutes.login:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) {
          final initialEmail = settings.arguments is String
              ? settings.arguments as String
              : '';
          return LoginScreen(initialEmail: initialEmail);
        },
      );
    case AppRoutes.forgotPassword:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) {
          final initialEmail = settings.arguments is String
              ? settings.arguments as String
              : '';
          return ForgotPasswordScreen(initialEmail: initialEmail);
        },
      );
    case AppRoutes.authPreview:
      return _buildFadeScaleRoute(
        settings: settings,
        builder: (_) => const AuthPreviewScreen(),
      );
    case AppRoutes.dashboard:
      return _buildInstantRoute(
        settings: settings,
        builder: (_) => const DashboardScreen(),
      );
    case AppRoutes.healthRecords:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const HealthRecordsScreen(),
      );
    case AppRoutes.medicalHistory:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicalHistoryScreen(),
      );
    case AppRoutes.immunizationRecords:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const ImmunizationRecordsScreen(),
      );
    case AppRoutes.medicalConsultations:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicalConsultationsScreen(),
      );
    case AppRoutes.laboratoryResults:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const LaboratoryResultsScreen(),
      );
    case AppRoutes.personalRecords:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const PersonalRecordsScreen(),
      );
    case AppRoutes.bodyMassIndex:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const BodyMassIndexScreen(),
      );
    case AppRoutes.bloodPressure:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const BloodPressureScreen(),
      );
    case AppRoutes.temperature:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const TemperatureScreen(),
      );
    case AppRoutes.medicineIntake:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicineIntakeScreen(),
      );
    case AppRoutes.appointments:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const AppointmentsScreen(),
      );
    case AppRoutes.onsiteConsultation:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const OnsiteConsultationScreen(),
      );
    case AppRoutes.teleconsultation:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const TeleconsultationScreen(),
      );
    case AppRoutes.medicationResupply:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicationResupplyScreen(),
      );
    case AppRoutes.medicationResupplyRequest:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicationResupplyRequestScreen(),
      );
    case AppRoutes.medicationResupplyHistory:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const MedicationResupplyHistoryScreen(),
      );
    case AppRoutes.calendar:
      return _buildInstantRoute(
        settings: settings,
        builder: (_) => const CalendarRouteScreen(),
      );
    case AppRoutes.notification:
      return _buildInstantRoute(
        settings: settings,
        builder: (_) => const NotificationScreen(),
      );
    case AppRoutes.profile:
      return _buildInstantRoute(
        settings: settings,
        builder: (_) => const ProfileRouteScreen(),
      );
    case AppRoutes.personalInformation:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const PersonalInformationScreen(),
      );
    case AppRoutes.aboutUs:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const AboutUsScreen(),
      );
    case AppRoutes.aboutApp:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const AboutAppScreen(),
      );
    case AppRoutes.privacyStatement:
      return _buildSlideRoute(
        settings: settings,
        builder: (_) => const PrivacyStatementScreen(),
      );
    default:
      return null;
  }
}

PageRouteBuilder<T> _buildInstantRoute<T>({
  required RouteSettings settings,
  required WidgetBuilder builder,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  );
}

PageRouteBuilder<T> _buildFadeScaleRoute<T>({
  required RouteSettings settings,
  required WidgetBuilder builder,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

PageRouteBuilder<T> _buildSlideRoute<T>({
  required RouteSettings settings,
  required WidgetBuilder builder,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final CurvedAnimation curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final Animation<Offset> offset = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(curve);

      return FadeTransition(
        opacity: curve,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
