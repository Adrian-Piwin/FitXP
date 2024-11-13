import 'dart:async';
import 'package:fitxp/constants/healthdatatypes.constants.dart';
import 'package:fitxp/models/health_item_value.dart';
import 'package:health/health.dart';
import '../enums/timeframe.enum.dart';
import '../utility/health.utility.dart';
import '../utility/timeframe.utility.dart';

class HealthFetcherService {
  final _health = Health();
  bool _isAuthorized = false;

  Map<String, List<HealthDataPoint>> _cache = {};

  Map<HealthDataType, List<HealthDataPoint>> _dataMap = {};
  TimeFrame _currentTimeFrame = TimeFrame.day;
  int _currentOffset = 0;

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

  void setTimeFrameAndOffset(TimeFrame timeframe, int offset) {
    _currentTimeFrame = timeframe;
    _currentOffset = offset;
  }

  Future<void> fetchData(List<HealthDataType> types) async {
    final cacheKey = _generateCacheKey(types, _currentTimeFrame, _currentOffset);

    // Check if the requested data is already in the cache
    if (_cache.containsKey(cacheKey)) {
      _dataMap = {for (var type in types) type: _cache[cacheKey]!.where((point) => point.type == type).toList()};
      return;
    }

    final data = await _fetchDataInternal(types);
    _cache[cacheKey] = data; // Cache the result
    _dataMap = {for (var type in types) type: data.where((point) => point.type == type).toList()};
  }

  Future<List<HealthDataPoint>> _fetchDataInternal(List<HealthDataType> types) async {
    final dateRange = calculateDateRange(_currentTimeFrame, _currentOffset);

    try {
      return await _health.getHealthDataFromTypes(types: types, startTime: dateRange.start, endTime: dateRange.end);
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  String _generateCacheKey(List<HealthDataType> types, TimeFrame timeframe, int offset) {
    final typeString = types.map((type) => type.toString()).join(',');
    return '$typeString|$timeframe|$offset';
  }

  void clearCache() {
    _cache.clear();
    _dataMap.clear();
  }

  HealthItemValue getBasicHealthItemValue(HealthDataType type) {
    List<HealthDataPoint> dataPoints = _dataMap[type] ?? [];
    return HealthItemValue()
      ..average = getHealthAverage(dataPoints)
      ..total = getHealthTotal(dataPoints);
  }

  HealthItemValue getStrengthTrainingMinutes() {
    List<HealthDataPoint> dataPoints = _dataMap[HealthDataType.WORKOUT] ?? [];

    return HealthItemValue()
      ..average = getWorkoutMinutesAverage(extractStrengthTrainingMinutes(dataPoints))
      ..total = getWorkoutMinutesTotal(extractStrengthTrainingMinutes(dataPoints)); 
  }

  HealthItemValue getCardioMinutes() {
    List<HealthDataPoint> dataPoints = _dataMap[HealthDataType.WORKOUT] ?? [];
    return HealthItemValue()
      ..average = getWorkoutMinutesAverage(extractCardioMinutes(dataPoints))
      ..total = getWorkoutMinutesTotal(extractCardioMinutes(dataPoints)); 
  }

  double getLatestWeight() {
    List<HealthDataPoint> dataPoints = _dataMap[HealthDataType.WEIGHT] ?? [];

    if (dataPoints.isEmpty) {
      return 0;
    }

    dataPoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    return (dataPoints.last.value as NumericHealthValue).numericValue.toDouble();
  }

  double getOldestWeight() {
    List<HealthDataPoint> dataPoints = _dataMap[HealthDataType.WEIGHT] ?? [];

    if (dataPoints.isEmpty) {
      return 0;
    }

    dataPoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    return (dataPoints.first.value as NumericHealthValue).numericValue.toDouble();
  }
}
