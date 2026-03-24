import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoDetailScreen(
      title: 'About the App',
      subtitle: 'Frontend preview build information.',
      body:
          'This version focuses on visual parity and clean structure. '
          'The backend layer can be connected later without rewriting the UI.',
      icon: Icons.info_outline,
      highlights: const <String>[
        'UI recreated from the original visual positioning',
        'No Supabase or API calls in this build',
        'Modular widgets ready for future scaling',
      ],
      primaryButtonText: 'Back to Profile',
      onPrimaryPressed: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
      },
    );
  }
}
