import 'package:flutter/material.dart';

import '../../../../core/widgets/feature/app_screen_header.dart';

class ResupplyScreenHeader extends StatelessWidget {
  const ResupplyScreenHeader({
    super.key,
    required this.title,
    required this.onBackPressed,
    required this.onHelpPressed,
  });

  final String title;
  final VoidCallback onBackPressed;
  final VoidCallback onHelpPressed;

  @override
  Widget build(BuildContext context) {
    return AppScreenHeader(
      title: title,
      isTablet: MediaQuery.of(context).size.width > 600,
      onBackPressed: onBackPressed,
      onHelpPressed: onHelpPressed,
    );
  }
}
