import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/feature/help_modal_widget.dart';
import '../../../auth/data/auth_local_store.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../phr/data/personal_records_api_client.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/widgets/profile_completion_prompt_dialog.dart';
import '../../data/weekly_health_report_repository.dart';
import '../../domain/dashboard_models.dart';
import '../../domain/weekly_health_report_calculator.dart';
import '../widgets/dashboard_alerts_tab.dart';
import '../widgets/dashboard_calendar_tab.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/dashboard_service_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    WeeklyHealthReportRepository? weeklyHealthReportRepository,
  }) : _weeklyHealthReportRepository = weeklyHealthReportRepository;

  final WeeklyHealthReportRepository? _weeklyHealthReportRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;
  bool _profilePromptChecked = false;
  bool _profilePromptVisible = false;
  late final WeeklyHealthReportRepository _weeklyHealthReportRepository =
      widget._weeklyHealthReportRepository ?? WeeklyHealthReportRepository();
  List<DashboardMetricData> _healthReportMetrics = _buildHealthReportMetrics(
    WeeklyHealthReport.empty(),
  );
  String? _loadedHealthReportToken;

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

  static List<DashboardMetricData> _buildHealthReportMetrics(
    WeeklyHealthReport report,
  ) {
    return <DashboardMetricData>[
      DashboardMetricData(
        label: 'BMI',
        value: report.bmi.value,
        unit: report.bmi.unit,
        icon: Icons.monitor_weight_outlined,
        accentColor: AppColors.primary,
        hasData: report.bmi.hasData,
        entryCount: report.bmi.entryCount,
      ),
      DashboardMetricData(
        label: 'Blood Pressure',
        value: report.bloodPressure.value,
        unit: report.bloodPressure.unit,
        icon: Icons.favorite_outline,
        accentColor: AppColors.secondary,
        hasData: report.bloodPressure.hasData,
        entryCount: report.bloodPressure.entryCount,
      ),
      DashboardMetricData(
        label: 'Temperature',
        value: report.temperature.value,
        unit: report.temperature.unit,
        icon: Icons.thermostat_outlined,
        accentColor: AppColors.tertiary,
        hasData: report.temperature.hasData,
        entryCount: report.temperature.entryCount,
      ),
    ];
  }

  String? _metricRouteForLabel(String label) {
    return switch (label) {
      'BMI' => AppRoutes.bodyMassIndex,
      'Blood Pressure' => AppRoutes.bloodPressure,
      'Temperature' => AppRoutes.temperature,
      _ => null,
    };
  }

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

  @override
  void initState() {
    super.initState();
    AuthSession.notifier.addListener(_syncWeeklyHealthReportWithSession);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncWeeklyHealthReportWithSession();
      _maybeShowProfileCompletionPrompt();
    });
  }

  @override
  void dispose() {
    AuthSession.notifier.removeListener(_syncWeeklyHealthReportWithSession);
    super.dispose();
  }

  void _syncWeeklyHealthReportWithSession() {
    final token = AuthSession.accessToken?.trim() ?? '';
    if (_loadedHealthReportToken == token) {
      return;
    }

    _loadWeeklyHealthReport(token);
  }

  Future<void> _loadWeeklyHealthReport(String accessToken) async {
    _loadedHealthReportToken = accessToken;

    if (accessToken.isEmpty) {
      _applyHealthReportIfCurrent(accessToken, WeeklyHealthReport.empty());
      return;
    }

    try {
      final report = await _weeklyHealthReportRepository.loadWeeklyHealthReport(
        accessToken: accessToken,
      );
      _applyHealthReportIfCurrent(accessToken, report);
    } on PersonalRecordsApiException {
      _applyHealthReportIfCurrent(accessToken, WeeklyHealthReport.empty());
    } on FormatException {
      _applyHealthReportIfCurrent(accessToken, WeeklyHealthReport.empty());
    } on Object {
      _applyHealthReportIfCurrent(accessToken, WeeklyHealthReport.empty());
    }
  }

  void _applyHealthReportIfCurrent(
    String accessToken,
    WeeklyHealthReport report,
  ) {
    if (!mounted || _loadedHealthReportToken != accessToken) {
      return;
    }

    setState(() {
      _healthReportMetrics = _buildHealthReportMetrics(report);
    });
  }

  Future<void> _maybeShowProfileCompletionPrompt() async {
    if (_profilePromptChecked || !mounted) {
      return;
    }

    _profilePromptChecked = true;
    final dismissed = await AuthLocalStore.isProfileCompletionPromptDismissed();
    if (!mounted || dismissed || AuthSession.isPatientProfileComplete) {
      return;
    }

    _profilePromptVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return ProfileCompletionPromptDialog(
          onCompleteProfile: () {
            unawaited(AuthLocalStore.setProfileCompletionPromptDismissed(true));
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pushNamed(AppRoutes.personalInformation);
          },
          onSkipForNow: () async {
            final navigator = Navigator.of(dialogContext);
            await AuthLocalStore.setProfileCompletionPromptDismissed(true);
            if (navigator.canPop()) {
              navigator.pop();
            }
          },
          onClose: () {
            unawaited(AuthLocalStore.setProfileCompletionPromptDismissed(true));
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );

    if (mounted) {
      _profilePromptVisible = false;
    }
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
    return ValueListenableBuilder<int>(
      valueListenable: AuthSession.notifier,
      builder: (context, _, __) {
        if (!_profilePromptChecked && !_profilePromptVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeShowProfileCompletionPrompt();
          });
        }

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
              DashboardHeader(
                displayName: AuthSession.greetingName,
                onHelpPressed: _showHelp,
              ),
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
              ..._healthReportMetrics.map(
                (metric) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DashboardMetricCard(
                    data: metric,
                    onTap: () {
                      final routeName = _metricRouteForLabel(metric.label);
                      if (routeName == null) {
                        return;
                      }

                      Navigator.of(context).pushNamed(routeName);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return const DashboardCalendarTab();
  }

  Widget _buildNotificationsTab() {
    return const DashboardAlertsTab();
  }

  Widget _buildProfileTab() {
    return ValueListenableBuilder<int>(
      valueListenable: AuthSession.notifier,
      builder: (context, _, __) {
        return const ProfileScreen(
          showBackButton: false,
          wrapWithSafeArea: false,
        );
      },
    );
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
