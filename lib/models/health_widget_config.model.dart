import 'package:fitxp/pages/home/basic_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:fitxp/models/goal.model.dart';
import 'package:fitxp/models/health_data.model.dart';
import 'package:fitxp/pages/home/basic_large_widget_item.dart';

class HealthWidgetConfig {
  final String Function(BuildContext) title;
  final String Function(BuildContext, Goal goals, HealthData healthData) subtitle;
  final String Function(BuildContext) unit;
  final IconData icon;
  final Color color;
  final int size;
  final double Function(Goal goals) goalValue;
  final double Function(HealthData healthData) currentValue;

  HealthWidgetConfig({
    required this.title,
    required this.subtitle,
    required this.unit,
    required this.icon,
    required this.color,
    required this.size,
    required this.goalValue,
    required this.currentValue,
  });

  Map<String, dynamic> generateWidget(BuildContext context, Goal goals, HealthData healthData) {
    double current = currentValue(healthData);
    double goal = goalValue(goals);
    double percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0; // Avoid division by zero

    return {
      "size": size,
      "widget": size == 1 ?
        BasicWidgetItem(
          title: title(context),
          value: "${current.toStringAsFixed(0)} ${unit(context)}",
        ) :
        BasicLargeWidgetItem(
          title: title(context),
          subTitle: subtitle(context, goals, healthData),
          value: "${current.toStringAsFixed(0)} ${unit(context)}",
          icon: icon,
          percent: percent,
          color: color,
        )
    };
  }
}
