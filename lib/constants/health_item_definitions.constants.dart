import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/models/health_widget.model.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../enums/health_item_type.enum.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';

typedef GoalGetter = double Function(Goal goal);
typedef WidgetFactory = HealthWidget Function(
    HealthItem item, Goal goals, int widgetSize);

class HealthItem {
  List<HealthDataType> dataType = [];
  late HealthItemType itemType;
  late String title;
  late String unit;
  late Color color;
  late IconData icon;
  GoalGetter? getGoal;
  WidgetFactory widgetFactory =
      ((item, goals, widgetSize) =>
          HealthWidget(item, goals, widgetSize));
}

class HealthItemDefinitions {
  static HealthItem expendedEnergy = HealthItem()
    ..dataType = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED
    ]
    ..itemType = HealthItemType.expendedEnergy
    ..title = "Expended Energy"
    ..unit = "cal"
    ..color = RepresentationColors.activeCaloriesColor
    ..icon = IconTypes.caloriesIcon
    ..getGoal = (Goal goal) => goal.caloriesOutGoal;

  static HealthItem proteinIntake = HealthItem()
    ..dataType = [HealthDataType.DIETARY_PROTEIN_CONSUMED]
    ..itemType = HealthItemType.proteinIntake
    ..title = "Protein"
    ..unit = "g"
    ..color = RepresentationColors.proteinColor
    ..icon = IconTypes.proteinIcon
    ..getGoal = (Goal goal) => goal.proteinGoal;

  static HealthItem exerciseTime = HealthItem()
    ..dataType = [HealthDataType.EXERCISE_TIME]
    ..itemType = HealthItemType.exerciseTime
    ..title = "Excercise time"
    ..unit = "min"
    ..color = RepresentationColors.exerciseColor
    ..icon = IconTypes.exerciseIcon
    ..getGoal = (Goal goal) => goal.exerciseMinutesGoal;

  static HealthItem sleepDuration = HealthItem()
    ..dataType = [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_REM, HealthDataType.SLEEP_LIGHT, HealthDataType.SLEEP_DEEP]
    ..itemType = HealthItemType.sleepDuration
    ..title = "Sleep"
    ..unit = "hrs"
    ..color = RepresentationColors.sleepColor
    ..icon = IconTypes.sleepDurationIcon
    ..getGoal = ((Goal goal) => goal.sleepGoal.inMinutes.toDouble())
    ..widgetFactory = ((item, goals, widgetSize) =>
        SleepHealthWidget(item, goals, widgetSize));

  static HealthItem activeCalories = HealthItem()
    ..dataType = [HealthDataType.ACTIVE_ENERGY_BURNED]
    ..itemType = HealthItemType.activeCalories
    ..title = "Active Calories"
    ..unit = "cal"
    ..color = RepresentationColors.activeCaloriesColor
    ..icon = IconTypes.activeCaloriesIcon;

  static HealthItem restingCalories = HealthItem()
    ..dataType = [HealthDataType.BASAL_ENERGY_BURNED]
    ..itemType = HealthItemType.restingCalories
    ..title = "Resting Calories"
    ..unit = "cal"
    ..color = RepresentationColors.restingCaloriesColor
    ..icon = IconTypes.caloriesIcon
    ..getGoal = (Goal goal) => goal.caloriesOutGoal;

  static HealthItem dietaryCalories = HealthItem()
    ..dataType = [HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.dietaryCalories
    ..title = "Dietary Calories"
    ..unit = "cal"
    ..color = RepresentationColors.dietaryCaloriesColor
    ..icon = IconTypes.dietaryIcon
    ..getGoal = (Goal goal) => goal.caloriesInGoal;

  static HealthItem netCalories = HealthItem()
    ..itemType = HealthItemType.netCalories
    ..title = "Net Calories"
    ..unit = "cal"
    ..color = RepresentationColors.netCaloriesColor
    ..icon = IconTypes.netCaloriesIcon
    ..getGoal = ((Goal goal) =>  goal.caloriesInGoal - goal.caloriesOutGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        NetCaloriesHealthWidget(item, goals, widgetSize));

  static HealthItem steps = HealthItem()
    ..dataType = [HealthDataType.STEPS]
    ..itemType = HealthItemType.steps
    ..title = "Steps"
    ..unit = " steps"
    ..color = RepresentationColors.stepsColor
    ..icon = IconTypes.stepsIcon
    ..getGoal = ((Goal goal) => goal.stepsGoal);
}
