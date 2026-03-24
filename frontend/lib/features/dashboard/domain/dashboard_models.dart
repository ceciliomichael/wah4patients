import 'package:flutter/material.dart';

class DashboardServiceCardData {
  const DashboardServiceCardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}

class DashboardMetricData {
  const DashboardMetricData({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accentColor,
    required this.trendPoints,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final List<double> trendPoints;
}

class HubActionData {
  const HubActionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
}
