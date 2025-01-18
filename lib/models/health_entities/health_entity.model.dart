import 'dart:async';

import 'package:flutter/material.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/goal_edit_button.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/constants/magic_numbers.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/services/streak_service.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:health/health.dart';
import 'package:healthxp/utility/general.utility.dart';
import 'package:healthxp/utility/timeframe.utility.dart';
import '../../utility/health.utility.dart';
import '../../services/goals_service.dart';

class HealthEntity extends ChangeNotifier {
  final HealthItem healthItem;
  late final GoalsService _goalsService;
  final HealthFetcherService healthFetcherService;
  double? _cachedGoal;
  final int widgetSize;

  Map<HealthDataType, List<DataPoint>> data = {};
  bool showLoading = false;
  bool _isLoading = false;
  Timer? _loadingTimer;

  // Getter and setter for isLoading to handle the delayed showLoading
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (value) {
      _loadingTimer?.cancel();
      _loadingTimer = Timer(loadingDelay, () {
        showLoading = true;
      });
    } else {
      _loadingTimer?.cancel();
      showLoading = false;
    }
  }

  TimeFrame timeframe = TimeFrame.day;
  int offset = 0;
  DateTimeRange? queryDateRange;
  double? cachedTotal;
  double? cachedAverage;
  int? cachedStreak = 0;
  List<DataPoint>? cachedMergedData;

  HealthEntity(this.healthItem, this.widgetSize, this.healthFetcherService) {
    _initialize();
  }

  Future<void> _initialize() async {
    _goalsService = await GoalsService.getInstance();
    await _loadGoal();

    // if (healthItem.doesGoalSupportStreaks) {
    //   var streakService = StreakService(healthFetcherService);
    //   cachedStreak = await streakService.getStreak(this, goal);
    // }
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
    if (showLoading) return 0;
    if (timeframe != TimeFrame.day) {
      return getGoalAveragePercent.clamp(0, 1);
    }

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
    if (showLoading) return "--";

    if (timeframe == TimeFrame.day && goal != -1) {
      return goal - total >= 0 ? 
          "${(goal - total).toStringAsFixed(0)}${healthItem.unit} left" : 
          "${(total - goal).toStringAsFixed(0)}${healthItem.unit} over";
    } else {
      return "${average.toStringAsFixed(0)} avg";
    }
  }

  // The main value displayed on the home page widget
  String get getDisplayValueWithUnit {
    if (showLoading) return "--";
    return formatNumber(total) + healthItem.unit;
  }

  String get getDisplayValue {
    if (showLoading) return "--";
    return formatNumber(total);
  }

  // The daily average displayed on the details page widget
  String get getDisplayAverage {
    if (showLoading) return "--";
    return formatNumber(average) + healthItem.unit;
  }

  // The goal value displayed on the details page widget
  String get getDisplayGoalWithUnit {
    if (showLoading) return "--";
    return formatNumber(goal) + healthItem.unit;
  }

  String get getDisplayGoal {
    if (showLoading) return "--";
    return formatNumber(goal);
  }

  // The percentage of the goal for this health entity against our daily average
  String get getDisplayGoalWithUnitAveragePercent {
    if (showLoading) return "--";
    return "${(getGoalAveragePercent * 100).toStringAsFixed(0)}%";
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
    if (showLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.largeHeight);

    return BarChartWidget(
      groupedData: getBarchartData,
      barColor: healthItem.color,
      getXAxisLabel: getXAxisLabel,
      getBarchartValue: getBarchartValue,
    );
  }

  List<Widget> get getInfoWidgets {
    return [
      InfoWidget(
        title: "Streak",
        displayValue: cachedStreak.toString(),
      ),
      InfoWidget(
        title: "Total",
        displayValue: getDisplayValueWithUnit,
      ),
      InfoWidget(
        title: "Average",
        displayValue: getDisplayAverage,
      ),
    ];
  }

  // The widgets displayed on the details page
  List<Widget> get getDetailWidgets {
    return [
      getGraphWidget,
      ...getInfoWidgets,
      getGoalEditButton,
    ];
  }

  // #endregion

  // #region Update

  void updateQuery(TimeFrame newTimeFrame, int newOffset) {
    queryDateRange = calculateDateRange(newTimeFrame, newOffset);
    timeframe = newTimeFrame;
    offset = newOffset;
  }

  Future<void> updateData() async {
    final batchData = await healthFetcherService.fetchBatchData([this]);
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
    return HealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
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

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
  // #endregion

  double getIconSize(double size) {
    return size * healthItem.iconSizeMultiplier;
  }

  // #region Goal

  double get goal {
    return _cachedGoal ?? 0.0;
  }

  Future<void> _loadGoal() async {
    try {
      final primaryType = healthItem.itemType.toString();
      _cachedGoal = await _goalsService.getGoal(primaryType);
    } catch (e) {
      await ErrorLogger.logError('Error loading goal: $e');
      _cachedGoal = 0.0;
    }
  }

  Future<void> updateGoal(double value) async {
    try {
      final primaryType = healthItem.itemType.toString();
      await _goalsService.saveGoal(primaryType, value);
      _cachedGoal = value;
      notifyListeners();
    } catch (e) {
      await ErrorLogger.logError('Error saving goal: $e');
    }
  }

  Widget get getGoalEditButton {
    return GoalEditButton(
      label: 'Edit ${healthItem.title} Goal',
      unit: healthItem.unit,
      allowDecimals: healthItem.doesGoalSupportDecimals,
      allowNegative: healthItem.doesGoalSupportNegative,
      onSave: (value) async {
        await updateGoal(value);
      },
      currentValue: goal,
    );
  }
  // #endregion
}
