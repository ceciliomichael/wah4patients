import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_notification_center.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../interoperability/data/interoperability_api_client.dart';
import '../../../interoperability/domain/interoperability_models.dart';
import '../../data/appointment_request_api_client.dart';
import '../../data/appointment_history_api_client.dart';
import '../../data/appointment_history_local_cache.dart';
import '../models/appointment_booking_models.dart';
import '../widgets/appointment_details_step.dart';
import '../widgets/appointment_mode_step.dart';
import '../widgets/appointment_provider_step.dart';
import '../widgets/appointment_schedule_step.dart';
import '../widgets/appointment_step_header.dart';
import '../widgets/appointment_type_step.dart';
import 'appointment_review_screen.dart';

class AppointmentBookingScreen extends StatefulWidget {
  AppointmentBookingScreen({
    super.key,
    this.initialMode,
    InteroperabilityClient? providerClient,
    AppointmentRequestApiClient? requestClient,
  })  : providerClient = providerClient ?? InteroperabilityApiClient.instance,
        requestClient = requestClient ?? AppointmentRequestApiClient.instance;

  final AppointmentBookingMode? initialMode;
  final InteroperabilityClient providerClient;
  final AppointmentRequestApiClient requestClient;

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int _currentStep = 0;
  AppointmentBookingMode? _selectedMode;
  int? _selectedTypeIndex;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedLocation;
  String? _selectedProviderId;
  bool _teleReady = false;
  bool _isLoadingProviders = false;
  bool _isSubmitting = false;
  String? _providerErrorMessage;
  List<InteroperabilityProviderSummary> _providers =
      const <InteroperabilityProviderSummary>[];

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final List<SyncIdentifierOption> _patientIdentifierOptions;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _patientIdentifierOptions = buildSyncIdentifierOptions(AuthSession.profile);
    unawaited(_loadProviders());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Appointments Help',
          messages: const <String>[
            'Choose a consultation mode, then the app will guide you through the rest of the request.',
            'Provider lookup happens inside the flow so you can pick a valid target before sending.',
            'The final confirmation sends the appointment request to the backend gateway.',
          ],
          icons: const <IconData>[
            Icons.list_alt_outlined,
            Icons.apartment_outlined,
            Icons.verified_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    AppNotificationCenter.instance.showInfo(message);
  }

  AppointmentBookingMode? get _mode => _selectedMode;

  AppointmentBookingContent? get _content {
    final mode = _mode;
    if (mode == null) {
      return null;
    }

    return appointmentBookingContentForMode(mode);
  }

  SyncIdentifierOption? get _selectedPatientIdentifier {
    if (_patientIdentifierOptions.isEmpty) {
      return null;
    }

    return _patientIdentifierOptions.first;
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

  bool get _isModeSelectionRequired => _selectedMode == null;

  void _handleBack() {
    if (_isModeSelectionRequired) {
      Navigator.of(context).pop();
      return;
    }

    if (_currentStep == 0) {
      if (widget.initialMode == null) {
        setState(() {
          _selectedMode = null;
          _selectedTypeIndex = null;
          _selectedDate = null;
          _selectedTime = null;
          _selectedLocation = null;
          _selectedProviderId = null;
          _teleReady = false;
        });
        return;
      }

      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentStep -= 1;
    });
  }

