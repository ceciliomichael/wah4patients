import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../dashboard/presentation/widgets/dashboard_route_shell.dart';
import 'profile_screen.dart';

class ProfileRouteScreen extends StatelessWidget {
  const ProfileRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardRouteShell(
      currentIndex: 3,
      onDestinationSelected: (index) {
        if (index == 3) {
          return;
        }

        switch (index) {
          case 0:
            Navigator.of(context).pushNamed(AppRoutes.dashboard);
            return;
          case 1:
            Navigator.of(context).pushNamed(AppRoutes.calendar);
            return;
          case 2:
            Navigator.of(context).pushNamed(AppRoutes.notification);
            return;
        }
      },
      child: const ProfileScreen(
        showBackButton: false,
        wrapWithSafeArea: false,
        centerContent: true,
      ),
    );
  }
}
