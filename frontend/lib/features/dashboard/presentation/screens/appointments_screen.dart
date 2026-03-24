import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';
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
        'These choices are visual placeholders for now.',
        'The structure is ready for scheduling logic later.',
        'Both booking paths keep the original navigation feel.',
      ],
      onActionTap: (action) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InfoDetailScreen(
              title: action.title,
              subtitle: action.description,
              body:
                  'This route intentionally stops at the UI layer while the '
                  'booking logic remains out of scope for now.',
              icon: action.icon,
              highlights: const <String>[
                'Two clear booking paths',
                'Future form and calendar hooks can plug in later',
                'No backend calls required',
              ],
              primaryButtonText: 'Back to Appointments',
              onPrimaryPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}
