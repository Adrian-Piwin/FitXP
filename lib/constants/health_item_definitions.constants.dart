import 'package:healthxp/enums/xp_type.enum.dart';
import 'package:healthxp/models/health_entities/bodyfat_health_entity.model.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/health_entities/sleep_health_entity.model.dart';
import 'package:healthxp/models/health_entities/netcalories_health_entity.model.dart';
import 'package:healthxp/models/health_entities/weight_health_entity.model.dart';
import 'package:healthxp/models/health_entities/workout_health_entity.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import '../enums/health_item_type.enum.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';

class HealthItemDefinitions {
  static HealthItem expendedEnergy = HealthItem()
    ..dataType = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED
    ]
    ..itemType = HealthItemType.expendedEnergy
    ..title = "Expended Energy"
    ..unit = "cal"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.caloriesIcon;

  static HealthItem proteinIntake = HealthItem()
    ..dataType = [HealthDataType.DIETARY_PROTEIN_CONSUMED]
    ..itemType = HealthItemType.proteinIntake
    ..title = "Protein"
    ..unit = "g"
    ..color = CoreColors.coreBlue
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.proteinIcon
    ..iconSizeMultiplier = 0.90
    ..xpType = XPType.protein;

  static HealthItem exerciseTime = HealthItem()
    ..dataType = [HealthDataType.EXERCISE_TIME]
    ..itemType = HealthItemType.exerciseTime
    ..title = "Excercise time"
    ..unit = "min"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.exerciseIcon
    ..xpType = XPType.exerciseTime;

  static HealthItem workoutTime = HealthItem()
    ..dataType = [HealthDataType.WORKOUT]
    ..itemType = HealthItemType.workoutTime
    ..title = "Workout time"
    ..unit = "min"
    ..color = CoreColors.coreOrange
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.workoutIcon
    ..iconSizeMultiplier = 0.80
    ..widgetFactory = ((item, widgetSize, healthFetcherService) =>
        WorkoutHealthEntity(item, widgetSize, healthFetcherService));

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
    ..doesGoalSupportTimeInput = true
    ..widgetFactory = ((item, widgetSize, healthFetcherService) =>
        SleepHealthEntity(item, widgetSize, healthFetcherService));

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
    ..icon = IconTypes.caloriesIcon;

  static HealthItem dietaryCalories = HealthItem()
    ..dataType = [HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.dietaryCalories
    ..title = "Dietary Calories"
    ..unit = "cal"
    ..color = CoreColors.coreBlue
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.dietaryIcon;

  static HealthItem netCalories = HealthItem()
    ..dataType = [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED, HealthDataType.DIETARY_ENERGY_CONSUMED]
    ..itemType = HealthItemType.netCalories
    ..title = "Net Calories"
    ..unit = "cal"
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
    ..doesGoalSupportNegative = true
    ..icon = IconTypes.netCaloriesIcon
    ..xpType = XPType.hitNetCaloriesGoal
    ..widgetFactory = ((item, widgetSize, healthFetcherService) =>
        NetCaloriesHealthEntity(item, widgetSize, healthFetcherService));

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
    ..xpType = XPType.steps;

  static HealthItem weight = HealthItem()
    ..dataType = [HealthDataType.WEIGHT]
    ..itemType = HealthItemType.weight
    ..title = "Weight"
    ..unit = "kg"
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.weightIcon
    ..iconSizeMultiplier = 0.80
    ..doesGoalSupportStreaks = false
    ..widgetFactory = ((item, widgetSize, healthFetcherService) =>
        WeightHealthEntity(item, widgetSize, healthFetcherService));

  static HealthItem bodyFat = HealthItem()
    ..dataType = [HealthDataType.BODY_FAT_PERCENTAGE]
    ..itemType = HealthItemType.bodyFatPercentage
    ..title = "Body Fat"
    ..unit = "%"
    ..color = CoreColors.textColor
    ..offColor = CoreColors.coreGrey
    ..icon = IconTypes.bodyFatIcon
    ..doesGoalSupportDecimals = true
    ..doesGoalSupportStreaks = false
    ..widgetFactory = ((item, widgetSize, healthFetcherService) =>
        BodyfatHealthEntity(item, widgetSize, healthFetcherService));
}
