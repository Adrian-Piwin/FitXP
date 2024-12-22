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

  /// Public method to fetch data in batch for a list of [HealthEntity].
  /// Breaks down the logic into smaller private methods for clarity.
  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
      List<HealthEntity> entities) async {
    // 1. Group entities by health data type
    final Map<HealthDataType, List<HealthEntity>> typeGroups =
        _groupEntitiesByType(entities);

    // 2. Check cache for each type and determine which data is uncached
    final cachedAndUncached =
        _processCacheChecks(typeGroups);
    final cachedData = cachedAndUncached['cachedData']
        as Map<HealthDataType, List<DataPoint>>;
    final uncachedTypes = cachedAndUncached['uncachedTypes']
        as Map<HealthDataType, List<HealthEntity>>;

    // If everything was cached, return immediately
    if (uncachedTypes.isEmpty) {
      return cachedData;
    }

    // 3. Fetch and aggregate the data for uncached types (Fitbit, Sleep, Health)
    final Map<HealthDataType, List<DataPoint>> newData =
        await _fetchUncachedData(uncachedTypes);

    // 4. Cache the newly fetched data to avoid duplicate fetching
    await _cacheNewData(typeGroups, newData);

    // 5. Combine cached and newly fetched data
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

  /// Fetches a batch of health data using the Health plugin for a list of [HealthEntity].
  /// Already existed as a separate method; left largely unchanged for clarity.
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
      final Set<HealthDataType> batchTypes =
          entities.expand((entity) => entity.healthItem.dataType).toSet();

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

  /// Fetches sleep data using the Health plugin (fallback if Fitbit sleep is not supported or fails).
  /// Already existed as a separate method; left largely unchanged for clarity.
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
          sleepStage: _mapSleepStage(item),
        );
      }).toList());
    }

    // Filter out any points that are not in the date range
    data = data.where((p) => !p.dayOccurred.isAfter(endDate)).toList();
    return data;
  }

  /// Maps a [HealthDataType] to our [SleepStage] enum.
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

  // -------------------------------------------------
  // PRIVATE HELPER METHODS FOR fetchBatchData
  // -------------------------------------------------

  /// Groups the incoming [HealthEntity] list by their [HealthDataType].
  Map<HealthDataType, List<HealthEntity>> _groupEntitiesByType(
      List<HealthEntity> entities) {
    // Group entities by their data types
    Map<HealthDataType, List<HealthEntity>> typeGroups = {};
    // Track which types an entity has been mapped to
    Map<String, Set<HealthDataType>> processedEntityTypes = {};

    for (var entity in entities) {
      String entityKey = entity.healthItem.itemType.toString();
      if (!processedEntityTypes.containsKey(entityKey)) {
        processedEntityTypes[entityKey] = {};
      }

      for (var type in entity.healthItem.dataType) {
        // Skip if we've already mapped this entity to this type
        if (processedEntityTypes[entityKey]!.contains(type)) {
          continue;
        }

        if (!typeGroups.containsKey(type)) {
          typeGroups[type] = [];
        }
        typeGroups[type]!.add(entity);
        processedEntityTypes[entityKey]!.add(type);
      }
    }

    return typeGroups;
  }

  /// Checks the cache for each [HealthDataType] and determines which data is uncached.
  /// Returns a map containing `cachedData`, `uncachedTypes`, and `fetchedCombos`.
  Map<String, dynamic> _processCacheChecks(
      Map<HealthDataType, List<HealthEntity>> typeGroups) {
    final Map<HealthDataType, List<DataPoint>> cachedData = {};
    final Map<HealthDataType, List<HealthEntity>> uncachedTypes = {};

    // Track which timeframe+offset combos we've already fetched for each type
    final Map<HealthDataType, Set<String>> fetchedCombos = {};

    for (var entry in typeGroups.entries) {
      var type = entry.key;
      var entityList = entry.value;
      fetchedCombos[type] = {};

      for (var entity in entityList) {
        // Create unique key for this timeframe+offset combination
        String cacheKey = '${entity.timeframe}_${entity.offset}';

        if (!fetchedCombos[type]!.contains(cacheKey)) {
          var cached = _cache.getDataForType(entity.timeframe, entity.offset, type);
          if (cached != null) {
            cachedData[type] = (cachedData[type] ?? [])..addAll(cached);
            fetchedCombos[type]!.add(cacheKey);
          } else {
            if (!uncachedTypes.containsKey(type)) {
              uncachedTypes[type] = [];
            }
            uncachedTypes[type]!.add(entity);
          }
        }
      }
    }

    return {
      'cachedData': cachedData,
      'uncachedTypes': uncachedTypes,
      'fetchedCombos': fetchedCombos,
    };
  }

  /// Fetches uncached data from Fitbit or Health, and handles special cases like sleep data.
  Future<Map<HealthDataType, List<DataPoint>>> _fetchUncachedData(
    Map<HealthDataType, List<HealthEntity>> uncachedTypes,
  ) async {
    // Get Fitbit-supported types
    final supportedTypes = await _fitbitService.getSupportedHealthTypes(
      uncachedTypes.keys.toList(),
    );

    final Map<HealthDataType, List<DataPoint>> newData = {};

    // 1. Handle sleep data separately if present
    if (uncachedTypes.containsKey(HealthDataType.SLEEP_ASLEEP)) {
      await _fetchSleepData(uncachedTypes, newData);
      uncachedTypes.remove(HealthDataType.SLEEP_ASLEEP);
    }

    // 2. Handle Fitbit data for supported types
    for (var type in supportedTypes) {
      if (uncachedTypes.containsKey(type)) {
        await _fetchDataForTypeUsingFitbit(uncachedTypes, newData, type);
        // Remove the type from uncached after we attempt fetching
        uncachedTypes.remove(type);
      }
    }

    // 3. Handle remaining data via Health plugin
    for (var entry in uncachedTypes.entries) {
      final healthData = await _fetchHealthBatchData(entry.value);
      newData.addAll(healthData);
    }

    return newData;
  }

  /// Fetches and populates [newData] with sleep data (Fitbit if supported, else Health plugin).
  Future<void> _fetchSleepData(
    Map<HealthDataType, List<HealthEntity>> uncachedTypes,
    Map<HealthDataType, List<DataPoint>> newData,
  ) async {
    try {
      if (_fitbitService.isSleepSupported()) {
        // If Fitbit sleep is supported, fetch it from Fitbit
        for (var entity in uncachedTypes[HealthDataType.SLEEP_ASLEEP]!) {
          final dateRange = entity.queryDateRange!;
          final sleepData = await _fitbitService.getFitbitSleepData(
            dateRange.start,
            dateRange.end,
          );
          newData[HealthDataType.SLEEP_ASLEEP] =
              (newData[HealthDataType.SLEEP_ASLEEP] ?? [])..addAll(sleepData);
        }
      } else {
        // Otherwise fetch from Health plugin
        for (var entity in uncachedTypes[HealthDataType.SLEEP_ASLEEP]!) {
          final dateRange = entity.queryDateRange!;
          final sleepData = await _fetchSleepHealthData(
            dateRange.start,
            dateRange.end,
          );
          newData[HealthDataType.SLEEP_ASLEEP] =
              (newData[HealthDataType.SLEEP_ASLEEP] ?? [])..addAll(sleepData);
        }
      }
    } catch (e) {
      await ErrorLogger.logError('Error fetching sleep data: $e');
    }
  }

  /// Attempts to fetch data for a specific type from Fitbit. On failure, falls back to Health plugin.
  Future<void> _fetchDataForTypeUsingFitbit(
    Map<HealthDataType, List<HealthEntity>> uncachedTypes,
    Map<HealthDataType, List<DataPoint>> newData,
    HealthDataType type,
  ) async {
    try {
      final fitbitData = await _fitbitService.fetchBatchData(uncachedTypes[type]!);
      newData.addAll(fitbitData);
      print("Fitbit data fetched for type: $type");
      print(uncachedTypes[type]);
    } catch (e) {
      await ErrorLogger.logError('Fitbit fetch failed: $e');
      // Fall back to Health data
      final healthData = await _fetchHealthBatchData(uncachedTypes[type]!);
      newData.addAll(healthData);
    }
  }

  /// Caches the newly fetched data for each [HealthDataType], avoiding duplicates.
  Future<void> _cacheNewData(
    Map<HealthDataType, List<HealthEntity>> typeGroups,
    Map<HealthDataType, List<DataPoint>> newData,
  ) async {
    // Track which data has already been cached to avoid duplicates
    Set<String> cachedKeys = {};

    for (var entry in newData.entries) {
      final type = entry.key;
      if (!typeGroups.containsKey(type)) continue;

      for (var entity in typeGroups[type]!) {
        // Generate a unique cache key for this data
        String cacheKey = '${entity.timeframe}_${entity.offset}_$type';
        if (!cachedKeys.contains(cacheKey)) {
          await _cache.cacheDataPoint(
            entity.timeframe,
            entity.offset,
            type,
            entry.value,
          );
          cachedKeys.add(cacheKey);
        }
      }
    }
  }
}
