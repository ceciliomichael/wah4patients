import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feature/info_detail_screen.dart';
import '../../domain/dashboard_models.dart';
import 'feature_hub_screen.dart';

class MedicationResupplyScreen extends StatelessWidget {
  const MedicationResupplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <HubActionData>[
      const HubActionData(
        title: 'Request Resupply',
        description: 'Start a refill request for your medicines.',
        icon: Icons.medication_outlined,
        accentColor: AppColors.primary,
      ),
      const HubActionData(
        title: 'Prescription History',
        description: 'Review your past refill and prescription activity.',
        icon: Icons.history_outlined,
        accentColor: AppColors.secondary,
      ),
    ];

    return FeatureHubScreen(
      title: 'Medication Resupply',
      subtitle: 'A compact entry point for medication workflows and history.',
      icon: Icons.medication_outlined,
      actions: actions,
      helpTitle: 'Medication Resupply Help',
      helpMessages: const <String>[
        'The cards mirror the original two-choice action sheet.',
        'You can replace these placeholders with real forms later.',
        'The layout is intentionally light and readable.',
      ],
      onActionTap: (action) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => InfoDetailScreen(
              title: action.title,
              subtitle: action.description,
              body:
                  'This frontend-only placeholder keeps the medication flow '
                  'visible without adding any service integration yet.',
              icon: action.icon,
              highlights: const <String>[
                'Designed to be extended later',
                'Keeps refill and history as separate actions',
                'No backend logic included',
              ],
              primaryButtonText: 'Back to Medication Resupply',
              onPrimaryPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}
