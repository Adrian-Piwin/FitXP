import 'package:flutter/material.dart';

class HealthWidgetConfig {
  final String title;
  final String subtitle;
  final String displayValue;
  final IconData icon;
  final Color color;
  final int size;
  final double goalPercent;

  HealthWidgetConfig({
    required this.title,
    required this.subtitle,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.size,
    required this.goalPercent,
  });
}
