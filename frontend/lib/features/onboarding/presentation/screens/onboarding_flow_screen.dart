import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/widgets/ui/indicators/page_indicator_widget.dart';
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
  late double _pageProgress;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = _sanitizePageIndex(widget.initialPageIndex);
    _pageProgress = _currentPageIndex.toDouble();
    _pageController = PageController(initialPage: _currentPageIndex);
    _pageController.addListener(_handlePageProgressChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageProgressChanged);
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

  void _handlePageProgressChanged() {
    final page = _pageController.page;
    if (page == null || (_pageProgress - page).abs() < 0.001) {
      return;
    }

    setState(() {
      _pageProgress = page;
    });
  }

  void _goToRegistration() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.registration);
  }

  void _handleSkipPressed() {
    _goToRegistration();
  }

  void _handleActionPressed() {
    final currentPage = OnboardingPageRepository.pages[_currentPageIndex];
    if (currentPage.isLastPage) {
      _goToRegistration();
      return;
    }

    _animateToPage(_currentPageIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    const topPadding = 24.0;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
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
            Positioned(
              top: topPadding,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: PageIndicatorStyles.onboardingWithProgress(
                    pageProgress: _pageProgress,
                    pageCount: OnboardingPageRepository.pages.length,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
