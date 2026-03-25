import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../domain/onboarding_page_repository.dart';
import '../widgets/onboarding_base_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.initialPageIndex});

  final int initialPageIndex;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const Duration _pageTransitionDuration = Duration(milliseconds: 450);

  late final PageController _pageController;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = _sanitizePageIndex(widget.initialPageIndex);
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _sanitizePageIndex(int pageIndex) {
    final lastPageIndex = OnboardingPageRepository.pages.length - 1;
    return pageIndex.clamp(0, lastPageIndex);
  }

  Future<void> _animateToPage(int pageIndex) {
    return _pageController.animateToPage(
      pageIndex,
      duration: _pageTransitionDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _handlePageChanged(int pageIndex) {
    if (_currentPageIndex == pageIndex) {
      return;
    }

    setState(() {
      _currentPageIndex = pageIndex;
    });
  }

  void _handleSkipPressed() {
    final currentPage = OnboardingPageRepository.pages[_currentPageIndex];
    if (currentPage.isLastPage) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
      return;
    }

    _animateToPage(OnboardingPageRepository.pages.length - 1);
  }

  void _handleActionPressed() {
    final currentPage = OnboardingPageRepository.pages[_currentPageIndex];
    if (currentPage.isLastPage) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
      return;
    }

    _animateToPage(_currentPageIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: _handlePageChanged,
          itemCount: OnboardingPageRepository.pages.length,
          itemBuilder: (context, index) {
            return OnboardingBaseScreen(
              key: ValueKey<int>(index),
              pageData: OnboardingPageRepository.pages[index],
              onSkipPressed: _handleSkipPressed,
              onActionPressed: _handleActionPressed,
            );
          },
        ),
      ),
    );
  }
}