  Future<void> _handleNext() async {
    if (_isModeSelectionRequired) {
      _showSnackBar('Select a consultation mode first.');
      return;
    }

    if (_currentStep == 0) {
      if (_selectedTypeIndex == null) {
        _showSnackBar('Select a consultation type first.');
        return;
      }

      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_currentStep == 1) {
      if (_selectedDate == null || _selectedTime == null) {
        _showSnackBar('Choose both a date and a time.');
        return;
      }

      setState(() {
        _currentStep = 2;
      });
      return;
    }

    if (_currentStep == 2) {
      if (_selectedProvider == null) {
        _showSnackBar('Select a provider first.');
        return;
      }

      setState(() {
        _currentStep = 3;
      });
      return;
    }

    await _openReviewScreen();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoadingProviders = true;
      _providerErrorMessage = null;
    });

    try {
      final providers = await widget.providerClient.getProviders();
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

  Future<void> _openReviewScreen() async {
    final mode = _mode;
    final content = _content;
    final selectedIdentifier = _selectedPatientIdentifier;
    final selectedProvider = _selectedProvider;
    final selectedType = _selectedTypeIndex;
    final selectedDate = _selectedDate;
    final selectedTime = _selectedTime;
    final selectedLocation = _selectedLocation;
    final reason = _reasonController.text.trim();
    final notes = _notesController.text.trim();

    if (mode == null || content == null) {
      _showSnackBar('Select a consultation mode first.');
      return;
    }
    if (selectedIdentifier == null) {
      _showSnackBar('Complete your profile with a valid patient identifier first.');
      return;
    }
    if (selectedType == null) {
      _showSnackBar('Select a consultation type first.');
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      _showSnackBar('Choose both a date and a time.');
      return;
    }
    if (selectedProvider == null) {
      _showSnackBar('Select a provider first.');
      return;
    }
    if (mode == AppointmentBookingMode.teleconsultation && selectedLocation == null) {
      _showSnackBar('Select a platform first.');
      return;
    }
    if (reason.isEmpty) {
      _showSnackBar('Complete the appointment details first.');
      return;
    }
    if (mode == AppointmentBookingMode.teleconsultation && !_teleReady) {
      _showSnackBar('Confirm remote consultation readiness first.');
      return;
    }

    final summary = AppointmentBookingSummary(
      mode: mode,
      consultationType: content.typeOptions[selectedType],
      date: selectedDate,
      timeSlot: '${selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
      location: mode == AppointmentBookingMode.onsite ? selectedProvider.name : selectedLocation!,
      provider: selectedProvider,
      patientIdentifier: selectedIdentifier,
      reason: reason,
      notes: notes,
      teleReady: _teleReady,
    );

    final confirmed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AppointmentReviewScreen(summary: summary),
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await _submitAppointmentRequest(summary);
  }

  Future<void> _submitAppointmentRequest(
    AppointmentBookingSummary summary,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await widget.requestClient.requestAppointment(
        providerId: summary.provider.id,
        appointmentMode: summary.mode.name,
        appointmentType: summary.consultationType.title,
        scheduledAt: _buildScheduledStart(summary.date, summary.timeSlot)
            .toUtc()
            .toIso8601String(),
        durationMinutes: 30,
        locationOrPlatform: summary.location,
        identifierSystem: summary.patientIdentifier.systemUri,
        identifierValue: summary.patientIdentifier.value,
        reason: summary.reason,
        notes: summary.notes,
      );

      if (!mounted) {
        return;
      }

      AppointmentHistoryLocalCache.upsertPendingRecord(
        _buildPendingAppointmentHistoryRecord(
          summary,
          response.transactionId,
          response.correlationId,
        ),
      );
      _showSnackBar(response.message);
      Navigator.of(context).pop();
    } on AppointmentRequestApiException catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackBar(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  DateTime _buildScheduledStart(DateTime date, String timeSlot) {
    final startText = timeSlot.split('-').first.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$').firstMatch(startText);
    if (match == null) {
      return DateTime(date.year, date.month, date.day, 9, 0);
    }

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridiem = match.group(3)!;

    var normalizedHour = hour % 12;
    if (meridiem == 'PM') {
      normalizedHour += 12;
    }

    return DateTime(date.year, date.month, date.day, normalizedHour, minute);
  }

  AppointmentHistoryRecordResponse _buildPendingAppointmentHistoryRecord(
    AppointmentBookingSummary summary,
    String transactionId,
    String correlationId,
  ) {
    final scheduledStart = _buildScheduledStart(summary.date, summary.timeSlot)
        .toUtc()
        .toIso8601String();
    final nowIso = DateTime.now().toUtc().toIso8601String();
    final modeLabel = summary.mode == AppointmentBookingMode.onsite
        ? 'Onsite consultation'
        : 'Teleconsultation';

    return AppointmentHistoryRecordResponse(
      id: 'pending-$transactionId',
      gatewayTransactionId: transactionId,
      correlationId: correlationId,
      profileId: AuthSession.userId ?? '',
      title: summary.consultationType.title,
      subtitle: '${summary.provider.name} • ${summary.location}',
      summaryLabel: 'Scheduled',
      summaryValue: _formatAppointmentDate(summary.date),
      filterValue: 'Pending',
      statusLabel: 'Pending',
      statusColorKey: 'tertiary',
      accentColorKey:
          summary.mode == AppointmentBookingMode.onsite ? 'primary' : 'secondary',
      iconKey: 'schedule',
      details: <AppointmentHistoryDetailResponse>[
        AppointmentHistoryDetailResponse(
          label: 'Provider',
          value: summary.provider.name,
        ),
        AppointmentHistoryDetailResponse(
          label: 'Mode',
          value: modeLabel,
        ),
        AppointmentHistoryDetailResponse(
          label: 'Location/Platform',
          value: summary.location,
        ),
        AppointmentHistoryDetailResponse(
          label: 'Scheduled At',
          value: scheduledStart,
        ),
        AppointmentHistoryDetailResponse(
          label: 'Reason',
          value: summary.reason,
        ),
        if (summary.notes.trim().isNotEmpty)
          AppointmentHistoryDetailResponse(
            label: 'Notes',
            value: summary.notes.trim(),
          ),
      ],
      recordedAt: scheduledStart,
      displayOrder: 10,
      createdAt: nowIso,
      updatedAt: nowIso,
    );
  }

  String _formatAppointmentDate(DateTime date) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildReviewPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        'Complete the previous steps to review and send the request.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    if (_isModeSelectionRequired) {
      return AppointmentModeStep(
        selectedMode: _selectedMode,
        onChanged: (mode) {
          setState(() {
            _selectedMode = mode;
            _selectedTypeIndex = null;
            _selectedDate = null;
            _selectedTime = null;
            _selectedLocation = null;
            _selectedProviderId = null;
            _teleReady = false;
            _currentStep = 0;
          });
        },
      );
    }

    final content = _content;
    if (content == null) {
      return _buildReviewPlaceholder();
    }

    return switch (_currentStep) {
      0 => AppointmentTypeStep(
        options: content.typeOptions,
        selectedIndex: _selectedTypeIndex,
        onSelected: (index) {
          setState(() {
            _selectedTypeIndex = index;
          });
        },
      ),
      1 => AppointmentScheduleStep(
        selectedDate: _selectedDate,
        selectedTime: _selectedTime,
        onDateSelected: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        onTimeSelected: (time) {
          setState(() {
            _selectedTime = time;
          });
        },
      ),
      2 => AppointmentProviderStep(
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
      _ => AppointmentDetailsStep(
        mode: content.mode,
        provider: _selectedProvider!,
        locationOptions: content.locationOptions,
        selectedLocation: _selectedLocation,
        reasonController: _reasonController,
        notesController: _notesController,
        teleReady: _teleReady,
        onLocationChanged: (value) {
          setState(() {
            _selectedLocation = value;
          });
        },
        onTeleReadyChanged: (value) {
          setState(() {
            _teleReady = value;
          });
        },
      ),
    };
  }

  String _stepTitle() {
    if (_isModeSelectionRequired) {
      return 'Choose consultation mode';
    }

    final content = _content;
    if (content == null) {
      return 'Appointments';
    }

    return switch (_currentStep) {
      0 => content.stepOneTitle,
      1 => content.stepTwoTitle,
      2 => 'Select provider',
      _ => content.stepThreeTitle,
    };
  }

  String _stepSubtitle() {
    if (_isModeSelectionRequired) {
      return 'Pick whether this appointment is onsite or remote before you continue.';
    }

    final content = _content;
    if (content == null) {
      return 'Complete the booking flow before sending the request.';
    }

    return switch (_currentStep) {
      0 => content.stepOneSubtitle,
      1 => content.stepTwoSubtitle,
      2 => 'Choose the provider that should receive the request.',
      _ => content.stepThreeSubtitle,
    };
  }

  String _primaryButtonText() {
    if (_isModeSelectionRequired) {
      return 'Continue';
    }

    final content = _content;
    if (content == null) {
      return 'Continue';
    }

    return _currentStep == 3 ? 'Review Booking' : 'Continue';
  }

  bool _canContinue() {
    if (_isSubmitting) {
      return false;
    }

    if (_isModeSelectionRequired) {
      return _selectedMode != null;
    }

    return switch (_currentStep) {
      0 => _selectedTypeIndex != null,
      1 => _selectedDate != null && _selectedTime != null,
      2 => _selectedProvider != null,
      _ => true,
    };
  }

  void _handlePrimaryAction() {
    if (!_canContinue()) {
      if (_isModeSelectionRequired) {
        _showSnackBar('Select a consultation mode first.');
      }
      return;
    }

    if (_isModeSelectionRequired) {
      setState(() {
        _currentStep = 0;
      });
      return;
    }

    unawaited(_handleNext());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: 'Appointments',
                isTablet: isTablet,
                topPadding: 24.0,
                onBackPressed: _handleBack,
                onHelpPressed: _showHelpDialog,
              ),
              const SizedBox(height: 12),
              AppointmentStepHeader(
                currentStep: _isModeSelectionRequired ? 0 : _currentStep,
                totalSteps: _isModeSelectionRequired ? 1 : 4,
                title: _stepTitle(),
                subtitle: _stepSubtitle(),
                accentColor: _mode == AppointmentBookingMode.teleconsultation
                    ? AppColors.secondary
                    : AppColors.textPrimary,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildStepBody(),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButtonWidget(
                      text: _isModeSelectionRequired && widget.initialMode == null
                          ? 'Cancel'
                          : 'Back',
                      onPressed: _isSubmitting ? null : _handleBack,
                      textColor: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButtonWidget(
                      text: _primaryButtonText(),
                      onPressed: _canContinue() ? _handlePrimaryAction : null,
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
