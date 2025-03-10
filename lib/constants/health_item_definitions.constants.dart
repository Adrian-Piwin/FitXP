import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/health_entities/bodyfat_health_entity.model.dart';
import 'package:healthxp/models/health_entities/netcalories_health_entity.model.dart';
import 'package:healthxp/models/health_entities/sleep_health_entity.model.dart';
import 'package:healthxp/models/health_entities/trend_health_entity.model.dart';
import 'package:healthxp/models/health_entities/weight_health_entity.model.dart';
import 'package:healthxp/models/health_entities/workout_health_entity.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import '../enums/health_item_type.enum.dart';
import 'colors.constants.dart';
import 'icons.constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HealthItemDefinitions {
  // List of all available health items
  static final List<HealthItem> allHealthItems = [
    expendedEnergy,
    dietaryCalories,
    netCalories,
    activeCalories,
    steps,
    proteinIntake,
    sleepDuration,
    exerciseTime,
    weight,
    bodyFat,
    workoutTime,
    dietaryCarbs,
    dietaryFats,
    dietaryFiber,
    dietarySugar,
    dietaryCholesterol,
    dietaryCaffeine,
    vitaminA,
    vitaminB6,
    vitaminB12,
    vitaminC,
    vitaminD,
    vitaminE,
    calcium,
    iron,
    magnesium,
    potassium,
    sodium,
    bloodGlucose,
    bloodOxygen,
    bloodPressureDiastolic,
    bloodPressureSystolic,
    bodyTemperature,
    heartRate,
    restingHeartRate,
    walkingHeartRate,
    respiratoryRate,
    height,
    waistCircumference,
    distanceWalkingRunning,
    distanceSwimming,
    distanceCycling,
    flightsClimbed,
    water,
    mindfulness,
  ];

  // Default header widgets (static, cannot be changed)
  static final List<HealthItem> defaultHeaderItems = [
    expendedEnergy,
    dietaryCalories,
    netCalories,
    activeCalories,
  ];

  // Default body widgets (can be customized)
  static final List<HealthItem> defaultBodyItems = [
    steps,
    proteinIntake,
    sleepDuration,
    exerciseTime,
    weight,
    bodyFat,
  ];

  // Factory method for creating health items
  static HealthItem _createHealthItem({
    required List<HealthDataType> dataTypes,
    required HealthItemType itemType,
    required String title,
    required String unit,
    required Color color,
    required Color offColor,
    required IconData icon,
    bool isTrendItem = false,
    bool supportStreaks = true,
    bool supportDecimals = false,
    bool supportNegative = false,
    bool supportTimeInput = false,
    double iconRotation = 0,
    WidgetFactory? customWidgetFactory,
  }) {
    final item = HealthItem()
      ..dataType = dataTypes
      ..itemType = itemType
      ..title = title
      ..unit = unit
      ..color = color
      ..offColor = offColor
      ..icon = icon
      ..iconRotation = iconRotation
      ..doesGoalSupportStreaks = supportStreaks
      ..doesGoalSupportDecimals = supportDecimals
      ..doesGoalSupportNegative = supportNegative
      ..doesGoalSupportTimeInput = supportTimeInput;

    if (customWidgetFactory != null) {
      item.widgetFactory = customWidgetFactory;
    } else if (isTrendItem) {
      item.widgetFactory = (item, widgetSize, healthFetcherService) =>
          TrendHealthEntity(item, widgetSize, healthFetcherService);
    }

    return item;
  }

  static HealthItem expendedEnergy = _createHealthItem(
    dataTypes: [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED],
    itemType: HealthItemType.expendedEnergy,
    title: "Expended Energy",
    unit: "cal",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.caloriesIcon
  );

  static HealthItem proteinIntake = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_PROTEIN_CONSUMED],
    itemType: HealthItemType.proteinIntake,
    title: "Protein",
    unit: "g",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.proteinIcon
  );

  static HealthItem exerciseTime = _createHealthItem(
    dataTypes: [HealthDataType.EXERCISE_TIME],
    itemType: HealthItemType.exerciseTime,
    title: "Excercise time",
    unit: "min",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.exerciseIcon
  );

  static HealthItem workoutTime = _createHealthItem(
    dataTypes: [HealthDataType.WORKOUT],
    itemType: HealthItemType.workoutTime,
    title: "Workout time",
    unit: "min",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.workoutIcon,
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        WorkoutHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem sleepDuration = _createHealthItem(
    dataTypes: [HealthDataType.SLEEP_ASLEEP],
    itemType: HealthItemType.sleep,
    title: "Sleep",
    unit: "hrs",
    color: CoreColors.coreLightOrange,
    offColor: CoreColors.coreOffLightOrange,
    icon: IconTypes.sleepDurationIcon,
    supportTimeInput: true,
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        SleepHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem activeCalories = _createHealthItem(
    dataTypes: [HealthDataType.ACTIVE_ENERGY_BURNED],
    itemType: HealthItemType.activeCalories,
    title: "Active Calories",
    unit: "cal",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.activeCaloriesIcon
  );

  static HealthItem restingCalories = _createHealthItem(
    dataTypes: [HealthDataType.BASAL_ENERGY_BURNED],
    itemType: HealthItemType.restingCalories,
    title: "Resting Calories",
    unit: "cal",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.caloriesIcon
  );

  static HealthItem dietaryCalories = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_ENERGY_CONSUMED],
    itemType: HealthItemType.dietaryCalories,
    title: "Dietary Calories",
    unit: "cal",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon
  );

  static HealthItem netCalories = _createHealthItem(
    dataTypes: [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED, HealthDataType.DIETARY_ENERGY_CONSUMED],
    itemType: HealthItemType.netCalories,
    title: "Net Calories",
    unit: "cal",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.netCaloriesIcon,
    supportNegative: true,
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        NetCaloriesHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem steps = _createHealthItem(
    dataTypes: [HealthDataType.STEPS],
    itemType: HealthItemType.steps,
    title: "Steps",
    unit: "",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: IconTypes.stepsIcon,
    iconRotation: 4.70
  );

  static HealthItem weight = _createHealthItem(
    dataTypes: [HealthDataType.WEIGHT],
    itemType: HealthItemType.weight,
    title: "Weight",
    unit: "kg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.weightIcon,
    supportStreaks: false,
    supportDecimals: true,
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        WeightHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem bodyFat = _createHealthItem(
    dataTypes: [HealthDataType.BODY_FAT_PERCENTAGE],
    itemType: HealthItemType.bodyFatPercentage,
    title: "Body Fat",
    unit: "%",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.bodyFatIcon,
    supportDecimals: true,
    supportStreaks: false,
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        BodyfatHealthEntity(item, widgetSize, healthFetcherService))
  );

  // Dietary Macronutrients
  static HealthItem dietaryCarbs = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CARBS_CONSUMED],
    itemType: HealthItemType.dietaryCarbs,
    title: "Carbohydrates",
    unit: "g",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem dietaryFats = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_FATS_CONSUMED],
    itemType: HealthItemType.dietaryFats,
    title: "Fats",
    unit: "g",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem dietaryFiber = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_FIBER],
    itemType: HealthItemType.dietaryFiber,
    title: "Fiber",
    unit: "g",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem dietarySugar = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_SUGAR],
    itemType: HealthItemType.dietarySugar,
    title: "Sugar",
    unit: "g",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem dietaryCholesterol = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CHOLESTEROL],
    itemType: HealthItemType.dietaryCholesterol,
    title: "Cholesterol",
    unit: "mg",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem dietaryCaffeine = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CAFFEINE],
    itemType: HealthItemType.dietaryCaffeine,
    title: "Caffeine",
    unit: "mg",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: IconTypes.dietaryIcon,
  );

  // Vitamins
  static HealthItem vitaminA = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_A],
    itemType: HealthItemType.vitaminA,
    title: "Vitamin A",
    unit: "μg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem vitaminB6 = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_B6],
    itemType: HealthItemType.vitaminB6,
    title: "Vitamin B6",
    unit: "mg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem vitaminB12 = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_B12],
    itemType: HealthItemType.vitaminB12,
    title: "Vitamin B12",
    unit: "μg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem vitaminC = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_C],
    itemType: HealthItemType.vitaminC,
    title: "Vitamin C",
    unit: "mg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem vitaminD = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_D],
    itemType: HealthItemType.vitaminD,
    title: "Vitamin D",
    unit: "μg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem vitaminE = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_E],
    itemType: HealthItemType.vitaminE,
    title: "Vitamin E",
    unit: "mg",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: IconTypes.dietaryIcon,
  );

  // Minerals
  static HealthItem calcium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CALCIUM],
    itemType: HealthItemType.calcium,
    title: "Calcium",
    unit: "mg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem iron = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_IRON],
    itemType: HealthItemType.iron,
    title: "Iron",
    unit: "mg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem magnesium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_MAGNESIUM],
    itemType: HealthItemType.magnesium,
    title: "Magnesium",
    unit: "mg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem potassium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_POTASSIUM],
    itemType: HealthItemType.potassium,
    title: "Potassium",
    unit: "mg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.dietaryIcon,
  );

  static HealthItem sodium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_SODIUM],
    itemType: HealthItemType.sodium,
    title: "Sodium",
    unit: "mg",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: IconTypes.dietaryIcon,
  );

  // Vitals
  static HealthItem bloodGlucose = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_GLUCOSE],
    itemType: HealthItemType.bloodGlucose,
    title: "Blood Glucose",
    unit: "mg/dL",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: FontAwesomeIcons.droplet,
    isTrendItem: true
  );

  static HealthItem bloodOxygen = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_OXYGEN],
    itemType: HealthItemType.bloodOxygen,
    title: "Blood Oxygen",
    unit: "%",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: FontAwesomeIcons.lungs,
    isTrendItem: true
  );

  static HealthItem bloodPressureDiastolic = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
    itemType: HealthItemType.bloodPressureDiastolic,
    title: "Diastolic BP",
    unit: "mmHg",
    color: CoreColors.coreBrown,
    offColor: CoreColors.coreOffBrown,
    icon: FontAwesomeIcons.heartPulse,
    isTrendItem: true
  );

  static HealthItem bloodPressureSystolic = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
    itemType: HealthItemType.bloodPressureSystolic,
    title: "Systolic BP",
    unit: "mmHg",
    color: CoreColors.coreBrown,
    offColor: CoreColors.coreOffBrown,
    icon: FontAwesomeIcons.heartPulse,
    isTrendItem: true
  );

  static HealthItem bodyTemperature = _createHealthItem(
    dataTypes: [HealthDataType.BODY_TEMPERATURE],
    itemType: HealthItemType.bodyTemperature,
    title: "Body Temperature",
    unit: "°C",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: FontAwesomeIcons.temperatureHalf,
    isTrendItem: true
  );

  static HealthItem heartRate = _createHealthItem(
    dataTypes: [HealthDataType.HEART_RATE],
    itemType: HealthItemType.heartRate,
    title: "Heart Rate",
    unit: "bpm",
    color: CoreColors.coreBrown,
    offColor: CoreColors.coreOffBrown,
    icon: FontAwesomeIcons.heartPulse,
    isTrendItem: true
  );

  static HealthItem restingHeartRate = _createHealthItem(
    dataTypes: [HealthDataType.RESTING_HEART_RATE],
    itemType: HealthItemType.restingHeartRate,
    title: "Resting HR",
    unit: "bpm",
    color: CoreColors.coreBrown,
    offColor: CoreColors.coreOffBrown,
    icon: FontAwesomeIcons.bed,
    isTrendItem: true
  );

  static HealthItem walkingHeartRate = _createHealthItem(
    dataTypes: [HealthDataType.WALKING_HEART_RATE],
    itemType: HealthItemType.walkingHeartRate,
    title: "Walking HR",
    unit: "bpm",
    color: CoreColors.coreBrown,
    offColor: CoreColors.coreOffBrown,
    icon: FontAwesomeIcons.personWalking,
    isTrendItem: true
  );

  static HealthItem respiratoryRate = _createHealthItem(
    dataTypes: [HealthDataType.RESPIRATORY_RATE],
    itemType: HealthItemType.respiratoryRate,
    title: "Respiratory Rate",
    unit: "br/min",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: FontAwesomeIcons.lungs,
    isTrendItem: true
  );

  // Body Measurements
  static HealthItem height = _createHealthItem(
    dataTypes: [HealthDataType.HEIGHT],
    itemType: HealthItemType.height,
    title: "Height",
    unit: "cm",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: FontAwesomeIcons.rulerVertical,
    isTrendItem: true
  );

  static HealthItem waistCircumference = _createHealthItem(
    dataTypes: [HealthDataType.WAIST_CIRCUMFERENCE],
    itemType: HealthItemType.waistCircumference,
    title: "Waist",
    unit: "cm",
    color: CoreColors.coreLightGrey,
    offColor: CoreColors.coreOffLightGrey,
    icon: FontAwesomeIcons.ruler,
    isTrendItem: true
  );

  // Distance & Activity
  static HealthItem distanceWalkingRunning = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_WALKING_RUNNING],
    itemType: HealthItemType.distanceWalkingRunning,
    title: "Distance (Walk/Run)",
    unit: "km",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: FontAwesomeIcons.personRunning,
  );

  static HealthItem distanceSwimming = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_SWIMMING],
    itemType: HealthItemType.distanceSwimming,
    title: "Distance (Swim)",
    unit: "m",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: FontAwesomeIcons.personSwimming,
  );

  static HealthItem distanceCycling = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_CYCLING],
    itemType: HealthItemType.distanceCycling,
    title: "Distance (Cycle)",
    unit: "km",
    color: CoreColors.coreGreen,
    offColor: CoreColors.coreOffGreen,
    icon: FontAwesomeIcons.bicycle,
  );

  static HealthItem flightsClimbed = _createHealthItem(
    dataTypes: [HealthDataType.FLIGHTS_CLIMBED],
    itemType: HealthItemType.flightsClimbed,
    title: "Flights Climbed",
    unit: "floors",
    color: CoreColors.coreOrange,
    offColor: CoreColors.coreOffOrange,
    icon: FontAwesomeIcons.stairs,
  );

  // Other
  static HealthItem water = _createHealthItem(
    dataTypes: [HealthDataType.WATER],
    itemType: HealthItemType.water,
    title: "Water",
    unit: "ml",
    color: CoreColors.coreBlue,
    offColor: CoreColors.coreOffBlue,
    icon: FontAwesomeIcons.glassWater,
  );

  static HealthItem mindfulness = _createHealthItem(
    dataTypes: [HealthDataType.MINDFULNESS],
    itemType: HealthItemType.mindfulness,
    title: "Mindfulness",
    unit: "min",
    color: CoreColors.coreLightOrange,
    offColor: CoreColors.coreOffLightOrange,
    icon: FontAwesomeIcons.brain,
  );
}
