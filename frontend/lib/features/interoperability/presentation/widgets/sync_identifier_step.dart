import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../../domain/interoperability_models.dart';

class SyncIdentifierStep extends StatelessWidget {
  const SyncIdentifierStep({
    super.key,
    required this.options,
    required this.selectedFieldKey,
    required this.onChanged,
  });

  final List<SyncIdentifierOption> options;
  final String? selectedFieldKey;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No sync-ready identifier is available yet. Complete your profile first.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select an identifier',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the identifier the gateway should use to match your records.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        BottomSheetSelectFormField<String>(
          value: selectedFieldKey,
          options: options
              .map(
                (option) => BottomSheetSelectOption<String>(
                  value: option.fieldKey,
                  label: option.label,
                  description: option.value,
                  icon: option.fieldKey == 'philHealthId'
                      ? Icons.credit_card_outlined
                      : Icons.perm_identity_outlined,
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          label: 'Patient identifier',
          hintText: 'Select identifier',
          icon: Icons.badge_outlined,
          helperText:
              'Only identifiers already saved in your profile are shown.',
        ),
      ],
    );
  }
}
