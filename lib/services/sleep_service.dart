import 'package:health/health.dart';
import 'package:healthxp/models/data_point.model.dart';

class SleepService {
  final Map<HealthDataType, List<DataPoint>> sleepData;

  SleepService(this.sleepData);

  int calculateSleepScore() {
    // Extract total sleep, REM, deep, and light sleep data
    final totalSleep = _calculateTotal(HealthDataType.SLEEP_ASLEEP);
    final remSleep = _calculateTotal(HealthDataType.SLEEP_REM);
    final deepSleep = _calculateTotal(HealthDataType.SLEEP_DEEP);
    final lightSleep = _calculateTotal(HealthDataType.SLEEP_LIGHT);

    if (totalSleep == 0) {
      return 0; // If there's no sleep data, score is 0
    }

    // Calculate percentages for REM, Deep, and Light sleep
    final remPercentage = (remSleep / totalSleep) * 100;
    final deepPercentage = (deepSleep / totalSleep) * 100;
    final lightPercentage = (lightSleep / totalSleep) * 100;

    // Calculate subscores
    final totalScore = _scoreTotalSleep(totalSleep);
    final remScore = _scorePercentage(remPercentage, 22.5, 4);
    final deepScore = _scorePercentage(deepPercentage, 17.5, 4);
    final lightPenalty = _lightSleepPenalty(lightPercentage);

    // Calculate overall score
    double sleepScore = (0.4 * totalScore) + (0.3 * remScore) + (0.3 * deepScore) - lightPenalty;

    // Clamp score to 0-100
    sleepScore = sleepScore.clamp(0, 100);

    return sleepScore.round();
  }

  double _calculateTotal(HealthDataType type) {
    final dataPoints = sleepData[type];
    if (dataPoints == null || dataPoints.isEmpty) {
      return 0;
    }
    return dataPoints.fold(0, (sum, dp) => sum + dp.value);
  }

  int _scoreTotalSleep(double totalMinutes) {
    // Full score for 420-540 minutes (7-9 hours), proportional score otherwise
    if (totalMinutes < 300) return 0; // Below 5 hours, no score
    if (totalMinutes > 540) return 100; // More than 9 hours gets full score
    return ((totalMinutes - 300) / 240 * 100).clamp(0, 100).round();
  }

  int _scorePercentage(double percentage, double target, double weight) {
    // Scaled score based on deviation from the target percentage
    return (100 - (percentage - target).abs() * weight).clamp(0, 100).round();
  }

  int _lightSleepPenalty(double lightPercentage) {
    // Penalty for light sleep above 55%
    return lightPercentage > 55 ? ((lightPercentage - 55) * 2).round() : 0;
  }
}
