import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';

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
    if (isLoading) return "--";
    if (mostRecentDataPoint == null) return "--";
    
    return mostRecentDataPoint!.value.toStringAsFixed(1);
  }

  @override
  String get getDisplaySubtitle {
    if (isLoading) return "--";
    if (getCombinedData.isEmpty) return "No data";

    return "Avg: ${average.toStringAsFixed(1)}${healthItem.unit}";
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
