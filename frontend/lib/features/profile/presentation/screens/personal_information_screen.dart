import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoDetailScreen(
      title: 'Personal Information',
      subtitle: 'A future-ready profile details page.',
      body:
          'This placeholder keeps the shape of the old screen while leaving '
          'the data source unconnected for now.',
      icon: Icons.person_outline,
      highlights: const <String>[
        'Update contact and demographic details later',
        'Build the form with a clean data boundary',
        'Keep the UI separate from any backend implementation',
      ],
      primaryButtonText: 'Back to Profile',
      onPrimaryPressed: () {
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
      },
    );
  }
}
