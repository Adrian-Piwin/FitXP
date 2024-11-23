import 'package:health/health.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';

class HealthDataCache {
  static final HealthDataCache _instance = HealthDataCache._internal();
  factory HealthDataCache() => _instance;

  final Map<String, Map<HealthDataType, List<DataPoint>>> _cache = {};

  HealthDataCache._internal();

  String _generateKey(TimeFrame timeframe, int offset) => '${timeframe.name}_$offset';

  void cacheData(TimeFrame timeframe, int offset, Map<HealthDataType, List<DataPoint>> data) {
    final key = _generateKey(timeframe, offset);
    _cache[key] = data;
  }

  Map<HealthDataType, List<DataPoint>>? getData(TimeFrame timeframe, int offset) {
    final key = _generateKey(timeframe, offset);
    return _cache[key];
  }

  void clearCache() {
    _cache.clear();
  }
} 
