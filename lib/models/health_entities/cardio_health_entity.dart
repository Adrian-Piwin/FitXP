import 'package:health/health.dart';
import 'package:healthcore/constants/workout_definitions.constants.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/data_points/workout_data_point.model.dart';
import 'package:healthcore/models/health_entities/workout_health_entity.model.dart';

class CardioHealthEntity extends WorkoutHealthEntity {
  CardioHealthEntity(super.healthItem, super.widgetSize, super.healthFetcherService);

  @override
  List<WorkoutDataPoint> workoutDataPoints(Map<HealthDataType, List<DataPoint>> data) {
    var workoutDataPoints =  super.workoutDataPoints(data);
    return workoutDataPoints.where((point) => !WorkoutDefinitions.strengthTrainingWorkoutTypes.contains(point.workoutType)).toList();
  }
}
