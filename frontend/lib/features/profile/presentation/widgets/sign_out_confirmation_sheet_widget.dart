import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_bottom_sheet_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';

class SignOutConfirmationSheetWidget extends StatelessWidget {
  const SignOutConfirmationSheetWidget({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: AppRadii.large,
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Out',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Do you want to sign out of your account and return to the splash screen?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
                tooltip: 'Cancel',
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButtonWidget(
            text: 'Sign Out',
            backgroundColor: AppColors.danger,
            icon: Icons.logout,
            onPressed: () {
              Navigator.of(context).pop();
              onSignOut();
            },
          ),
        ],
      ),
    );
  }
}
