import 'package:health/health.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';

String formatMinutes(int totalMinutes) {
  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;
  return hours > 0 
    ? "$hours:${minutes.toString().padLeft(2, '0')} ${hours > 1 ? 'hrs' : 'hr'}" 
    : "${minutes}min";
}

String formatNumber(num number) {
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
