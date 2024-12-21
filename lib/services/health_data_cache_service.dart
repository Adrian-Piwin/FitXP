import 'package:health/health.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';

class HealthDataCache {
  static final HealthDataCache _instance = HealthDataCache._internal();
  static const String _boxName = 'health_data_cache';
  Box<List<dynamic>>? _box;
  bool _initialized = false;
  
  factory HealthDataCache() => _instance;

  HealthDataCache._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<List<dynamic>>(_boxName);
      _initialized = true;
    } catch (e) {
      print('Failed to initialize cache: $e');
      _initialized = false;
    }
  }

  Box<List<dynamic>> get _getBox {
    if (_box == null) {
      throw StateError('HealthDataCache must be initialized before use. Call initialize() first.');
    }
    return _box!;
  }

  String _generateKey(TimeFrame timeframe, int offset, HealthDataType type) => 
    '${timeframe.name}_${offset}_${type.name}';

  Future<void> cacheDataPoint(
    TimeFrame timeframe, 
    int offset, 
    HealthDataType type, 
    List<DataPoint> data
  ) async {
    final key = _generateKey(timeframe, offset, type);
    final serializedData = _serializeDataPoints(data, type);
    await _getBox.put(key, serializedData);
  }

  List<dynamic> _serializeDataPoints(List<DataPoint> data, HealthDataType type) {
    return data.map((point) => _serializeDataPoint(point, type)).toList();
  }

  Map<String, Object> _serializeDataPoint(DataPoint point, HealthDataType type) {
    var baseData = {
      'value': point.value,
      'dateFrom': point.dateFrom.toIso8601String(),
      'dateTo': point.dateTo.toIso8601String(),
      'dayOccurred': point.dayOccurred.toIso8601String(),
    };

    if (type == HealthDataType.SLEEP_ASLEEP && point is SleepDataPoint) {
      baseData['sleepStage'] = point.sleepStage?.index as Object;
    }

    return baseData;
  }

  List<DataPoint>? getDataForType(
    TimeFrame timeframe, 
    int offset, 
    HealthDataType type
  ) {
    final key = _generateKey(timeframe, offset, type);
    final data = _getBox.get(key);
    
    if (data == null) return null;

    return type == HealthDataType.SLEEP_ASLEEP
        ? _deserializeSleepData(data)
        : _deserializeDataPoints(data);
  }

  List<DataPoint> _deserializeDataPoints(List<dynamic> data) {
    return data.map<DataPoint>((point) => DataPoint(
      value: point['value'],
      dateFrom: DateTime.parse(point['dateFrom']),
      dateTo: DateTime.parse(point['dateTo']),
      dayOccurred: DateTime.parse(point['dayOccurred']),
    )).toList();
  }

  List<SleepDataPoint> _deserializeSleepData(List<dynamic> data) {
    return data.map<SleepDataPoint>((point) => SleepDataPoint(
      value: point['value'],
      dateFrom: DateTime.parse(point['dateFrom']),
      dateTo: DateTime.parse(point['dateTo']),
      dayOccurred: DateTime.parse(point['dayOccurred']),
      sleepStage: point['sleepStage'] != null 
          ? SleepStage.values[point['sleepStage']]
          : SleepStage.unknown,
    )).toList();
  }

  Future<void> cacheData(TimeFrame timeframe, int offset, Map<HealthDataType, List<DataPoint>> data) async {
    for (var entry in data.entries) {
      await cacheDataPoint(timeframe, offset, entry.key, entry.value);
    }
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

  Future<void> clearCache() async {
    await _getBox.clear();
  }

  Future<void> clearCacheForTimeFrameAndOffset(TimeFrame timeframe, int offset) async {
    final keysToRemove = _getBox.keys.where((key) {
      final parts = key.toString().split('_');
      return parts[0] == timeframe.name && parts[1] == offset.toString();
    }).toList();

    for (var key in keysToRemove) {
      await _getBox.delete(key);
    }
  }

  bool get isInitialized => _initialized;
} 
