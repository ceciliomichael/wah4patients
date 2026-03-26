import 'package:flutter/material.dart';

import '../../constants/app_border_radii.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../ui/buttons/secondary_button_widget.dart';

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    required this.onBackPressed,
    required this.onHelpPressed,
    this.isTablet = false,
    this.topPadding = 12.0,
  });

  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onHelpPressed;
  final bool isTablet;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 8.0),
      child: Row(
        children: [
          _HeaderBackButton(onPressed: onBackPressed),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: isTablet ? 24.0 : 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SecondaryButtonWidget(
            text: 'Help',
            onPressed: onHelpPressed,
            textColor: AppColors.secondary,
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
        side: BorderSide(color: AppColors.border),
      ),
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
            child: Icon(
              Icons.arrow_back,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
