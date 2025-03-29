import 'package:health/health.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';

class NetCaloriesHealthEntity extends HealthEntity {
  NetCaloriesHealthEntity(
    super.healthItem,
    super.timeFrame,
    super.healthFetcherService,
  );

  @override
  List<DataPoint> aggregateData(Map<HealthDataType, List<DataPoint>> data) {
    Map<HealthDataType, List<DataPoint>> newData = Map.from(data);

    if (data.containsKey(HealthDataType.ACTIVE_ENERGY_BURNED)) {
      newData[HealthDataType.ACTIVE_ENERGY_BURNED] = data[HealthDataType.ACTIVE_ENERGY_BURNED]!
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo,
                dayOccurred: point.dayOccurred,
              ))
          .toList();
    }
    if (data.containsKey(HealthDataType.BASAL_ENERGY_BURNED)) {
      newData[HealthDataType.BASAL_ENERGY_BURNED] = data[HealthDataType.BASAL_ENERGY_BURNED]!
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo,
                dayOccurred: point.dayOccurred,
              ))
          .toList();
    }
    return newData.values.expand((list) => list).toList();
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
    return NetCaloriesHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }
}
