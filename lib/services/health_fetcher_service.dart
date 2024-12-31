import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/utility/general.utility.dart';
import '../models/data_point.model.dart';
import '../services/health_data_cache_service.dart';
import '../utility/health.utility.dart';

class HealthFetcherService {
  final Health _health = Health();
  final HealthDataCache _cache = HealthDataCache();
  bool _isAuthorized = false;

  HealthFetcherService() {
    _initialize();
  }

  Future<void> _initialize() async {
    await dotenv.load(fileName: ".env");
    _isAuthorized = await _health.hasPermissions(AllHealthDataTypes) == true;
    await _cache.initialize();
  }

  Future<bool> checkAndRequestPermissions() async {
    _isAuthorized = await _health.hasPermissions(AllHealthDataTypes) == true;
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(AllHealthDataTypes);
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
      List<HealthEntity> entities) async {
    Map<HealthDataType, List<DataPoint>> result = {};

    for (var entity in entities) {
      for (var type in entity.healthItem.dataType) {
        final dateRange = entity.queryDateRange!;
        final lastFullCache = _cache.getLastFullCacheTime();
        
        if (lastFullCache != null) {
          // Fetch fresh data from last cache time to now
          final freshData = await _fetchHealthData(
            type, 
            DateTimeRange(start: lastFullCache, end: DateTime.now())
          );
          
          if (freshData.isNotEmpty) {
            await _cache.replaceRecentDataPoints(type, freshData, DateTime.now());
          }
        }
        
        // Get cached data for the requested range
        final cachedData = _cache.getDataForTimeFrame(
          type,
          dateRange.start,
          dateRange.end,
        );
        
        if (cachedData != null && cachedData.isNotEmpty) {
          result[type] = cachedData;
        }
      }
    }

    return result;
  }

  Future<List<DataPoint>> _fetchHealthData(
      HealthDataType healthType, DateTimeRange dateRange) async {
    if (healthType == HealthDataType.SLEEP_ASLEEP) {
      return await _fetchSleepHealthData(dateRange.start, dateRange.end);
    }

    List<DataPoint> data = [];

    try {
      List<HealthDataPoint> points = await _health.getHealthDataFromTypes(
        startTime: dateRange.start,
        endTime: dateRange.end,
        types: [healthType],
      );
      points = removeOverlappingData(points);

      // Process points for each type
      return points.map((p) {
        return DataPoint(
          value: p.value is NumericHealthValue 
          ? (p.value as NumericHealthValue).numericValue.toDouble()
          : (p.value as WorkoutHealthValue).totalEnergyBurned?.toDouble() 
          ?? 0.0,
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
          dayOccurred: p.dateFrom,
          subType: p.value is WorkoutHealthValue 
          ? (p.value as WorkoutHealthValue).workoutActivityType.name
          : null,
        );
      }).toList();
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    return data;
  }

  Future<List<SleepDataPoint>> _fetchSleepHealthData(
      DateTime startDate, DateTime endDate) async {
    List<SleepDataPoint> data = [];
    List<HealthDataPoint> points = [];
    try {
      // Fetch 6 hours before start date to catch sleep from previous night
      points = await _health.getHealthDataFromTypes(
        startTime: startDate.add(const Duration(hours: -6)),
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
          dayOccurred: p.dateFrom.hour >= 18
              ? p.dateFrom.add(const Duration(days: 1))
              : p.dateFrom,
          sleepStage: mapSleepStage(item),
        );
      }).toList());
    }

    // Filter out any points that are not in the date range
    data = data.where((p) => !p.dayOccurred.isAfter(endDate)).toList();
    return data;
  }

  Future<void> cacheAllHistoricalData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 365));
    
    await _cache.clearCache();
    await _cache.initialize();

    for (var type in AllHealthDataTypes) {
      final data = await _fetchHealthData(
        type,
        DateTimeRange(start: startDate, end: endDate),
      );
      
      if (data.isNotEmpty) {
        await _cache.cacheDataPoints(type, data, endDate);
      }
    }

    // Update the last full cache time
    await _cache.updateLastFullCacheTime(endDate);
  }

  bool _isRecentDateRange(DateTimeRange range) {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return range.end.isAfter(twoDaysAgo);
  }
}
