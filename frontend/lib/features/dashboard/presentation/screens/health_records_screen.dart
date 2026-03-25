import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/dashboard_models.dart';
import 'feature_hub_screen.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <HubActionData>[
      const HubActionData(
        title: 'Medical History',
        description: 'Review prior diagnoses, surgeries, and care notes.',
        icon: Icons.history_outlined,
        accentColor: AppColors.primary,
      ),
      const HubActionData(
        title: 'Immunization Records',
        description: 'See vaccine history and coverage at a glance.',
        icon: Icons.vaccines_outlined,
        accentColor: AppColors.secondary,
      ),
      const HubActionData(
        title: 'Medical Consultations',
        description: 'Open consultation summaries and visit notes.',
        icon: Icons.medical_services_outlined,
        accentColor: AppColors.tertiary,
      ),
      const HubActionData(
        title: 'Laboratory Results',
        description: 'View lab reports and related clinical findings.',
        icon: Icons.science_outlined,
        accentColor: AppColors.primaryDark,
      ),
    ];

    return FeatureHubScreen(
      title: 'Health Records',
      subtitle: 'A clean view of your electronic health record sections.',
      icon: Icons.description_outlined,
      actions: actions,
      helpTitle: 'Health Records Help',
      helpMessages: const <String>[
        'Each card opens a focused, frontend-only record view.',
        'The layout follows the original app positioning without Supabase.',
        'This screen is ready for real data integration later.',
      ],
      onActionTap: (action) {
        final String? routeName = switch (action.title) {
          'Medical History' => AppRoutes.medicalHistory,
          'Immunization Records' => AppRoutes.immunizationRecords,
          'Medical Consultations' => AppRoutes.medicalConsultations,
          'Laboratory Results' => AppRoutes.laboratoryResults,
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
