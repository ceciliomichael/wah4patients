import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../data/auth_api_client.dart';
import '../../data/mpin_local_store.dart';
import '../../domain/auth_session.dart';
import '../../domain/models/auth_api_models.dart';
import '../controllers/mpin_entry_controller.dart';
import '../widgets/auth_surface_card.dart';
import '../widgets/mpin_code_field.dart';

class MpinConfirmScreen extends StatefulWidget {
  const MpinConfirmScreen({super.key, required this.arguments});

  final MpinConfirmArguments arguments;

  @override
  State<MpinConfirmScreen> createState() => _MpinConfirmScreenState();
}

class _MpinConfirmScreenState extends State<MpinConfirmScreen> {
  final MpinEntryController _controller = MpinEntryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveMpin() async {
    if (!_controller.isComplete || _controller.isSubmitting) {
      _controller.setError('Confirm your 4-digit MPIN');
      return;
    }

    final accessToken = AuthSession.accessToken?.trim() ?? '';
    if (accessToken.isEmpty) {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    await _controller.submit((pin) async {
      if (pin != widget.arguments.initialMpin) {
        _controller.clear();
        _controller.setError('MPIN does not match. Try again.');
        return;
      }

      final deviceId = await MpinLocalStore.readOrCreateDeviceId();
      await AuthApiClient.instance.setMpin(
        accessToken: accessToken,
        mpin: pin,
        confirmMpin: pin,
        deviceId: deviceId,
      );
      await MpinLocalStore.setMpinEnabled(true);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MPIN set successfully')));

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.securitySettings,
        (route) => route.settings.name == AppRoutes.dashboard,
      );
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
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                24,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _controller.isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                          ),
                          tooltip: 'Back',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Confirm MPIN',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Re-enter your MPIN to finish setup.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AuthSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Confirm your MPIN',
                              style: AppTextStyles.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            MpinCodeField(
                              value: _controller.value,
                              isEnabled: !_controller.isSubmitting,
                              onChanged: _controller.setValue,
                            ),
                            if (_controller.errorMessage != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _controller.errorMessage!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Spacer(),
                      PrimaryButtonWidget(
                        text: 'Save MPIN',
                        onPressed: _saveMpin,
                        isLoading: _controller.isSubmitting,
                        icon: Icons.check,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
