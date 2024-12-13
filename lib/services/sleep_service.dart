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
    if (sleepData.isEmpty) return 0;
    
    // Extract sleep stage durations in minutes
    final totalSleep = _calculateTotal(HealthDataType.SLEEP_ASLEEP);
    final remSleep = _calculateTotal(HealthDataType.SLEEP_REM);
    final deepSleep = _calculateTotal(HealthDataType.SLEEP_DEEP);
    final lightSleep = _calculateTotal(HealthDataType.SLEEP_LIGHT);

    if (totalSleep == 0) return 0;

    // Calculate subscores
    final durationScore = _scoreTotalSleep(totalSleep);          // 60% weight
    final remScore = _scoreStageDuration(remSleep, 108);         // 20% weight
    final deepScore = _scoreStageDuration(deepSleep, 96);        // 20% weight
    
    // Calculate weighted score
    double sleepScore = (0.6 * durationScore) + 
                       (0.2 * remScore) + 
                       (0.2 * deepScore);

    // Only apply light sleep penalty if it's excessive relative to total sleep
    if (totalSleep > 0) {
      double lightSleepRatio = lightSleep / totalSleep;
      if (lightSleepRatio > 0.65) {  // Only penalize if light sleep is >65% of total
        sleepScore -= (lightSleepRatio - 0.65) * 20;  // Reduced penalty
      }
    }

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
    if (totalMinutes < 240) return 50;  // Minimum 50 score if at least 4 hours
    if (totalMinutes > 600) return 75;  // More than 10 hours: reduced score but not severe
    
    // Perfect range: 420-540 minutes (7-9 hours)
    if (totalMinutes >= 420 && totalMinutes <= 540) return 100;
    
    // Between 4-7 hours or 9-10 hours: proportional score
    if (totalMinutes < 420) {
      return (50 + ((totalMinutes - 240) / 180) * 50).round();  // 4-7 hours
    } else {
      return (100 - ((totalMinutes - 540) / 60) * 25).round();  // 9-10 hours
    }
  }

  int _scoreStageDuration(double minutes, double targetMinutes) {
    if (minutes == 0) return 0;
    
    // Calculate the ratio of actual to target duration
    double ratio = minutes / targetMinutes;
    
    // More lenient scoring:
    // Perfect score if within 25% of target duration (increased from 15%)
    if (ratio >= 0.75 && ratio <= 1.25) return 100;
    
    // Less harsh penalties
    if (ratio < 0.75) {
      return (70 + (ratio / 0.75) * 30).round();  // Minimum 70 if any sleep in this stage
    } else {
      return (100 - (ratio - 1.25) * 30).clamp(0, 100).round();  // Gentler decline
    }
  }
}
