import 'package:fitxp/constants/colors.constants.dart';
import 'package:fitxp/constants/icons.constants.dart';
import 'package:fitxp/enums/health_item.enum.dart';
import 'package:fitxp/models/health_widget_config.model.dart';
import 'package:flutter/material.dart';
import '../models/goal.model.dart';
import '../models/health_data.model.dart';
import '../pages/home/basic_large_widget_item.dart';
import '../pages/home/basic_widget_item.dart';
import 'health_fetcher_service.dart';

typedef HealthConfigGenerator = HealthWidgetConfig Function(Goal goals, HealthData healthData);

class HealthWidgetBuilderService {
  BuildContext? context;
  HealthFetcherService? healthFetcherService;


  final Map<HealthItem, HealthConfigGenerator> _healthConfigGenerators = {
    HealthItem.proteinIntake: (Goal goals, HealthData healthData) {
      String subtitle = healthData.averages ?
        "${(healthData.getProtein.average).toStringAsFixed(0)} avg" :
        "${(goals.proteinGoal - healthData.getProtein.total).toStringAsFixed(0)}g left";
      return HealthWidgetConfig(
        title: "Protein",
        subtitle: subtitle,
        displayValue: "${healthData.getProtein.total.toStringAsFixed(0)}g",
        icon: IconTypes.proteinIcon,
        color: RepresentationColors.proteinColor,
        size: 2,
        goalPercent: healthData.getProtein.total / goals.proteinGoal.toDouble(),
      );
    },
    HealthItem.exerciseTime: (Goal goals, HealthData healthData) {
      String subtitle = healthData.averages ?
        "${(healthData.getExerciseMinutes.average).toStringAsFixed(0)} avg" :
        "${(goals.exerciseMinutesGoal - healthData.getExerciseMinutes.total).toStringAsFixed(0)}min left";
      return HealthWidgetConfig(
        title: "Exercise Time",
        subtitle: subtitle,
        displayValue: "${healthData.getExerciseMinutes.total.toStringAsFixed(0)}min",
        icon: IconTypes.exerciseIcon,
        color: RepresentationColors.exerciseColor,
        size: 2,
        goalPercent: healthData.getExerciseMinutes.total / goals.exerciseMinutesGoal.toDouble(),
      );
    },
    HealthItem.sleepDuration: (Goal goals, HealthData healthData) {
      int totalMinutes = healthData.getSleep.total.toInt();
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;
      String displayValue = "$hours:${minutes.toString().padLeft(2, '0')}hrs";

      int sleepGoalMinutes = goals.sleepGoal.inMinutes;
      int actualSleepMinutes = healthData.getSleep.total.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      String displayDifference;
      if (differenceMinutes >= 60) {
        int hours = differenceMinutes ~/ 60;
        int minutes = differenceMinutes % 60;
        displayDifference = "$hours:${minutes.toString().padLeft(2, '0')}hrs from goal";
      } else {
        displayDifference = "$differenceMinutes min from goal";
      }

      String subtitle = healthData.averages ?
        "${(healthData.getSleep.average).toStringAsFixed(0)} avg" :
        displayDifference;
      return HealthWidgetConfig(
        title: "Sleep Duration",
        subtitle: subtitle,
        displayValue: displayValue,
        icon: IconTypes.sleepDurationIcon,
        color: RepresentationColors.sleepColor,
        size: 2,
        goalPercent: healthData.getSleep.total / goals.sleepGoal.inMinutes.toDouble(),
      );
    },
    HealthItem.weight: (Goal goals, HealthData healthData) {
     String subtitle = healthData.averages ?
        "${(healthData.getOldestWeight - healthData.getOldestWeight).toStringAsFixed(1)}lb difference" :
        "${(goals.weightGoal - healthData.getLatestWeight).toStringAsFixed(1)}lb left";
      return HealthWidgetConfig(
        title: "Weight",
        subtitle: subtitle,
        displayValue: "${healthData.getLatestWeight.toStringAsFixed(1)}lb",
        icon: IconTypes.weightIcon,
        color: RepresentationColors.weightColor,
        size: 2,
        goalPercent: -1,
      );
    },
  };

  HealthWidgetConfig generateWidgetConfig(Goal goals, HealthData healthData, HealthItem healthItemType) {
    if (_healthConfigGenerators.containsKey(healthItemType)) {
      return _healthConfigGenerators[healthItemType]!(goals, healthData);
    } else {
      return HealthWidgetConfig(
        title: "Incorrect type",
        subtitle: "",
        displayValue: "",
        icon: Icons.error,
        color: Colors.red,
        size: 1,
        goalPercent: 0,
      );
    }
  }

  Map<String, dynamic> generateWidget(Goal goals, HealthData healthData, HealthItem healthItemType) {
    final config = generateWidgetConfig(goals, healthData, healthItemType);

    return {
      "size": config.size,
      "widget": config.size == 1
          ? BasicWidgetItem(
              config: config,
            )
          : BasicLargeWidgetItem(
              config: config,
            )
    };
  }
}
