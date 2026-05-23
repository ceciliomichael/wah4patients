import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/inputs/bottom_sheet_select_form_field.dart';
import '../../../interoperability/domain/interoperability_models.dart';
import 'appointment_step_header.dart';

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
      return _LoadingState();
    }

    if (errorMessage != null) {
      return _ErrorState(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    final activeProviders = providers
        .where((provider) => provider.isActive)
        .toList(growable: false);

    if (activeProviders.isEmpty) {
      return _ErrorState(
        message: 'No providers are currently available. Please try again.',
        onRetry: onRetry,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppointmentSectionLabel('YOUR PROVIDER'),
        BottomSheetSelectFormField<String>(
          value: selectedProviderId,
          options: activeProviders
              .map(
                (provider) => BottomSheetSelectOption<String>(
                  value: provider.id,
                  label: provider.name,
                  description: '${provider.facilityCode} • ${provider.location}',
                  icon: Icons.local_hospital_outlined,
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          label: 'Hospital or Clinic',
          hintText: 'Choose a provider',
          icon: Icons.apartment_outlined,
          helperText: 'Showing currently available providers.',
        ),
        const SizedBox(height: 16),
        Text(
          'Your request will be sent directly to this provider.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding available providers…',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          PrimaryButtonWidget(
            text: 'Try again',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
