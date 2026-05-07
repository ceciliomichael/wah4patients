import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';

class ProfileCompletionPromptDialog extends StatelessWidget {
  const ProfileCompletionPromptDialog({
    super.key,
    required this.onCompleteProfile,
    required this.onSkipForNow,
    required this.onClose,
  });

  final VoidCallback onCompleteProfile;
  final VoidCallback onSkipForNow;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.extraLarge),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadii.medium,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Complete profile',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Add your patient details now so your profile is ready for future WAH facility sync.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can always finish it later from Personal Information.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButtonWidget(
              text: 'Complete profile',
              onPressed: onCompleteProfile,
              icon: Icons.arrow_forward_outlined,
            ),
            const SizedBox(height: 12),
            SecondaryButtonWidget(
              text: 'Skip for now',
              onPressed: onSkipForNow,
              textColor: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
