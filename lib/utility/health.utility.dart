import 'package:health/health.dart';

List<String> strengthTrainingTypes = [
  "traditionalStrengthTraining",
  "functionalStrengthTraining",
  "weightLifting",
  "highIntensityIntervalTraining",
  "strengthTraining"
];

double getHealthAverage(List<HealthDataPoint> data) {
  double sum = data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + (element.value as NumericHealthValue).numericValue,
  );

  return data.isNotEmpty ? sum / data.length : 0.0;
}

double getHealthTotal(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + (element.value as NumericHealthValue).numericValue,
  );
}

double getWorkoutMinutes(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.dateTo.difference(element.dateFrom).inMinutes,
  );
}

double getWorkoutEnergyBurned(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.workoutSummary!.totalEnergyBurned,
  );
}

// Extract strength training minutes
List<HealthDataPoint> extractStrengthTrainingMinutes(
    List<HealthDataPoint> dataPoints) {
  return dataPoints
      .where((point) =>
          strengthTrainingTypes.contains(point.workoutSummary?.workoutType))
      .toList();
}

// Extract cardio minutes
List<HealthDataPoint> extractCardioMinutes(List<HealthDataPoint> dataPoints) {
  return dataPoints
      .where((point) =>
          !strengthTrainingTypes.contains(point.workoutSummary?.workoutType))
      .toList();
}
