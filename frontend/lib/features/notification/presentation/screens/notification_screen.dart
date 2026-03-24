import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../dashboard/presentation/widgets/dashboard_route_shell.dart';
import '../../../dashboard/presentation/widgets/dashboard_alerts_tab.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardRouteShell(
      currentIndex: 2,
      onDestinationSelected: (index) {
        if (index == 2) {
          return;
        }

        switch (index) {
          case 0:
            Navigator.of(context).pushNamed(AppRoutes.dashboard);
            return;
          case 1:
            Navigator.of(context).pushNamed(AppRoutes.calendar);
            return;
          case 3:
            Navigator.of(context).pushNamed(AppRoutes.profile);
            return;
        }
      },
      child: const DashboardAlertsTab(),
    );
  }
}
