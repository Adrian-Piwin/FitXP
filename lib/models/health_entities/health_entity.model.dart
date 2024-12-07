import 'package:flutter/material.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/pages/home/basic_large_widget_item.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:health/health.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../utility/health.utility.dart';

class HealthEntity{
  final HealthItem healthItem;
  final Goal goals;
  final int widgetSize;

  Map<HealthDataType, List<DataPoint>> data = {};
  bool isLoading = false;

  TimeFrame timeframe = TimeFrame.day;
  int offset = 0;
  double? _cachedTotal;
  double? _cachedAverage;
  List<DataPoint>? _cachedMergedData;
  double goal = 0;

  HealthEntity(this.healthItem, this.goals, this.widgetSize){
    goal = healthItem.getGoal != null && healthItem.getGoal!(goals) != -1 ? healthItem.getGoal!(goals) : -1;
  }

  // #region Getters

  double get total {
    _cachedTotal ??= getHealthTotal(getCombinedData);
    return _cachedTotal!;
  }

  double get average {
    _cachedAverage ??= getHealthAverage(getCombinedData);
    return _cachedAverage!;
  }

  List<DataPoint> get getMergedData {
    _cachedMergedData ??= mergeDataPoints(data);
    return _cachedMergedData!;
  }

  List<DataPoint> get getCombinedData {
    return data.values.expand((list) => list).toList();
  }

  double get getGoalPercent {
    if (isLoading) return 0;

    if (goal == 0) return 0.0;
    if (goal == -1) return -1;
    return (total / goal).clamp(0.0, 1.0);
  }

  double get getGoalAveragePercent {
    if (goal == 0) return 0.0;
    if (goal == -1) return -1;
    return (average / goal).clamp(0, double.infinity);
  }

  String get getDisplaySubtitle {
    if (isLoading) return "--";

    if (timeframe == TimeFrame.day && goal != -1) {
      return goal - total >= 0 ? 
          "${(goal - total).toStringAsFixed(0)}${healthItem.unit} left" : 
          "${(total - goal).toStringAsFixed(0)}${healthItem.unit} over";
    } else {
      return "${average.toStringAsFixed(0)} avg";
    }
  }

  String get getDisplayValue {
    if (isLoading) return "--";
    return (total).toStringAsFixed(0);
  }

  String get getDisplayAverage {
    if (isLoading) return "--";
    return (average).toStringAsFixed(0);
  }

  String get getDisplayGoal {
    if (isLoading) return "--";
    return (goal).toStringAsFixed(0);
  }

  String get getDisplayGoalAveragePercent {
    if (isLoading) return "--";
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

  List<BarData> get getBarchartData {
    if (getCombinedData.isEmpty) return [];
    return ChartUtility.groupDataByTimeFrame(getCombinedData, timeframe, offset);
  }

  String getBarchartValue(double value) {
    return value.toStringAsFixed(0);
  }

  String getXAxisLabel(double value) {
    return ChartUtility.getXAxisLabel(getBarchartData, timeframe, value);
  }

  // #endregion

  // #region Info widgets

  Widget get getGraphWidget {
    if (isLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.mediumHeight);

    return BarChartWidget(
      groupedData: getBarchartData,
      barColor: healthItem.color,
      getXAxisLabel: getXAxisLabel,
      getBarchartValue: getBarchartValue,
    );
  }

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

  void updateData(Map<HealthDataType, List<DataPoint>> batchData, TimeFrame newTimeFrame, int newOffset) {
    data = Map.fromEntries(
      healthItem.dataType.map((type) => 
        MapEntry(type, batchData[type] ?? [])
      )
    );
    clearCache();
    timeframe = newTimeFrame;
    offset = newOffset;
  }

  // #endregion

  void clearCache() {
    _cachedTotal = null;
    _cachedAverage = null;
    _cachedMergedData = null;
  }

  // #region Clone

  HealthEntity clone() {
    return HealthEntity(healthItem, goals, widgetSize)..data = data;
  }

  static HealthEntity from(HealthEntity widget) {
    return widget.clone();
  }

  // #endregion
}
