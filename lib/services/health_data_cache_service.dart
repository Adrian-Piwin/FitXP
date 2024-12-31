import 'package:health/health.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_point.model.dart';

class HealthDataCache {
  static const String _boxPrefix = 'health_data_';
  static const Duration _recentDataThreshold = Duration(minutes: 10);
  static const String _lastFullCacheKey = 'last_full_cache';
  Box<Map>? _metadataBox;
  Map<HealthDataType, Box<Map>>? _dataBoxes;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _metadataBox = await Hive.openBox<Map>('health_data_metadata');
    _dataBoxes = {};
    
    for (var type in AllHealthDataTypes) {
      _dataBoxes![type] = await Hive.openBox<Map>('$_boxPrefix${type.name}');
    }
  }

  DateTime? getLastFullCacheTime() {
    final metadata = _metadataBox?.get(_lastFullCacheKey);
    if (metadata == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(metadata['timestamp']);
  }

  Future<void> updateLastFullCacheTime(DateTime time) async {
    await _metadataBox?.put(_lastFullCacheKey, {
      'timestamp': time.millisecondsSinceEpoch,
    });
  }

  List<DataPoint>? getDataForTimeFrame(
    HealthDataType type,
    DateTime start,
    DateTime end,
  ) {
    final box = _dataBoxes![type];
    if (box == null) return null;

    final lastFullCache = getLastFullCacheTime();
    if (lastFullCache == null) return null;

    // Only return cached data up until the last full cache time
    final effectiveEnd = end.isAfter(lastFullCache) 
        ? lastFullCache 
        : end;

    return box.values
        .where((data) => 
            data['dateFrom'] >= start.millisecondsSinceEpoch &&
            data['dateTo'] <= effectiveEnd.millisecondsSinceEpoch)
        .map((data) => _deserializeDataPoint(data, type))
        .toList();
  }

  Future<void> clearCache() async {
    await Hive.deleteFromDisk();
  }

  bool shouldRefetchRecentData(HealthDataType type) {
    final lastFullCache = getLastFullCacheTime();
    if (lastFullCache == null) return true;
    
    return DateTime.now().difference(lastFullCache) > _recentDataThreshold;
  }

  Future<void> cacheDataPoints(HealthDataType type, List<DataPoint> points, DateTime cacheTime) async {
    final box = _dataBoxes![type];
    
    // Store each point with timestamp as key
    for (var point in points) {
      await box?.put(point.dateFrom.millisecondsSinceEpoch.toString(), {
        'value': point.value,
        'dateFrom': point.dateFrom.millisecondsSinceEpoch,
        'dateTo': point.dateTo.millisecondsSinceEpoch,
        'dayOccurred': point.dayOccurred.millisecondsSinceEpoch,
        'subType': point.subType,
        if (point is SleepDataPoint) 'sleepStage': point.sleepStage?.index,
      });
    }

    // Update metadata
    await _metadataBox?.put(type.name, {
      'lastCached': cacheTime.millisecondsSinceEpoch,
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

  Future<void> replaceRecentDataPoints(
    HealthDataType type, 
    List<DataPoint> points, 
    DateTime cacheTime
  ) async {
    final box = _dataBoxes![type];
    if (box == null) return;

    // Delete existing data from last 2 days
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    final keysToDelete = box.keys.where((key) {
      final data = box.get(key);
      if (data == null) return false;
      final dateFrom = DateTime.fromMillisecondsSinceEpoch(data['dateFrom']);
      return dateFrom.isAfter(twoDaysAgo);
    }).toList();

    // Delete old data
    for (var key in keysToDelete) {
      await box.delete(key);
    }

    print('Replacing recent data for $type with ${points.length} points from ${points.first.dateFrom} to ${points.last.dateTo}');

    // Store new data points
    for (var point in points) {
      await box.put(point.dateFrom.millisecondsSinceEpoch.toString(), {
        'value': point.value,
        'dateFrom': point.dateFrom.millisecondsSinceEpoch,
        'dateTo': point.dateTo.millisecondsSinceEpoch,
        'dayOccurred': point.dayOccurred.millisecondsSinceEpoch,
        'subType': point.subType,
        if (point is SleepDataPoint) 'sleepStage': point.sleepStage?.index,
      });
    }

    // Update metadata
    await _metadataBox?.put(type.name, {
      'lastCached': cacheTime.millisecondsSinceEpoch,
    });
  }
} 
