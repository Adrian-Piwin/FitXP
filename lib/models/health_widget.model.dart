import 'package:flutter/material.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/sleep_barchart_widget.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/pages/home/basic_large_widget_item.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:health/health.dart';
import 'package:healthxp/utility/general.utility.dart';
import '../constants/health_item_definitions.constants.dart';
import '../utility/health.utility.dart';

class HealthWidget{
  final HealthItem healthItem;
  final Goal goals;
  final int widgetSize;

  Map<HealthDataType, List<DataPoint>> data = {};
  TimeFrame _timeFrame = TimeFrame.day;
  int _offset = 0;
  double _total = 0;
  double _average = 0;
  double _goal = 0;

  HealthWidget(this.healthItem, this.goals, this.widgetSize){
    _goal = healthItem.getGoal != null && healthItem.getGoal!(goals) != -1 ? healthItem.getGoal!(goals) : -1;
  }

  // #region Getters

  TimeFrame get getTimeFrame => _timeFrame;
  int get getOffset => _offset;

  double get getTotal => _total;
  double get getAverage => _average;

  List<DataPoint> get getMergedData {
    return mergeDataPoints(data);
  }

  List<DataPoint> get _getCombinedData {
    return data.values.expand((list) => list).toList();
  }

  double get getGoal {
    return _goal;
  }

  double get getGoalPercent {
    if (_goal == 0) return 0.0;
    if (_goal == -1) return -1;
    return (_total / _goal).clamp(0, double.infinity);
  }

  double get getGoalPercentClamped => getGoalPercent.clamp(0.0, 1.0);

  double get getGoalAveragePercent {
    if (_goal == 0) return 0.0;
    if (_goal == -1) return -1;
    return (_average / _goal).clamp(0, double.infinity);
  }

  String get getUnit {
    return healthItem.unit;
  }

  String get getSubtitle {
    if (_timeFrame == TimeFrame.day && _goal != -1) {
      return _goal - _total >= 0 ? 
          "${(_goal - _total).toStringAsFixed(0)}${healthItem.unit} left" : 
          "${(_total - _goal).toStringAsFixed(0)}${healthItem.unit} over";
    } else {
      return "${_average.toStringAsFixed(0)} avg";
    }
  }

  String get getDisplayValue {
    return (_total).toStringAsFixed(0);
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
    if (_getCombinedData.isEmpty) return [];
    return ChartUtility.groupDataByTimeFrame(_getCombinedData, _timeFrame, _offset);
  }

  String getBarchartValue(double value) {
    return value.toStringAsFixed(0);
  }

  String getXAxisLabel(double value) {
    return ChartUtility.getXAxisLabel(getBarchartData, _timeFrame, value);
  }

  // #endregion

  // #region Info widgets

  List<Widget> get getDetailWidgets {
    return [
      BarChartWidget(
        groupedData: getBarchartData,
        barColor: healthItem.color,
        getXAxisLabel: getXAxisLabel,
        getBarchartValue: getBarchartValue,
      ),
      InfoWidget(
        title: "Total",
        displayValue: getTotal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Average",
        displayValue: getAverage.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal",
        displayValue: getGoal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal Progress",
        displayValue: "${(getGoalAveragePercent * 100).toStringAsFixed(0)}%",
      ),
    ];
  }

  // #endregion

  // #region Update

  void updateQueryOptions(TimeFrame newTimeFrame, int newOffset) {
    _timeFrame = newTimeFrame;
    _offset = newOffset;
  }

  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    data = Map.fromEntries(
      healthItem.dataType.map((type) => 
        MapEntry(type, batchData[type] ?? [])
      )
    );
    _total = getHealthTotal(_getCombinedData);
    _average = getHealthAverage(_getCombinedData);
  }

  // #endregion

  // #region Clone

  HealthWidget clone() {
    return HealthWidget(healthItem, goals, widgetSize)..data = data;
  }

  static HealthWidget from(HealthWidget widget) {
    return widget.clone();
  }

  // #endregion
}

