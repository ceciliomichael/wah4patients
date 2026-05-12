import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../auth/domain/auth_session.dart';
import '../../data/interoperability_api_client.dart';
import '../../domain/interoperability_models.dart';
import '../widgets/sync_identifier_step.dart';
import '../widgets/sync_provider_step.dart';
import '../widgets/sync_request_review_step.dart';
import '../widgets/sync_request_simulation_button.dart';
import '../widgets/sync_wizard_step_header.dart';

class SyncRecordsWizardScreen extends StatefulWidget {
  SyncRecordsWizardScreen({
    super.key,
    InteroperabilityClient? apiClient,
    this.profileRefresh,
  })
    : apiClient = apiClient ?? InteroperabilityApiClient.instance;

  final InteroperabilityClient apiClient;
  final Future<bool> Function()? profileRefresh;

  @override
  State<SyncRecordsWizardScreen> createState() =>
      _SyncRecordsWizardScreenState();
}

class _SyncRecordsWizardScreenState extends State<SyncRecordsWizardScreen> {
  int _currentStep = 0;
  String? _selectedIdentifierFieldKey;
  String? _selectedProviderId;
  bool _isLoadingProviders = false;
  bool _isPreparingRequest = false;
  bool _isSimulatingRequest = false;
  String? _providerErrorMessage;
  List<InteroperabilityProviderSummary> _providers =
      const <InteroperabilityProviderSummary>[];
  late final List<SyncIdentifierOption> _identifierOptions;

