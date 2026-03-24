import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.userName,
    required this.onHelpPressed,
  });

  final String userName;
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
                    const TextSpan(text: 'nderful day, '),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Open Sans',
                      ),
                    ),
                    const TextSpan(text: '!'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadii.medium,
          ),
          child: IconButton(
            onPressed: onHelpPressed,
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
