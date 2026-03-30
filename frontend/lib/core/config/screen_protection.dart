import 'package:flutter/foundation.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

class ScreenProtection {
  const ScreenProtection._();

  static Future<void> enableSecureMode() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (_) {
      // Intentionally ignored to avoid blocking unlock flow on unsupported devices.
    }
  }

  static Future<void> disableSecureMode() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } catch (_) {
      // Intentionally ignored to keep navigation stable.
    }
  }
}
