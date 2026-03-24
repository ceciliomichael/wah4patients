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
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.medium,
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
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
