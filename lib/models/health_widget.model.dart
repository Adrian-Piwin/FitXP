import 'package:xpfitness/enums/timeframe.enum.dart';
import 'package:xpfitness/models/data_point.model.dart';
import 'package:xpfitness/models/goal.model.dart';
import 'package:xpfitness/models/health_widget_config.model.dart';
import 'package:xpfitness/pages/home/basic_large_widget_item.dart';
import 'package:xpfitness/pages/home/basic_widget_item.dart';
import 'package:xpfitness/utility/timeframe.utility.dart';
import 'package:health/health.dart';
import '../constants/health_item_definitions.constants.dart';
import '../utility/health.utility.dart';

class HealthWidget{
  final HealthItem healthItem;
  final Goal goals;
  final int widgetSize;

  Map<HealthDataType, List<DataPoint>> _data = {};
  TimeFrame _timeFrame = TimeFrame.day;
  int _offset = 0;
  double _total = 0;
  double _average = 0;
  double _goal = 0;

  HealthWidget(this.healthItem, this.goals, this.widgetSize){
    _goal = healthItem.getGoal != null && healthItem.getGoal!(goals) != -1 ? healthItem.getGoal!(goals) : -1;
  }

  void update(TimeFrame newTimeFrame, int newOffset) {
    _timeFrame = newTimeFrame;
    _offset = newOffset;
  }

  void updateData(Map<HealthDataType, List<DataPoint>> batchData) {
    _data = Map.fromEntries(
      healthItem.dataType.map((type) => 
        MapEntry(type, batchData[type] ?? [])
      )
    );
    _total = _getTotal;
    _average = _getAverage;
  }

  List<DataPoint> _getCombinedData() {
    return _data.values.expand((list) => list).toList();
  }

  double get _getTotal {
    return getHealthTotal(_getCombinedData());
  }

  double get _getAverage {
    return getHealthAverage(_getCombinedData());
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

  String get _getValue {
    return (_total).toStringAsFixed(0);
  }

  double get _getGoalPercent {
    if (_goal == 0) return 0.0;
    if (_goal == -1) return -1;
    return (_total / _goal).clamp(0, 1);
  }

  HealthWidgetConfig get getConfig {
    return HealthWidgetConfig(
      title: healthItem.title, 
      subtitle: _getSubtitle, 
      displayValue: _getValue, 
      icon: healthItem.icon, 
      color: healthItem.color, 
      size: widgetSize, 
      goalPercent: _getGoalPercent);
  }

  Map<String, dynamic> generateWidget() {
    HealthWidgetConfig config = getConfig;
    config.data = _getCombinedData();

    return {
      "size": config.size,
      "widget": config.size == 1
          ? BasicWidgetItem(
              config: config,
            )
          : BasicLargeWidgetItem(
              config: config,
            )
    };
  }
}

class StepsHealthWidget extends HealthWidget {
  StepsHealthWidget(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  double get _getAverage {
    final dateRange = calculateDateRange(_timeFrame, _offset);
    return _getTotal / dateRange.duration.inDays;
  }
}

class NetCaloriesHealthWidget extends HealthWidget {
  NetCaloriesHealthWidget(
    super.healthItem,
    super.goal,
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

    _total = totalEnergyConsumed - totalEnergyBurned;
    _average = avgEnergyConsumed - avgEnergyBurned;
  }

  @override
  double get _getGoalPercent {
    if (_goal == 0) return 0.0;

    var total = _total;
    if (_goal < 0) {
      total = _total.abs();
    }
    return (total / _goal.abs()).clamp(0, 1);
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
      int actualSleepMinutes = _getTotal.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      return _goal - _getTotal >= 0 ? 
          "${_formatMinutes(differenceMinutes)} left" : 
          "${_formatMinutes(differenceMinutes)} over";
    }

    return "${_formatMinutes(_getAverage.toInt())} avg";
  }

  @override
  String get _getValue {
    int totalMinutes = _total.toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')} hrs";
  }
}
