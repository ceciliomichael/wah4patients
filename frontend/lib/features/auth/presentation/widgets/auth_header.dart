import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.stepLabel,
    this.centerTitle = false,
    this.onBackPressed,
    this.helpTitle,
    this.helpMessages = const <String>[],
    this.helpIcons = const <IconData>[],
  });

  final String title;
  final String subtitle;
  final String? stepLabel;
  final bool centerTitle;
  final VoidCallback? onBackPressed;
  final String? helpTitle;
  final List<String> helpMessages;
  final List<IconData> helpIcons;

  @override
  Widget build(BuildContext context) {
    final titleAlign = centerTitle ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (onBackPressed != null || stepLabel != null || helpTitle != null)
          Row(
            children: [
              if (onBackPressed != null)
                IconButton(
                  onPressed: onBackPressed,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: AppColors.textPrimary,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  splashRadius: 24,
                  tooltip: 'Back',
                )
              else
                const SizedBox(width: 28),
              if (onBackPressed != null) const SizedBox(width: 16),
              if (stepLabel != null)
                Text(
                  stepLabel!,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const Spacer(),
              if (helpTitle != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) {
                            return HelpModalWidget(
                              title: helpTitle!,
                              messages: helpMessages,
                              icons: helpIcons,
                              onClose: () => Navigator.of(dialogContext).pop(),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.help_outline,
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      splashRadius: 20,
                      tooltip: 'Help',
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Help',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        if (onBackPressed != null || stepLabel != null || helpTitle != null)
          const SizedBox(height: 32),
        Text(
          title,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w700,
          ),
          textAlign: titleAlign,
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          textAlign: titleAlign,
        ),
      ],
    );
  }
}
