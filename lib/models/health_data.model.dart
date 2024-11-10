import 'package:fitxp/services/health_fetcher_service.dart';
import 'package:health/health.dart';

class HealthData{
  HealthFetcherService healthService;
  HealthData(this.healthService);

  // decide if we should return the average or the total
  bool averages = true;

  double get getActiveCalories => healthService.getBasicHealthItemValue(HealthDataType.ACTIVE_ENERGY_BURNED, averages);
  double get getRestingCalories => healthService.getBasicHealthItemValue(HealthDataType.BASAL_ENERGY_BURNED, averages);
  double get getDietaryCalories => healthService.getBasicHealthItemValue(HealthDataType.DIETARY_ENERGY_CONSUMED, averages);
  double get getProtein => healthService.getBasicHealthItemValue(HealthDataType.DIETARY_PROTEIN_CONSUMED, averages);
  double get getExerciseMinutes => healthService.getBasicHealthItemValue(HealthDataType.EXERCISE_TIME, averages);
  double get getStrengthTrainingMinutes => healthService.getStrengthTrainingMinutes(averages);
  double get getCardioMinutes => healthService.getCardioMinutes(averages);
  double get getSteps => healthService.getBasicHealthItemValue(HealthDataType.STEPS, averages);
  double get getSleep => healthService.getBasicHealthItemValue(HealthDataType.SLEEP_ASLEEP, averages);

}
