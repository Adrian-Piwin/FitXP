import 'package:healthxp/models/data_points/data_point.model.dart';

class WorkoutDataPoint extends DataPoint {
  final String? workoutType;
  final double? energyBurned;
  final double? distance;
  final String? distanceUnit;
  final int? steps;

  WorkoutDataPoint({
    required super.value,
    required super.dateFrom,
    required super.dateTo,
    required super.dayOccurred,
    required this.workoutType,
    required this.energyBurned,
    required this.distance,
    required this.distanceUnit,
    required this.steps,
  });
}
