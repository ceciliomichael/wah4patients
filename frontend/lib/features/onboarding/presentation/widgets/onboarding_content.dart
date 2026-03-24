import 'package:flutter/material.dart';

import '../../../../core/constants/app_text_styles.dart';

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.screenWidth,
    required this.screenHeight,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  final String title;
  final String subtitle;
  final double screenWidth;
  final double screenHeight;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    final titleSubtitleSpacing = (screenHeight * 0.025).clamp(16.0, 32.0);
    final bottomSpacing = (screenHeight * 0.05).clamp(32.0, 64.0);

    return AnimatedBuilder(
      animation: Listenable.merge([fadeAnimation, slideAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: slideAnimation,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(flex: 2),
                _buildTitle(),
                SizedBox(height: titleSubtitleSpacing),
                _buildSubtitle(),
                SizedBox(height: bottomSpacing),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    final titleFontSize = (screenWidth * 0.078).clamp(28.0, 42.0);
    final titleHorizontalPadding = (screenWidth * 0.08).clamp(24.0, 80.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: titleHorizontalPadding),
      child: Text(
        title,
        style: AppTextStyles.onboardingHeader.copyWith(
          fontSize: titleFontSize,
          shadows: [
            Shadow(
              offset: const Offset(0, 2),
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    final subtitleFontSize = (screenWidth * 0.042).clamp(14.0, 20.0);
    final subtitleHorizontalPadding = (screenWidth * 0.12).clamp(32.0, 100.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: subtitleHorizontalPadding),
      child: Text(
        subtitle,
        style: AppTextStyles.onboardingSubtext.copyWith(
          fontSize: subtitleFontSize,
          color: Colors.white.withValues(alpha: 0.9),
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 6,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
