import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/app_bottom_sheet_widget.dart';
import '../../domain/calendar_event.dart';

class CalendarEventDetailSheetWidget extends StatelessWidget {
  const CalendarEventDetailSheetWidget({
    super.key,
    required this.event,
    required this.onClose,
  });

  final CalendarEvent event;
  final VoidCallback onClose;

  String _formatTimeRange() {
    final startHour = event.startTime.hour > 12
        ? event.startTime.hour - 12
        : (event.startTime.hour == 0 ? 12 : event.startTime.hour);
    final endHour = event.endTime.hour > 12
        ? event.endTime.hour - 12
        : (event.endTime.hour == 0 ? 12 : event.endTime.hour);
    final startPeriod = event.startTime.hour >= 12 ? 'PM' : 'AM';
    final endPeriod = event.endTime.hour >= 12 ? 'PM' : 'AM';
    final startMinute = event.startTime.minute.toString().padLeft(2, '0');
    final endMinute = event.endTime.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute $startPeriod - $endHour:$endMinute $endPeriod';
  }

  String _formatDate(DateTime date) {
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
    const days = <String>[
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];

    return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = event.color ?? event.eventType.color;

    return AppBottomSheetWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: eventColor.withValues(alpha: 0.15),
                  borderRadius: AppRadii.large,
                ),
                child: Icon(
                  event.eventType.icon,
                  color: eventColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.eventType.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: AppColors.textSecondary,
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailTile(
            icon: Icons.access_time,
            title: 'Time',
            value: _formatTimeRange(),
            accentColor: eventColor,
          ),
          const SizedBox(height: 12),
          _DetailTile(
            icon: Icons.calendar_month_outlined,
            title: 'Date',
            value: _formatDate(event.startTime),
            accentColor: AppColors.secondary,
          ),
          if (event.location != null) ...[
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.location_on_outlined,
              title: 'Location',
              value: event.location!,
              accentColor: AppColors.tertiary,
            ),
          ],
          if (event.doctorName != null) ...[
            const SizedBox(height: 12),
            _DetailTile(
              icon: Icons.person_outline,
              title: 'Doctor',
              value: event.doctorName!,
              accentColor: AppColors.primary,
            ),
          ],
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppRadii.large,
              ),
              child: Text(
                event.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: AppRadii.medium,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
