import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';

class OnboardingNavigation extends StatelessWidget {
  const OnboardingNavigation({
    super.key,
    required this.actionButtonText,
    required this.buttonTextColor,
    required this.onSkipPressed,
    required this.onActionPressed,
    required this.fadeAnimation,
  });

  final String actionButtonText;
  final Color buttonTextColor;
  final VoidCallback onSkipPressed;
  final VoidCallback onActionPressed;
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SecondaryButtonWidget(
                text: 'Skip',
                onPressed: onSkipPressed,
                textColor: AppColors.white,
              ),
              PrimaryButtonWidget(
                text: actionButtonText,
                onPressed: onActionPressed,
                icon: Icons.arrow_forward,
                iconPosition: IconPosition.trailing,
                fullWidth: false,
                size: AppButtonSize.medium,
                backgroundColor: AppColors.white,
                textColor: buttonTextColor,
              ),
            ],
          ),
        );
      },
    );
  }
}
