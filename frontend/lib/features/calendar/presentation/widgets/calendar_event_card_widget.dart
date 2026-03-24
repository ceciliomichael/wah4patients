import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/calendar_event.dart';

class CalendarEventCardWidget extends StatelessWidget {
  const CalendarEventCardWidget({
    super.key,
    required this.event,
    this.onTap,
  });

  final CalendarEvent event;
  final VoidCallback? onTap;

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

  @override
  Widget build(BuildContext context) {
    final eventColor = event.color ?? event.eventType.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border(left: BorderSide(color: eventColor, width: 4.0)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: eventColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  event.eventType.icon,
                  color: eventColor,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.0,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            _formatTimeRange(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14.0,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              event.location!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (event.doctorName != null) ...[
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14.0,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              event.doctorName!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12.0),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
