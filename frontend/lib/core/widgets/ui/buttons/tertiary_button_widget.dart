import 'package:flutter/material.dart';

import '../../../constants/app_border_radii.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class TertiaryButtonWidget extends StatelessWidget {
  const TertiaryButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.tertiary,
        side: const BorderSide(color: AppColors.tertiary),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      child: Text(
        text,
        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.tertiary),
      ),
    );
  }
}
