import 'package:flutter/material.dart';

import '../core/widgets/feature/app_notification_host.dart';
import '../core/constants/app_border_radii.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'app_lock_state_service.dart';
import 'app_notification_center.dart';
import '../features/auth/data/auth_api_client.dart';
import '../features/auth/data/mpin_local_store.dart';
import '../features/auth/domain/auth_session.dart';
import '../features/auth/presentation/services/security_settings_status_cache_service.dart';
import 'app_router.dart';
import 'app_routes.dart';
import 'startup_gate_screen.dart';

class WAH4PApp extends StatefulWidget {
  const WAH4PApp({super.key});

  @override
  State<WAH4PApp> createState() => _WAH4PAppState();
}

class _WAH4PAppState extends State<WAH4PApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final _RouteTrackerObserver _routeTrackerObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _routeTrackerObserver = _RouteTrackerObserver();
    AuthSession.notifier.addListener(_handleSessionStateChange);
    AppLockStateService.notifier.addListener(_handleLockStateChange);
  }

  @override
  void dispose() {
    AuthSession.notifier.removeListener(_handleSessionStateChange);
    AppLockStateService.notifier.removeListener(_handleLockStateChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _handleSessionStateChange() {
    _syncRouteWithSessionAndLockState();
  }

  void _handleLockStateChange() {
    _syncRouteWithSessionAndLockState();
  }

  Future<void> _syncRouteWithSessionAndLockState() async {
    final currentRoute = _routeTrackerObserver.currentRoute;
    if (_isPublicRoute(currentRoute) || currentRoute == AppRoutes.mpinUnlock) {
      return;
    }

    await AuthSession.restoreFromStorage();
    if (!AuthSession.isAuthenticated) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null || !mounted) {
        return;
      }

      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    try {
      final deviceId = await MpinLocalStore.readOrCreateDeviceId();
      final accessToken = AuthSession.accessToken?.trim() ?? '';
      final status = await AuthApiClient.instance.getSecuritySettingsStatus(
        accessToken: accessToken,
        deviceId: deviceId,
      );
      SecuritySettingsStatusCacheService.cacheStatus(
        userId: AuthSession.userId ?? '',
        status: status,
      );

      await MpinLocalStore.setMpinEnabled(
        status.isMpinConfigured && status.isMpinDeviceRegistered,
      );
    } on AuthApiException {
      // Keep the local device state as the fallback when security status cannot be resolved.
    }

    final isMpinEnabled = await MpinLocalStore.isMpinEnabled();
    if (!isMpinEnabled || !AppLockStateService.shouldRequireUnlockOnResume()) {
      return;
    }

    final navigator = _navigatorKey.currentState;
    if (navigator == null || !mounted) {
      return;
    }

    if (_routeTrackerObserver.currentRoute == AppRoutes.mpinUnlock) {
      return;
    }

    navigator.pushNamedAndRemoveUntil(AppRoutes.mpinUnlock, (route) => false);
  }

  bool _isPublicRoute(String? routeName) {
    switch (routeName) {
      case AppRoutes.splash:
      case AppRoutes.onboarding1:
      case AppRoutes.onboarding2:
      case AppRoutes.onboarding3:
      case AppRoutes.onboarding4:
      case AppRoutes.onboardingComplete:
      case AppRoutes.registration:
      case AppRoutes.registrationEmail:
      case AppRoutes.registrationVerification:
      case AppRoutes.registrationDetails:
      case AppRoutes.registrationPassword:
      case AppRoutes.login:
      case AppRoutes.forgotPassword:
      case AppRoutes.authPreview:
        return true;
      default:
        return false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AppLockStateService.markBackgrounded();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      AppLockStateService.markForegrounded();
      _syncRouteWithSessionAndLockState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      fontFamily: 'Open Sans',
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.large),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.extraLarge),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.topRounded),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.large),
        ),
      ),
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ).copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            tertiary: AppColors.tertiary,
            surface: AppColors.surface,
            onPrimary: AppColors.textOnPrimary,
            onSecondary: AppColors.textOnSecondary,
            onSurface: AppColors.textPrimary,
          ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );

    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_routeTrackerObserver],
      title: 'WAH for Patients',
      debugShowCheckedModeBanner: false,
      theme: theme,
      initialRoute: AppRoutes.splash,
      builder: (context, child) {
        final appContent = Stack(
          fit: StackFit.expand,
          children: [
            if (child != null) child,
            AppNotificationHost(controller: AppNotificationCenter.instance),
          ],
        );

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => AppLockStateService.registerActivity(),
          onPointerMove: (_) => AppLockStateService.registerActivity(),
          onPointerSignal: (_) => AppLockStateService.registerActivity(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification ||
                  notification is ScrollUpdateNotification ||
                  notification is UserScrollNotification) {
                AppLockStateService.registerActivity();
              }
              return false;
            },
            child: appContent,
          ),
        );
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.splash) {
          return _buildStartupRoute(settings);
        }

        return buildAppRoute(settings);
      },
    );
  }

  Route<dynamic> _buildStartupRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => const StartupGateScreen(),
    );
  }
}

class _RouteTrackerObserver extends NavigatorObserver {
  String? currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = route.settings.name;
    AppLockStateService.registerActivity();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute = previousRoute?.settings.name;
    AppLockStateService.registerActivity();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRoute = newRoute?.settings.name;
    AppLockStateService.registerActivity();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
