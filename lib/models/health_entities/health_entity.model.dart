import 'dart:async';

import 'package:flutter/material.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/constants/magic_numbers.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/pages/home/basic_large_widget_item.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:health/health.dart';
import 'package:healthxp/utility/timeframe.utility.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../utility/health.utility.dart';

class HealthEntity{
  final HealthItem healthItem;
  final Goal goals;
  final int widgetSize;

  Map<HealthDataType, List<DataPoint>> data = {};
  bool _isLoading = false;
  bool _showLoading = false;
  Timer? _loadingTimer;

  // Getter and setter for isLoading to handle the delayed showLoading
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (value) {
      _loadingTimer?.cancel();
      _loadingTimer = Timer(loadingDelay, () {
        _showLoading = true;
      });
    } else {
      _loadingTimer?.cancel();
      _showLoading = false;
    }
  }

  TimeFrame timeframe = TimeFrame.day;
  int offset = 0;
  DateTimeRange? queryDateRange;
  double? cachedTotal;
  double? cachedAverage;
  List<DataPoint>? cachedMergedData;
  double goal = 0;

  HealthEntity(this.healthItem, this.goals, this.widgetSize){
    goal = healthItem.getGoal != null && healthItem.getGoal!(goals) != -1 ? healthItem.getGoal!(goals) : -1;
  }

  // #region Getters

  // The total sum of all combined data points
  double get total {
    cachedTotal ??= getHealthTotal(getCurrentData);
    return cachedTotal!;
  }

  // The daily average of all combined data points
  double get average {
    cachedAverage ??= getHealthAverage(getCurrentData);
    return cachedAverage!;
  }

  List<DataPoint> get getMergedData {
    cachedMergedData ??= mergeDataPoints(data);
    return cachedMergedData!;
  }

  // The combined data points for all types
  List<DataPoint> get getCombinedData {
    return data.values.expand((list) => list).toList();
  }

  // Use this for the context of our datapoints for the selected timeframe and offset
  List<DataPoint> get getCurrentData {
    return getCombinedData;
  }

  // The percentage of the goal for this health entity against our total
  double get getGoalPercent {
    if (_showLoading) return 0;

    if (goal == 0) return 0.0;
    if (goal == -1) return -1;
    return (total / goal).clamp(0.0, 1.0);
  }

  // The percentage of the goal for this health entity against our daily average
  double get getGoalAveragePercent {
    if (goal == 0) return 0.0;
    if (goal == -1) return -1;
    return (average / goal).clamp(0, double.infinity);
  }

  // The subtitle for the home page widget
  String get getDisplaySubtitle {
    if (_showLoading) return "--";

    if (timeframe == TimeFrame.day && goal != -1) {
      return goal - total >= 0 ? 
          "${(goal - total).toStringAsFixed(0)}${healthItem.unit} left" : 
          "${(total - goal).toStringAsFixed(0)}${healthItem.unit} over";
    } else {
      return "${average.toStringAsFixed(0)} avg";
    }
  }

  // The main value displayed on the home page widget
  String get getDisplayValue {
    if (_showLoading) return "--";
    return (total).toStringAsFixed(0) + healthItem.unit;
  }

  // The daily average displayed on the details page widget
  String get getDisplayAverage {
    if (_showLoading) return "--";
    return (average).toStringAsFixed(0) + healthItem.unit;
  }

  // The goal value displayed on the details page widget
  String get getDisplayGoal {
    if (_showLoading) return "--";
    return (goal).toStringAsFixed(0) + healthItem.unit;
  }

  // The percentage of the goal for this health entity against our daily average
  String get getDisplayGoalAveragePercent {
    if (_showLoading) return "--";
    return "${(getGoalAveragePercent * 100).toStringAsFixed(0)}%";
  }

  // #endregion

  // #region Widget 

  Widget generateWidget() {
    return BasicLargeWidgetItem(
      widget: this,
    );
  }

  // #endregion

  // #region Bar Chart

  // The data points for the bar chart
  List<BarData> get getBarchartData {
    if (getCurrentData.isEmpty) return [];
    return ChartUtility.groupDataByTimeFrame(getCurrentData, timeframe, offset);
  }

  // The value displayed on the bar chart
  String getBarchartValue(double value) {
    return value.toStringAsFixed(0);
  }

  // The label for the x-axis of the bar chart
  String getXAxisLabel(double value) {
    return ChartUtility.getXAxisLabel(getBarchartData, timeframe, value);
  }

  // #endregion

  // #region Info widgets

  // The graph widget displayed on the details page
  Widget get getGraphWidget {
    if (_showLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.mediumHeight);

    return BarChartWidget(
      groupedData: getBarchartData,
      barColor: healthItem.color,
      getXAxisLabel: getXAxisLabel,
      getBarchartValue: getBarchartValue,
    );
  }

  // The widgets displayed on the details page
  List<Widget> get getDetailWidgets {
    return [
      getGraphWidget,
      InfoWidget(
        title: "Total",
        displayValue: getDisplayValue,
      ),
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
        displayValue: getDisplayGoalAveragePercent,
      ),
    ];
  }

  // #endregion

  // #region Update

  void updateQuery(TimeFrame newTimeFrame, int newOffset) {
    queryDateRange = calculateDateRange(newTimeFrame, newOffset);
    timeframe = newTimeFrame;
    offset = newOffset;
  }

  // Update the data we will use for this health entity
  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    data = Map.fromEntries(
      healthItem.dataType.map((type) => 
        MapEntry(type, batchData[type] ?? [])
      )
    );
    _clearCache();
  }

  // #endregion

  // #region Clone

  HealthEntity clone() {
    return HealthEntity(healthItem, goals, widgetSize)..data = data;
  }

  static HealthEntity from(HealthEntity widget) {
    return widget.clone();
  }

  // #endregion

  // #region Internal functions

  void _clearCache() {
    cachedTotal = null;
    cachedAverage = null;
    cachedMergedData = null;
  }

  void dispose() {
    _loadingTimer?.cancel();
  }
  // #endregion
}
