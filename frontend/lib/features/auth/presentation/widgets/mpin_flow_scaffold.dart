import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_border_radii.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MpinFlowScaffold extends StatelessWidget {
  const MpinFlowScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.surfaceTitle,
    required this.surfaceSubtitle,
    required this.content,
    this.primaryAction,
    this.secondaryAction,
    this.heroIcon = Icons.lock_outline,
    this.onBackPressed,
    this.backTooltip = 'Back',
  });

  final String title;
  final String subtitle;
  final String surfaceTitle;
  final String surfaceSubtitle;
  final Widget content;
  final Widget? primaryAction;
  final Widget? secondaryAction;
  final IconData heroIcon;
  final VoidCallback? onBackPressed;
  final String backTooltip;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              final bool isCompactHeight = constraints.maxHeight < 840;
              final double horizontalPadding = isTablet ? 32.0 : 16.0;
              final double surfaceMaxWidth = math.min(
                isTablet ? 420.0 : 392.0,
                constraints.maxWidth - horizontalPadding * 2,
              );
              final double surfacePadding = isTablet
                  ? 24.0
                  : (isCompactHeight ? 16.0 : 24.0);
              final double contentTopGap = isCompactHeight ? 12.0 : 24.0;
              final double cardInnerGap = isCompactHeight ? 10.0 : 18.0;
              final double footerBottomPadding = isTablet ? 24.0 : 20.0;
              final double secondaryFooterBottomPadding = isTablet
                  ? 24.0
                  : 16.0;

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.96),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -72,
                      right: -36,
                      child: _MpinGlow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        size: 168,
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -48,
                      child: _MpinGlow(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        size: 184,
                      ),
                    ),
                    Column(
                      children: [
                        if (onBackPressed != null)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              isTablet ? 24 : 20,
                              horizontalPadding,
                              0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _MpinBackButton(
                                onPressed: onBackPressed!,
                                tooltip: backTooltip,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              contentTopGap,
                              horizontalPadding,
                              footerBottomPadding,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 760,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.topCenter,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: surfaceMaxWidth,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _MpinHero(
                                                  title: title,
                                                  subtitle: subtitle,
                                                  icon: heroIcon,
                                                  compact: isCompactHeight,
                                                ),
                                                SizedBox(height: contentTopGap),
                                                Container(
                                                  padding: EdgeInsets.all(
                                                    surfacePadding,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surface
                                                        .withValues(
                                                          alpha: 0.98,
                                                        ),
                                                    borderRadius:
                                                        AppRadii.extraLarge,
                                                    border: Border.all(
                                                      color: AppColors.border,
                                                      width: 1,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.black
                                                            .withValues(
                                                              alpha: 0.04,
                                                            ),
                                                        blurRadius: 28,
                                                        offset: const Offset(
                                                          0,
                                                          10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Text(
                                                        surfaceTitle,
                                                        style: AppTextStyles
                                                            .titleLarge
                                                            .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      if (surfaceSubtitle
                                                          .trim()
                                                          .isNotEmpty) ...[
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          surfaceSubtitle,
                                                          style: AppTextStyles
                                                              .bodyMedium
                                                              .copyWith(
                                                                color: AppColors
                                                                    .textSecondary,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                      SizedBox(
                                                        height: cardInnerGap,
                                                      ),
                                                      content,
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (primaryAction != null ||
                                        secondaryAction != null) ...[
                                      SizedBox(height: contentTopGap),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: surfaceMaxWidth,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (primaryAction != null)
                                              primaryAction!,
                                            if (primaryAction != null &&
                                                secondaryAction != null)
                                              const SizedBox(height: 12),
                                            if (secondaryAction != null)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      secondaryFooterBottomPadding,
                                                ),
                                                child: Center(
                                                  child: secondaryAction!,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MpinHero extends StatelessWidget {
  const _MpinHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.compact,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double heroIconSize = compact ? 56.0 : 72.0;
    final double heroIconGlyphSize = compact ? 28.0 : 36.0;
    final double titleFontSize = compact ? 22.0 : 24.0;

    return Column(
      children: [
        Container(
          width: heroIconSize,
          height: heroIconSize,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadii.extraLarge,
          ),
          child: Icon(icon, size: heroIconGlyphSize, color: AppColors.primary),
        ),
        SizedBox(height: compact ? 10 : 16),
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: titleFontSize,
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compact ? 4 : 8),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MpinBackButton extends StatelessWidget {
  const _MpinBackButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.medium,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: RoundedRectangleBorder(borderRadius: AppRadii.medium),
        splashColor: AppColors.black.withValues(alpha: 0.08),
        highlightColor: AppColors.black.withValues(alpha: 0.04),
        child: Tooltip(
          message: tooltip,
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                Icons.arrow_back,
                size: 22,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MpinGlow extends StatelessWidget {
  const _MpinGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
