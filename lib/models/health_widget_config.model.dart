import 'package:fitxp/models/health_data.model.dart';
import 'package:flutter/material.dart';
import 'package:fitxp/models/goal.model.dart';

class HealthWidgetConfig {
  final String Function(BuildContext) title;
  final String Function(BuildContext) unit;
  final IconData icon;
  final Color color;
  final double Function(Goal goals) goalValue;
  final double Function(HealthData healthData) currentValue;

  HealthWidgetConfig({
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.goalValue,
    required this.currentValue,
  });
}
