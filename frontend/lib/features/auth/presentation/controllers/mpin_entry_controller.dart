import 'package:flutter/foundation.dart';

class MpinEntryController extends ChangeNotifier {
  MpinEntryController({
    this.requiredLength = 4,
    this.maxRetries = 5,
    this.localLockDuration = const Duration(minutes: 1),
  });

  final int requiredLength;
  final int maxRetries;
  final Duration localLockDuration;

  String _value = '';
  bool _isSubmitting = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  String get value => _value;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockedUntil => _lockedUntil;
  bool get isLocked {
    final lockTime = _lockedUntil;
    if (lockTime == null) {
      return false;
    }
    return DateTime.now().isBefore(lockTime);
  }

  Duration get remainingLockDuration {
    final lockTime = _lockedUntil;
    if (lockTime == null) {
      return Duration.zero;
    }

    final remaining = lockTime.difference(DateTime.now());
    if (remaining.isNegative) {
      return Duration.zero;
    }
    return remaining;
  }

  bool get isComplete => _value.length == requiredLength;

  void setValue(String value) {
    if (isLocked || _isSubmitting) {
      return;
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = digitsOnly.length > requiredLength
        ? digitsOnly.substring(0, requiredLength)
        : digitsOnly;

    if (_value == normalized) {
      return;
    }

    _value = normalized;
    _errorMessage = null;
    notifyListeners();
  }

  void appendDigit(String digit) {
    if (isLocked || _isSubmitting || _value.length >= requiredLength) {
      return;
    }

    if (!RegExp(r'^[0-9]$').hasMatch(digit)) {
      return;
    }

    setValue('$_value$digit');
  }

  void removeLastDigit() {
    if (isLocked || _isSubmitting || _value.isEmpty) {
      return;
    }

    setValue(_value.substring(0, _value.length - 1));
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clear() {
    _value = '';
    _errorMessage = null;
    notifyListeners();
  }

  void registerFailure({
    int? remainingAttempts,
    DateTime? backendLockedUntil,
    String? message,
  }) {
    _failedAttempts += 1;

    if (remainingAttempts != null && remainingAttempts >= 0) {
      final computedFailedAttempts = maxRetries - remainingAttempts;
      if (computedFailedAttempts > _failedAttempts) {
        _failedAttempts = computedFailedAttempts;
      }
    }

    if (backendLockedUntil != null &&
        DateTime.now().isBefore(backendLockedUntil)) {
      _lockedUntil = backendLockedUntil;
    } else if (_failedAttempts >= maxRetries) {
      _lockedUntil = DateTime.now().add(localLockDuration);
    }

    _value = '';
    _errorMessage =
        message ??
        (_lockedUntil != null
            ? 'Too many attempts. Try again later.'
            : 'Incorrect MPIN. Try again.');
    notifyListeners();
  }

  void registerSuccess() {
    _failedAttempts = 0;
    _lockedUntil = null;
    _errorMessage = null;
    _value = '';
    notifyListeners();
  }

  void syncLockState() {
    if (_lockedUntil == null) {
      return;
    }

    if (remainingLockDuration == Duration.zero) {
      _lockedUntil = null;
      _failedAttempts = 0;
      notifyListeners();
    }
  }

  Future<void> submit(Future<void> Function(String pin) action) async {
    if (_isSubmitting || isLocked || !isComplete) {
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action(_value);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
