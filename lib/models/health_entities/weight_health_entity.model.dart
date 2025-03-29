import 'package:healthcore/constants/magic_numbers.constants.dart';
import 'package:healthcore/enums/unit_system.enum.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/models/health_entities/trend_health_entity.model.dart';
import 'package:healthcore/services/preferences_service.dart';

class WeightHealthEntity extends TrendHealthEntity {
  WeightHealthEntity(super.healthItem, super.widgetSize, super.healthFetcherService);

  @override
  Future<void> updateData() async {
    await super.updateData();
    await _convertToImperialIfNeeded();
  }

  Future<void> _convertToImperialIfNeeded() async {
    if (await PreferencesService.getUnitSystem() == UnitSystem.imperial) {
      healthItem.unit = imperialUnit;
      data = data.map((key, value) => MapEntry(key, value.map((point) => DataPoint(value: point.value * imperialToMetricFactor, dateFrom: point.dateFrom, dateTo: point.dateTo, dayOccurred: point.dayOccurred)).toList()));
    }
  }

  @override
  HealthEntity clone() {
    return WeightHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }
}
