import 'package:healthxp/enums/xp_type.enum.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/models/health_entities/bodyfat_health_entity.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/health_entities/sleep_health_entity.model.dart';
import 'package:healthxp/models/health_entities/netcalories_health_entity.model.dart';
import 'package:healthxp/models/health_entities/weight_health_entity.model.dart';
import '../enums/health_item_type.enum.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';

typedef GoalGetter = double Function(Goal goal);
typedef WidgetFactory = HealthEntity Function(
    HealthItem item, Goal goals, int widgetSize);

class HealthItem {
  List<HealthDataType> dataType = [];
  late HealthItemType itemType;
  late String title;
  late String unit;
  late Color color;
  late IconData icon;
  XPType? xpType;
  GoalGetter? getGoal;
  WidgetFactory widgetFactory =
      ((item, goals, widgetSize) =>
          HealthEntity(item, goals, widgetSize));
}

class HealthItemDefinitions {
  static HealthItem expendedEnergy = HealthItem()
    ..dataType = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED
    ]
    ..itemType = HealthItemType.expendedEnergy
    ..title = "Expended Energy"
    ..unit = ""
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
    ..xpType = XPType.hitProteinGoal
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
    ..dataType = [HealthDataType.SLEEP_ASLEEP]
    ..itemType = HealthItemType.sleep
    ..title = "Sleep"
    ..unit = "hrs"
    ..color = RepresentationColors.sleepColor
    ..icon = IconTypes.sleepDurationIcon
    ..xpType = XPType.hitSleepGoal
    ..getGoal = ((Goal goal) => goal.sleepGoal.inMinutes.toDouble())
    ..widgetFactory = ((item, goals, widgetSize) =>
        SleepHealthEntity(item, goals, widgetSize));

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
    ..unit = ""
    ..color = RepresentationColors.dietaryCaloriesColor
    ..icon = IconTypes.dietaryIcon
    ..getGoal = (Goal goal) => goal.caloriesInGoal;

  static HealthItem netCalories = HealthItem()
    ..dataType = [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED, HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.netCalories
    ..title = "Net Calories"
    ..unit = ""
    ..color = RepresentationColors.netCaloriesColor
    ..icon = IconTypes.netCaloriesIcon
    ..xpType = XPType.hitNetCaloriesGoal
    ..getGoal = ((Goal goal) =>  goal.caloriesInGoal - goal.caloriesOutGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        NetCaloriesHealthEntity(item, goals, widgetSize));

  static HealthItem steps = HealthItem()
    ..dataType = [HealthDataType.STEPS]
    ..itemType = HealthItemType.steps
    ..title = "Steps"
    ..unit = ""
    ..color = RepresentationColors.stepsColor
    ..icon = IconTypes.stepsIcon
    ..xpType = XPType.steps
    ..getGoal = ((Goal goal) => goal.stepsGoal);

  static HealthItem weight = HealthItem()
    ..dataType = [HealthDataType.WEIGHT]
    ..itemType = HealthItemType.weight
    ..title = "Weight"
    ..unit = "kg"
    ..color = RepresentationColors.weightColor
    ..icon = IconTypes.weightIcon
    ..getGoal = ((Goal goal) => goal.weightGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        WeightHealthEntity(item, goals, widgetSize));

  static HealthItem bodyFat = HealthItem()
    ..dataType = [HealthDataType.BODY_FAT_PERCENTAGE]
    ..itemType = HealthItemType.bodyFatPercentage
    ..title = "Body Fat"
    ..unit = "%"
    ..color = RepresentationColors.bodyFatColor
    ..icon = IconTypes.bodyFatIcon
    ..getGoal = ((Goal goal) => goal.bodyFatGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        BodyfatHealthEntity(item, goals, widgetSize));
}
