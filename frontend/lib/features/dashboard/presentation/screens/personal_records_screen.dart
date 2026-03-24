import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';
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
      subtitle: 'Fast access to the self-monitoring screens from the original app.',
      icon: Icons.monitor_heart_outlined,
      actions: actions,
      helpTitle: 'Personal Records Help',
      helpMessages: const <String>[
        'Use these cards for the vital-signs and intake workflows.',
        'The screens remain frontend-only and lightweight.',
        'The card layout mirrors the old visual spacing.',
      ],
      onActionTap: (action) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InfoDetailScreen(
              title: action.title,
              subtitle: action.description,
              body:
                  'This placeholder keeps the screen structure visible and '
                  'scalable without binding the experience to any backend.',
              icon: action.icon,
              highlights: const <String>[
                'Ready for future forms and charts',
                'Shared spacing and typography system',
                'No Supabase or API logic included',
              ],
              primaryButtonText: 'Back to Personal Records',
              onPrimaryPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}
