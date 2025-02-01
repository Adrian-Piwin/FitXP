import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/data_points/sleep_data_point.model.dart';

class SleepService {
  final List<SleepDataPoint> sleepData;

  SleepService(this.sleepData);

  static String getSleepQualityDescription(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Poor';
  }

  int calculateSleepScore() {
    if (sleepData.isEmpty) return 0;
    
    // Extract sleep stage durations in minutes
    final totalSleep = _calculateTotal([SleepStage.rem, SleepStage.deep, SleepStage.light]);
    final remSleep = _calculateTotal([SleepStage.rem]);
    final deepSleep = _calculateTotal([SleepStage.deep]);
    final lightSleep = _calculateTotal([SleepStage.light]);

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
      if (lightSleepRatio > 0.70) {  // Only penalize if light sleep is >70% of total
        sleepScore -= (lightSleepRatio - 0.70) * 10;  // Further reduced penalty
      }
    }

    return sleepScore.clamp(0, 100).round();
  }

  double _calculateTotal(List<SleepStage> types) {
    var dataPoints = sleepData.where((point) => types.contains(point.sleepStage)).toList();
    if (dataPoints.isEmpty) {
      return 0;
    }
    return dataPoints.fold(0, (sum, dp) => sum + dp.value);
  }

  int _scoreTotalSleep(double totalMinutes) {
    if (totalMinutes < 240) return 30;  // Less than 4 hours
    if (totalMinutes > 540 && totalMinutes < 600) return 80;  // 9-10 hours
    if (totalMinutes > 600) return 70;  // More than 10 hours
    
    // Perfect range: 420-540 minutes (7-9 hours)
    if (totalMinutes >= 420 && totalMinutes <= 540) return 100;
    
    // Between 4-7 hours
    return 50;
  }

  int _scoreStageDuration(double minutes, double targetMinutes) {
    if (minutes == 0) return 0;
    
    // Calculate the ratio of actual to target duration
    double ratio = minutes / targetMinutes;
    
    // More lenient scoring:
    // Perfect score if within 15% of target duration
    if (ratio >= 0.85 && ratio <= 1.15) return 100;
    
    if (ratio < 0.85) {
      return ((ratio / 0.85) * 100).round();  // Minimum 40 if any sleep in this stage
    } else {
      return (100 - (ratio - 1.15) * 60).clamp(0, 100).round();  // Steeper decline
    }
  }
}
