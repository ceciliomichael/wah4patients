import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'dashboard_bottom_nav.dart';

class DashboardRouteShell extends StatelessWidget {
  const DashboardRouteShell({
    super.key,
    required this.currentIndex,
    required this.child,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final Widget child;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            Expanded(child: child),
            DashboardBottomNav(
              currentIndex: currentIndex,
              onChanged: onDestinationSelected,
            ),
          ],
        ),
      ),
    );
  }
}
