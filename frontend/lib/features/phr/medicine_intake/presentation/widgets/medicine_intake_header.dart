import 'package:flutter/material.dart';

import '../../../../../core/widgets/feature/app_screen_header.dart';

class MedicineIntakeHeader extends StatelessWidget {
  const MedicineIntakeHeader({
    super.key,
    required this.title,
    required this.isTablet,
    required this.onBackPressed,
    required this.onHelpPressed,
  });

  final String title;
  final bool isTablet;
  final VoidCallback onBackPressed;
  final VoidCallback onHelpPressed;

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      title: title,
      isTablet: isTablet,
      topPadding: 24.0,
      onBackPressed: onBackPressed,
      onHelpPressed: onHelpPressed,
    );
  }
}
