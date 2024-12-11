import 'package:health/health.dart';
import 'package:healthxp/models/data_point.model.dart';

class SleepService {
  final Map<HealthDataType, List<DataPoint>> sleepData;

  SleepService(this.sleepData);

  String getSleepQualityDescription(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Poor';
  }

  int calculateSleepScore() {
    // Extract sleep stage durations in minutes
    final totalSleep = _calculateTotal(HealthDataType.SLEEP_ASLEEP);
    final remSleep = _calculateTotal(HealthDataType.SLEEP_REM);
    final deepSleep = _calculateTotal(HealthDataType.SLEEP_DEEP);
    final lightSleep = _calculateTotal(HealthDataType.SLEEP_LIGHT);

    if (totalSleep == 0) return 0;

    // Calculate percentages of each sleep stage
    final remPercentage = (remSleep / totalSleep) * 100;
    final deepPercentage = (deepSleep / totalSleep) * 100;
    final lightPercentage = (lightSleep / totalSleep) * 100;

    // Ideal ranges based on sleep science:
    // - Total sleep: 7-9 hours (420-540 minutes)
    // - REM: 20-25% of total sleep
    // - Deep: 15-25% of total sleep
    // - Light: 50-60% of total sleep

    // Calculate subscores
    final durationScore = _scoreTotalSleep(totalSleep);          // 40% weight
    final remScore = _scorePercentage(remPercentage, 22.5, 2);   // 30% weight
    final deepScore = _scorePercentage(deepPercentage, 20, 2);   // 30% weight
    
    // Only apply light sleep penalty if it's significantly above ideal range
    final lightPenalty = _lightSleepPenalty(lightPercentage);

    // Calculate weighted score
    double sleepScore = (0.4 * durationScore) + 
                       (0.3 * remScore) + 
                       (0.3 * deepScore) - 
                       lightPenalty;

    return sleepScore.clamp(0, 100).round();
  }

  double _calculateTotal(HealthDataType type) {
    final dataPoints = sleepData[type];
    if (dataPoints == null || dataPoints.isEmpty) {
      return 0;
    }
    return dataPoints.fold(0, (sum, dp) => sum + dp.value);
  }

  int _scoreTotalSleep(double totalMinutes) {
    if (totalMinutes < 300) return 40;  // Less than 5 hours: base score
    if (totalMinutes > 600) return 70;  // More than 10 hours: reduced score
    
    // Perfect range: 420-540 minutes (7-9 hours)
    if (totalMinutes >= 420 && totalMinutes <= 540) return 100;
    
    // Between 5-7 hours or 9-10 hours: proportional score
    if (totalMinutes < 420) {
      return (40 + ((totalMinutes - 300) / 120) * 60).round();  // 5-7 hours
    } else {
      return (100 - ((totalMinutes - 540) / 60) * 30).round();  // 9-10 hours
    }
  }

  int _scorePercentage(double percentage, double target, double weight) {
    // Perfect score if within 2.5% of target
    if ((percentage - target).abs() <= 2.5) return 100;
    
    // Calculate score based on deviation from target
    // Less aggressive penalty for being off-target
    return (100 - (percentage - target).abs() * weight).clamp(0, 100).round();
  }

  int _lightSleepPenalty(double lightPercentage) {
    // Only penalize if light sleep is significantly above ideal range (>65%)
    if (lightPercentage > 65) {
      return ((lightPercentage - 65) * 1.5).round();
    }
    return 0;
  }
}
