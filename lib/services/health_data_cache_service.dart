import 'package:health/health.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/data_points/sleep_data_point.model.dart';
import 'package:healthxp/models/data_points/workout_data_point.model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_points/data_point.model.dart';

class HealthDataCache {
  static HealthDataCache? _instance;
  
  // Private constructor
  HealthDataCache._();

  // Factory constructor
  static Future<HealthDataCache> getInstance() async {
    if (_instance == null) {
      _instance = HealthDataCache._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  static const String _boxPrefix = 'health_data_';
  static const Duration _recentDataThreshold = Duration(minutes: 10);
  static const Duration _oldDataThreshold = Duration(days: 7);
  Map<HealthDataType, Box<Map>>? _dataBoxes;
  bool _isInitialized = false;

  Future<void> _initialize() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _dataBoxes = {};
      
      for (var type in AllHealthDataTypes) {
        _dataBoxes![type] = await Hive.openBox<Map>('$_boxPrefix${type.name}');
      }
      _isInitialized = true;
    }
  }

  Future<void> clearCache() async {
    if (_dataBoxes != null) {
      for (var box in _dataBoxes!.values) {
        if (box.isOpen) {
          await box.clear();
        }
      }
    }
  }

  Future<void> dispose() async {
    if (_dataBoxes != null) {
      for (var box in _dataBoxes!.values) {
        if (box.isOpen) {
          await box.close();
        }
      }
      _dataBoxes = null;
      _isInitialized = false;
    }
  }

  String _getDayKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _shouldRefreshData(DateTime cacheTime) {
    final now = DateTime.now();
    final daysDifference = now.difference(cacheTime).inDays;
    
    if (daysDifference < 2) {
      // For recent data (last 2 days), check 10-minute threshold
      return now.difference(cacheTime) > _recentDataThreshold;
    } else {
      // For older data, check 7-day threshold
      return now.difference(cacheTime) > _oldDataThreshold;
    }
  }

  Future<Map<DateTime, List<DataPoint>>> getDataForDays(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) async {
    final box = _dataBoxes![type];
    if (box == null) return {};

    Map<DateTime, List<DataPoint>> result = {};
    Set<DateTime> daysToFetch = {};
    
    // Check each day in the range
    for (DateTime date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
      final dayKey = _getDayKey(date);
      final cachedDay = box.get(dayKey);
      
      if (cachedDay == null) {
        daysToFetch.add(date);
        continue;
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedDay['cacheTime']);
      if (_shouldRefreshData(cacheTime)) {
        daysToFetch.add(date);
        continue;
      }

      // Use cached data
      final List<dynamic> points = cachedDay['points'];
      result[date] = points.map((p) => _deserializeDataPoint(p, type)).toList();
    }

    return result;
  }

  Future<void> cacheDayData(
    HealthDataType type,
    DateTime day,
    List<DataPoint> points,
  ) async {
    final box = _dataBoxes![type];
    if (box == null) return;

    final dayKey = _getDayKey(day);
    List<Map<String, dynamic>> processedPoints;

    if (sleepTypes.contains(type) || trendTypes.contains(type) || type == HealthDataType.WORKOUT) {
      // Don't group sleep data / trend points / workout data
      processedPoints = points.map((point) => {
        'value': point.value,
        'dateFrom': point.dateFrom.millisecondsSinceEpoch,
        'dateTo': point.dateTo.millisecondsSinceEpoch,
        'dayOccurred': point.dayOccurred.millisecondsSinceEpoch,
        if (point is SleepDataPoint) 'sleepStage': point.sleepStage?.index,
        if (point is WorkoutDataPoint) 'workoutType': point.workoutType,
        if (point is WorkoutDataPoint) 'energyBurned': point.energyBurned,
        if (point is WorkoutDataPoint) 'distance': point.distance,
        if (point is WorkoutDataPoint) 'distanceUnit': point.distanceUnit,
        if (point is WorkoutDataPoint) 'steps': point.steps,
      }).toList();
    } else {
      // Group other data points by hour
      Map<int, _HourlyData> hourlyGroups = {};

      for (var point in points) {
        final hour = DateTime(
          point.dateFrom.year,
          point.dateFrom.month,
          point.dateFrom.day,
          point.dateFrom.hour,
        );
        final hourKey = hour.millisecondsSinceEpoch;

        hourlyGroups.putIfAbsent(
          hourKey,
          () => _HourlyData(
            hour: hour,
            dayOccurred: point.dayOccurred,
          ),
        );

        hourlyGroups[hourKey]!.addValue(point.value);
      }

      processedPoints = hourlyGroups.values.map((hourData) => {
        'value': hourData.totalValue,
        'dateFrom': hourData.hour.millisecondsSinceEpoch,
        'dateTo': hourData.hour.add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'dayOccurred': hourData.dayOccurred.millisecondsSinceEpoch,
        'count': hourData.count,
      }).toList();
    }

    await box.put(dayKey, {
      'cacheTime': DateTime.now().millisecondsSinceEpoch,
      'points': processedPoints,
    });
  }

  DataPoint _deserializeDataPoint(Map data, HealthDataType type) {
    final dateFrom = DateTime.fromMillisecondsSinceEpoch(data['dateFrom']);
    final dateTo = DateTime.fromMillisecondsSinceEpoch(data['dateTo']);
    final dayOccurred = DateTime.fromMillisecondsSinceEpoch(data['dayOccurred']);
    
    // Handle sleep data points separately
    if (type == HealthDataType.SLEEP_ASLEEP || type == HealthDataType.SLEEP_AWAKE) {
      final sleepStageIndex = data['sleepStage'] as int?;
      return SleepDataPoint(
        value: data['value'],
        dateFrom: dateFrom,
        dateTo: dateTo,
        dayOccurred: dayOccurred,
        sleepStage: sleepStageIndex != null ? SleepStage.values[sleepStageIndex] : null,
      );
    }

    if (type == HealthDataType.WORKOUT) {
      return WorkoutDataPoint(
        value: data['value'],
        dateFrom: dateFrom,
        dateTo: dateTo,
        dayOccurred: dayOccurred,
        workoutType: data['workoutType'],
        energyBurned: data['energyBurned'],
        distance: data['distance'],
        distanceUnit: data['distanceUnit'],
        steps: data['steps'],
      );
    }
    
    // Regular data points (now grouped by hour)
    return DataPoint(
      value: data['value'],
      dateFrom: dateFrom,
      dateTo: dateTo,
      dayOccurred: dayOccurred,
    );
  }
}

class _HourlyData {
  final DateTime hour;
  final DateTime dayOccurred;
  double totalValue = 0;
  int count = 0;

  _HourlyData({
    required this.hour,
    required this.dayOccurred,
  });

  void addValue(double value) {
    totalValue += value;
    count++;
  }
} 
