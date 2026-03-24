import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/dashboard_models.dart';
import '../../../medication_resupply/presentation/screens/medication_resupply_history_screen.dart';
import '../../../medication_resupply/presentation/screens/medication_resupply_request_screen.dart';
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
        'Open Request Resupply to choose a medicine and fill out a refill request.',
        'Open Prescription History to review earlier requests and their status.',
        'The screens stay frontend-only and do not connect to backend services yet.',
      ],
      onActionTap: (action) {
        final Widget screen = switch (action.title) {
          'Request Resupply' => const MedicationResupplyRequestScreen(),
          'Prescription History' => const MedicationResupplyHistoryScreen(),
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
