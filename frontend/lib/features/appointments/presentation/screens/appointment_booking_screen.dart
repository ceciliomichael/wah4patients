import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_notification_center.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/feature/app_screen_header.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../models/appointment_booking_models.dart';
import 'appointment_review_screen.dart';
import '../widgets/appointment_details_step.dart';
import '../widgets/appointment_schedule_step.dart';
import '../widgets/appointment_step_header.dart';
import '../widgets/appointment_type_step.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key, required this.content});

  final AppointmentBookingContent content;

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int _currentStep = 0;
  int? _selectedTypeIndex;
  int? _selectedDateIndex;
  String? _selectedTimeSlot;
  String? _selectedLocation;
  String? _selectedProvider;
  bool _teleReady = false;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  late final List<DateTime> _dateOptions;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateOptions = List<DateTime>.generate(
      6,
      (index) => DateTime(now.year, now.month, now.day + index + 1),
    );
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
          title: widget.content.mode.helpTitle,
          messages: widget.content.mode.helpMessages,
          icons: const <IconData>[
            Icons.list_alt_outlined,
            Icons.calendar_month_outlined,
            Icons.fact_check_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _showSnackBar(String message) {
    AppNotificationCenter.instance.showInfo(message);
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

  void _handleNext() {
    switch (_currentStep) {
      case 0:
        if (_selectedTypeIndex == null) {
          _showSnackBar('Select a consultation type first.');
          return;
        }
        break;
      case 1:
        if (_selectedDateIndex == null || _selectedTimeSlot == null) {
          _showSnackBar('Choose both a date and a time slot.');
          return;
        }
        break;
      case 2:
        unawaited(_openReviewScreen());
        return;
    }

    setState(() {
      _currentStep += 1;
    });
  }

  Future<void> _openReviewScreen() async {
    final reason = _reasonController.text.trim();
    final notes = _notesController.text.trim();
    final selectedType = _selectedTypeIndex;
    final selectedDate = _selectedDateIndex;
    final selectedTimeSlot = _selectedTimeSlot;
    final selectedLocation = _selectedLocation;
    final selectedProvider = _selectedProvider;

    if (selectedType == null) {
      _showSnackBar('Select a consultation type first.');
      return;
    }
    if (selectedDate == null || selectedTimeSlot == null) {
      _showSnackBar('Choose both a date and a time slot.');
      return;
    }
    if (selectedLocation == null || selectedProvider == null || reason.isEmpty) {
      _showSnackBar('Complete the required booking details.');
      return;
    }
    if (widget.content.mode == AppointmentBookingMode.teleconsultation &&
        !_teleReady) {
      _showSnackBar('Confirm remote consultation readiness first.');
      return;
    }

    final summary = AppointmentBookingSummary(
      mode: widget.content.mode,
      consultationType: widget.content.typeOptions[selectedType],
      date: _dateOptions[selectedDate],
      timeSlot: selectedTimeSlot,
      location: selectedLocation,
      provider: selectedProvider,
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

    _showSnackBar('${widget.content.mode.title} saved locally for this session.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

    final stepTitle = switch (_currentStep) {
      0 => widget.content.stepOneTitle,
      1 => widget.content.stepTwoTitle,
      _ => widget.content.stepThreeTitle,
    };

    final stepSubtitle = switch (_currentStep) {
      0 => widget.content.stepOneSubtitle,
      1 => widget.content.stepTwoSubtitle,
      _ => widget.content.stepThreeSubtitle,
    };

    final Widget stepBody = switch (_currentStep) {
      0 => AppointmentTypeStep(
        options: widget.content.typeOptions,
        selectedIndex: _selectedTypeIndex,
        onSelected: (index) {
          setState(() {
            _selectedTypeIndex = index;
          });
        },
      ),
      1 => AppointmentScheduleStep(
        selectedDateIndex: _selectedDateIndex,
        selectedTimeSlot: _selectedTimeSlot,
        dateOptions: _dateOptions,
        timeSlots: mockAppointmentTimeSlots,
        onDateSelected: (index) {
          setState(() {
            _selectedDateIndex = index;
          });
        },
        onTimeSlotSelected: (slot) {
          setState(() {
            _selectedTimeSlot = slot;
          });
        },
      ),
      _ => AppointmentDetailsStep(
        mode: widget.content.mode,
        locationOptions: widget.content.locationOptions,
        providerOptions: widget.content.providerOptions,
        selectedLocation: _selectedLocation,
        selectedProvider: _selectedProvider,
        reasonController: _reasonController,
        notesController: _notesController,
        teleReady: _teleReady,
        onLocationChanged: (value) {
          setState(() {
            _selectedLocation = value;
          });
        },
        onProviderChanged: (value) {
          setState(() {
            _selectedProvider = value;
          });
        },
        onTeleReadyChanged: (value) {
          setState(() {
            _teleReady = value;
          });
        },
      ),
    };

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppScreenHeader(
                title: widget.content.mode.title,
                isTablet: isTablet,
                topPadding: 24.0,
                onBackPressed: _handleBack,
                onHelpPressed: _showHelpDialog,
              ),
              const SizedBox(height: 12),
              AppointmentStepHeader(
                currentStep: _currentStep,
                title: stepTitle,
                subtitle: stepSubtitle,
                accentColor: widget.content.mode.accentColor,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: stepBody,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButtonWidget(
                      text: _currentStep == 0 ? 'Cancel' : 'Back',
                      onPressed: _handleBack,
                      textColor: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButtonWidget(
                      text: _currentStep == 2 ? 'Review Booking' : 'Continue',
                      onPressed: _handleNext,
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
