import 'package:fitxp/constants/colors.constants.dart';
import 'package:fitxp/constants/icons.constants.dart';
import 'package:fitxp/enums/health_item.enum.dart';
import 'package:fitxp/models/health_widget_config.model.dart';
import 'package:flutter/material.dart';
import '../models/goal.model.dart';
import '../models/health_data.model.dart';
import '../pages/home/basic_large_widget_item.dart';
import '../pages/home/basic_widget_item.dart';

class HealthWidgetBuilderService {
  BuildContext? context;

  HealthWidgetConfig generateWidgetConfig(Goal goals, HealthData healthData, HealthItem healthItemType){
    switch(healthItemType){
      case HealthItem.proteinIntake:
        return HealthWidgetConfig(
          title: "Protein",
          subtitle: "${(goals.proteinGoal.toDouble() - healthData.getProtein).toStringAsFixed(0)} left",
          displayValue: "${healthData.getProtein.toStringAsFixed(0)}g",
          icon: IconTypes.proteinIcon,
          color: RepresentationColors.proteinColor,
          size: 2,
          goalPercent: healthData.getProtein / goals.proteinGoal.toDouble(),
        );
      case HealthItem.exerciseTime:
        return HealthWidgetConfig(
          title: "Exercise Time",
          subtitle: "${(goals.exerciseMinutesGoal.toDouble() - healthData.getExerciseMinutes).toStringAsFixed(0)} left",
          displayValue: "${healthData.getExerciseMinutes.toStringAsFixed(0)}min",
          icon: IconTypes.exerciseIcon,
          color: RepresentationColors.exerciseColor,
          size: 2,
          goalPercent: healthData.getExerciseMinutes / goals.exerciseMinutesGoal.toDouble(),
        );
      case HealthItem.sleepDuration:
        int totalMinutes = healthData.getSleep.toInt();
        int hours = totalMinutes ~/ 60;
        int minutes = totalMinutes % 60;
        String displayValue = "$hours:${minutes.toString().padLeft(2, '0')} hrs";

        int sleepGoalMinutes = goals.sleepGoal.inMinutes;
        int actualSleepMinutes = healthData.getSleep.toInt();
        int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

        String displayDifference;
        if (differenceMinutes >= 60) {
          int hours = differenceMinutes ~/ 60;
          int minutes = differenceMinutes % 60;
          displayDifference = "$hours:${minutes.toString().padLeft(2, '0')} hrs from goal";
        } else {
          displayDifference = "$differenceMinutes min from goal";
        }
        return HealthWidgetConfig(
          title: "Sleep Duration",
          subtitle: displayDifference,
          displayValue: displayValue,
          icon: IconTypes.sleepDurationIcon,
          color: RepresentationColors.sleepColor,
          size: 2,
          goalPercent: healthData.getSleep / goals.sleepGoal.inMinutes.toDouble(),
        );
      default:
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
      "widget": config.size == 1 ?
        BasicWidgetItem(
          config: config,
        ) :
        BasicLargeWidgetItem(
          config: config,
        )
    };
  }
}
