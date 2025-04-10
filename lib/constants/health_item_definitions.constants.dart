import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthcore/models/health_entities/bodyfat_health_entity.model.dart';
import 'package:healthcore/models/health_entities/netcalories_health_entity.model.dart';
import 'package:healthcore/models/health_entities/sleep_health_entity.model.dart';
import 'package:healthcore/models/health_entities/trend_health_entity.model.dart';
import 'package:healthcore/models/health_entities/weight_health_entity.model.dart';
import 'package:healthcore/models/health_entities/workout_health_entity.model.dart';
import 'package:healthcore/models/health_item.model.dart';
import '../enums/health_item_type.enum.dart';
import '../enums/health_category.enum.dart';
import 'icons.constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utility/health_category_colors.utility.dart';

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
    distanceWalkingRunning,
    distanceSwimming,
    distanceCycling,
    flightsClimbed,
    water,
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
    required HealthCategory category,
    required IconData icon,
    required double defaultGoal,
    String shortDescription = "",
    String longDescription = "",
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
      ..category = category
      ..color = HealthCategoryColors.getColorForCategory(category)
      ..offColor = HealthCategoryColors.getOffColorForCategory(category)
      ..icon = icon
      ..iconRotation = iconRotation
      ..doesGoalSupportStreaks = supportStreaks
      ..doesGoalSupportDecimals = supportDecimals
      ..doesGoalSupportNegative = supportNegative
      ..doesGoalSupportTimeInput = supportTimeInput
      ..shortDescription = shortDescription
      ..longDescription = longDescription
      ..defaultGoal = defaultGoal;

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
    category: HealthCategory.energy,
    icon: IconTypes.caloriesIcon,
    defaultGoal: 2500,
    longDescription: "The amount of energy you burn during the day",
    shortDescription: "Total energy burned",
  );

  static HealthItem proteinIntake = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_PROTEIN_CONSUMED],
    itemType: HealthItemType.proteinIntake,
    title: "Protein",
    unit: "g",
    category: HealthCategory.nutrition,
    icon: IconTypes.proteinIcon,
    defaultGoal: 100,
  );

  static HealthItem exerciseTime = _createHealthItem(
    dataTypes: [HealthDataType.EXERCISE_TIME],
    itemType: HealthItemType.exerciseTime,
    title: "Excercise time",
    unit: "min",
    category: HealthCategory.exercise,
    icon: IconTypes.exerciseIcon,
    defaultGoal: 30,
    longDescription: "The amount of time you spend exercising during the day",
    shortDescription: "Total time spent exercising",
  );

  static HealthItem workoutTime = _createHealthItem(
    dataTypes: [HealthDataType.WORKOUT],
    itemType: HealthItemType.workoutTime,
    title: "Workout time",
    unit: "min",
    category: HealthCategory.exercise,
    icon: IconTypes.workoutIcon,
    defaultGoal: 45,
    longDescription: "The amount of time in minutes you spend doing strength training workouts during the day",
    shortDescription: "Total time spent working out",
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        WorkoutHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem sleepDuration = _createHealthItem(
    dataTypes: [HealthDataType.SLEEP_ASLEEP],
    itemType: HealthItemType.sleep,
    title: "Sleep",
    unit: "hrs",
    category: HealthCategory.wellness,
    icon: IconTypes.sleepDurationIcon,
    defaultGoal: 480,
    supportTimeInput: true,
    longDescription: "The duration, each stage, and quality of your sleep",
    shortDescription: "Sleep stages, duration, and quality",
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        SleepHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem activeCalories = _createHealthItem(
    dataTypes: [HealthDataType.ACTIVE_ENERGY_BURNED],
    itemType: HealthItemType.activeCalories,
    title: "Active Calories",
    unit: "cal",
    category: HealthCategory.energy,
    icon: IconTypes.activeCaloriesIcon,
    defaultGoal: 600,
    longDescription: "Calories burned through physical activity, excluding your resting metabolic rate",
    shortDescription: "Active energy expenditure",
  );

  static HealthItem restingCalories = _createHealthItem(
    dataTypes: [HealthDataType.BASAL_ENERGY_BURNED],
    itemType: HealthItemType.restingCalories,
    title: "Resting Calories",
    unit: "cal",
    category: HealthCategory.energy,
    icon: IconTypes.caloriesIcon,
    defaultGoal: 1600,
    longDescription: "The calories your body burns at rest to maintain basic life functions, excluding activity calories",
    shortDescription: "Basal metabolic rate",
  );

  static HealthItem dietaryCalories = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_ENERGY_CONSUMED],
    itemType: HealthItemType.dietaryCalories,
    title: "Dietary Calories",
    unit: "cal",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 2000,
    longDescription: "The amount of calories you consume during the day",
    shortDescription: "Total calories consumed",
  );

  static HealthItem netCalories = _createHealthItem(
    dataTypes: [HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED, HealthDataType.DIETARY_ENERGY_CONSUMED],
    itemType: HealthItemType.netCalories,
    title: "Net Calories",
    unit: "cal",
    category: HealthCategory.body,
    icon: IconTypes.netCaloriesIcon,
    defaultGoal: -500,
    supportNegative: true,
    longDescription: "The difference between calories burned and calories consumed",
    shortDescription: "Energy expended minus energy consumed",
    customWidgetFactory: ((item, widgetSize, healthFetcherService) =>
        NetCaloriesHealthEntity(item, widgetSize, healthFetcherService))
  );

  static HealthItem steps = _createHealthItem(
    dataTypes: [HealthDataType.STEPS],
    itemType: HealthItemType.steps,
    title: "Steps",
    unit: "",
    category: HealthCategory.movement,
    icon: IconTypes.stepsIcon,
    defaultGoal: 10000,
    iconRotation: 4.70
  );

  static HealthItem weight = _createHealthItem(
    dataTypes: [HealthDataType.WEIGHT],
    itemType: HealthItemType.weight,
    title: "Weight",
    unit: "kg",
    category: HealthCategory.body,
    icon: IconTypes.weightIcon,
    defaultGoal: 70,
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
    category: HealthCategory.body,
    icon: IconTypes.bodyFatIcon,
    defaultGoal: 20,
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
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 250,
  );

  static HealthItem dietaryFats = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_FATS_CONSUMED],
    itemType: HealthItemType.dietaryFats,
    title: "Fats",
    unit: "g",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 65,
  );

  static HealthItem dietaryFiber = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_FIBER],
    itemType: HealthItemType.dietaryFiber,
    title: "Fiber",
    unit: "g",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 30,
  );

  static HealthItem dietarySugar = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_SUGAR],
    itemType: HealthItemType.dietarySugar,
    title: "Sugar",
    unit: "g",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 25,
  );

  static HealthItem dietaryCholesterol = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CHOLESTEROL],
    itemType: HealthItemType.dietaryCholesterol,
    title: "Cholesterol",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 300,
  );

  static HealthItem dietaryCaffeine = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CAFFEINE],
    itemType: HealthItemType.dietaryCaffeine,
    title: "Caffeine",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 400,
  );

  // Vitamins
  static HealthItem vitaminA = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_A],
    itemType: HealthItemType.vitaminA,
    title: "Vitamin A",
    unit: "μg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 900,
  );

  static HealthItem vitaminB6 = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_B6],
    itemType: HealthItemType.vitaminB6,
    title: "Vitamin B6",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 1.3,
  );

  static HealthItem vitaminB12 = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_B12],
    itemType: HealthItemType.vitaminB12,
    title: "Vitamin B12",
    unit: "μg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 2.4,
  );

  static HealthItem vitaminC = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_C],
    itemType: HealthItemType.vitaminC,
    title: "Vitamin C",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 90,
  );

  static HealthItem vitaminD = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_D],
    itemType: HealthItemType.vitaminD,
    title: "Vitamin D",
    unit: "μg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 20,
  );

  static HealthItem vitaminE = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_VITAMIN_E],
    itemType: HealthItemType.vitaminE,
    title: "Vitamin E",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 15,
  );

  // Minerals
  static HealthItem calcium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_CALCIUM],
    itemType: HealthItemType.calcium,
    title: "Calcium",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 1000,
  );

  static HealthItem iron = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_IRON],
    itemType: HealthItemType.iron,
    title: "Iron",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 8,
  );

  static HealthItem magnesium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_MAGNESIUM],
    itemType: HealthItemType.magnesium,
    title: "Magnesium",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 400,
  );

  static HealthItem potassium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_POTASSIUM],
    itemType: HealthItemType.potassium,
    title: "Potassium",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 3500,
  );

  static HealthItem sodium = _createHealthItem(
    dataTypes: [HealthDataType.DIETARY_SODIUM],
    itemType: HealthItemType.sodium,
    title: "Sodium",
    unit: "mg",
    category: HealthCategory.nutrition,
    icon: IconTypes.dietaryIcon,
    defaultGoal: 2300,
  );

  // Vitals
  static HealthItem bloodGlucose = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_GLUCOSE],
    itemType: HealthItemType.bloodGlucose,
    title: "Blood Glucose",
    unit: "mg/dL",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.droplet,
    defaultGoal: 100,
    isTrendItem: true
  );

  static HealthItem bloodOxygen = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_OXYGEN],
    itemType: HealthItemType.bloodOxygen,
    title: "Blood Oxygen",
    unit: "%",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.lungs,
    defaultGoal: 95,
    isTrendItem: true
  );

  static HealthItem bloodPressureDiastolic = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
    itemType: HealthItemType.bloodPressureDiastolic,
    title: "Diastolic BP",
    unit: "mmHg",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.heartPulse,
    defaultGoal: 80,
    isTrendItem: true,
    shortDescription: "Diastolic blood pressure",
  );

  static HealthItem bloodPressureSystolic = _createHealthItem(
    dataTypes: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
    itemType: HealthItemType.bloodPressureSystolic,
    title: "Systolic BP",
    unit: "mmHg",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.heartPulse,
    defaultGoal: 120,
    isTrendItem: true,
    shortDescription: "Systolic blood pressure",
  );

  static HealthItem bodyTemperature = _createHealthItem(
    dataTypes: [HealthDataType.BODY_TEMPERATURE],
    itemType: HealthItemType.bodyTemperature,
    title: "Body Temperature",
    unit: "°C",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.temperatureHalf,
    defaultGoal: 37,
    isTrendItem: true
  );

  static HealthItem heartRate = _createHealthItem(
    dataTypes: [HealthDataType.HEART_RATE],
    itemType: HealthItemType.heartRate,
    title: "Heart Rate",
    unit: "bpm",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.heartPulse,
    defaultGoal: 70,
    isTrendItem: true,
    longDescription: "The number of times your heart beats per minute",
  );

  static HealthItem restingHeartRate = _createHealthItem(
    dataTypes: [HealthDataType.RESTING_HEART_RATE],
    itemType: HealthItemType.restingHeartRate,
    title: "Resting HR",
    unit: "bpm",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.bed,
    defaultGoal: 60,
    isTrendItem: true,
    longDescription: "The number of times your heart beats per minute while at rest",
    shortDescription: "Resting heart rate",
  );

  static HealthItem walkingHeartRate = _createHealthItem(
    dataTypes: [HealthDataType.WALKING_HEART_RATE],
    itemType: HealthItemType.walkingHeartRate,
    title: "Walking HR",
    unit: "bpm",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.personWalking,
    defaultGoal: 100,
    isTrendItem: true,
    longDescription: "The number of times your heart beats per minute while walking",
    shortDescription: "Walking heart rate",
  );

  static HealthItem respiratoryRate = _createHealthItem(
    dataTypes: [HealthDataType.RESPIRATORY_RATE],
    itemType: HealthItemType.respiratoryRate,
    title: "Respiratory Rate",
    unit: "br/min",
    category: HealthCategory.health,
    icon: FontAwesomeIcons.lungs,
    defaultGoal: 16,
    isTrendItem: true,
    longDescription: "The number of breaths per minute",
  );

  // Body Measurements
  static HealthItem height = _createHealthItem(
    dataTypes: [HealthDataType.HEIGHT],
    itemType: HealthItemType.height,
    title: "Height",
    unit: "cm",
    category: HealthCategory.body,
    icon: FontAwesomeIcons.rulerVertical,
    defaultGoal: 170,
    isTrendItem: true
  );

  static HealthItem waistCircumference = _createHealthItem(
    dataTypes: [HealthDataType.WAIST_CIRCUMFERENCE],
    itemType: HealthItemType.waistCircumference,
    title: "Waist",
    unit: "cm",
    category: HealthCategory.body,
    icon: FontAwesomeIcons.ruler,
    defaultGoal: 90,
    isTrendItem: true
  );

  // Distance & Activity
  static HealthItem distanceWalkingRunning = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_WALKING_RUNNING],
    itemType: HealthItemType.distanceWalkingRunning,
    title: "Distance (Walk/Run)",
    unit: "km",
    category: HealthCategory.movement,
    icon: FontAwesomeIcons.personRunning,
    defaultGoal: 5,
  );

  static HealthItem distanceSwimming = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_SWIMMING],
    itemType: HealthItemType.distanceSwimming,
    title: "Distance (Swim)",
    unit: "m",
    category: HealthCategory.movement,
    icon: FontAwesomeIcons.personSwimming,
    defaultGoal: 500,
  );

  static HealthItem distanceCycling = _createHealthItem(
    dataTypes: [HealthDataType.DISTANCE_CYCLING],
    itemType: HealthItemType.distanceCycling,
    title: "Distance (Cycle)",
    unit: "km",
    category: HealthCategory.movement,
    icon: FontAwesomeIcons.bicycle,
    defaultGoal: 10,
  );

  static HealthItem flightsClimbed = _createHealthItem(
    dataTypes: [HealthDataType.FLIGHTS_CLIMBED],
    itemType: HealthItemType.flightsClimbed,
    title: "Flights Climbed",
    unit: "floors",
    category: HealthCategory.movement,
    icon: FontAwesomeIcons.stairs,
    defaultGoal: 10,
    longDescription: "The number of flights of stairs you climb",
  );

  // Other
  static HealthItem water = _createHealthItem(
    dataTypes: [HealthDataType.WATER],
    itemType: HealthItemType.water,
    title: "Water",
    unit: "ml",
    category: HealthCategory.nutrition,
    icon: FontAwesomeIcons.glassWater,
    defaultGoal: 2500,
  );

  static HealthItem mindfulness = _createHealthItem(
    dataTypes: [HealthDataType.MINDFULNESS],
    itemType: HealthItemType.mindfulness,
    title: "Mindfulness",
    unit: "min",
    category: HealthCategory.wellness,
    icon: FontAwesomeIcons.brain,
    defaultGoal: 15,
    longDescription: "The amount of time you spend meditating",
  );
}
