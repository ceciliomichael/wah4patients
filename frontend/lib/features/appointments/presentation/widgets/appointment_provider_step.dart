import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../../../interoperability/domain/interoperability_models.dart';

class AppointmentProviderStep extends StatelessWidget {
  const AppointmentProviderStep({
    super.key,
    required this.providers,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedProviderId,
    required this.onChanged,
    required this.onRetry,
  });

  final List<InteroperabilityProviderSummary> providers;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedProviderId;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _StateCard(
        icon: Icons.cloud_download_outlined,
        title: 'Looking up providers',
        message: 'Fetching the current provider list from the gateway.',
      );
    }

    if (errorMessage != null) {
      return _StateCard(
        icon: Icons.cloud_off_outlined,
        title: 'Provider lookup unavailable',
        message: errorMessage!,
        actionLabel: 'Retry',
        onActionPressed: onRetry,
      );
    }

    final activeProviders = providers
        .where((provider) => provider.isActive)
        .toList(growable: false);

    if (activeProviders.isEmpty) {
      return _StateCard(
        icon: Icons.domain_disabled_outlined,
        title: 'No active providers yet',
        message:
            'The gateway does not currently have any active provider entries.',
        actionLabel: 'Retry',
        onActionPressed: onRetry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select target provider',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the hospital or clinic that should receive the appointment request.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        BottomSheetSelectFormField<String>(
          value: selectedProviderId,
          options: activeProviders
              .map(
                (provider) => BottomSheetSelectOption<String>(
                  value: provider.id,
                  label: provider.name,
                  description:
                      '${provider.facilityCode} • ${provider.location}',
                  icon: Icons.local_hospital_outlined,
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          label: 'Provider',
          hintText: 'Select provider',
          icon: Icons.apartment_outlined,
          helperText: 'Only active providers are available for appointment requests.',
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.extraLarge,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.medium,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.refresh_outlined),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
