import 'dart:async';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
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
      List<HealthDataType> items, TimeFrame timeframe, int offset) async {
    // Check cache first for all requested types
    final cachedData = _cache.getData(timeframe, offset, items);
    
    // Determine which types need to be fetched
    final uncachedTypes = items
        .where((type) => !cachedData.containsKey(type))
        .toList();

    if (uncachedTypes.isEmpty) {
      return cachedData; // All data was in cache
    }

    // Get list of Fitbit-supported types from uncached types only
    final supportedTypes = await _fitbitService.getSupportedHealthTypes(uncachedTypes);
    
    // Split uncached items into Fitbit and Health types
    final fitbitTypes = uncachedTypes.where((type) => supportedTypes.contains(type)).toSet();
    final healthTypes = uncachedTypes.where((type) => !supportedTypes.contains(type)).toSet();

    Map<HealthDataType, List<DataPoint>> newData = {};

    final dateRange = calculateDateRange(timeframe, offset);

    // Fetch sleep data first
    if (healthTypes.contains(HealthDataType.SLEEP_ASLEEP)) {
      try {
        if (_fitbitService.isSleepSupported()) {
          final sleepData = await _fitbitService.getFitbitSleepData(dateRange.start, dateRange.end);
          newData[HealthDataType.SLEEP_ASLEEP] = sleepData;
        }
        else {
          final sleepData = await _fetchSleepHealthData(dateRange.start, dateRange.end);
          newData[HealthDataType.SLEEP_ASLEEP] = sleepData;
        }
        healthTypes.remove(HealthDataType.SLEEP_ASLEEP);
      } catch (e) {
        await ErrorLogger.logError('Error fetching sleep data: $e');
      }
    }
    // Fetch Fitbit data for supported types
    if (fitbitTypes.isNotEmpty) {
      try {
        final fitbitData = await _fitbitService.fetchBatchData(
            fitbitTypes, dateRange.start, dateRange.end);
        newData.addAll(fitbitData);
      } catch (e) {
        await ErrorLogger.logError('Fitbit fetch failed, falling back to Health for those types: $e');
        final fallbackData = await _fetchHealthBatchData(fitbitTypes, dateRange.start, dateRange.end);
        newData.addAll(fallbackData);
      }
    }

    // Fetch remaining data from Health
    if (healthTypes.isNotEmpty) {
      final healthData = await _fetchHealthBatchData(healthTypes, dateRange.start, dateRange.end);
      newData.addAll(healthData);
    }

    // Cache the new data
    await _cache.cacheData(timeframe, offset, newData);

    // Combine cached and new data
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
      Set<HealthDataType> items, DateTime startDate, DateTime endDate) async {
    Map<HealthDataType, List<DataPoint>> data = {};

    List<HealthDataPoint> points = [];
    try {
      points = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: items.toList(),
      );
      points = removeOverlappingData(points);
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    for (var item in items) {
      data[item] = points.where((p) => p.type == item).map((p) {
        return DataPoint(
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
          dayOccurred: p.dateFrom,
        );
      }).toList();
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
