import 'package:flutter/material.dart';
import 'package:healthxp/models/data_point.model.dart';

class HealthWidgetConfig {
  final String title;
  final String subtitle;
  final String displayValue;
  final IconData icon;
  final Color color;
  final int size;
  final double goalPercent;
  late List<DataPoint> data;

  HealthWidgetConfig({
    required this.title,
    required this.subtitle,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.size,
    required this.goalPercent,
  });

  double get goalPercentClamped => goalPercent.clamp(0.0, 1.0);
}
