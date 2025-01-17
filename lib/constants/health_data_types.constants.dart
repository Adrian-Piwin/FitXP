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
];

List<String> strengthTrainingTypes = [
  "TRADITIONAL_STRENGTH_TRAINING",
  "FUNCTIONAL_STRENGTH_TRAINING",
  "WEIGHT_LIFTING",
  "HIGH_INTENSITY_INTERVAL_TRAINING",
  "STRENGTH_TRAINING"
];