class NetCaloriesHealthWidget extends HealthWidget {
  NetCaloriesHealthWidget(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    var energyBurnedActive = batchData[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [];
    var energyBurnedBasal = batchData[HealthDataType.BASAL_ENERGY_BURNED] ?? [];
    var energyConsumed = batchData[HealthDataType.DIETARY_ENERGY_CONSUMED] ?? [];

    var totalEnergyBurned = getHealthTotal(energyBurnedActive) + 
                           getHealthTotal(energyBurnedBasal);
    var totalEnergyConsumed = getHealthTotal(energyConsumed);
    var avgEnergyBurned = getHealthAverage(energyBurnedActive) + 
                         getHealthAverage(energyBurnedBasal);
    var avgEnergyConsumed = getHealthAverage(energyConsumed);

    data = batchData;
    _total = totalEnergyConsumed - totalEnergyBurned;
    _average = avgEnergyConsumed - avgEnergyBurned;
  }

  @override
  List<DataPoint> get getMergedData {
    var allPoints = <HealthDataType, List<DataPoint>>{
      HealthDataType.ACTIVE_ENERGY_BURNED: data[HealthDataType.ACTIVE_ENERGY_BURNED] ?? [],
      HealthDataType.BASAL_ENERGY_BURNED: data[HealthDataType.BASAL_ENERGY_BURNED] ?? [],
      HealthDataType.DIETARY_ENERGY_CONSUMED: (data[HealthDataType.DIETARY_ENERGY_CONSUMED] ?? [])
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo))
          .toList()
    };

    return mergeDataPoints(allPoints);
  }

  @override
  double get getGoalPercent {
    if (_goal == 0) return 0.0;

    var total = _total;
    if (_goal < 0) {
      if (total > 0) {
        return 0;
      }
      total = _total.abs();
    }
    return (total / _goal.abs()).clamp(0, double.infinity);
  }

  @override
  HealthWidget clone() {
    return NetCaloriesHealthWidget(healthItem, goals, widgetSize)..data = data;
  }
}

class SleepHealthWidget extends HealthWidget {
  SleepHealthWidget(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  String get getSubtitle {
    if (_timeFrame == TimeFrame.day && _goal != -1) {
      int sleepGoalMinutes = _goal.toInt();
      int actualSleepMinutes = getTotal.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      return _goal - getTotal >= 0 ? 
          "${formatMinutes(differenceMinutes)} left" : 
          "${formatMinutes(differenceMinutes)} over";
    }

    return "${formatMinutes(getAverage.toInt())} avg";
  }

  @override
  String get getDisplayValue {
    int totalMinutes = _total.toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')} hrs";
  }

  @override
  String getBarchartValue(double value) {
    return formatMinutes(value.toInt());
  }

  @override
  List<BarData> get getBarchartData {
    if (_getCombinedData.isEmpty) return [];

    if (_timeFrame == TimeFrame.day) {
      return ChartUtility.getSleepBarData(data);
    }
    return super.getBarchartData;
  }

  @override
  List<Widget> get getDetailWidgets {
    return [
      _timeFrame == TimeFrame.day ?
      SleepBarChartWidget(
        barDataList: getBarchartData,
      ) : BarChartWidget(
        groupedData: getBarchartData,
        barColor: healthItem.color,
        getXAxisLabel: getXAxisLabel,
          getBarchartValue: getBarchartValue,
        ),
      InfoWidget(
        title: "Total",
        displayValue: getTotal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Average",
        displayValue: getAverage.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal",
        displayValue: getGoal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal Progress",
        displayValue: "${(getGoalAveragePercent * 100).toStringAsFixed(0)}%",
      ),
    ];
  }

  @override
  HealthWidget clone() {
    return SleepHealthWidget(healthItem, goals, widgetSize)..data = data;
  }
}
