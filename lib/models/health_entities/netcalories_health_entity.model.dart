import 'package:health/health.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

class NetCaloriesHealthEntity extends HealthEntity {
  NetCaloriesHealthEntity(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    Map<HealthDataType, List<DataPoint>> newData = Map.from(batchData);
    if (batchData.containsKey(HealthDataType.DIETARY_ENERGY_CONSUMED)) {
      newData[HealthDataType.DIETARY_ENERGY_CONSUMED] = batchData[HealthDataType.DIETARY_ENERGY_CONSUMED]!
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo))
          .toList();
    }
    super.updateData(newData);
  }

  @override
  double get getGoalPercent {
    if (goal == 0) return 0.0;

    double total = this.total;
    if (goal < 0) {
      if (total > 0) {
        return 0;
      }
      total = total.abs();
    }
    return (total / goal.abs()).clamp(0, 1.0);
  }

  @override
  HealthEntity clone() {
    return NetCaloriesHealthEntity(healthItem, goals, widgetSize)..data = data;
  }
}
