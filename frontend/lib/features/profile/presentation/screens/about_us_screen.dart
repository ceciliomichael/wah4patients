import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoDetailScreen(
      title: 'About Us',
      subtitle: 'Who built WAH for Patients.',
      body:
          'This page keeps the original app information flow available with '
          'frontend-only content and no backend dependencies.',
      icon: Icons.groups_outlined,
      highlights: const <String>[
        'Mission-first patient experience',
        'Clear ownership of the app shell',
        'Ready for future content expansion',
      ],
      primaryButtonText: 'Back to Profile',
      onPrimaryPressed: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
      },
    );
  }
}
