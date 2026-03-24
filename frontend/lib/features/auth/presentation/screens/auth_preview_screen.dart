import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/secondary_button_widget.dart';
import '../../../../core/widgets/ui/buttons/tertiary_button_widget.dart';
import '../widgets/auth_brand_logo.dart';
import '../widgets/auth_surface_card.dart';

class AuthPreviewScreen extends StatelessWidget {
  const AuthPreviewScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _restart(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
  }

  void _openDashboard(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 48.0 : 24.0;

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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: 32,
                bottom: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 64,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthBrandLogo(height: 92),
                      const SizedBox(height: 24),
                      Text(
                        'Preview mode ready',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'The auth flow is now frontend-only and ready for future wiring.',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: AuthSurfaceCard(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 56,
                                  color: AppColors.secondary,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'This is a local UI preview.',
                                  style: AppTextStyles.titleLarge,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No Supabase or backend logic is connected yet.',
                                  style: AppTextStyles.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButtonWidget(
                        text: 'Open Dashboard',
                        onPressed: () => _openDashboard(context),
                        icon: Icons.home_outlined,
                      ),
                      const SizedBox(height: 12),
                      TertiaryButtonWidget(
                        text: 'Back to Sign In',
                        onPressed: () => _goToLogin(context),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: SecondaryButtonWidget(
                          text: 'Back to Splash',
                          onPressed: () => _restart(context),
                          textColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
