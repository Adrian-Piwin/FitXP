import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/goal.model.dart';
import 'package:healthxp/models/health_widget_config.model.dart';
import 'package:healthxp/pages/home/basic_large_widget_item.dart';
import 'package:healthxp/pages/home/basic_widget_item.dart';
import 'package:healthxp/utility/timeframe.utility.dart';
import 'package:health/health.dart';
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

  TimeFrame get getTimeFrame => _timeFrame;
  int get getOffset => _offset;

  List<DataPoint> get getCombinedData {
    return combineDataPoints(data);
  }

  List<DataPoint> get _getCombinedData {
    return data.values.expand((list) => list).toList();
  }

  double get getTotal => _total;
  double get getAverage => _average;

  double get getGoal {
    return _goal;
  }

  double get getGoalPercent {
    if (_goal == 0) return 0.0;
    if (_goal == -1) return -1;
    return (_total / _goal).clamp(0, double.infinity);
  }

  double get getGoalAveragePercent {
    if (_goal == 0) return 0.0;
    if (_goal == -1) return -1;
    return (_average / _goal).clamp(0, 1);
  }

  String get getUnit {
    return healthItem.unit;
  }

  String get _getSubtitle {
    if (_timeFrame == TimeFrame.day && _goal != -1) {
      return _goal - _total >= 0 ? 
          "${(_goal - _total).toStringAsFixed(0)}${healthItem.unit} left" : 
          "${(_total - _goal).toStringAsFixed(0)}${healthItem.unit} over";
    } else {
      return "${_average.toStringAsFixed(0)} avg";
    }
  }

  String get _getDisplayValue {
    return (_total).toStringAsFixed(0);
  }

  HealthWidgetConfig get getConfig {
    return HealthWidgetConfig(
      title: healthItem.title, 
      subtitle: _getSubtitle, 
      displayValue: _getDisplayValue, 
      icon: healthItem.icon, 
      color: healthItem.color, 
      size: widgetSize, 
      goalPercent: getGoalPercent,
    );
  }

  void update(TimeFrame newTimeFrame, int newOffset) {
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

  Map<String, dynamic> generateWidget() {
    HealthWidgetConfig config = getConfig;
    config.data = _getCombinedData;

    return {
      "size": config.size,
      "widget": config.size == 1
          ? BasicWidgetItem(
              config: config,
            )
          : BasicLargeWidgetItem(
              widget: this,
            )
    };
  }

  HealthWidget clone() {
    return HealthWidget(healthItem, goals, widgetSize)..data = data;
  }

  static HealthWidget from(HealthWidget widget) {
    return widget.clone();
  }
}

class StepsHealthWidget extends HealthWidget {
  StepsHealthWidget(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  double get getAverage {
    final dateRange = calculateDateRange(_timeFrame, _offset);
    return getTotal / dateRange.duration.inDays;
  }

  @override
  HealthWidget clone() {
    return StepsHealthWidget(healthItem, goals, widgetSize)..data = data;
  }
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
  List<DataPoint> get getCombinedData {
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

    return combineDataPoints(allPoints);
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

  String _formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return hours > 0 ? "$hours:${minutes.toString().padLeft(2, '0')} hrs" : "${minutes}min";
  }

  @override
  String get _getSubtitle {
    if (_timeFrame == TimeFrame.day && _goal != -1) {
      int sleepGoalMinutes = _goal.toInt();
      int actualSleepMinutes = getTotal.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      return _goal - getTotal >= 0 ? 
          "${_formatMinutes(differenceMinutes)} left" : 
          "${_formatMinutes(differenceMinutes)} over";
    }

    return "${_formatMinutes(getAverage.toInt())} avg";
  }

  @override
  String get _getDisplayValue {
    int totalMinutes = _total.toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')} hrs";
  }

  @override
  HealthWidget clone() {
    return SleepHealthWidget(healthItem, goals, widgetSize)..data = data;
  }
}
