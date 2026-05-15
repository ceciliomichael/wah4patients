import 'package:flutter/material.dart';

import '../../../app/app_notification_center.dart';
import '../../constants/app_border_radii.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class AppNotificationHost extends StatelessWidget {
  const AppNotificationHost({
    super.key,
    required this.controller,
    this.maxWidth = 560,
  });

  final AppNotificationCenter controller;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppNotificationMessage?>(
      valueListenable: controller.current,
      builder: (context, notification, _) {
        return IgnorePointer(
          ignoring: notification == null,
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0, -0.18),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: notification == null
                        ? const SizedBox.shrink(key: ValueKey<String>('hidden'))
                        : _AppNotificationCard(
                            key: ValueKey<int>(notification.id),
                            notification: notification,
                            onDismiss: controller.dismiss,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppNotificationCard extends StatelessWidget {
  const _AppNotificationCard({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  final AppNotificationMessage notification;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = _AppNotificationPalette.fromSeverity(notification.severity);
    final hasTitle = notification.title != null;

    return Dismissible(
      key: ValueKey<int>(notification.id),
      direction: DismissDirection.up,
      dismissThresholds: const {DismissDirection.up: 0.28},
      movementDuration: const Duration(milliseconds: 180),
      resizeDuration: null,
      onDismissed: (_) => onDismiss(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDismiss,
          borderRadius: AppRadii.extraLarge,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.extraLarge,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: AppRadii.medium,
                  ),
                  child: Icon(
                    palette.icon,
                    size: 20,
                    color: palette.foreground,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasTitle) ...[
                        Text(
                          notification.title!,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppNotificationPalette {
  const _AppNotificationPalette({
    required this.background,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final IconData icon;

  factory _AppNotificationPalette.fromSeverity(AppNotificationSeverity severity) {
    return switch (severity) {
      AppNotificationSeverity.info => const _AppNotificationPalette(
        background: Color(0xFFF3F4F6),
        foreground: Color(0xFF4B5563),
        icon: Icons.info_outline_rounded,
      ),
      AppNotificationSeverity.success => const _AppNotificationPalette(
        background: Color(0xFFEAF7EE),
        foreground: Color(0xFF15803D),
        icon: Icons.check_circle_outline_rounded,
      ),
      AppNotificationSeverity.warning => const _AppNotificationPalette(
        background: Color(0xFFFFF4E5),
        foreground: Color(0xFFB45309),
        icon: Icons.report_outlined,
      ),
      AppNotificationSeverity.error => const _AppNotificationPalette(
        background: Color(0xFFFDECEC),
        foreground: Color(0xFFB91C1C),
        icon: Icons.error_outline_rounded,
      ),
    };
  }
}
