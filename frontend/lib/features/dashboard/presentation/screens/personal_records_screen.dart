import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/dashboard_models.dart';
import 'feature_hub_screen.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <HubActionData>[
      const HubActionData(
        title: 'Body Mass Index (BMI)',
        description: 'Log and review weight trends over time.',
        icon: Icons.monitor_weight_outlined,
        accentColor: AppColors.primary,
      ),
      const HubActionData(
        title: 'Blood Pressure',
        description: 'Track systolic and diastolic readings.',
        icon: Icons.favorite_outline,
        accentColor: AppColors.secondary,
      ),
      const HubActionData(
        title: 'Temperature',
        description: 'Record temperature measurements and notes.',
        icon: Icons.thermostat_outlined,
        accentColor: AppColors.tertiary,
      ),
      const HubActionData(
        title: 'Medicine Intake',
        description: 'Keep a simple medication intake record.',
        icon: Icons.medication_liquid_outlined,
        accentColor: AppColors.primaryDark,
      ),
    ];

    return FeatureHubScreen(
      title: 'Personal Records',
      subtitle:
          'Fast access to the self-monitoring screens from the original app.',
      icon: Icons.monitor_heart_outlined,
      actions: actions,
      helpTitle: 'Personal Records Help',
      helpMessages: const <String>[
        'Open any card to review or record that part of your personal health data.',
        'Use the tabbed screens for quick entry and a simple record history.',
        'Each flow keeps the same spacing and color language used across the app.',
      ],
      onActionTap: (action) {
        final String? routeName = switch (action.title) {
          'Body Mass Index (BMI)' => AppRoutes.bodyMassIndex,
          'Blood Pressure' => AppRoutes.bloodPressure,
          'Temperature' => AppRoutes.temperature,
          'Medicine Intake' => AppRoutes.medicineIntake,
          _ => null,
        };

        if (routeName == null) {
          return;
        }

        Navigator.of(context).pushNamed(routeName);
      },
    );
  }
}
