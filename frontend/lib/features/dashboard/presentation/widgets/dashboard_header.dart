import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.displayName,
    required this.onHelpPressed,
  });

  final String displayName;
  final VoidCallback onHelpPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/logo/wah_transparent.png',
                height: 72,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(text: 'Have a '),
                    TextSpan(
                      text: 'WAH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    const TextSpan(text: 'nderful day'),
                    if (displayName.trim().isNotEmpty) ...[
                      const TextSpan(text: ', '),
                      TextSpan(
                        text: displayName.trim(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Open Sans',
                        ),
                      ),
                    ],
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _HeaderHelpButton(onPressed: onHelpPressed),
      ],
    );
  }
}

class _HeaderHelpButton extends StatelessWidget {
  const _HeaderHelpButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.1),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const RoundedRectangleBorder(
          borderRadius: AppRadii.medium,
        ),
        splashColor: AppColors.black.withValues(alpha: 0.12),
        highlightColor: AppColors.black.withValues(alpha: 0.08),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Icon(Icons.help_outline, size: 22, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
