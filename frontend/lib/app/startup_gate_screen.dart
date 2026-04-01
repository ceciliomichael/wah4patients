import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'app_routes.dart';
import 'app_startup_service.dart';

class StartupGateScreen extends StatefulWidget {
  const StartupGateScreen({super.key});

  @override
  State<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends State<StartupGateScreen> {
  late final Future<AppStartupResult> _startupResultFuture;
  bool _hasScheduledNavigation = false;

  @override
  void initState() {
    super.initState();
    _startupResultFuture = AppStartupService.resolveInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: FutureBuilder<AppStartupResult>(
            future: _startupResultFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return _StartupStatusView(
                  title: 'Starting WAH for Patients',
                  subtitle: 'Checking your session and loading your experience.',
                );
              }

              final startupResult = snapshot.data;
              final initialRoute = startupResult?.initialRoute ??
                  AppStartupResult.login.initialRoute;
              final bool isUnlockRoute =
                  initialRoute == AppRoutes.mpinUnlock;

              if (!_hasScheduledNavigation) {
                _hasScheduledNavigation = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) {
                    return;
                  }

                  Navigator.of(context).pushReplacementNamed(initialRoute);
                });
              }

              return _StartupStatusView(
                title: isUnlockRoute ? 'Unlock your session' : 'Welcome back',
                subtitle: isUnlockRoute
                    ? 'Please enter your MPIN to continue.'
                    : 'Preparing your secure session now.',
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StartupStatusView extends StatelessWidget {
  const _StartupStatusView({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
