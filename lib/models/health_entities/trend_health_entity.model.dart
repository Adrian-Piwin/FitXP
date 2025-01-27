import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/utility/health.utility.dart';

class TrendHealthEntity extends HealthEntity {
  TrendHealthEntity(super.healthItem, super.widgetSize, super.healthFetcherService);

  DataPoint? get mostRecentDataPoint {
    if (getCurrentData.isEmpty) return null;
    return getCurrentData.reduce(
      (a, b) => a.dateFrom.isAfter(b.dateFrom) ? a : b
    );
  }

  String get getDisplayGoalWithUnitProgress {
    if (mostRecentDataPoint == null) return "--";
    return "${(mostRecentDataPoint!.value - goal).abs().toStringAsFixed(0)}${healthItem.unit} away";
  }

  @override
  double get getGoalPercent{
    return -1;
  }

  @override
  double get average {
    cachedAverage ??= getTrendHealthAverage(getCurrentData);
    return cachedAverage!;
  }

  // We only want the most recent data point for each day
  @override
  List<DataPoint> get getCurrentData {
    List<DataPoint> data = super.getCurrentData;
    return getLatestPointPerDay(data);
  }

  // Include the past 30 days so we can get the most recent data point
  @override
  void updateQuery(TimeFrame newTimeFrame, int newOffset) {
    super.updateQuery(newTimeFrame, newOffset);
    queryDateRange = DateTimeRange(
      start: queryDateRange!.start.subtract(const Duration(days: 30)),
      end: queryDateRange!.end
    );
  }

  @override
  String get getDisplayValueWithUnit {
    if (showLoading) return "--";
    if (mostRecentDataPoint == null) return "--";
    
    return mostRecentDataPoint!.value.toStringAsFixed(1) + healthItem.unit;
  }

  @override
  String get getDisplaySubtitle {
    if (showLoading) return "--";
    if (getCurrentData.isEmpty) return "No data";

    return "${average.toStringAsFixed(1)}${healthItem.unit} avg";
  }

  @override
  List<Widget> get getInfoWidgets {
    return [
      InfoWidget(
        title: "Average",
        displayValue: getDisplayAverage,
      ),
      InfoWidget(
        title: "Goal",
        displayValue: getDisplayGoalWithUnit,
      ),
      InfoWidget(
        title: "Goal Progress",
        displayValue: getDisplayGoalWithUnitProgress,
      ),
    ];
  }

  @override
  HealthEntity clone() {
    return TrendHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }
}
