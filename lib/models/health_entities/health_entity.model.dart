import 'dart:async';

import 'package:flutter/material.dart';
import 'package:healthcore/components/barchart_widget.dart';
import 'package:healthcore/components/goal_edit_button.dart';
import 'package:healthcore/components/icon_info_widget.dart';
import 'package:healthcore/components/loading_widget.dart';
import 'package:healthcore/constants/icons.constants.dart';
import 'package:healthcore/constants/magic_numbers.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/bar_data.model.dart';
import 'package:healthcore/models/daily_goal_status.model.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_item.model.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/services/health_fetcher_service.dart';
import 'package:healthcore/services/streak_service.dart';
import 'package:healthcore/utility/chart.utility.dart';
import 'package:health/health.dart';
import 'package:healthcore/utility/general.utility.dart';
import 'package:healthcore/utility/timeframe.utility.dart';
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
        if (_isLoading) {  // Only show loading if we're still loading after delay
          showLoading = true;
          notifyListeners();
        }
      });
    } else {
      _loadingTimer?.cancel();
      showLoading = false;
      notifyListeners();
    }
  }

  TimeFrame timeframe = TimeFrame.day;
  int offset = 0;
  DateTimeRange? queryDateRange;
  double? cachedTotal;
  double? cachedAverage;
  int cachedStreak = 0;
  List<DataPoint>? cachedCurrentData;

  HealthEntity(this.healthItem, this.widgetSize, this.healthFetcherService);

  Future<void> initialize() async {
    _goalsService = await GoalsService.getInstance();
    await _loadGoal();
    if (healthItem.doesGoalSupportStreaks) {
      if (goal != 0){
        var streakService = StreakService();
        cachedStreak = await streakService.getStreak(this, goal);
      }
    }
  }

  // #region Getters

  List<TimeFrame> get supportedTimeFrames => [TimeFrame.day, TimeFrame.week, TimeFrame.month, TimeFrame.year];

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

  // The lowest value of all combined data points
  double get minimum {
    var points = aggregateData(data);
    if (points.isEmpty) return 0;
    return points.reduce((a, b) => a.value < b.value ? a : b).value;
  }

  // The highest value of all combined data points
  double get maximum {
    var points = aggregateData(data);
    if (points.isEmpty) return 0;
    return points.reduce((a, b) => a.value > b.value ? a : b).value;
  }

  // The combined data points for all types
  List<DataPoint> aggregateData(Map<HealthDataType, List<DataPoint>> data) {
    return data.values.expand((list) => list).toList();
  }

  // Use this for the context of our datapoints for the selected timeframe and offset
  List<DataPoint> get getCurrentData {
    cachedCurrentData ??= aggregateData(data);
    return cachedCurrentData!;
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

    if (timeframe == TimeFrame.day) {
      if (goal == -1 || goal == 0) {
        return "";
      }

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
    return formatNumber(total, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0) + healthItem.unit;
  }

  String get getDisplayStreak {
    if (showLoading) return "--";
    return "${cachedStreak.toString()} day streak";
  }

  String formatValue(double value) {
    return formatNumber(value, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0);
  }

  String formatValueWithUnit(double value) {
    return formatNumber(value, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0) + healthItem.unit;
  }

  String get getDisplayValue {
    if (showLoading) return "--";
    return formatNumber(total, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0);
  }

  // The daily average displayed on the details page widget
  String get getDisplayAverage {
    if (showLoading) return "--";
    return formatNumber(average, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0) + healthItem.unit;
  }

  // The goal value displayed on the details page widget
  String get getDisplayGoalWithUnit {
    if (showLoading) return "--";
    return formatNumber(goal, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0) + healthItem.unit;
  }

  String get getDisplayGoal {
    if (showLoading) return "--";
    return formatNumber(goal, decimalPlaces: healthItem.doesGoalSupportDecimals ? 1 : 0);
  }

  // #endregion

  List<DailyGoalStatus> getWeeklyGoalStatus() {
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    // Create a map to store daily totals
    Map<int, double> dailyTotals = {};
    
    // Sum up values for each day of the week
    for (var dataPoint in getCurrentData) {
      final dayIndex = dataPoint.dayOccurred.weekday - 1; // 0-6 for Monday-Sunday
      dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + dataPoint.value;
    }
    
    // Create DailyGoalStatus for each day
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return DailyGoalStatus(
        dayLetter: weekDays[index],
        value: dailyTotals[index] ?? 0,
        goalValue: goal,
        date: date,
      );
    });
  }

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
    if (showLoading) return LoadingWidget(size: 6, height: WidgetSizes.largeHeight);

    return BarChartWidget(
      groupedData: getBarchartData,
      barColor: healthItem.color,
      getXAxisLabel: getXAxisLabel,
      getBarchartValue: getBarchartValue,
      unit: healthItem.unit,
    );
  }

  List<Widget> get getInfoWidgets {
    return [
      IconInfoWidget(
        title: "Streak",
        displayValue: getDisplayStreak,
        icon: IconTypes.streakIcon,
        iconColor: healthItem.color,
      ),
      IconInfoWidget(
        title: "Total",
        displayValue: getDisplayValueWithUnit,
        icon: healthItem.icon,
        iconColor: healthItem.color,
      ),
      IconInfoWidget(
        title: "Average",
        displayValue: getDisplayAverage,
        icon: IconTypes.averageIcon,
        iconColor: healthItem.color,
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
    clearCache();
  }

  Future<Map<HealthDataType, List<DataPoint>>> getData(DateTimeRange dateRange) async {
    Map<HealthDataType, List<DataPoint>> result = {};
    for (var type in healthItem.dataType) {
      result[type] = await healthFetcherService.fetchHealthData(type, dateRange);
    }
    return result;
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

  void clearCache() {
    cachedTotal = null;
    cachedAverage = null;
    cachedCurrentData = null;
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
  // #endregion

  // #region Goal

  double get goal {
    return _cachedGoal ?? 0.0;
  }

  Future<void> _loadGoal() async {
    try {
      final primaryType = healthItem.itemType.toString();
      _cachedGoal = await _goalsService.getGoal(primaryType) ?? healthItem.defaultGoal;
    } catch (e) {
      await ErrorLogger.logError('Error loading goal: $e');
      rethrow;
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
      allowTimeInput: healthItem.doesGoalSupportTimeInput,
      onSave: (value) async {
        await updateGoal(value);
      },
      currentValue: goal,
    );
  }
  // #endregion
}
