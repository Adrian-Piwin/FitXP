import 'package:fitxp/enums/timeframe.enum.dart';
import 'package:fitxp/models/goal.model.dart';
import 'package:fitxp/models/health_widget_config.model.dart';
import 'package:fitxp/pages/home/basic_large_widget_item.dart';
import 'package:fitxp/pages/home/basic_widget_item.dart';
import 'package:fitxp/services/health_fetcher_service.dart';
import 'package:health/health.dart';
import '../constants/health_item_definitions.constants.dart';
import '../utility/health.utility.dart';

class HealthWidget{
  final HealthFetcherService healthFetcherService;
  final HealthItem healthItem;
  final Goal goals;
  final int widgetSize;

  Map<HealthDataType, List<HealthDataPoint>> _data = {};
  TimeFrame _timeFrame = TimeFrame.day;
  int _offset = 0;
  double _total = 0;
  double _average = 0;
  double _goal = 0;

  HealthWidget(this.healthFetcherService, this.healthItem, this.goals, this.widgetSize){
    _goal = healthItem.getGoal != null && healthItem.getGoal!(goals) != -1 ? healthItem.getGoal!(goals) : -1;
  }

  void update(TimeFrame newTimeFrame, int newOffset) {
    _timeFrame = newTimeFrame;
    _offset = newOffset;
  }

  Future<void> fetchData() async {
   _data = await healthFetcherService.fetchData(healthItem.dataType, _timeFrame, _offset);
   _total = _getTotal;
   _average = _getAverage;
  }

  List<HealthDataPoint> _getCombinedData() {
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
      return "${(_goal - _total).toStringAsFixed(0)}${healthItem.unit} left";
    } else {
      return "$_average avg";
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

class NetCaloriesyHealthWidget extends HealthWidget{
  NetCaloriesyHealthWidget(
    super.healthFetcherService,
    super.healthItem,
    super.goal,
    super.timeFrame,
  );

  Map<HealthDataType, List<HealthDataPoint>> _subtractData = {};

  @override
  Future<void> fetchData() async {
    _data = await healthFetcherService.fetchData([HealthDataType.ACTIVE_ENERGY_BURNED, HealthDataType.BASAL_ENERGY_BURNED],_timeFrame, _offset);
    _subtractData = await healthFetcherService.fetchData([HealthDataType.DIETARY_ENERGY_CONSUMED], _timeFrame, _offset);
    _total = _getTotal;
    _average = _getAverage;
  }

  @override
  double get _getTotal {
    return getHealthTotal(_data[HealthDataType.ACTIVE_ENERGY_BURNED]!) + getHealthTotal(_data[HealthDataType.BASAL_ENERGY_BURNED]!) - getHealthTotal(_subtractData[HealthDataType.DIETARY_ENERGY_CONSUMED]!);
  }

  @override
  double get _getAverage {
    return getHealthAverage(_data[HealthDataType.ACTIVE_ENERGY_BURNED]!) + getHealthAverage(_data[HealthDataType.BASAL_ENERGY_BURNED]!) - getHealthAverage(_subtractData[HealthDataType.DIETARY_ENERGY_CONSUMED]!);
  }
}

class SleepHealthWidget extends HealthWidget {
  SleepHealthWidget(
    super.healthFetcherService,
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  String _formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return hours > 0 ? "$hours:${minutes.toString().padLeft(2, '0')} hrs" : "$minutes min";
  }

  @override
  String get _getSubtitle {
    if (_timeFrame == TimeFrame.day && _goal != -1) {
      int sleepGoalMinutes = _goal.toInt();
      int actualSleepMinutes = _getTotal.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      return "${_formatMinutes(differenceMinutes)} from goal";
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
