import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/trend_health_entity.model.dart';

class BodyfatHealthEntity extends TrendHealthEntity {
  BodyfatHealthEntity(super.healthItem, super.goals, super.widgetSize);

  @override
  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    super.updateData(batchData);
    data = data.map((key, value) => MapEntry(key, value.map((point) => DataPoint(value: point.value * 100, dateFrom: point.dateFrom, dateTo: point.dateTo, dayOccurred: point.dayOccurred)).toList()));
  }

  @override
  void updateQuery(TimeFrame newTimeFrame, int newOffset) {
    super.updateQuery(newTimeFrame, newOffset);
    queryDateRange = DateTimeRange(
      start: queryDateRange!.start.subtract(const Duration(days: 30)),
      end: queryDateRange!.end
    );
  }
}
