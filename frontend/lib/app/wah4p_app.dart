import 'package:flutter/material.dart';

import '../core/constants/app_border_radii.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../features/auth/presentation/screens/auth_preview_screen.dart';
import '../features/auth/presentation/screens/email_registration_screen.dart';
import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/password_registration_screen.dart';
import '../features/auth/presentation/screens/registration_screen.dart';
import '../features/dashboard/presentation/screens/appointments_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/dashboard/presentation/screens/health_records_screen.dart';
import '../features/dashboard/presentation/screens/medication_resupply_screen.dart';
import '../features/dashboard/presentation/screens/personal_records_screen.dart';
import '../features/calendar/presentation/screens/calendar_route_screen.dart';
import '../features/notification/presentation/screens/notification_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_1.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_2.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_3.dart';
import '../features/onboarding/presentation/screens/onboarding_screen_4.dart';
import '../features/profile/presentation/screens/about_app_screen.dart';
import '../features/profile/presentation/screens/about_us_screen.dart';
import '../features/profile/presentation/screens/profile_route_screen.dart';
import '../features/profile/presentation/screens/personal_information_screen.dart';
import '../features/legal/presentation/privacy_statement_screen.dart';
import '../features/splash/presentation/splash_screen.dart';
import 'app_routes.dart';

PageRouteBuilder<void> _instantRoute({
  required WidgetBuilder builder,
  required RouteSettings settings,
}) {
  return PageRouteBuilder<void>(
    settings: settings,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
  );
}

class WAH4PApp extends StatelessWidget {
  const WAH4PApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Open Sans',
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.extraLarge),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.topRounded),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.tertiary,
            surface: AppColors.surface,
            onPrimary: AppColors.textOnPrimary,
            onSecondary: AppColors.textOnSecondary,
            onSurface: AppColors.textPrimary,
          ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );

    return MaterialApp(
      title: 'WAH for Patients',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding1: (_) => const OnboardingScreen1(),
        AppRoutes.onboarding2: (_) => const OnboardingScreen2(),
        AppRoutes.onboarding3: (_) => const OnboardingScreen3(),
        AppRoutes.onboarding4: (_) => const OnboardingScreen4(),
        AppRoutes.onboardingComplete: (_) => const OnboardingCompleteScreen(),
        AppRoutes.registration: (_) => const RegistrationScreen(),
        AppRoutes.registrationEmail: (_) => const EmailRegistrationScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.authPreview: (_) => const AuthPreviewScreen(),
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.healthRecords: (_) => const HealthRecordsScreen(),
        AppRoutes.personalRecords: (_) => const PersonalRecordsScreen(),
        AppRoutes.appointments: (_) => const AppointmentsScreen(),
        AppRoutes.medicationResupply: (_) => const MedicationResupplyScreen(),
        AppRoutes.personalInformation: (_) => const PersonalInformationScreen(),
        AppRoutes.aboutUs: (_) => const AboutUsScreen(),
        AppRoutes.aboutApp: (_) => const AboutAppScreen(),
        AppRoutes.privacyStatement: (_) => const PrivacyStatementScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.calendar) {
          return _instantRoute(
            builder: (_) => const CalendarRouteScreen(),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.notification) {
          return _instantRoute(
            builder: (_) => const NotificationScreen(),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.profile) {
          return _instantRoute(
            builder: (_) => const ProfileRouteScreen(),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.registrationVerification) {
          final email = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => EmailVerificationScreen(email: email),
            settings: settings,
          );
        }

        if (settings.name == AppRoutes.registrationPassword) {
          final email = settings.arguments as String? ?? '';
          return MaterialPageRoute<void>(
            builder: (_) => PasswordRegistrationScreen(email: email),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}
