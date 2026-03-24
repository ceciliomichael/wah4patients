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
  final VoidCallback onPressed;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTextStyles.buttonMedium.copyWith(
              color: textColor,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
