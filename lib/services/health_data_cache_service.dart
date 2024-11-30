import 'package:health/health.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';

class HealthDataCache {
  static final HealthDataCache _instance = HealthDataCache._internal();
  factory HealthDataCache() => _instance;

  // Cache structure: timeframe_offset_healthDataType -> List<DataPoint>
  final Map<String, List<DataPoint>> _cache = {};

  HealthDataCache._internal();

  String _generateKey(TimeFrame timeframe, int offset, HealthDataType type) => 
    '${timeframe.name}_${offset}_${type.name}';

  void cacheDataPoint(TimeFrame timeframe, int offset, HealthDataType type, List<DataPoint> data) {
    final key = _generateKey(timeframe, offset, type);
    _cache[key] = data;
  }

  void cacheData(TimeFrame timeframe, int offset, Map<HealthDataType, List<DataPoint>> data) {
    data.forEach((type, dataPoints) {
      cacheDataPoint(timeframe, offset, type, dataPoints);
    });
  }

  List<DataPoint>? getDataForType(TimeFrame timeframe, int offset, HealthDataType type) {
    final key = _generateKey(timeframe, offset, type);
    return _cache[key];
  }

  Map<HealthDataType, List<DataPoint>> getData(
    TimeFrame timeframe, 
    int offset, 
    List<HealthDataType> types
  ) {
    Map<HealthDataType, List<DataPoint>> result = {};
    
    for (var type in types) {
      final data = getDataForType(timeframe, offset, type);
      if (data != null) {
        result[type] = data;
      }
    }
    
    return result;
  }

  void clearCache() {
    _cache.clear();
  }

  void clearCacheForTimeFrameAndOffset(TimeFrame timeframe, int offset) {
    final keysToRemove = _cache.keys.where((key) {
      final parts = key.split('_');
      return parts[0] == timeframe.name && parts[1] == offset.toString();
    }).toList();

    for (var key in keysToRemove) {
      _cache.remove(key);
    }
  }
} 
