import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/utility/health.utility.dart';
import 'package:healthxp/utility/timeframe.utility.dart';

class TrendHealthEntity extends HealthEntity {
  TrendHealthEntity(super.healthItem, super.goals, super.widgetSize);

  DataPoint? get mostRecentDataPoint {
    if (getCombinedData.isEmpty) return null;
    return getCombinedData.reduce(
      (a, b) => a.dateFrom.isAfter(b.dateFrom) ? a : b
    );
  }

  String get getDisplayGoalProgress {
    if (mostRecentDataPoint == null) return "--";
    return "${(mostRecentDataPoint!.value - goal).abs().toStringAsFixed(0)}${healthItem.unit} away";
  }

  @override
  double get getGoalPercent{
    return -1;
  }

  @override
  double get average {
    cachedAverage ??= getTrendHealthAverage(getCombinedData);
    return cachedAverage!;
  }

  // Filter out the data points that are not in the current timeframe
  @override
  List<DataPoint> get getCurrentData {
    var contextDataRange = calculateDateRange(timeframe, offset);
    return getCombinedData.where((point) => point.dateFrom.isAfter(contextDataRange.start) && point.dateTo.isBefore(contextDataRange.end)).toList();
  }

  // We only want the most recent data point for each day
  @override
  List<DataPoint> get getCombinedData {
    List<DataPoint> data = super.getCombinedData;
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
  String get getDisplayValue {
    if (showLoading) return "--";
    if (mostRecentDataPoint == null) return "--";
    
    return mostRecentDataPoint!.value.toStringAsFixed(1) + healthItem.unit;
  }

  @override
  String get getDisplaySubtitle {
    if (showLoading) return "--";
    if (getCombinedData.isEmpty) return "No data";

    return "${average.toStringAsFixed(1)}${healthItem.unit} avg";
  }

  @override
  List<Widget> get getDetailWidgets {
    return [
      getGraphWidget,
      InfoWidget(
        title: "Average",
        displayValue: getDisplayAverage,
      ),
      InfoWidget(
        title: "Goal",
        displayValue: getDisplayGoal,
      ),
      InfoWidget(
        title: "Goal Progress",
        displayValue: getDisplayGoalProgress,
      ),
    ];
  }

  @override
  HealthEntity clone() {
    return TrendHealthEntity(healthItem, goals, widgetSize)..data = data;
  }
}
