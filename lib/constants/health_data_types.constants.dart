  import 'package:health/health.dart';

final List<HealthDataType> healthDataTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.NUTRITION,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.WORKOUT
  ];

final List<HealthDataType> sleepTypes = [
  HealthDataType.SLEEP_ASLEEP,
  HealthDataType.SLEEP_AWAKE,
  HealthDataType.SLEEP_DEEP,
  HealthDataType.SLEEP_LIGHT,
  HealthDataType.SLEEP_REM,
];

final List<HealthDataType> trendTypes = [
  HealthDataType.WEIGHT,
  HealthDataType.BODY_FAT_PERCENTAGE,
  HealthDataType.BODY_MASS_INDEX,
];

final List<HealthDataType> allHealthDataTypes = [
  ...healthDataTypes,
  ...sleepTypes,
  ...trendTypes,
  // Dietary
  HealthDataType.DIETARY_CARBS_CONSUMED,
  HealthDataType.DIETARY_FATS_CONSUMED,
  HealthDataType.DIETARY_FIBER,
  HealthDataType.DIETARY_SUGAR,
  HealthDataType.DIETARY_CHOLESTEROL,
  HealthDataType.DIETARY_CAFFEINE,
  // Vitamins
  HealthDataType.DIETARY_VITAMIN_A,
  HealthDataType.DIETARY_VITAMIN_B6,
  HealthDataType.DIETARY_VITAMIN_B12,
  HealthDataType.DIETARY_VITAMIN_C,
  HealthDataType.DIETARY_VITAMIN_D,
  HealthDataType.DIETARY_VITAMIN_E,
  // Minerals
  HealthDataType.DIETARY_CALCIUM,
  HealthDataType.DIETARY_IRON,
  HealthDataType.DIETARY_MAGNESIUM,
  HealthDataType.DIETARY_POTASSIUM,
  HealthDataType.DIETARY_SODIUM,
  // Vitals
  HealthDataType.BLOOD_GLUCOSE,
  HealthDataType.BLOOD_OXYGEN,
  HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
  HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
  HealthDataType.BODY_TEMPERATURE,
  HealthDataType.HEART_RATE,
  HealthDataType.RESTING_HEART_RATE,
  HealthDataType.WALKING_HEART_RATE,
  HealthDataType.RESPIRATORY_RATE,
  // Body Measurements
  HealthDataType.HEIGHT,
  HealthDataType.WAIST_CIRCUMFERENCE,
  // Distance & Activity
  HealthDataType.DISTANCE_WALKING_RUNNING,
  HealthDataType.DISTANCE_SWIMMING,
  HealthDataType.DISTANCE_CYCLING,
  HealthDataType.FLIGHTS_CLIMBED,
  HealthDataType.WATER,
  HealthDataType.MINDFULNESS,
];

List<String> strengthTrainingTypes = [
  "TRADITIONAL_STRENGTH_TRAINING",
  "FUNCTIONAL_STRENGTH_TRAINING",
  "WEIGHT_LIFTING",
  "HIGH_INTENSITY_INTERVAL_TRAINING",
  "STRENGTH_TRAINING"
];
