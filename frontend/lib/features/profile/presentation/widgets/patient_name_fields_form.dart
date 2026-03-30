import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class PatientNameFieldsForm extends StatelessWidget {
  const PatientNameFieldsForm({
    super.key,
    required this.firstNameController,
    required this.secondNameController,
    required this.middleNameController,
    required this.lastNameController,
    required this.enabled,
    this.showRequirementIndicators = false,
    this.helperText,
  });

  final TextEditingController firstNameController;
  final TextEditingController secondNameController;
  final TextEditingController middleNameController;
  final TextEditingController lastNameController;
  final bool enabled;
  final bool showRequirementIndicators;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        final fieldWidth = isWide
            ? (constraints.maxWidth - 16.0) / 2.0
            : constraints.maxWidth;

        return AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (helperText != null) ...[
                Text(
                  helperText!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: _NameField(
                      controller: firstNameController,
                      enabled: enabled,
                      label: 'First name',
                      requirement: _FieldRequirement.required,
                      hintText: 'Enter first name',
                      autofillHints: const [AutofillHints.givenName],
                      textInputAction: TextInputAction.next,
                      validator: _requiredNameValidator,
                      icon: Icons.person_outline,
                      showRequirementIndicator: showRequirementIndicators,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _NameField(
                      controller: secondNameController,
                      enabled: enabled,
                      label: 'Second name',
                      requirement: _FieldRequirement.optional,
                      hintText: 'Enter second name',
                      autofillHints: const [AutofillHints.middleName],
                      textInputAction: TextInputAction.next,
                      validator: _optionalNameValidator,
                      icon: Icons.badge_outlined,
                      showRequirementIndicator: showRequirementIndicators,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _NameField(
                      controller: middleNameController,
                      enabled: enabled,
                      label: 'Middle name',
                      requirement: _FieldRequirement.optional,
                      hintText: 'Enter middle name',
                      autofillHints: const [AutofillHints.middleName],
                      textInputAction: TextInputAction.next,
                      validator: _optionalNameValidator,
                      icon: Icons.account_circle_outlined,
                      showRequirementIndicator: showRequirementIndicators,
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: _NameField(
                      controller: lastNameController,
                      enabled: enabled,
                      label: 'Last name',
                      requirement: _FieldRequirement.required,
                      hintText: 'Enter last name',
                      autofillHints: const [AutofillHints.familyName],
                      textInputAction: TextInputAction.done,
                      validator: _requiredNameValidator,
                      icon: Icons.badge,
                      showRequirementIndicator: showRequirementIndicators,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.enabled,
    required this.label,
    required this.requirement,
    required this.hintText,
    required this.autofillHints,
    required this.textInputAction,
    required this.validator,
    required this.icon,
    required this.showRequirementIndicator,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final _FieldRequirement requirement;
  final String hintText;
  final List<String>? autofillHints;
  final TextInputAction textInputAction;
  final String? Function(String?) validator;
  final IconData icon;
  final bool showRequirementIndicator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        label: showRequirementIndicator
            ? _RequirementLabel(label: label, requirement: requirement)
            : Text(label),
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
    );
  }
}

enum _FieldRequirement { required, optional }

class _RequirementLabel extends StatelessWidget {
  const _RequirementLabel({required this.label, required this.requirement});

  final String label;
  final _FieldRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTextStyles.labelLarge.copyWith(
      color: AppColors.textPrimary,
    );

    final indicatorStyle = AppTextStyles.labelSmall.copyWith(
      color: requirement == _FieldRequirement.required
          ? AppColors.danger
          : AppColors.textSecondary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: label),
          const TextSpan(text: ' '),
          TextSpan(
            text: requirement == _FieldRequirement.required
                ? '*'
                : '(Optional)',
            style: indicatorStyle,
          ),
        ],
      ),
    );
  }
}

String? _requiredNameValidator(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) {
    return 'Please enter this name';
  }

  if (name.length > 100) {
    return 'Name must be 100 characters or less';
  }

  return null;
}

String? _optionalNameValidator(String? value) {
  final name = value?.trim() ?? '';
  if (name.length > 100) {
    return 'Name must be 100 characters or less';
  }

  return null;
}
