import '../../../../app/app_routes.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';

class PostLoginRouteService {
  PostLoginRouteService._();

  static Future<String> resolveNextRouteAfterLogin({
    required String accessToken,
  }) async {
    try {
      final deviceId = await MpinLocalStore.readOrCreateDeviceId();
      final status = await AuthApiClient.instance.getSecuritySettingsStatus(
        accessToken: accessToken,
        deviceId: deviceId,
      );

      if (status.isMpinConfigured && status.isMpinDeviceRegistered) {
        await MpinLocalStore.setMpinEnabled(true);
        return AppRoutes.mpinUnlock;
      }

      await MpinLocalStore.setMpinEnabled(false);
    } on AuthApiException {
      // Fall back to the dashboard when security status cannot be resolved.
    }

    return AppRoutes.dashboard;
  }
}
