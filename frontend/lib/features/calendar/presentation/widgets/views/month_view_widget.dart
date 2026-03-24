import 'package:flutter/material.dart';

import '../../../../../core/constants/app_border_radii.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../domain/calendar_event.dart';
import '../calendar_event_card_widget.dart';

class MonthViewWidget extends StatelessWidget {
  const MonthViewWidget({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.selectedDayEvents,
    required this.onDateSelected,
    required this.onEventTap,
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final List<CalendarEvent> selectedDayEvents;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<CalendarEvent> onEventTap;

  List<DateTime> _buildMonthDays(DateTime date) {
    final firstOfMonth = DateTime(date.year, date.month, 1);
    final startWeekday = firstOfMonth.weekday % 7;
    final start = firstOfMonth.subtract(Duration(days: startWeekday));
    return List<DateTime>.generate(
      42,
      (index) => start.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final monthDays = _buildMonthDays(selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gridSpacing = 6.0;
          final gridWidth = constraints.maxWidth;
          final cellWidth = (gridWidth - (gridSpacing * 6)) / 7;
          final gridHeight = (cellWidth * 6) + (gridSpacing * 5);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: const [
                  Expanded(child: Center(child: Text('Sun'))),
                  Expanded(child: Center(child: Text('Mon'))),
                  Expanded(child: Center(child: Text('Tue'))),
                  Expanded(child: Center(child: Text('Wed'))),
                  Expanded(child: Center(child: Text('Thu'))),
                  Expanded(child: Center(child: Text('Fri'))),
                  Expanded(child: Center(child: Text('Sat'))),
                ],
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: gridHeight,
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: monthDays.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: gridSpacing,
                    crossAxisSpacing: gridSpacing,
                  ),
                  itemBuilder: (context, index) {
                    final date = monthDays[index];
                    final isCurrentMonth = date.month == selectedDate.month;
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final isSelected =
                        date.year == selectedDate.year &&
                        date.month == selectedDate.month &&
                        date.day == selectedDate.day;
                    final dayEvents = events
                        .where(
                          (event) =>
                              event.startTime.year == date.year &&
                              event.startTime.month == date.month &&
                              event.startTime.day == date.day,
                        )
                        .toList();

                    return Material(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: AppRadii.small,
                      child: InkWell(
                        borderRadius: AppRadii.small,
                        onTap: () => onDateSelected(date),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.small,
                            border: Border.all(
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.border.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: isSelected
                                      ? AppColors.textOnPrimary
                                      : isCurrentMonth
                                      ? AppColors.black
                                      : AppColors.textSecondary.withValues(
                                          alpha: 0.55,
                                        ),
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              if (dayEvents.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 2,
                                  runSpacing: 2,
                                  alignment: WrapAlignment.center,
                                  children: dayEvents.take(3).map((event) {
                                    final color =
                                        event.color ?? event.eventType.color;
                                    return Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.white
                                            : color,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              if (selectedDayEvents.isEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 128),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.large,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No events for this day',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: selectedDayEvents.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      return CalendarEventCardWidget(
                        event: event,
                        onTap: () => onEventTap(event),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
