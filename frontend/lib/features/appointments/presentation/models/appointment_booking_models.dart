import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../interoperability/domain/interoperability_models.dart';

enum AppointmentBookingMode { onsite, teleconsultation }

extension AppointmentBookingModeX on AppointmentBookingMode {
  String get title => switch (this) {
    AppointmentBookingMode.onsite => 'Onsite Consultation',
    AppointmentBookingMode.teleconsultation => 'Teleconsultation',
  };

  String get helpTitle => switch (this) {
    AppointmentBookingMode.onsite => 'Onsite Consultation Help',
    AppointmentBookingMode.teleconsultation => 'Teleconsultation Help',
  };

  List<String> get helpMessages => switch (this) {
    AppointmentBookingMode.onsite => const <String>[
      'Select the consultation type that best matches your visit.',
      'Choose a date and time slot, then look up the provider for the request.',
      'Review the request and send it through the gateway when everything looks right.',
    ],
    AppointmentBookingMode.teleconsultation => const <String>[
      'Select the remote consultation type that fits your concern.',
      'Choose a date and time slot, then look up the provider for the request.',
      'Review the request and send it through the gateway when everything looks right.',
    ],
  };

  IconData get icon => switch (this) {
    AppointmentBookingMode.onsite => Icons.local_hospital_outlined,
    AppointmentBookingMode.teleconsultation => Icons.video_call_outlined,
  };

  Color get accentColor => switch (this) {
    AppointmentBookingMode.onsite => AppColors.primary,
    AppointmentBookingMode.teleconsultation => AppColors.secondary,
  };

  String get locationLabel => switch (this) {
    AppointmentBookingMode.onsite => 'Facility',
    AppointmentBookingMode.teleconsultation => 'Platform',
  };

  String get locationHint => switch (this) {
    AppointmentBookingMode.onsite => 'Select facility',
    AppointmentBookingMode.teleconsultation => 'Select platform',
  };

  String get confirmationLabel => switch (this) {
    AppointmentBookingMode.onsite => 'Confirm Onsite Booking',
    AppointmentBookingMode.teleconsultation => 'Confirm Teleconsultation',
  };

  String get reviewTitle => switch (this) {
    AppointmentBookingMode.onsite => 'Review Onsite Consultation',
    AppointmentBookingMode.teleconsultation => 'Review Teleconsultation',
  };
}

class AppointmentTypeOption {
  const AppointmentTypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

class AppointmentModeOption {
  const AppointmentModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
  });

  final AppointmentBookingMode mode;
  final String title;
  final String description;
  final IconData icon;
}

