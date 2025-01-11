import 'package:healthxp/enums/xp_type.enum.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/models/health_entities/bodyfat_health_entity.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/health_entities/sleep_health_entity.model.dart';
import 'package:healthxp/models/health_entities/netcalories_health_entity.model.dart';
import 'package:healthxp/models/health_entities/weight_health_entity.model.dart';
import 'package:healthxp/models/health_entities/workout_health_entity.model.dart';
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
  late Color offColor;
  late IconData icon;
  double iconSizeMultiplier = 1.0;
  double iconRotation = 0;
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
    ..title = "Calories"
    ..unit = ""
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.caloriesIcon
    ..getGoal = (Goal goal) => goal.caloriesOutGoal;

  static HealthItem proteinIntake = HealthItem()
    ..dataType = [HealthDataType.DIETARY_PROTEIN_CONSUMED]
    ..itemType = HealthItemType.proteinIntake
    ..title = "Protein"
    ..unit = "g"
    ..color = CoreColors.coreBlue
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.proteinIcon
    ..iconSizeMultiplier = 0.90
    ..xpType = XPType.hitProteinGoal
    ..getGoal = (Goal goal) => goal.proteinGoal;

  static HealthItem exerciseTime = HealthItem()
    ..dataType = [HealthDataType.EXERCISE_TIME]
    ..itemType = HealthItemType.exerciseTime
    ..title = "Excercise time"
    ..unit = "min"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.exerciseIcon
    ..getGoal = (Goal goal) => goal.exerciseMinutesGoal;

  static HealthItem workoutTime = HealthItem()
    ..dataType = [HealthDataType.WORKOUT]
    ..itemType = HealthItemType.workoutTime
    ..title = "Workout time"
    ..unit = "min"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.workoutIcon
    ..iconSizeMultiplier = 0.85
    ..getGoal = ((Goal goal) => goal.exerciseMinutesGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        WorkoutHealthEntity(item, goals, widgetSize));

  static HealthItem sleepDuration = HealthItem()
    ..dataType = [HealthDataType.SLEEP_ASLEEP]
    ..itemType = HealthItemType.sleep
    ..title = "Sleep"
    ..unit = "hrs"
    ..color = CoreColors.coreLightOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.sleepDurationIcon
    ..iconSizeMultiplier = 0.90
    ..xpType = XPType.hitSleepGoal
    ..getGoal = ((Goal goal) => goal.sleepGoal.inMinutes.toDouble())
    ..widgetFactory = ((item, goals, widgetSize) =>
        SleepHealthEntity(item, goals, widgetSize));

  static HealthItem activeCalories = HealthItem()
    ..dataType = [HealthDataType.ACTIVE_ENERGY_BURNED]
    ..itemType = HealthItemType.activeCalories
    ..title = "Active Calories"
    ..unit = "cal"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.activeCaloriesIcon;

  static HealthItem restingCalories = HealthItem()
    ..dataType = [HealthDataType.BASAL_ENERGY_BURNED]
    ..itemType = HealthItemType.restingCalories
    ..title = "Resting Calories"
    ..unit = "cal"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.caloriesIcon
    ..getGoal = (Goal goal) => goal.caloriesOutGoal;

  static HealthItem dietaryCalories = HealthItem()
    ..dataType = [HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.dietaryCalories
    ..title = "Dietary Calories"
    ..unit = ""
    ..color = CoreColors.coreBlue
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.dietaryIcon
    ..getGoal = (Goal goal) => goal.caloriesInGoal;

  static HealthItem netCalories = HealthItem()
    ..dataType = [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED, HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.netCalories
    ..title = "Net Calories"
    ..unit = ""
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
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
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.stepsIcon
    ..iconSizeMultiplier = 0.80
    ..iconRotation = 4.70
    ..xpType = XPType.steps
    ..getGoal = ((Goal goal) => goal.stepsGoal);

  static HealthItem weight = HealthItem()
    ..dataType = [HealthDataType.WEIGHT]
    ..itemType = HealthItemType.weight
    ..title = "Weight"
    ..unit = "kg"
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.weightIcon
    ..iconSizeMultiplier = 0.80
    ..getGoal = ((Goal goal) => goal.weightGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        WeightHealthEntity(item, goals, widgetSize));

  static HealthItem bodyFat = HealthItem()
    ..dataType = [HealthDataType.BODY_FAT_PERCENTAGE]
    ..itemType = HealthItemType.bodyFatPercentage
    ..title = "Body Fat"
    ..unit = "%"
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.bodyFatIcon
    ..getGoal = ((Goal goal) => goal.bodyFatGoal)
    ..widgetFactory = ((item, goals, widgetSize) =>
        BodyfatHealthEntity(item, goals, widgetSize));
}
