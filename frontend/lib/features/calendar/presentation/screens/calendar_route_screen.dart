import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../dashboard/presentation/widgets/dashboard_route_shell.dart';
import '../screens/calendar_screen.dart';

class CalendarRouteScreen extends StatelessWidget {
  const CalendarRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardRouteShell(
      currentIndex: 1,
      onDestinationSelected: (index) {
        if (index == 1) {
          return;
        }

        switch (index) {
          case 0:
            Navigator.of(context).pushNamed(AppRoutes.dashboard);
            return;
          case 2:
            Navigator.of(context).pushNamed(AppRoutes.notification);
            return;
          case 3:
            Navigator.of(context).pushNamed(AppRoutes.profile);
            return;
        }
      },
      child: const CalendarScreen(),
    );
  }
}
