import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/onboarding_page_data.dart';
import 'onboarding_background.dart';
import 'onboarding_content.dart';
import 'onboarding_header.dart';
import 'onboarding_navigation.dart';

class OnboardingBaseScreen extends StatefulWidget {
  const OnboardingBaseScreen({
    super.key,
    required this.pageData,
    required this.onSkipPressed,
    required this.onActionPressed,
  });

  final OnboardingPageData pageData;
  final VoidCallback onSkipPressed;
  final VoidCallback onActionPressed;

  @override
  State<OnboardingBaseScreen> createState() => _OnboardingBaseScreenState();
}

class _OnboardingBaseScreenState extends State<OnboardingBaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Duration animationDuration = Duration(milliseconds: 800);
  static const Duration animationDelay = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  void _startAnimations() {
    Future.delayed(animationDelay, () {
      if (!mounted) {
        return;
      }
      _fadeAnimationController.forward();
      _slideAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final horizontalPadding = (screenWidth * 0.06).clamp(20.0, 60.0);
    final verticalPadding = (screenHeight * 0.035).clamp(24.0, 48.0);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Stack(
      children: [
        OnboardingBackground(
          imagePath: widget.pageData.backgroundImagePath,
          backgroundColor: widget.pageData.primaryColor,
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingHeader(
                currentPage: widget.pageData.pageIndex,
                pageCount: widget.pageData.totalPages,
                fadeAnimation: _fadeAnimation,
              ),
              Expanded(
                child: OnboardingContent(
                  title: widget.pageData.title,
                  subtitle: widget.pageData.subtitle,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  fadeAnimation: _fadeAnimation,
                  slideAnimation: _slideAnimation,
                ),
              ),
              OnboardingNavigation(
                actionButtonText: widget.pageData.actionButtonText,
                buttonTextColor: widget.pageData.buttonTextColor,
                onSkipPressed: widget.onSkipPressed,
                onActionPressed: widget.onActionPressed,
                fadeAnimation: _fadeAnimation,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
