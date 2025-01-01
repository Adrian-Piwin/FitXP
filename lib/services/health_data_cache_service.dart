import 'package:health/health.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_point.model.dart';

class HealthDataCache {
  static const String _boxPrefix = 'health_data_';
  static const Duration _recentDataThreshold = Duration(minutes: 10);
  static const Duration _oldDataThreshold = Duration(days: 7);
  Map<HealthDataType, Box<Map>>? _dataBoxes;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _dataBoxes = {};
    
    for (var type in AllHealthDataTypes) {
      _dataBoxes![type] = await Hive.openBox<Map>('$_boxPrefix${type.name}');
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
    await box.put(dayKey, {
      'cacheTime': DateTime.now().millisecondsSinceEpoch,
      'points': points.map((point) => {
        'value': point.value,
        'dateFrom': point.dateFrom.millisecondsSinceEpoch,
        'dateTo': point.dateTo.millisecondsSinceEpoch,
        'dayOccurred': point.dayOccurred.millisecondsSinceEpoch,
        'subType': point.subType,
        if (point is SleepDataPoint) 'sleepStage': point.sleepStage?.index,
      }).toList(),
    });
  }

  DataPoint _deserializeDataPoint(Map data, HealthDataType type) {
    final dateFrom = DateTime.fromMillisecondsSinceEpoch(data['dateFrom']);
    final dateTo = DateTime.fromMillisecondsSinceEpoch(data['dateTo']);
    final dayOccurred = DateTime.fromMillisecondsSinceEpoch(data['dayOccurred']);
    
    // Handle sleep data points separately
    if (type == HealthDataType.SLEEP_ASLEEP) {
      final sleepStageIndex = data['sleepStage'] as int?;
      return SleepDataPoint(
        value: data['value'],
        dateFrom: dateFrom,
        dateTo: dateTo,
        dayOccurred: dayOccurred,
        sleepStage: sleepStageIndex != null ? SleepStage.values[sleepStageIndex] : null,
      );
    }
    
    // Regular data points
    return DataPoint(
      value: data['value'],
      dateFrom: dateFrom,
      dateTo: dateTo,
      dayOccurred: dayOccurred,
      subType: data['subType'],
    );
  }

  Future<void> clearCache() async {
    await Hive.deleteFromDisk();
  }
} 
