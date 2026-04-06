import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';

class MpinDeviceRegistrationService {
  MpinDeviceRegistrationService._();

  static Future<void> registerCurrentDevice({
    required String accessToken,
    String? securityVerificationToken,
  }) async {
    final deviceId = await MpinLocalStore.readOrCreateDeviceId();

    await AuthApiClient.instance.registerMpinDevice(
      accessToken: accessToken,
      deviceId: deviceId,
      securityVerificationToken: securityVerificationToken,
    );

    await MpinLocalStore.setMpinEnabled(true);
  }
}
