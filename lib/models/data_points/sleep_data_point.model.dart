import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/enums/sleep_stages.enum.dart';

class SleepDataPoint extends DataPoint {
  final SleepStage? sleepStage;

  SleepDataPoint({
    required super.value,
    required super.dateFrom,
    required super.dateTo,
    required super.dayOccurred,
    required this.sleepStage,
  });
}
