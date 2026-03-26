import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/health_record_models.dart';
import '../widgets/health_record_screen_template.dart';

class MedicalConsultationsScreen extends StatelessWidget {
  const MedicalConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HealthRecordScreenTemplate(
      content: HealthRecordScreenContent(
        title: 'Medical Consultations',
        searchHint: 'Search consultations',
        filterOptions: <String>[
          'All',
          'Teleconsultation',
          'Onsite',
          'Follow-up',
        ],
        helpTitle: 'Medical Consultations Help',
        helpMessages: <String>[
          'Search consultations by reason, provider, or location.',
          'Use the type filter to narrow the consultation list.',
          'Tap any consultation to review its summary details.',
        ],
        emptyTitle: 'No matching consultations',
        emptyMessage: 'Try a different search term or consultation type.',
        entries: <HealthRecordEntry>[
          HealthRecordEntry(
            id: 'con-001',
            title: 'Cardiology Follow-up',
            subtitle: 'Reviewed blood pressure trend and medication response',
            summaryLabel: 'Visit',
            summaryValue: 'March 21, 2026',
            filterValue: 'Follow-up',
            statusLabel: 'Follow-up',
            statusColor: AppColors.primary,
            accentColor: AppColors.primary,
            icon: Icons.medical_services_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Provider', value: 'Dr. Reyes'),
              HealthRecordDetailField(label: 'Type', value: 'Follow-up'),
              HealthRecordDetailField(
                label: 'Location',
                value: 'WAH Heart Center',
              ),
              HealthRecordDetailField(
                label: 'Summary',
                value:
                    'Continue current medication and monitor readings weekly',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'con-002',
            title: 'Teleconsultation - Fever',
            subtitle: 'Remote assessment for mild fever symptoms',
            summaryLabel: 'Visit',
            summaryValue: 'February 09, 2026',
            filterValue: 'Teleconsultation',
            statusLabel: 'Teleconsultation',
            statusColor: AppColors.secondary,
            accentColor: AppColors.secondary,
            icon: Icons.video_call_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Provider', value: 'Dr. Lopez'),
              HealthRecordDetailField(label: 'Type', value: 'Teleconsultation'),
              HealthRecordDetailField(
                label: 'Reason',
                value: 'Low-grade fever and fatigue',
              ),
              HealthRecordDetailField(
                label: 'Summary',
                value:
                    'Hydration advised and temperature monitoring recommended',
              ),
            ],
          ),
          HealthRecordEntry(
            id: 'con-003',
            title: 'General Checkup',
            subtitle: 'Routine in-clinic physical examination',
            summaryLabel: 'Visit',
            summaryValue: 'January 16, 2026',
            filterValue: 'Onsite',
            statusLabel: 'Onsite',
            statusColor: AppColors.tertiary,
            accentColor: AppColors.tertiary,
            icon: Icons.local_hospital_outlined,
            details: <HealthRecordDetailField>[
              HealthRecordDetailField(label: 'Provider', value: 'Dr. Navarro'),
              HealthRecordDetailField(label: 'Type', value: 'Onsite'),
              HealthRecordDetailField(
                label: 'Location',
                value: 'WAH Main Clinic',
              ),
              HealthRecordDetailField(
                label: 'Summary',
                value: 'Routine labs requested and wellness goals discussed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
