class AppLockStateService {
  AppLockStateService._();

  static const Duration autoLockTimeout = Duration(minutes: 5);

  static DateTime? _backgroundedAt;

  static void markBackgrounded({DateTime? at}) {
    _backgroundedAt = at ?? DateTime.now();
  }

  static bool shouldRequireUnlockOnResume({DateTime? now}) {
    final backgroundedAt = _backgroundedAt;
    if (backgroundedAt == null) {
      return false;
    }

    final currentTime = now ?? DateTime.now();
    return currentTime.difference(backgroundedAt) >= autoLockTimeout;
  }

  static void clearBackgroundState() {
    _backgroundedAt = null;
  }
}