  @override
  void initState() {
    super.initState();
    _identifierOptions = buildSyncIdentifierOptions(AuthSession.profile);
    if (_identifierOptions.length == 1) {
      _selectedIdentifierFieldKey = _identifierOptions.first.fieldKey;
    }
    unawaited(_loadProviders());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    final stepTitle = switch (_currentStep) {
      0 => 'Select patient identifier',
      1 => 'Select provider',
      _ => 'Review sync request',
    };

    final stepSubtitle = switch (_currentStep) {
      0 => 'Choose the identifier that will be sent with the sync request.',
      1 => 'Choose the provider to sync records from.',
      _ => 'Confirm the request details before the backend prepares it.',
    };

    final stepBody = switch (_currentStep) {
      0 => SyncIdentifierStep(
        options: _identifierOptions,
        selectedFieldKey: _selectedIdentifierFieldKey,
        onChanged: (value) {
          setState(() {
            _selectedIdentifierFieldKey = value;
          });
        },
      ),
      1 => SyncProviderStep(
        providers: _providers,
        isLoading: _isLoadingProviders,
        errorMessage: _providerErrorMessage,
        selectedProviderId: _selectedProviderId,
        onChanged: (value) {
          setState(() {
            _selectedProviderId = value;
          });
        },
        onRetry: _reloadProviders,
      ),
      _ => _buildReviewStep(),
    };

    final canContinue = switch (_currentStep) {
      0 => _selectedIdentifierOption != null,
      1 => _selectedProvider != null,
      _ => _selectedIdentifierOption != null && _selectedProvider != null,
    };
    final isBusy = _isPreparingRequest || _isSimulatingRequest;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppScreenHeader(
                    title: 'Sync records',
                    isTablet: isTablet,
                    topPadding: 0,
                    onBackPressed: _handleBack,
                    onHelpPressed: _showHelpDialog,
                  ),
                  const SizedBox(height: 20),
                  SyncWizardStepHeader(
                    currentStep: _currentStep,
                    title: stepTitle,
                    subtitle: stepSubtitle,
                  ),
                  const SizedBox(height: 20),
                  stepBody,
                  const SizedBox(height: 24),
                  PrimaryButtonWidget(
                    text: _currentStep == 2 ? 'Prepare request' : 'Continue',
                    icon: _currentStep == 2
                        ? Icons.verified_outlined
                        : Icons.arrow_forward,
                    onPressed: canContinue && !isBusy
                        ? _handleNext
                        : null,
                    isLoading: _isPreparingRequest,
                  ),
                  if (_currentStep == 2) ...[
                    const SizedBox(height: 12),
                    SyncRequestSimulationButton(
                      onPressed: canContinue && !isBusy
                          ? _simulateSyncRequest
                          : null,
                      isLoading: _isSimulatingRequest,
                    ),
                  ],
                  if (_currentStep > 0) ...[
                    const SizedBox(height: 12),
                    _BackButton(
                      onPressed: isBusy ? null : _handleBack,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SyncIdentifierOption? get _selectedIdentifierOption {
    final selectedFieldKey = _selectedIdentifierFieldKey;
    if (selectedFieldKey == null) {
      return null;
    }

    return syncIdentifierOptionForFieldKey(
      _identifierOptions,
      selectedFieldKey,
    );
  }

  InteroperabilityProviderSummary? get _selectedProvider {
    final selectedProviderId = _selectedProviderId;
    if (selectedProviderId == null) {
      return null;
    }

    for (final provider in _providers) {
      if (provider.id == selectedProviderId) {
        return provider;
      }
    }

    return null;
  }

  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _handleNext() async {
    if (_currentStep == 0) {
      if (_selectedIdentifierOption == null) {
        _showSnackBar('Select an identifier first.');
        return;
      }

      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_currentStep == 1) {
      if (_selectedProvider == null) {
        _showSnackBar('Select a provider first.');
        return;
      }

      setState(() {
        _currentStep = 2;
      });
      return;
    }

    await _prepareSyncRequest();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoadingProviders = true;
      _providerErrorMessage = null;
    });

    try {
      final providers = await widget.apiClient.getProviders();
      if (!mounted) {
        return;
      }

      setState(() {
        _providers = providers;
        _isLoadingProviders = false;
        _providerErrorMessage = null;
        if (_selectedProviderId == null) {
          final activeProviders = providers
              .where((provider) => provider.isActive)
              .toList(growable: false);
          if (activeProviders.length == 1) {
            _selectedProviderId = activeProviders.first.id;
          }
        }
      });
    } on InteroperabilityApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingProviders = false;
        _providerErrorMessage = error.message;
      });
    }
  }

  Future<void> _reloadProviders() async {
    await _loadProviders();
  }

  Future<void> _prepareSyncRequest() async {
    final selectedIdentifier = _selectedIdentifierOption;
    final selectedProvider = _selectedProvider;
    if (selectedIdentifier == null || selectedProvider == null) {
      _showSnackBar('Select an identifier and provider first.');
      return;
    }

    setState(() {
      _isPreparingRequest = true;
    });

    try {
      final preview = await widget.apiClient.prepareSyncRequest(
        providerId: selectedProvider.id,
        identifierSystem: selectedIdentifier.systemUri,
        identifierValue: selectedIdentifier.value,
        reason: 'Patient requested sync records',
      );

      if (!mounted) {
        return;
      }

      if (!preview.canSubmit) {
        _showSnackBar('Please complete the request details first.');
        return;
      }

      _showSnackBar('Your sync request is ready.');
      _returnToDashboard();
    } on InteroperabilityApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isPreparingRequest = false;
        });
      }
    }
  }

  Future<void> _simulateSyncRequest() async {
    final selectedIdentifier = _selectedIdentifierOption;
    final selectedProvider = _selectedProvider;
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (selectedIdentifier == null || selectedProvider == null) {
      _showSnackBar('Select an identifier and provider first.');
      return;
    }

    if (accessToken.isEmpty) {
      _showSnackBar('Sign in again so the app can authenticate the request.');
      return;
    }

    setState(() {
      _isSimulatingRequest = true;
    });

    try {
      await widget.apiClient.simulateSyncRequest(
        accessToken: accessToken,
        providerId: selectedProvider.id,
        identifierSystem: selectedIdentifier.systemUri,
        identifierValue: selectedIdentifier.value,
        reason: 'Patient requested sync records',
      );

      await (widget.profileRefresh ?? AuthSession.refreshProfileFromBackend)();

      if (!mounted) {
        return;
      }

      _showSnackBar('Your records were synced successfully.');
      _returnToDashboard();
    } on InteroperabilityApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSimulatingRequest = false;
        });
      }
    }
  }

  Widget _buildReviewStep() {
    final selectedIdentifier = _selectedIdentifierOption;
    final selectedProvider = _selectedProvider;

    if (selectedIdentifier == null || selectedProvider == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Complete the identifier and provider steps before reviewing the request.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SyncRequestReviewStep(
      identifier: selectedIdentifier,
      provider: selectedProvider,
    );
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Sync records help',
          messages: const <String>[
            'Choose an identifier that already exists in your profile.',
            'Select the hospital or clinic that should receive the sync request.',
            'Review the request, then let the backend prepare the gateway payload.',
          ],
          icons: const <IconData>[
            Icons.badge_outlined,
            Icons.local_hospital_outlined,
            Icons.verified_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.textPrimary),
    );
  }

  void _returnToDashboard() {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.dashboard || route.isFirst,
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: isEnabled
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back,
              size: 18,
              color: isEnabled
                  ? AppColors.textPrimary
                  : AppColors.textPrimary.withValues(alpha: 0.45),
            ),
            const SizedBox(width: 8),
            Text(
              'Back',
              style: AppTextStyles.buttonLarge.copyWith(
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textPrimary.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
