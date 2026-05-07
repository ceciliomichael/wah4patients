import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/widgets/feature/app_bottom_sheet_widget.dart';
import '../../domain/medicine_status.dart';

class MedicineStatusDropdown extends StatelessWidget {
  const MedicineStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MedicineStatus? value;
  final ValueChanged<MedicineStatus?> onChanged;

  String _labelFor(MedicineStatus? status) {
    return status?.menuLabel ?? 'All Status';
  }

  IconData _iconFor(MedicineStatus? status) {
    return status?.icon ?? Icons.filter_list;
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<MedicineStatus?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return AppBottomSheetWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter by status',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose a medicine status to narrow the list.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: MedicineStatus.values.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final status = index == 0
                        ? null
                        : MedicineStatus.values[index - 1];
                    final isSelected = status == value;

                    return Material(
                      color: isSelected
                          ? AppColors.surfaceVariant
                          : AppColors.surface,
                      borderRadius: AppRadii.large,
                      child: InkWell(
                        onTap: () => Navigator.of(sheetContext).pop(status),
                        borderRadius: AppRadii.large,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.large,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _iconFor(status),
                                size: 20,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _labelFor(status),
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = value != null;

    return SizedBox(
      width: 56,
      height: 56,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        child: InkWell(
          onTap: () => _openPicker(context),
          borderRadius: AppRadii.large,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadii.large,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Center(
              child: Icon(
                _iconFor(value),
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
