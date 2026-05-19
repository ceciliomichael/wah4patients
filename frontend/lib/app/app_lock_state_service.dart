import 'dart:async';

import 'package:flutter/foundation.dart';

class AppLockStateService {
  AppLockStateService._();

  static const Duration autoLockTimeout = Duration(minutes: 5);

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static Timer? _idleTimer;
  static DateTime? _backgroundedAt;
  static DateTime? _lastActivityAt;
  static bool _isLocked = false;

  static bool get isLocked => _isLocked;

  static bool get isBackgrounded => _backgroundedAt != null;

  static DateTime? get lastActivityAt => _lastActivityAt;

  static void registerActivity({DateTime? at}) {
    final timestamp = (at ?? DateTime.now()).toUtc();
    _lastActivityAt = timestamp;

    if (_isLocked || isBackgrounded) {
      return;
    }

    _scheduleIdleLock(timestamp);
  }

  static void markBackgrounded({DateTime? at}) {
    _backgroundedAt = (at ?? DateTime.now()).toUtc();
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  static void markForegrounded({DateTime? at}) {
    final now = (at ?? DateTime.now()).toUtc();
    _backgroundedAt = null;

    if (_isLocked) {
      return;
    }

    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt == null) {
      _scheduleIdleLock(now);
      return;
    }

    final idleDuration = now.difference(lastActivityAt);
    if (idleDuration >= autoLockTimeout) {
      lock();
      return;
    }

    _scheduleIdleLock(now);
  }

  static bool shouldRequireUnlockOnResume({DateTime? now}) {
    if (_isLocked) {
      return true;
    }

    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt == null) {
      return false;
    }

    final currentTime = (now ?? DateTime.now()).toUtc();
    return currentTime.difference(lastActivityAt) >= autoLockTimeout;
  }

  static void lock() {
    if (_isLocked) {
      return;
    }

    _isLocked = true;
    _idleTimer?.cancel();
    _idleTimer = null;
    _notifyChanged();
  }

  static void unlock({DateTime? at}) {
    _isLocked = false;
    registerActivity(at: at);
    _notifyChanged();
  }

  static void reset() {
    _idleTimer?.cancel();
    _idleTimer = null;
    _backgroundedAt = null;
    _lastActivityAt = null;
    if (_isLocked) {
      _isLocked = false;
    }
    _notifyChanged();
  }

  static void clearBackgroundState() {
    _backgroundedAt = null;
  }

  static void _scheduleIdleLock(DateTime now) {
    _idleTimer?.cancel();

    final lastActivityAt = _lastActivityAt;
    if (lastActivityAt == null) {
      return;
    }

    final remaining = autoLockTimeout - now.difference(lastActivityAt);
    if (remaining <= Duration.zero) {
      lock();
      return;
    }

    _idleTimer = Timer(remaining, lock);
  }

  static void _notifyChanged() {
    notifier.value++;
  }
}
