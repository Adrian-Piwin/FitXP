import 'package:health/health.dart';

List<String> strengthTrainingTypes = [
  "traditionalStrengthTraining",
  "functionalStrengthTraining",
  "weightLifting",
  "highIntensityIntervalTraining",
  "strengthTraining"
];

double getHealthAverage(List<HealthDataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of health points for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);

    // Add the value to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + (point.value as NumericHealthValue).numericValue;
    } else {
      dailySums[date] = (point.value as NumericHealthValue).numericValue.toDouble();
    }
  }

  // Calculate the total sum of health points
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
}

double getHealthTotal(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + (element.value as NumericHealthValue).numericValue,
  );
}

double getWorkoutMinutesTotal(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.dateTo.difference(element.dateFrom).inMinutes,
  );
}

double getWorkoutMinutesAverage(List<HealthDataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of workout minutes for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);

    // Calculate the workout minutes for the current point
    double workoutMinutes = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();

    // Add the workout minutes to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + workoutMinutes;
    } else {
      dailySums[date] = workoutMinutes;
    }
  }

  // Calculate the total sum of workout minutes
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
}

double getWorkoutEnergyBurned(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.workoutSummary!.totalEnergyBurned,
  );
}

double getWorkoutEnergyBurnedAverage(List<HealthDataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of workout energy burned for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);

    // Add the workout energy burned to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + point.workoutSummary!.totalEnergyBurned;
    } else {
      dailySums[date] = point.workoutSummary!.totalEnergyBurned.toDouble();
    }
  }

  // Calculate the total sum of workout energy burned
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
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
