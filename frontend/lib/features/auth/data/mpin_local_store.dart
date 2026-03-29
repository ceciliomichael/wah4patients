import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MpinLocalStore {
  MpinLocalStore._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _deviceIdKey = 'auth.mpin.device_id';
  static const String _enabledKey = 'auth.mpin.enabled';

  static Future<String> readOrCreateDeviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.trim().length >= 16) {
      return existing.trim();
    }

    final generated = _generateDeviceId();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  static Future<bool> isMpinEnabled() async {
    final rawValue = await _storage.read(key: _enabledKey);
    return rawValue == 'true';
  }

  static Future<void> setMpinEnabled(bool enabled) {
    return _storage.write(key: _enabledKey, value: enabled ? 'true' : 'false');
  }

  static Future<void> clearMpin() async {
    await _storage.delete(key: _enabledKey);
  }

  static String _generateDeviceId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final entropy = List<int>.generate(
      24,
      (_) => random.nextInt(256),
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '$timestamp$entropy';
  }
}
