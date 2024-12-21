import 'package:health/health.dart';
import '../models/data_point.model.dart';
import '../models/health_entities/health_entity.model.dart';

class CacheCheckResult {
  final Map<HealthDataType, List<DataPoint>> cachedData;
  final Map<HealthDataType, List<HealthEntity>> uncachedTypes;

  CacheCheckResult(this.cachedData, this.uncachedTypes);
}

class TypeCacheResult {
  final List<DataPoint> cached;
  final List<HealthEntity> uncached;

  TypeCacheResult(this.cached, this.uncached);
} 
