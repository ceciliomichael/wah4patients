import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../constants/app_border_radii.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../feature/app_bottom_sheet_widget.dart';

class BottomSheetSelectOption<T> {
  const BottomSheetSelectOption({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });

  final T value;
  final String label;
  final String? description;
  final IconData? icon;
}

class BottomSheetSelectFormField<T> extends StatelessWidget {
  const BottomSheetSelectFormField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.label,
    required this.hintText,
    required this.icon,
    this.enabled = true,
    this.validator,
    this.showRequiredIndicator = false,
    this.helperText,
  });

  final T? value;
  final List<BottomSheetSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String hintText;
  final IconData icon;
  final bool enabled;
  final String? Function(T?)? validator;
  final bool showRequiredIndicator;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: ValueKey<String>('${label}_${value?.toString()}'),
      initialValue: value,
      validator: validator,
      builder: (state) {
        final selectedOption = _optionForValue(state.value);
        final hasValue = selectedOption != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: enabled && onChanged != null
                  ? () async {
                      final selectedValue = await _showSelectionSheet(
                        context,
                        selectedOption,
                      );
                      if (selectedValue == null) {
                        return;
                      }

                      state.didChange(selectedValue);
                      onChanged?.call(selectedValue);
                    }
                  : null,
              borderRadius: AppRadii.medium,
              child: InputDecorator(
                isEmpty: !hasValue,
                decoration: InputDecoration(
                  label: showRequiredIndicator
                      ? _FieldLabel(label: label, required: true)
                      : Text(label),
                  hintText: hintText,
                  errorText: state.errorText,
                  prefixIcon: Icon(icon, color: AppColors.textSecondary),
                  suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                child: hasValue
                    ? Text(
                        selectedOption.label,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      )
                    : null,
              ),
            ),
            if (helperText != null) ...[
              const SizedBox(height: 6),
              Text(
                helperText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  BottomSheetSelectOption<T>? _optionForValue(T? selectedValue) {
    if (selectedValue == null) {
      return null;
    }

    for (final option in options) {
      if (option.value == selectedValue) {
        return option;
      }
    }

    return null;
  }

  Future<T?> _showSelectionSheet(
    BuildContext context,
    BottomSheetSelectOption<T>? selectedOption,
  ) async {
    final selectedValue = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        final sheetHeight = MediaQuery.sizeOf(sheetContext).height * 0.6;

        return AppBottomSheetWidget(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.max(240.0, sheetHeight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (helperText != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    helperText!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = selectedOption != null && option.value == selectedOption.value;

                      return _BottomSheetOptionTile(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => Navigator.of(sheetContext).pop(option.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return selectedValue;
  }
}

class _BottomSheetOptionTile<T> extends StatelessWidget {
  const _BottomSheetOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final BottomSheetSelectOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.surfaceVariant : AppColors.surface,
      borderRadius: AppRadii.large,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.large,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadii.large,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (option.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.required,
  });

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.labelLarge.copyWith(
      color: AppColors.textPrimary,
    );
    final indicatorStyle = AppTextStyles.labelSmall.copyWith(
      color: required ? AppColors.danger : AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' '),
          TextSpan(
            text: required ? '*' : '(Optional)',
            style: indicatorStyle,
          ),
        ],
      ),
    );
  }
}
