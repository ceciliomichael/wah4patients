import 'dart:async';

import 'package:flutter/material.dart';

enum AppNotificationSeverity { info, success, warning, error }

@immutable
class AppNotificationMessage {
  const AppNotificationMessage({
    required this.id,
    required this.message,
    required this.severity,
    required this.createdAt,
    this.title,
    this.duration = const Duration(seconds: 3),
  });

  final int id;
  final String? title;
  final String message;
  final AppNotificationSeverity severity;
  final Duration duration;
  final DateTime createdAt;
}

class AppNotificationCenter {
  AppNotificationCenter._();

  static final AppNotificationCenter instance = AppNotificationCenter._();

  final ValueNotifier<AppNotificationMessage?> current =
      ValueNotifier<AppNotificationMessage?>(null);

  Timer? _dismissTimer;
  int _nextId = 1;

  void show({
    required String message,
    String? title,
    AppNotificationSeverity severity = AppNotificationSeverity.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      return;
    }

    _dismissTimer?.cancel();

    current.value = AppNotificationMessage(
      id: _nextId++,
      title: _normalizeTitle(title),
      message: normalizedMessage,
      severity: severity,
      duration: duration,
      createdAt: DateTime.now(),
    );

    if (duration <= Duration.zero) {
      return;
    }

    _dismissTimer = Timer(duration, dismiss);
  }

  void showInfo(String message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    show(
      message: message,
      title: title,
      severity: AppNotificationSeverity.info,
      duration: duration,
    );
  }

  void showSuccess(String message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    show(
      message: message,
      title: title,
      severity: AppNotificationSeverity.success,
      duration: duration,
    );
  }

  void showWarning(String message, {String? title, Duration duration = const Duration(seconds: 3)}) {
    show(
      message: message,
      title: title,
      severity: AppNotificationSeverity.warning,
      duration: duration,
    );
  }

  void showError(String message, {String? title, Duration duration = const Duration(seconds: 4)}) {
    show(
      message: message,
      title: title,
      severity: AppNotificationSeverity.error,
      duration: duration,
    );
  }

  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (current.value != null) {
      current.value = null;
    }
  }

  String? _normalizeTitle(String? title) {
    final normalized = title?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
