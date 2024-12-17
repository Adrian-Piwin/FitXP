import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/fitbit_service.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';
import '../services/health_data_cache_service.dart';
import '../utility/health.utility.dart';

class HealthFetcherService {
  final Health _health = Health();
  final FitbitService _fitbitService = FitbitService();
  final HealthDataCache _cache = HealthDataCache();
  bool _isAuthorized = false;

  HealthFetcherService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await dotenv.load(fileName: ".env"); // Load env file first
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
    await _cache.initialize();
  }

  Future<bool> checkAndRequestPermissions() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(healthDataTypes);
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
      List<HealthEntity> entities) async {
    // Group entities by their data types
    Map<HealthDataType, List<HealthEntity>> typeGroups = {};
    for (var entity in entities) {
      for (var type in entity.healthItem.dataType) {
        if (!typeGroups.containsKey(type)) {
          typeGroups[type] = [];
        }
        typeGroups[type]!.add(entity);
      }
    }

    // Check cache for each type and entity combination
    Map<HealthDataType, List<DataPoint>> cachedData = {};
    Map<HealthDataType, List<HealthEntity>> uncachedTypes = {};

    for (var entry in typeGroups.entries) {
      var type = entry.key;
      var entityList = entry.value;
      
      for (var entity in entityList) {
        var cached = _cache.getDataForType(entity.timeframe, entity.offset, type);
        if (cached != null) {
          if (!cachedData.containsKey(type)) {
            cachedData[type] = [];
          }
          cachedData[type]!.addAll(cached);
        } else {
          if (!uncachedTypes.containsKey(type)) {
            uncachedTypes[type] = [];
          }
          uncachedTypes[type]!.add(entity);
        }
      }
    }

    if (uncachedTypes.isEmpty) {
      return cachedData;
    }

    // Get Fitbit-supported types
    final supportedTypes = await _fitbitService.getSupportedHealthTypes(
      uncachedTypes.keys.toList()
    );

    Map<HealthDataType, List<DataPoint>> newData = {};

    // Handle sleep data separately
    if (uncachedTypes.containsKey(HealthDataType.SLEEP_ASLEEP)) {
      try {
        if (_fitbitService.isSleepSupported()) {
          for (var entity in uncachedTypes[HealthDataType.SLEEP_ASLEEP]!) {
            final dateRange = entity.queryDateRange!;
            final sleepData = await _fitbitService.getFitbitSleepData(
              dateRange.start, 
              dateRange.end
            );
            if (!newData.containsKey(HealthDataType.SLEEP_ASLEEP)) {
              newData[HealthDataType.SLEEP_ASLEEP] = [];
            }
            newData[HealthDataType.SLEEP_ASLEEP]!.addAll(sleepData);
          }
        } else {
          for (var entity in uncachedTypes[HealthDataType.SLEEP_ASLEEP]!) {
            final dateRange = entity.queryDateRange!;
            final sleepData = await _fetchSleepHealthData(
              dateRange.start, 
              dateRange.end
            );
            if (!newData.containsKey(HealthDataType.SLEEP_ASLEEP)) {
              newData[HealthDataType.SLEEP_ASLEEP] = [];
            }
            newData[HealthDataType.SLEEP_ASLEEP]!.addAll(sleepData);
          }
        }
      } catch (e) {
        await ErrorLogger.logError('Error fetching sleep data: $e');
      }
      uncachedTypes.remove(HealthDataType.SLEEP_ASLEEP);
    }

    // Handle Fitbit data
    for (var type in supportedTypes) {
      if (uncachedTypes.containsKey(type)) {
        try {
          final fitbitData = await _fitbitService.fetchBatchData(
            uncachedTypes[type]!
          );
          newData.addAll(fitbitData);
        } catch (e) {
          await ErrorLogger.logError('Fitbit fetch failed: $e');
          // Fall back to Health data
          final healthData = await _fetchHealthBatchData(uncachedTypes[type]!);
          newData.addAll(healthData);
        }
        uncachedTypes.remove(type);
      }
    }

    // Handle remaining Health data
    for (var entry in uncachedTypes.entries) {
      final healthData = await _fetchHealthBatchData(entry.value);
      newData.addAll(healthData);
    }

    // Cache new data
    for (var entry in newData.entries) {
      for (var entity in typeGroups[entry.key]!) {
        await _cache.cacheDataPoint(
          entity.timeframe,
          entity.offset,
          entry.key,
          entry.value
        );
      }
    }

    return {
      ...cachedData,
      ...newData,
    };
  }

  Future<void> clearCache() async {
    await _cache.clearCache();
  }

  Future<void> clearCacheForKey(TimeFrame timeframe, int offset) async {
    await _cache.clearCacheForTimeFrameAndOffset(timeframe, offset);
  }

  Future<Map<HealthDataType, List<DataPoint>>> _fetchHealthBatchData(
      List<HealthEntity> entities) async {
    Map<HealthDataType, List<DataPoint>> data = {};
    
    // Group entities by timeframe and offset
    Map<String, List<HealthEntity>> batchGroups = {};
    for (var entity in entities) {
      final key = '${entity.timeframe}_${entity.offset}';
      if (!batchGroups.containsKey(key)) {
        batchGroups[key] = [];
      }
      batchGroups[key]!.add(entity);
    }

    // Process each batch group
    for (var group in batchGroups.entries) {
      final entities = group.value;

      final DateTimeRange dateRange = entities.first.queryDateRange!;
      final DateTime batchStartDate = dateRange.start;
      final DateTime batchEndDate = dateRange.end;

      // Collect all unique HealthDataTypes for this batch
      final Set<HealthDataType> batchTypes = entities
          .expand((entity) => entity.healthItem.dataType)
          .toSet();

      List<HealthDataPoint> points = [];
      try {
        points = await _health.getHealthDataFromTypes(
          startTime: batchStartDate,
          endTime: batchEndDate,
          types: batchTypes.toList(),
        );
        points = removeOverlappingData(points);
      } catch (e) {
        await ErrorLogger.logError('Error fetching health data batch: $e');
        continue;
      }

      // Process and distribute the data points
      for (var type in batchTypes) {
        final typePoints = points.where((p) => p.type == type).map((p) {
          return DataPoint(
            value: (p.value as NumericHealthValue).numericValue.toDouble(),
            dateFrom: p.dateFrom,
            dateTo: p.dateTo,
            dayOccurred: p.dateFrom,
          );
        }).toList();

        data[type] = typePoints;
      }
    }

    return data;
  }

  Future<List<SleepDataPoint>> _fetchSleepHealthData(DateTime startDate, DateTime endDate) async {
    List<SleepDataPoint> data = [];
    List<HealthDataPoint> points = [];
    try {
      points = await _health.getHealthDataFromTypes(
        startTime: startDate.add(const Duration(hours: -6)), // Fetch 6 hours before start date to catch sleep from previous night
        endTime: endDate,
        types: sleepTypes,
      );
      points = removeOverlappingData(points);
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
      return [];
    }

    for (var item in sleepTypes) {
      data.addAll(points.where((p) => p.type == item).map((p) {
        return SleepDataPoint(
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
          dayOccurred: p.dateFrom.hour >= 18 ? p.dateFrom.add(const Duration(days: 1)) : p.dateFrom,
          sleepStage: _mapSleepStage(item),
        );
      }).toList());
    }

    // Filter out any points that are not in the date range
    data = data.where((p) => 
      !p.dayOccurred.isAfter(endDate)
    ).toList();
    
    return data;
  }

  SleepStage _mapSleepStage(HealthDataType type) {
    switch (type) {
      case HealthDataType.SLEEP_AWAKE:
        return SleepStage.awake;
      case HealthDataType.SLEEP_DEEP:
        return SleepStage.deep;
      case HealthDataType.SLEEP_LIGHT:
        return SleepStage.light;
      case HealthDataType.SLEEP_REM:
        return SleepStage.rem;
      default:
        return SleepStage.unknown;
    }
  }
}
