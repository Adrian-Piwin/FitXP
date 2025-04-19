import 'package:health/health.dart';
import 'package:healthcore/enums/sleep_stages.enum.dart';

String formatMinutes(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return hours > 0 
    ? "$hours:${minutes.toString().padLeft(2, '0')} ${hours > 1 ? 'hrs' : 'hr'}" 
    : "${minutes}min";
}

String formatMinutesWithoutUnit(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return hours > 0 
    ? "$hours:${minutes.toString().padLeft(2, '0')}" 
    : "$minutes";
}

String formatNumber(num number, {int decimalPlaces = 0}) {
  return number.toStringAsFixed(decimalPlaces).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},'
  );
}

String formatNumberSimple(double number) {
  return number.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},'
  );
}

/// Maps a [HealthDataType] to our [SleepStage] enum.
SleepStage mapSleepStage(HealthDataType type) {
  switch (type) {
    case HealthDataType.SLEEP_AWAKE:
      return SleepStage.awake;
    case HealthDataType.SLEEP_DEEP:
      return SleepStage.deep;
    case HealthDataType.SLEEP_LIGHT:
      return SleepStage.light;
    case HealthDataType.SLEEP_REM:
      return SleepStage.rem;
    default:
      return SleepStage.unknown;
  }
}

  String formatDuration(double minutes) {
    final int totalMinutes = minutes.round();
    final int hours = totalMinutes ~/ 60;
    final int remainingMinutes = totalMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }

  /// Returns the number of minutes remaining in the current day
  /// For example, at 11:30 PM it would return 30 minutes
  int getMinutesLeftInDay() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
    final difference = endOfDay.difference(now);
    return difference.inMinutes;
  }

  /// Returns the number of minutes that have passed in the current day
  /// For example, at 11:30 PM it would return 1410 minutes (23.5 hours)
  int getMinutesPassedToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final difference = now.difference(startOfDay);
    return difference.inMinutes;
  }
