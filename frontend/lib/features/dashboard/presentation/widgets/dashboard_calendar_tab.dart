import 'package:flutter/material.dart';

import '../../../calendar/presentation/screens/calendar_screen.dart';

class DashboardCalendarTab extends StatefulWidget {
  const DashboardCalendarTab({super.key});

  @override
  State<DashboardCalendarTab> createState() => _DashboardCalendarTabState();
}

class _DashboardCalendarTabState extends State<DashboardCalendarTab> {
  @override
  Widget build(BuildContext context) {
    return const CalendarScreen();
  }
}
