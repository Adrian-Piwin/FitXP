import 'package:health/health.dart';

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
