import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class SyncRequestSimulationButton extends StatelessWidget {
  const SyncRequestSimulationButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: isEnabled
              ? AppColors.textPrimary
              : AppColors.textPrimary.withValues(alpha: 0.45),
          side: BorderSide(
            color: isEnabled
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textPrimary,
                  ),
                ),
              )
            : const Icon(Icons.science_outlined, size: 18),
        label: Text(
          'Simulate request',
          style: AppTextStyles.buttonLarge.copyWith(
            color: isEnabled
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
