import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../domain/auth_session.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/mpin_numeric_keypad.dart';
import '../widgets/mpin_pin_indicator.dart';

class TotpSetupScreen extends StatefulWidget {
  const TotpSetupScreen({super.key, this.allowSkip = false});

  final bool allowSkip;

  @override
  State<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

enum _SetupStage { loading, loadFailed, showQr, showSuccess }

class _TotpSetupScreenState extends State<TotpSetupScreen> {
  final MpinEntryController _verificationController = MpinEntryController(
    requiredLength: 6,
  );

  _SetupStage _stage = _SetupStage.loading;
  bool _isSubmitting = false;
  String _otpauthUrl = '';
  String _manualEntryKey = '';
  String _loadErrorMessage = '';

  void _copyManualKey() {
    Clipboard.setData(ClipboardData(text: _manualEntryKey));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Manual setup key copied.')));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _startSetup();
    });
  }

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  Future<void> _startSetup() async {
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to set up 2FA.')),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    setState(() {
      _stage = _SetupStage.loading;
    });

    try {
      final result = await AuthApiClient.instance.startTotpSetup(
        accessToken: accessToken,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _otpauthUrl = result.otpauthUrl;
        _manualEntryKey = result.manualEntryKey;
        _stage = _SetupStage.showQr;
      });
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadErrorMessage = error.message;
        _stage = _SetupStage.loadFailed;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }

      const fallbackMessage =
          'Unable to start authenticator setup right now. Please try again.';
      setState(() {
        _loadErrorMessage = fallbackMessage;
        _stage = _SetupStage.loadFailed;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(fallbackMessage)));
    }
  }

  Future<void> _verifyCode() async {
    if (!_verificationController.isComplete || _isSubmitting) {
      return;
    }

    final code = _verificationController.value.trim();
    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please sign in again.')),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await AuthApiClient.instance.verifyTotpSetup(
        accessToken: accessToken,
        code: code,
      );

      if (!mounted) {
        return;
      }

      if (widget.allowSkip) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
        return;
      }

      setState(() {
        _stage = _SetupStage.showSuccess;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }

      _verificationController.clear();
      _verificationController.setError(error.message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onDigitTap(String digit) {
    if (_isSubmitting || _verificationController.isLocked) {
      return;
    }

    _verificationController.appendDigit(digit);
    if (_verificationController.isComplete) {
      _verifyCode();
    }
  }

  void _onDeleteTap() {
    _verificationController.removeLastDigit();
  }

  void _leaveSetupFlow() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }

  void _skipSetup() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 720 ? 32.0 : 16.0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return AnimatedBuilder(
      animation: _verificationController,
      builder: (context, _) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                onPressed: _leaveSetupFlow,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                tooltip: 'Back',
              ),
              title: Text(
                'Set Up Authenticator',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_stage) {
      case _SetupStage.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator()),
        );
      case _SetupStage.loadFailed:
        return AuthSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Could not start 2FA setup',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadErrorMessage,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButtonWidget(
                text: 'Try again',
                onPressed: _startSetup,
                icon: Icons.refresh,
              ),
              const SizedBox(height: 8),
              Center(
                child: SecondaryButtonWidget(
                  text: 'Back',
                  onPressed: _leaveSetupFlow,
                ),
              ),
            ],
          ),
        );
      case _SetupStage.showQr:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '1. Scan QR in Google Authenticator',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Open Google Authenticator, tap +, then scan this code.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.all(16),
                      child: QrImageView(
                        data: _otpauthUrl,
                        version: QrVersions.auto,
                        size: 260,
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Manual entry key',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _manualEntryKey,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SecondaryButtonWidget(
                      text: 'Copy setup key',
                      onPressed: _copyManualKey,
                      icon: Icons.copy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If scanning fails, add manually in Google Authenticator with account name as your email and key type set to Time-based.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AuthSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '2. Verify 6-digit code',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MpinPinIndicator(
                    filledCount: _verificationController.value.length,
                    length: 6,
                    isError: _verificationController.errorMessage != null,
                    showDigits: true,
                    displayValue: _verificationController.value,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: MpinNumericKeypad(
                        isEnabled: !_isSubmitting,
                        showBiometricButton: false,
                        onDigitTap: _onDigitTap,
                        onDeleteTap: _onDeleteTap,
                      ),
                    ),
                  ),
                  if (_verificationController.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _verificationController.errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButtonWidget(
                    text: 'Enable 2FA',
                    onPressed: _isSubmitting ? null : _verifyCode,
                    isLoading: _isSubmitting,
                    icon: Icons.verified_outlined,
                  ),
                  if (widget.allowSkip) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: SecondaryButtonWidget(
                        text: 'Skip for now',
                        onPressed: _skipSetup,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      case _SetupStage.showSuccess:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: AppColors.success,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2FA Enabled',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your authenticator app is now linked to this account.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButtonWidget(
              text: 'Back to Security',
              onPressed: _leaveSetupFlow,
              icon: Icons.arrow_forward,
            ),
            const SizedBox(height: 8),
            Center(
              child: SecondaryButtonWidget(
                text: 'Close',
                onPressed: _leaveSetupFlow,
              ),
            ),
          ],
        );
    }
  }
}
