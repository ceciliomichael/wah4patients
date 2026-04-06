import '../features/auth/data/auth_local_store.dart';
import '../features/auth/data/auth_api_client.dart';
import '../features/auth/data/mpin_local_store.dart';
import '../features/auth/domain/auth_session.dart';
import 'app_routes.dart';

class AppStartupResult {
  const AppStartupResult._(this.initialRoute);

  final String initialRoute;

  static const AppStartupResult onboarding = AppStartupResult._('/onboarding/1');
  static const AppStartupResult login = AppStartupResult._('/login');
  static const AppStartupResult dashboard = AppStartupResult._('/dashboard');
  static const AppStartupResult mpinUnlock = AppStartupResult._(
    AppRoutes.mpinUnlock,
  );
}

class AppStartupService {
  AppStartupService._();

  static Future<AppStartupResult> resolveInitialRoute() async {
    final hasValidSession = await AuthSession.refreshIfNeeded();
    if (hasValidSession && AuthSession.isAuthenticated) {
      try {
        final deviceId = await MpinLocalStore.readOrCreateDeviceId();
        final accessToken = AuthSession.accessToken?.trim() ?? '';
        final status = await AuthApiClient.instance.getSecuritySettingsStatus(
          accessToken: accessToken,
          deviceId: deviceId,
        );

        if (status.isMpinConfigured && status.isMpinDeviceRegistered) {
          await MpinLocalStore.setMpinEnabled(true);
          return AppStartupResult.mpinUnlock;
        }

        await MpinLocalStore.setMpinEnabled(false);
      } on AuthApiException {
        // Keep the local device state as the fallback if security status cannot be resolved.
      }

      final isMpinEnabled = await MpinLocalStore.isMpinEnabled();
      return isMpinEnabled
          ? AppStartupResult.mpinUnlock
          : AppStartupResult.dashboard;
    }

    final onboardingCompleted = await AuthLocalStore.isOnboardingCompleted();
    if (!onboardingCompleted) {
      return AppStartupResult.onboarding;
    }

    return AppStartupResult.login;
  }
}
