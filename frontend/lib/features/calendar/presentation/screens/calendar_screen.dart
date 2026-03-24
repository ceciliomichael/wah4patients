import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/calendar_event.dart';
import '../widgets/calendar_event_card_widget.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/event_type_filter_widget.dart';
import '../widgets/views/day_view_widget.dart';
import '../widgets/views/month_view_widget.dart';
import '../widgets/views/week_view_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.month;
  DateTime _selectedDate = DateTime.now();
  EventType? _selectedType;
  late final List<CalendarEvent> _events = _buildPreviewEvents();

  List<CalendarEvent> _buildPreviewEvents() {
    final today = DateTime.now();

    DateTime at(int dayOffset, int hour, int minute) {
      return DateTime(
        today.year,
        today.month,
        today.day + dayOffset,
        hour,
        minute,
      );
    }

    return <CalendarEvent>[
      CalendarEvent(
        title: 'Onsite consultation',
        description: 'Bring your medical documents and arrive early.',
        startTime: at(0, 9, 0),
        endTime: at(0, 10, 0),
        eventType: EventType.appointment,
        location: 'WAH Clinic',
        doctorName: 'Dr. Santos',
      ),
      CalendarEvent(
        title: 'Medication refill check',
        description: 'Review the remaining supply before the next refill.',
        startTime: at(0, 13, 30),
        endTime: at(0, 14, 0),
        eventType: EventType.medication,
        location: 'Medication Desk',
      ),
      CalendarEvent(
        title: 'Laboratory review',
        description: 'Discuss your latest test results and next steps.',
        startTime: at(1, 16, 0),
        endTime: at(1, 16, 30),
        eventType: EventType.labTest,
        location: 'Lab Records',
      ),
      CalendarEvent(
        title: 'Routine checkup',
        description: 'Follow-up on your wellness metrics and observations.',
        startTime: at(2, 11, 0),
        endTime: at(2, 11, 30),
        eventType: EventType.checkup,
        location: 'Consultation Room',
        doctorName: 'Dr. Reyes',
      ),
      CalendarEvent(
        title: 'Gentle therapy',
        description: 'Stretch and breathing session to relax the body.',
        startTime: at(3, 15, 0),
        endTime: at(3, 15, 45),
        eventType: EventType.therapy,
        location: 'Rehab Hall',
      ),
      CalendarEvent(
        title: 'Follow-up call',
        description: 'Quick update for additional care instructions.',
        startTime: at(-1, 17, 0),
        endTime: at(-1, 17, 20),
        eventType: EventType.other,
        location: 'Phone',
      ),
    ];
  }

  List<CalendarEvent> _filteredEvents() {
    if (_selectedType == null) {
      return _events;
    }

    return _events
        .where((event) => event.eventType == _selectedType)
        .toList();
  }

  List<CalendarEvent> _eventsForDate(DateTime date) {
    final filteredEvents = _filteredEvents();
    return filteredEvents
        .where(
          (event) =>
              event.startTime.year == date.year &&
              event.startTime.month == date.month &&
              event.startTime.day == date.day,
        )
        .toList()
      ..sort((left, right) => left.startTime.compareTo(right.startTime));
  }

  List<CalendarEvent> _eventsForWeek(DateTime date) {
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day - (date.weekday % 7),
    );
    final endOfWeek = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day + 6,
    );
    final filteredEvents = _filteredEvents();

    return filteredEvents
        .where(
          (event) =>
              !event.startTime.isBefore(startOfWeek) &&
              !event.startTime.isAfter(
                endOfWeek.add(const Duration(days: 1)),
              ),
        )
        .toList()
      ..sort((left, right) => left.startTime.compareTo(right.startTime));
  }

  void _showEventDetails(CalendarEvent event) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CalendarEventCardWidget(
              event: event,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _filteredEvents();
    final selectedDayEvents = _eventsForDate(_selectedDate);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          CalendarHeaderWidget(
            selectedDate: _selectedDate,
            currentViewMode: _viewMode,
            onViewModeChanged: (mode) {
              setState(() {
                _viewMode = mode;
              });
            },
            onPreviousMonth: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month - 1,
                  _selectedDate.day,
                );
              });
            },
            onNextMonth: () {
              setState(() {
                _selectedDate = DateTime(
                  _selectedDate.year,
                  _selectedDate.month + 1,
                  _selectedDate.day,
                );
              });
            },
            onTodayPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
          EventTypeFilterWidget(
            selectedType: _selectedType,
            onTypeSelected: (type) {
              setState(() {
                _selectedType = type;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_viewMode) {
              CalendarViewMode.month => MonthViewWidget(
                  selectedDate: _selectedDate,
                  events: filteredEvents,
                  selectedDayEvents: selectedDayEvents,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  onEventTap: _showEventDetails,
                ),
              CalendarViewMode.week => WeekViewWidget(
                  selectedDate: _selectedDate,
                  events: _eventsForWeek(_selectedDate),
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _viewMode = CalendarViewMode.day;
                    });
                  },
                  onEventTap: _showEventDetails,
                ),
              CalendarViewMode.day => DayViewWidget(
                  selectedDate: _selectedDate,
                  events: selectedDayEvents,
                  onEventTap: _showEventDetails,
                ),
            },
          ),
        ],
      ),
    );
  }
}
