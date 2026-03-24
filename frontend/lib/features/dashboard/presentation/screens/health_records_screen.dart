import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/dashboard_models.dart';
import '../../../health_records/presentation/screens/immunization_records_screen.dart';
import '../../../health_records/presentation/screens/laboratory_results_screen.dart';
import '../../../health_records/presentation/screens/medical_consultations_screen.dart';
import '../../../health_records/presentation/screens/medical_history_screen.dart';
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
        final Widget screen = switch (action.title) {
          'Medical History' => const MedicalHistoryScreen(),
          'Immunization Records' => const ImmunizationRecordsScreen(),
          'Medical Consultations' => const MedicalConsultationsScreen(),
          'Laboratory Results' => const LaboratoryResultsScreen(),
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
