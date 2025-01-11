import 'package:health/health.dart';
import 'package:healthxp/constants/magic_numbers.constants.dart';
import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/health_entities/trend_health_entity.model.dart';
import 'package:healthxp/services/preferences_service.dart';

class WeightHealthEntity extends TrendHealthEntity {
  WeightHealthEntity(super.healthItem, super.goals, super.widgetSize);

  @override
  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    super.updateData(batchData);
    _convertToImperialIfNeeded();
  }

  Future<void> _convertToImperialIfNeeded() async {
    if (await PreferencesService.getUnitSystem() == UnitSystem.imperial) {
      healthItem.unit = imperialUnit;
      data = data.map((key, value) => MapEntry(key, value.map((point) => DataPoint(value: point.value * imperialToMetricFactor, dateFrom: point.dateFrom, dateTo: point.dateTo, dayOccurred: point.dayOccurred)).toList()));
    }
  }

  @override
  HealthEntity clone() {
    return WeightHealthEntity(healthItem, goals, widgetSize)..data = data;
  }
}
