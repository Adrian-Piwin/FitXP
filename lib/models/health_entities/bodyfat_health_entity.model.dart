import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/models/health_entities/trend_health_entity.model.dart';

class BodyfatHealthEntity extends TrendHealthEntity {
  BodyfatHealthEntity(super.healthItem, super.widgetSize, super.healthFetcherService);

  @override
  Future<void> updateData() async {
    await super.updateData();
    data = data.map((key, value) => MapEntry(key, value.map((point) => DataPoint(value: point.value * 100, dateFrom: point.dateFrom, dateTo: point.dateTo, dayOccurred: point.dayOccurred)).toList()));
  }

  @override
  String get getDisplayGoalWithUnit {
    if (showLoading) return "--";
    return "${goal.toStringAsFixed(1)}%";
  }

  @override
  HealthEntity clone() {
    return BodyfatHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }
}
