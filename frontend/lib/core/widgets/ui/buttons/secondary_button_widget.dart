import 'package:flutter/material.dart';

import '../../../constants/app_border_radii.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class SecondaryButtonWidget extends StatelessWidget {
  const SecondaryButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = AppColors.primary,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isEnabled
            ? textColor
            : textColor.withValues(alpha: 0.45),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isEnabled ? textColor : textColor.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTextStyles.buttonMedium.copyWith(
              color: isEnabled ? textColor : textColor.withValues(alpha: 0.45),
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
