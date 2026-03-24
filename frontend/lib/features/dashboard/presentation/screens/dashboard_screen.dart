import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../domain/dashboard_models.dart';
import '../widgets/dashboard_alerts_tab.dart';
import '../widgets/dashboard_calendar_tab.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/dashboard_service_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  static const List<DashboardServiceCardData>
  _services = <DashboardServiceCardData>[
    DashboardServiceCardData(
      title: 'Health Records',
      description:
          'View medical history, lab results, immunizations, and consultations.',
      icon: Icons.description_outlined,
      accentColor: AppColors.primary,
    ),
    DashboardServiceCardData(
      title: 'Personal Records',
      description:
          'Track BMI, blood pressure, temperature, and medicine intake.',
      icon: Icons.monitor_heart_outlined,
      accentColor: AppColors.secondary,
    ),
    DashboardServiceCardData(
      title: 'Appointments',
      description:
          'Book onsite consultation or teleconsultation from one place.',
      icon: Icons.calendar_month_outlined,
      accentColor: AppColors.tertiary,
    ),
    DashboardServiceCardData(
      title: 'Medication Resupply',
      description: 'Request refills and review your prescription history.',
      icon: Icons.medication_outlined,
      accentColor: AppColors.primaryDark,
    ),
  ];

  static const List<DashboardMetricData> _metrics = <DashboardMetricData>[
    DashboardMetricData(
      label: 'BMI',
      value: '23.5',
      unit: 'kg/m²',
      icon: Icons.monitor_weight_outlined,
      accentColor: AppColors.primary,
      trendPoints: <double>[23.1, 23.2, 23.3, 23.5, 23.4],
    ),
    DashboardMetricData(
      label: 'Blood Pressure',
      value: '120/80',
      unit: 'mmHg',
      icon: Icons.favorite_outline,
      accentColor: AppColors.secondary,
      trendPoints: <double>[119, 120, 121, 120, 120],
    ),
    DashboardMetricData(
      label: 'Temperature',
      value: '36.6',
      unit: '°C',
      icon: Icons.thermostat_outlined,
      accentColor: AppColors.tertiary,
      trendPoints: <double>[36.5, 36.5, 36.6, 36.6, 36.7],
    ),
  ];

  static const List<String> _tips = <String>[
    'Stay hydrated throughout the day to support energy and focus.',
    'Take a short walk or stretch break between screen sessions.',
    'Keep a consistent sleep schedule to support recovery.',
    'Review your medicines and refill early when stock is low.',
  ];

  String _currentTip() {
    final index = DateTime.now().day % _tips.length;
    return _tips[index];
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return HelpModalWidget(
          title: 'Dashboard Help',
          messages: const <String>[
            'Use the four service cards to open the main patient workflows.',
            'The health cards show a quick snapshot of your daily metrics.',
            'The bottom navigation keeps the main app sections one tap away.',
          ],
          icons: const <IconData>[
            Icons.grid_view_outlined,
            Icons.monitor_heart_outlined,
            Icons.navigation_outlined,
          ],
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  void _onServiceTap(DashboardServiceCardData service) {
    switch (service.title) {
      case 'Health Records':
        Navigator.of(context).pushNamed(AppRoutes.healthRecords);
        return;
      case 'Personal Records':
        Navigator.of(context).pushNamed(AppRoutes.personalRecords);
        return;
      case 'Appointments':
        Navigator.of(context).pushNamed(AppRoutes.appointments);
        return;
      case 'Medication Resupply':
        Navigator.of(context).pushNamed(AppRoutes.medicationResupply);
        return;
    }
  }

  Widget _buildHomeTab(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 32 : 20,
        18,
        isTablet ? 32 : 20,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardHeader(userName: 'User', onHelpPressed: _showHelp),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: _services
                .map(
                  (service) => DashboardServiceCard(
                    data: service,
                    onTap: () => _onServiceTap(service),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.tertiary.withValues(alpha: 0.16),
                  AppColors.tertiary.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadii.large,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    size: 28,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Health Tip',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currentTip(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Weekly Health Report',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ..._metrics.map(
            (metric) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DashboardMetricCard(data: metric),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return const DashboardCalendarTab();
  }

  Widget _buildNotificationsTab() {
    return const DashboardAlertsTab();
  }

  Widget _buildProfileTab() {
    return const ProfileScreen(showBackButton: false, wrapWithSafeArea: false);
  }

  void _onBottomNavChanged(int index) {
    if (index == _currentTab) {
      return;
    }

    setState(() {
      _currentTab = index;
    });

    switch (index) {
      case 0:
        return;
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.calendar);
        return;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.notification);
        return;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentTab,
          children: <Widget>[
            _buildHomeTab(isTablet),
            _buildCalendarTab(),
            _buildNotificationsTab(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: DashboardBottomNav(
          currentIndex: _currentTab,
          onChanged: _onBottomNavChanged,
        ),
      ),
    );
  }
}
