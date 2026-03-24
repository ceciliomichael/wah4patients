import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoAnimationController;
  late final AnimationController _textAnimationController;
  late final AnimationController _taglineScaleController;
  late final AnimationController _healthierController;
  late final AnimationController _happierController;
  late final AnimationController _communitiesController;
  late final AnimationController _backgroundAnimationController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _textOpacityAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _taglineScaleAnimation;
  late final Animation<double> _healthierOpacity;
  late final Animation<double> _happierOpacity;
  late final Animation<double> _communitiesOpacity;
  late final Animation<Color?> _backgroundColorAnimation;

  static const Duration splashDuration = Duration(seconds: 5);
  static const Duration logoAnimationDuration = Duration(milliseconds: 1500);
  static const Duration textAnimationDuration = Duration(milliseconds: 1000);
  static const Duration backgroundAnimationDuration = Duration(
    milliseconds: 2000,
  );

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateToOnboarding();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _taglineScaleController.dispose();
    _healthierController.dispose();
    _happierController.dispose();
    _communitiesController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: logoAnimationDuration,
      vsync: this,
    );
    _textAnimationController = AnimationController(
      duration: textAnimationDuration,
      vsync: this,
    );
    _taglineScaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _healthierController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _happierController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _communitiesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _backgroundAnimationController = AnimationController(
      duration: backgroundAnimationDuration,
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _taglineScaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _taglineScaleController, curve: Curves.easeInOut),
    );
    _healthierOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _healthierController, curve: Curves.easeIn),
    );
    _happierOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _happierController, curve: Curves.easeIn),
    );
    _communitiesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _communitiesController, curve: Curves.easeIn),
    );
    _backgroundColorAnimation =
        ColorTween(
          begin: AppColors.primary,
          end: AppColors.primaryDark,
        ).animate(
          CurvedAnimation(
            parent: _backgroundAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  void _startAnimationSequence() {
    _backgroundAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _logoAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _textAnimationController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _taglineScaleController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _healthierController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _happierController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _communitiesController.forward();
      }
    });
  }

  void _navigateToOnboarding() {
    _navigationTimer = Timer(splashDuration, () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding1);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _backgroundColorAnimation,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(color: AppColors.background),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoSection(),
                    const SizedBox(height: 40),
                    _buildTextSection(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoOpacityAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacityAnimation.value,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Image.asset(
              'assets/images/logo/wahforpatients_vertical.png',
              width: 240,
              height: 240,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _textOpacityAnimation,
        _textSlideAnimation,
        _taglineScaleAnimation,
        _healthierOpacity,
        _happierOpacity,
        _communitiesOpacity,
      ]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: Opacity(
            opacity: _textOpacityAnimation.value,
            child: Transform.scale(
              scale: _taglineScaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: _healthierOpacity.value,
                        child: Text(
                          'Healthier,',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Opacity(
                        opacity: _happierOpacity.value,
                        child: Text(
                          'Happier',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 0.1),
                  Opacity(
                    opacity: _communitiesOpacity.value,
                    child: Text(
                      'Communities',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
