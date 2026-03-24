import 'package:flutter/material.dart';

import '../../../constants/app_border_radii.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

enum AppButtonSize { small, medium, large }

enum IconPosition { leading, trailing }

class PrimaryButtonWidget extends StatelessWidget {
  const PrimaryButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.iconPosition = IconPosition.trailing,
    this.fullWidth = true,
    this.size = AppButtonSize.medium,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool fullWidth;
  final AppButtonSize size;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final padding = switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      AppButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      AppButtonSize.large => const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
    };

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      child: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null && iconPosition == IconPosition.leading) ...[
                  Icon(icon, size: 18, color: textColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: AppTextStyles.buttonLarge.copyWith(color: textColor),
                ),
                if (icon != null && iconPosition == IconPosition.trailing) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: textColor),
                ],
              ],
            ),
    );

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