class AppointmentLocationOption {
  const AppointmentLocationOption({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;
}

class AppointmentBookingContent {
  const AppointmentBookingContent({
    required this.mode,
    required this.stepOneTitle,
    required this.stepOneSubtitle,
    required this.stepTwoTitle,
    required this.stepTwoSubtitle,
    required this.stepThreeTitle,
    required this.stepThreeSubtitle,
    required this.typeOptions,
    required this.locationOptions,
  });

  final AppointmentBookingMode mode;
  final String stepOneTitle;
  final String stepOneSubtitle;
  final String stepTwoTitle;
  final String stepTwoSubtitle;
  final String stepThreeTitle;
  final String stepThreeSubtitle;
  final List<AppointmentTypeOption> typeOptions;
  final List<AppointmentLocationOption> locationOptions;
}

class AppointmentBookingSummary {
  const AppointmentBookingSummary({
    required this.mode,
    required this.consultationType,
    required this.date,
    required this.timeSlot,
    required this.location,
    required this.provider,
    required this.patientIdentifier,
    required this.reason,
    required this.notes,
    required this.teleReady,
  });

  final AppointmentBookingMode mode;
  final AppointmentTypeOption consultationType;
  final DateTime date;
  final String timeSlot;
  final String location;
  final InteroperabilityProviderSummary provider;
  final SyncIdentifierOption patientIdentifier;
  final String reason;
  final String notes;
  final bool teleReady;
}

const List<AppointmentModeOption> appointmentModeOptions = <AppointmentModeOption>[
  AppointmentModeOption(
    mode: AppointmentBookingMode.onsite,
    title: 'Onsite consultation',
    description: 'Book an in-person clinic visit with a provider.',
    icon: Icons.local_hospital_outlined,
  ),
  AppointmentModeOption(
    mode: AppointmentBookingMode.teleconsultation,
    title: 'Teleconsultation',
    description: 'Schedule a remote appointment through a video platform.',
    icon: Icons.video_call_outlined,
  ),
];

const List<String> mockAppointmentTimeSlots = <String>[
  '09:00 AM - 09:30 AM',
  '10:00 AM - 10:30 AM',
  '01:00 PM - 01:30 PM',
  '03:00 PM - 03:30 PM',
];

const AppointmentBookingContent onsiteAppointmentContent =
    AppointmentBookingContent(
      mode: AppointmentBookingMode.onsite,
      stepOneTitle: 'Type of Consultation',
      stepOneSubtitle:
          'Select the in-person visit that best fits your care need.',
      stepTwoTitle: 'Appointment Schedule',
      stepTwoSubtitle: 'Pick your preferred clinic date and time slot.',
      stepThreeTitle: 'Visit Details',
      stepThreeSubtitle: 'Add clinic details so the visit summary is complete.',
      typeOptions: <AppointmentTypeOption>[
        AppointmentTypeOption(
          title: 'General Checkup',
          description: 'Routine clinic visit for primary care needs.',
          icon: Icons.health_and_safety_outlined,
          accentColor: AppColors.primary,
        ),
        AppointmentTypeOption(
          title: 'Follow-up Visit',
          description: 'Return consultation after a recent appointment.',
          icon: Icons.assignment_return_outlined,
          accentColor: AppColors.secondary,
        ),
        AppointmentTypeOption(
          title: 'Prenatal Visit',
          description: 'Scheduled maternal care consultation in clinic.',
          icon: Icons.pregnant_woman_outlined,
          accentColor: AppColors.tertiary,
        ),
        AppointmentTypeOption(
          title: 'Lab Request Review',
          description: 'Discuss requested tests and next onsite steps.',
          icon: Icons.science_outlined,
          accentColor: AppColors.primaryDark,
        ),
        AppointmentTypeOption(
          title: 'Well-Child Visit',
          description: 'Routine pediatric care, development tracking, and immunization.',
          icon: Icons.child_care_outlined,
          accentColor: AppColors.success,
        ),
        AppointmentTypeOption(
          title: 'Dental Checkup',
          description: 'Oral health examination, cleaning, and dental care.',
          icon: Icons.medical_services_outlined,
          accentColor: AppColors.secondary,
        ),
        AppointmentTypeOption(
          title: 'Specialty Referral',
          description: 'Consultation with a specialist for targeted medical concerns.',
          icon: Icons.assignment_ind_outlined,
          accentColor: AppColors.tertiary,
        ),
        AppointmentTypeOption(
          title: 'Vaccination Visit',
          description: 'Scheduled immunization and vaccine administration.',
          icon: Icons.vaccines_outlined,
          accentColor: AppColors.primary,
        ),
      ],
      locationOptions: <AppointmentLocationOption>[
        AppointmentLocationOption(
          label: 'WAH Main Clinic',
          description: 'Primary outpatient consultation wing',
        ),
        AppointmentLocationOption(
          label: 'WAH Community Center',
          description: 'Accessible local clinic for regular visits',
        ),
        AppointmentLocationOption(
          label: 'WAH Women and Child Unit',
          description: 'Maternal and pediatric consultation area',
        ),
      ],
    );

const AppointmentBookingContent teleconsultationAppointmentContent =
    AppointmentBookingContent(
      mode: AppointmentBookingMode.teleconsultation,
      stepOneTitle: 'Type of Consultation',
      stepOneSubtitle:
          'Select the remote consultation format that best fits your concern.',
      stepTwoTitle: 'Appointment Schedule',
      stepTwoSubtitle: 'Choose a time slot for your online consultation.',
      stepThreeTitle: 'Call Details',
      stepThreeSubtitle: 'Add platform and provider details before confirming.',
      typeOptions: <AppointmentTypeOption>[
        AppointmentTypeOption(
          title: 'Medication Review',
          description: 'Discuss prescriptions and treatment adjustments.',
          icon: Icons.medication_outlined,
          accentColor: AppColors.primary,
        ),
        AppointmentTypeOption(
          title: 'Result Discussion',
          description: 'Review recent results without visiting the clinic.',
          icon: Icons.description_outlined,
          accentColor: AppColors.secondary,
        ),
        AppointmentTypeOption(
          title: 'Symptom Check',
          description: 'Quick remote assessment for current symptoms.',
          icon: Icons.monitor_heart_outlined,
          accentColor: AppColors.tertiary,
        ),
        AppointmentTypeOption(
          title: 'Follow-up Call',
          description: 'Continue an earlier care plan remotely.',
          icon: Icons.phone_in_talk_outlined,
          accentColor: AppColors.primaryDark,
        ),
      ],
      locationOptions: <AppointmentLocationOption>[
        AppointmentLocationOption(
          label: 'Google Meet',
          description: 'Video call with meeting link sent ahead of time',
        ),
        AppointmentLocationOption(
          label: 'Zoom',
          description: 'Remote consultation via secure video session',
        ),
        AppointmentLocationOption(
          label: 'Phone Call',
          description: 'Audio-only teleconsultation appointment',
        ),
      ],
    );

AppointmentBookingContent appointmentBookingContentForMode(
  AppointmentBookingMode mode,
) {
  return switch (mode) {
    AppointmentBookingMode.onsite => onsiteAppointmentContent,
    AppointmentBookingMode.teleconsultation =>
      teleconsultationAppointmentContent,
  };
}
