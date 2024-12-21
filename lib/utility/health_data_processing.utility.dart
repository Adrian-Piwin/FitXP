import 'package:health/health.dart';
import '../models/data_point.model.dart';
import '../models/health_entities/health_entity.model.dart';
import '../models/sleep_data_point.model.dart';
import '../enums/sleep_stages.enum.dart';

class HealthDataProcessing {
  static Map<String, List<HealthEntity>> groupEntitiesByTimeframe(List<HealthEntity> entities) {
    Map<String, List<HealthEntity>> batchGroups = {};
    for (var entity in entities) {
      final key = '${entity.timeframe}_${entity.offset}';
      batchGroups.putIfAbsent(key, () => []).add(entity);
    }
    return batchGroups;
  }

  static Map<HealthDataType, List<HealthEntity>> groupEntitiesByType(List<HealthEntity> entities) {
    Map<HealthDataType, List<HealthEntity>> typeGroups = {};
    Map<String, Set<HealthDataType>> processedEntityTypes = {};
    
    for (var entity in entities) {
      String entityKey = entity.healthItem.itemType.toString();
      processedEntityTypes.putIfAbsent(entityKey, () => {});
      
      for (var type in entity.healthItem.dataType) {
        if (processedEntityTypes[entityKey]!.contains(type)) continue;
        
        typeGroups.putIfAbsent(type, () => []).add(entity);
        processedEntityTypes[entityKey]!.add(type);
      }
    }
    return typeGroups;
  }

  static Map<HealthDataType, List<DataPoint>> processHealthPoints(
    List<HealthDataPoint> points,
    Set<HealthDataType> types
  ) {
    Map<HealthDataType, List<DataPoint>> data = {};
    
    for (var type in types) {
      final typePoints = points
          .where((p) => p.type == type)
          .map((p) => _convertHealthPointToDataPoint(p))
          .toList();

      if (typePoints.isNotEmpty) {
        data[type] = typePoints;
      }
    }
    
    return data;
  }

  static DataPoint _convertHealthPointToDataPoint(HealthDataPoint point) {
    return DataPoint(
      value: (point.value as NumericHealthValue).numericValue.toDouble(),
      dateFrom: point.dateFrom,
      dateTo: point.dateTo,
      dayOccurred: point.dateFrom,
    );
  }

  static SleepDataPoint convertToSleepDataPoint(
    HealthDataPoint point,
    SleepStage sleepStage
  ) {
    return SleepDataPoint(
      value: (point.value as NumericHealthValue).numericValue.toDouble(),
      dateFrom: point.dateFrom,
      dateTo: point.dateTo,
      dayOccurred: point.dateFrom.hour >= 18 
          ? point.dateFrom.add(const Duration(days: 1)) 
          : point.dateFrom,
      sleepStage: sleepStage,
    );
  }

  static Set<String> generateCacheKeys(
    Map<HealthDataType, List<HealthEntity>> typeGroups,
    Map<HealthDataType, List<DataPoint>> newData
  ) {
    Set<String> cacheKeys = {};
    
    for (var entry in newData.entries) {
      if (!typeGroups.containsKey(entry.key)) continue;
      
      for (var entity in typeGroups[entry.key]!) {
        cacheKeys.add('${entity.timeframe}_${entity.offset}_${entry.key}');
      }
    }
    
    return cacheKeys;
  }
} 
