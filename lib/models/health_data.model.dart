import 'package:health/health.dart';
import '../services/health_fetcher_service.dart';
import 'health_item_value.dart';

class HealthData{
  HealthFetcherService healthService;
  HealthData(this.healthService);

  // decide if we should return the average or the total
  bool averages = true;

  HealthItemValue get getActiveCalories => healthService.getBasicHealthItemValue(HealthDataType.ACTIVE_ENERGY_BURNED);
  HealthItemValue get getRestingCalories => healthService.getBasicHealthItemValue(HealthDataType.BASAL_ENERGY_BURNED);
  HealthItemValue get getDietaryCalories => healthService.getBasicHealthItemValue(HealthDataType.DIETARY_ENERGY_CONSUMED);
  HealthItemValue get getProtein => healthService.getBasicHealthItemValue(HealthDataType.DIETARY_PROTEIN_CONSUMED);
  HealthItemValue get getExerciseMinutes => healthService.getBasicHealthItemValue(HealthDataType.EXERCISE_TIME);
  HealthItemValue get getStrengthTrainingMinutes => healthService.getStrengthTrainingMinutes();
  HealthItemValue get getCardioMinutes => healthService.getCardioMinutes();
  HealthItemValue get getSteps => healthService.getBasicHealthItemValue(HealthDataType.STEPS);
  HealthItemValue get getSleep => healthService.getBasicHealthItemValue(HealthDataType.SLEEP_ASLEEP);
  double get getLatestWeight => healthService.getLatestWeight();
  double get getOldestWeight => healthService.getOldestWeight();
}
