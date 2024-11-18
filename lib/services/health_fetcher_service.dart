import 'dart:async';
import 'package:fitxp/constants/health_data_types.constants.dart';
import 'package:health/health.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';

class HealthFetcherService {
  final _health = Health();
  bool _isAuthorized = false;

  Map<String, List<HealthDataPoint>> _cache = {};

  Map<HealthDataType, List<HealthDataPoint>> _dataMap = {};

  HealthFetcherService(){
    _initialize();
  }

  Future<void> _initialize() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
  }

  Future<bool> checkAndRequestPermissions() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(healthDataTypes);
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<HealthDataPoint>>> fetchData(List<HealthDataType> types, TimeFrame timeframe, int offset) async {
    final cacheKey = _generateCacheKey(types, timeframe, offset);

    // Check if the requested data is already in the cache
    if (_cache.containsKey(cacheKey)) {
      return {for (var type in types) type: _cache[cacheKey]!.where((point) => point.type == type).toList()};
    }

    final data = await _fetchDataInternal(types, timeframe, offset);
    _cache[cacheKey] = data; // Cache the result
    return {for (var type in types) type: data.where((point) => point.type == type).toList()};
  }

  Future<List<HealthDataPoint>> _fetchDataInternal(List<HealthDataType> types, TimeFrame timeframe, int offset) async {
    final dateRange = calculateDateRange(timeframe, offset);

    try {
      return await _health.getHealthDataFromTypes(types: types, startTime: dateRange.start, endTime: dateRange.end);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<int> getSteps(TimeFrame timeframe, int offset) async {
    final dateRange = calculateDateRange(timeframe, offset);
    final data = await _health.getTotalStepsInInterval(dateRange.start, dateRange.end);
    return data ?? 0;
  }

  String _generateCacheKey(List<HealthDataType> types, TimeFrame timeframe, int offset) {
    final typeString = types.map((type) => type.toString()).join(',');
    return '$typeString|$timeframe|$offset';
  }

  void clearCache() {
    _cache.clear();
    _dataMap.clear();
  }
}
