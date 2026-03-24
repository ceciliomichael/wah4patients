import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../appointments/presentation/screens/onsite_consultation_screen.dart';
import '../../../appointments/presentation/screens/teleconsultation_screen.dart';
import '../../domain/dashboard_models.dart';
import 'feature_hub_screen.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <HubActionData>[
      const HubActionData(
        title: 'Onsite Consultation',
        description: 'Book an in-person appointment.',
        icon: Icons.local_hospital_outlined,
        accentColor: AppColors.primary,
      ),
      const HubActionData(
        title: 'Teleconsultation',
        description: 'Schedule a remote consultation session.',
        icon: Icons.video_call_outlined,
        accentColor: AppColors.secondary,
      ),
    ];

    return FeatureHubScreen(
      title: 'Appointments',
      subtitle: 'A lightweight booking hub with the original visual rhythm.',
      icon: Icons.calendar_month_outlined,
      actions: actions,
      helpTitle: 'Appointments Help',
      helpMessages: const <String>[
        'Open either booking path to follow the same three-step appointment flow.',
        'The screens keep everything local and do not create backend records yet.',
        'Onsite and teleconsultation each keep their own details step.',
      ],
      onActionTap: (action) {
        final Widget screen = switch (action.title) {
          'Onsite Consultation' => const OnsiteConsultationScreen(),
          'Teleconsultation' => const TeleconsultationScreen(),
          _ => const SizedBox.shrink(),
        };

        if (screen is SizedBox) {
          return;
        }

        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => screen));
      },
    );
  }
}
