import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../auth/data/auth_api_client.dart';
import '../../../auth/data/mpin_local_store.dart';
import '../../../auth/domain/auth_session.dart';
import '../../../auth/domain/models/auth_api_models.dart';
import '../../../auth/presentation/screens/security_verification_screen.dart';
import '../../../auth/presentation/services/security_settings_status_cache_service.dart';
import '../../../auth/presentation/widgets/auth_surface_card.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _isLoadingStatus = true;
  bool _isTotpEnabled = false;
  bool _isMpinConfigured = false;
  bool _isMpinDeviceRegistered = false;
  bool _isDisabling = false;
  bool _isUnregisteringMpin = false;

  @override
  void initState() {
    super.initState();
    _hydrateSecurityStatus();
  }

  void _applySecurityStatus(SecuritySettingsStatusResult status) {
    _isTotpEnabled = status.isTotpEnabled;
    _isMpinConfigured = status.isMpinConfigured;
    _isMpinDeviceRegistered = status.isMpinDeviceRegistered;
  }

  Future<void> _hydrateSecurityStatus() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    final cachedStatus = SecuritySettingsStatusCacheService.getCachedStatus(
      userId: AuthSession.userId ?? '',
    );

    if (cachedStatus != null) {
      _applySecurityStatus(cachedStatus);
      _isLoadingStatus = false;
      unawaited(_refreshSecurityStatus(showLoadingIndicator: false));
      return;
    }

    await _refreshSecurityStatus(showLoadingIndicator: true);
  }

  Future<void> _refreshSecurityStatus({
    required bool showLoadingIndicator,
  }) async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    if (showLoadingIndicator && mounted) {
      setState(() {
        _isLoadingStatus = true;
      });
    }

    final deviceId = await MpinLocalStore.readOrCreateDeviceId();

    try {
      final status = await AuthApiClient.instance.getSecuritySettingsStatus(
        accessToken: accessToken,
        deviceId: deviceId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _applySecurityStatus(status);
        _isLoadingStatus = false;
      });
      SecuritySettingsStatusCacheService.cacheStatus(
        userId: AuthSession.userId ?? '',
        status: status,
      );
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted && showLoadingIndicator) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  Future<void> _openSetupFlow() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    await Navigator.of(context).pushNamed(AppRoutes.totpSetup);
    if (mounted) {
      await _refreshSecurityStatus(showLoadingIndicator: false);
    }
  }

  Future<void> _openMpinSetup() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    String token = '';
    if (_isMpinConfigured) {
      token = await _requestSecurityVerificationToken(
        'changing your MPIN',
        preferredMethod: _isTotpEnabled
            ? SecurityVerificationMethod.authenticator
            : SecurityVerificationMethod.emailOtp,
      );
      if (!mounted || token.isEmpty) {
        return;
      }
    }

    await Navigator.of(context).pushNamed(
      AppRoutes.mpinSetup,
      arguments: MpinSetupArguments(
        securityVerificationToken: token.isEmpty ? null : token,
      ),
    );
    if (mounted) {
      await _refreshSecurityStatus(showLoadingIndicator: false);
    }
  }

  Future<bool> _confirmUnregisterMpin() async {
    return (await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Unregister MPIN device?'),
              content: const Text(
                'This will remove the current device binding and sign you out immediately. Your MPIN will stay on this account for future use.',
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              actions: [
                SecondaryButtonWidget(
                  text: 'Cancel',
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                ),
                const SizedBox(width: 12),
                SecondaryButtonWidget(
                  text: 'Unregister',
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  textColor: AppColors.danger,
                  icon: Icons.logout_outlined,
                ),
              ],
            );
          },
        )) ??
        false;
  }

  Future<void> _unregisterMpinDevice() async {
    if (_isUnregisteringMpin) return;

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    final shouldContinue = await _confirmUnregisterMpin();
    if (!mounted || !shouldContinue) {
      return;
    }

    final token = await _requestSecurityVerificationToken(
      'unregistering the MPIN device',
      preferredMethod: _isTotpEnabled
          ? SecurityVerificationMethod.authenticator
          : SecurityVerificationMethod.emailOtp,
    );
    if (!mounted || token.isEmpty) {
      return;
    }

    setState(() {
      _isUnregisteringMpin = true;
    });

    try {
      final response = await AuthApiClient.instance.unregisterMpinDevice(
        accessToken: accessToken,
        securityVerificationToken: token,
      );

      AuthSession.clear();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isUnregisteringMpin = false;
        });
      }
    }
  }

  Future<void> _disable2fa() async {
    if (_isDisabling) return;
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      _goToLogin();
      return;
    }

    final token = await _requestSecurityVerificationToken(
      'disabling 2FA',
      preferredMethod: SecurityVerificationMethod.authenticator,
    );
    if (!mounted || token.isEmpty) {
      return;
    }

    setState(() {
      _isDisabling = true;
    });

    try {
      final response = await AuthApiClient.instance.disableTotp(
        accessToken: accessToken,
        securityVerificationToken: token,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
      await _refreshSecurityStatus(showLoadingIndicator: false);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isDisabling = false;
        });
      }
    }
  }

  Future<String> _requestSecurityVerificationToken(
    String purpose, {
    SecurityVerificationMethod? preferredMethod,
  }) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.securityVerify,
      arguments: SecurityVerificationArguments(
        purpose: purpose,
        preferredMethod: preferredMethod,
      ),
    );
    if (result is String) {
      return result.trim();
    }
    return '';
  }

  void _goToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to access security settings.'),
        ),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isTablet = mediaQuery.size.width > 600;
    final horizontalPadding = isTablet ? 32.0 : 16.0;

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
        body: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        splashRadius: 20,
                        tooltip: 'Back',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PageHeader(isTablet: isTablet),
                    const SizedBox(height: 28),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _isLoadingStatus
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 64),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _SectionTitle(
                                    icon: Icons.shield_outlined,
                                    title: 'Authenticator app',
                                  ),
                                  const SizedBox(height: 12),
                                  AuthSurfaceCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Set up Google Authenticator as your second factor for safer sign-ins.',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                height: 1.6,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        PrimaryButtonWidget(
                                          text: _isTotpEnabled
                                              ? 'Disable 2FA'
                                              : 'Set up 2FA',
                                          onPressed: _isTotpEnabled
                                              ? (_isDisabling
                                                    ? null
                                                    : _disable2fa)
                                              : _openSetupFlow,
                                          isLoading: _isDisabling,
                                          icon: _isTotpEnabled
                                              ? Icons.gpp_bad_outlined
                                              : Icons.shield_outlined,
                                          backgroundColor: _isTotpEnabled
                                              ? AppColors.danger
                                              : AppColors.primary,
                                          textColor: _isTotpEnabled
                                              ? AppColors.white
                                              : AppColors.textOnPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Divider(
                                    color: AppColors.border,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 24),
                                  const _SectionTitle(
                                    icon: Icons.pin_outlined,
                                    title: 'App MPIN',
                                  ),
                                  const SizedBox(height: 12),
                                  AuthSurfaceCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          'Use a secure 4-digit MPIN to quickly unlock this app on your device.',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                height: 1.6,
                                              ),
                                        ),
                                        const SizedBox(height: 16),
                                        PrimaryButtonWidget(
                                          text: _isMpinConfigured
                                              ? 'Change MPIN'
                                              : 'Set up MPIN',
                                          onPressed: _openMpinSetup,
                                          icon: Icons.pin,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isMpinConfigured) ...[
                                    const SizedBox(height: 24),
                                    const _SectionTitle(
                                      icon: Icons.devices_outlined,
                                      title: 'Device registration',
                                    ),
                                    const SizedBox(height: 12),
                                    AuthSurfaceCard(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            _isMpinDeviceRegistered
                                                ? 'This device is registered for MPIN unlock. If you move to a new device, sign in there and it will register automatically.'
                                                : 'This device is not currently registered for MPIN unlock. It will register automatically after the next successful sign-in or MPIN setup.',
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  height: 1.6,
                                                ),
                                          ),
                                          const SizedBox(height: 16),
                                          PrimaryButtonWidget(
                                            text: 'Unregister device',
                                            onPressed: _isUnregisteringMpin
                                                ? null
                                                : _unregisterMpinDevice,
                                            isLoading: _isUnregisteringMpin,
                                            icon: Icons.logout_outlined,
                                            iconPosition: IconPosition.leading,
                                            backgroundColor: AppColors.danger,
                                            textColor: AppColors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'Security',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontSize: isTablet ? 36.0 : 30.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Manage your two-factor authentication settings.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
