import 'dart:async';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
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
  }

  Future<bool> checkAndRequestPermissions() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(healthDataTypes);
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
      Set<HealthDataType> items, TimeFrame timeframe, int offset) async {
    // Check cache first
    final cachedData = _cache.getData(timeframe, offset);
    if (cachedData != null) {
      return Map.from(cachedData);
    }

    Map<HealthDataType, List<DataPoint>> allData = {};

    // Get list of Fitbit-supported types
    final supportedTypes = await _fitbitService.getSupportedHealthTypes(items.toList());
    
    // Split items into Fitbit and Health types
    final fitbitTypes = items.where((type) => supportedTypes.contains(type)).toSet();
    final healthTypes = items.where((type) => !supportedTypes.contains(type)).toSet();

    // Fetch Fitbit data for supported types
    final dateRange = calculateDateRange(timeframe, offset);
    if (fitbitTypes.isNotEmpty) {
      try {
        final fitbitData = await _fitbitService.fetchBatchData(
            fitbitTypes, dateRange.start, dateRange.end);
        allData.addAll(fitbitData);
      } catch (e) {
        print('Fitbit fetch failed, falling back to Health for those types: $e');
        final fallbackData = await _fetchHealthBatchData(fitbitTypes, dateRange.start, dateRange.end);
        allData.addAll(fallbackData);
      }
    }

    // Fetch remaining data from Health
    if (healthTypes.isNotEmpty) {
      final healthData = await _fetchHealthBatchData(healthTypes, dateRange.start, dateRange.end);
      allData.addAll(healthData);
    }

    // Cache the results
    _cache.cacheData(timeframe, offset, allData);
    return allData;
  }

  void clearCache() {
    _cache.clearCache();
  }

  void clearCacheForKey(TimeFrame timeframe, int offset) {
    _cache.clearCacheForKey(timeframe, offset);
  }

  Future<Map<HealthDataType, List<DataPoint>>> _fetchHealthBatchData(
      Set<HealthDataType> items, DateTime startDate, DateTime endDate) async {
    Map<HealthDataType, List<DataPoint>> data = {};

    List<HealthDataPoint> points = [];
    try {
      print('fetching health data for ${items.toList()}');
      points = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: items.toList(),
      );
      points = removeOverlappingData(points);
    } catch (e) {
      print('Error fetching health data: $e');
    }

    for (var item in items) {
      data[item] = points.where((p) => p.type == item).map((p) {
        return DataPoint(
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
          activityType:
              '${p.recordingMethod} ${p.sourceName} ${p.sourcePlatform}',
        );
      }).toList();
    }
    
    return data;
  }
}
