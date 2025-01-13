import 'package:health/health.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';
import 'package:healthxp/models/data_points/workout_data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

class WorkoutHealthEntity extends HealthEntity {
  WorkoutHealthEntity(super.healthItem, super.widgetSize);

  List<WorkoutDataPoint> get workoutDataPoints {
    if (data[HealthDataType.WORKOUT] == null || data[HealthDataType.WORKOUT]!.isEmpty) {
      return [];
    }
    
    return data[HealthDataType.WORKOUT]!.map((point) {
      if (point is WorkoutDataPoint) {
        return point;
      }
      // If it's a regular DataPoint, convert it to WorkoutDataPoint
      return WorkoutDataPoint(
        value: point.value,
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        dayOccurred: point.dayOccurred,
        workoutType: '',
        energyBurned: 0,
        distance: 0,
        distanceUnit: '',
        steps: 0,
      );
    }).toList();
  }

  @override
  List<DataPoint> get getCurrentData {
    return workoutDataPoints.where((point) => strengthTrainingTypes.contains(point.workoutType)).toList() as List<DataPoint>;
  }

  @override
  HealthEntity clone() {
    return WorkoutHealthEntity(healthItem, widgetSize)..data = data;
  }
}
