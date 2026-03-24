import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/ui/buttons/primary_button_widget.dart';
import '../widgets/auth_brand_logo.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_surface_card.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  void _startRegistration(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.registrationEmail);
  }

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AuthBrandLogo(height: 92),
                      const SizedBox(height: 24),
                      const AuthHeader(
                        title: 'Welcome!',
                        subtitle: 'Let\'s create your account in just 3 simple steps',
                        centerTitle: true,
                      ),
                      const SizedBox(height: 18),
                      AuthSurfaceCard(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            _RegistrationStep(
                              number: '1',
                              title: 'Enter your email',
                              description:
                                  'Use this to verify your identity and secure your account.',
                            ),
                            SizedBox(height: 20),
                            Divider(height: 1, color: AppColors.border),
                            SizedBox(height: 20),
                            _RegistrationStep(
                              number: '2',
                              title: 'Verify your email',
                              description:
                                  'Check your inbox and confirm the 6-digit code sent to you.',
                            ),
                            SizedBox(height: 20),
                            Divider(height: 1, color: AppColors.border),
                            SizedBox(height: 20),
                            _RegistrationStep(
                              number: '3',
                              title: 'Create a password',
                              description:
                                  'Choose a secure password with simple requirements.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButtonWidget(
                        text: 'Start Registration',
                        onPressed: () => _startRegistration(context),
                        icon: Icons.arrow_forward,
                      ),
                      const SizedBox(height: 12),
                      AuthFooterLink(
                        prefixText: 'Already have an account? ',
                        actionText: 'Sign In',
                        onPressed: () => _goToLogin(context),
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

class _RegistrationStep extends StatelessWidget {
  const _RegistrationStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
