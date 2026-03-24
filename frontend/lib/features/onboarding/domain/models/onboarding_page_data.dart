import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.backgroundImagePath,
    required this.primaryColor,
    required this.buttonTextColor,
    required this.pageIndex,
    required this.totalPages,
    required this.actionButtonText,
    this.isLastPage = false,
  });

  final String title;
  final String subtitle;
  final String backgroundImagePath;
  final Color primaryColor;
  final Color buttonTextColor;
  final int pageIndex;
  final int totalPages;
  final String actionButtonText;
  final bool isLastPage;
}
