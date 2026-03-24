import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../domain/calendar_event.dart';
import '../calendar_event_card_widget.dart';

class WeekViewWidget extends StatelessWidget {
  const WeekViewWidget({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEvent> onEventTap;

  List<DateTime> _buildWeekDays(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return List<DateTime>.generate(
      7,
      (index) => DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekDays = _buildWeekDays(selectedDate);
    final groupedEvents = <String, List<CalendarEvent>>{};
    for (final event in events) {
      final key = '${event.startTime.year}-${event.startTime.month}-${event.startTime.day}';
      groupedEvents.putIfAbsent(key, () => <CalendarEvent>[]).add(event);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: weekDays.map((day) {
              final isSelected =
                  day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              final isToday =
                  day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
              final dayEvents = events.where((event) {
                return event.startTime.year == day.year &&
                    event.startTime.month == day.month &&
                    event.startTime.day == day.day;
              }).toList();

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onDateSelected(day),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.secondary.withValues(alpha: 0.12)
                                : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.secondary
                                  : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekdayLabel(day.weekday),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${day.day}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: isSelected
                                  ? AppColors.textOnPrimary
                                  : isToday
                                      ? AppColors.secondary
                                      : AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (dayEvents.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.white
                                    : dayEvents.first.eventType.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.view_week_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Schedule',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap a day to focus on its appointments.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Container(
              constraints: const BoxConstraints(minHeight: 180),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(child: Text('No events this week')),
            )
          else
            Column(
              children: weekDays.where((day) {
                final key = '${day.year}-${day.month}-${day.day}';
                return groupedEvents.containsKey(key);
              }).map((day) {
                final key = '${day.year}-${day.month}-${day.day}';
                final dayEvents = groupedEvents[key] ?? const <CalendarEvent>[];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _weekdayLabel(day.weekday),
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${day.month}/${day.day}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...dayEvents.map(
                          (event) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: CalendarEventCardWidget(
                              event: event,
                              onTap: () => onEventTap(event),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          if (events.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'This week is shown as a grouped agenda view for clarity in the preview build.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
    }

    throw StateError('Unsupported weekday: $weekday');
  }
}
