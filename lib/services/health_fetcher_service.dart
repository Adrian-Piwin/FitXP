import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/data_points/workout_data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/data_points/sleep_data_point.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/utility/general.utility.dart';
import '../models/data_points/data_point.model.dart';
import '../services/health_data_cache_service.dart';
import '../utility/health.utility.dart';
import 'package:synchronized/synchronized.dart';

class HealthFetcherService {
  static HealthFetcherService? _instance;
  static final _lock = Lock();
  final Health _health = Health();
  late final HealthDataCache _cache;
  bool _isAuthorized = false;
  bool _isInitialized = false;

  // Private constructor
  HealthFetcherService._();

  // Factory constructor to get instance
  static Future<HealthFetcherService> getInstance() async {
    if (_instance == null) {
      await _lock.synchronized(() async {
        if (_instance == null) {
          _instance = HealthFetcherService._();
          await _instance!._initialize();
        }
      });
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    await dotenv.load(fileName: ".env");
    _isAuthorized = await _health.hasPermissions(allHealthDataTypes) == true;
    
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(allHealthDataTypes);
    }
    
    _cache = await HealthDataCache.getInstance();
    _isInitialized = true;
  }

  bool get isReady => _isInitialized && _isAuthorized;

  Future<bool> checkAndRequestPermissions() async {
    if (!_isInitialized) {
      await _initialize();
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
      List<HealthEntity> entities) async {
    if (!isReady) {
      await _initialize();
      if (!isReady) {
        return {};
      }
    }
    Map<HealthDataType, List<DataPoint>> result = {};

    for (var entity in entities) {
      for (var type in entity.healthItem.dataType) {
        final dateRange = entity.queryDateRange!;
        
        // Get cached data and identify missing days
        final cachedData = await _cache.getDataForDays(
          type,
          dateRange.start,
          dateRange.end,
        );
        
        List<DataPoint> allData = [];
        
        // Fetch fresh data for missing or outdated days
        for (DateTime date = dateRange.start; 
             date.isBefore(dateRange.end); 
             date = date.add(const Duration(days: 1))) {
          
          if (!cachedData.containsKey(date)) {
            // Fetch data for this specific day
            final dayData = await fetchHealthData(
              type,
              DateTimeRange(
                start: date,
                end: date.add(const Duration(days: 1)),
              ),
            );

            await _cache.cacheDayData(type, date, dayData);
            allData.addAll(dayData);
          } else {
            allData.addAll(cachedData[date]!);
          }
        }
        
        if (allData.isNotEmpty) {
          result[type] = allData;
        }
      }
    }
    return result;
  }

  Future<List<DataPoint>> fetchHealthData(
      HealthDataType healthType, DateTimeRange dateRange) async {
    if (healthType == HealthDataType.SLEEP_ASLEEP) {
      return await _fetchSleepHealthData(dateRange.start, dateRange.end);
    }
    if (healthType == HealthDataType.WORKOUT) {
      return await _fetchWorkoutHealthData(dateRange.start, dateRange.end);
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
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
          dayOccurred: p.dateFrom,
        );
      }).toList();
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    return data;
  }

  Future<List<WorkoutDataPoint>> _fetchWorkoutHealthData(
      DateTime startDate, DateTime endDate) async {
    List<WorkoutDataPoint> data = [];
    List<HealthDataPoint> points = [];

    try {
      points = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.WORKOUT],
      );
      points = removeOverlappingData(points);
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
      return [];
    }

    for (var point in points) {
      data.add(WorkoutDataPoint(
        value: point.dateTo.difference(point.dateFrom).inMinutes.toDouble(),
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        dayOccurred: point.dateFrom,
        energyBurned: (point.value as WorkoutHealthValue).totalEnergyBurned?.toDouble(),
        distance: (point.value as WorkoutHealthValue).totalDistance?.toDouble(),
        distanceUnit: (point.value as WorkoutHealthValue).totalDistanceUnit?.name,
        steps: (point.value as WorkoutHealthValue).totalSteps?.toInt(),
        workoutType: (point.value as WorkoutHealthValue).workoutActivityType.name,
      ));
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
}
