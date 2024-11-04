import 'package:health/health.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';

class HealthService {
  final _health = Health();
  bool _isAuthorized = false;

  // List of data types we might need permissions for
  final List<HealthDataType> _dataTypes = [
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.NUTRITION,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.WORKOUT
  ];

  HealthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Request authorization
    _isAuthorized = await _health.hasPermissions(_dataTypes) == true;
  }

  Future<List<HealthDataPoint>> fetchAll(TimeFrame timeFrame, {int offset = 0}) async {
    final dateRange = calculateDateRange(timeFrame, offset: offset);

    return await _health.getHealthDataFromTypes(
      startTime: dateRange.start,
      endTime: dateRange.end,
      types: _dataTypes,
    );
  }

  Future<List<HealthDataPoint>> fetchData(
    HealthDataType type,
    TimeFrame timeFrame, {
    int offset = 0,
  }) async {
    final dateRange = calculateDateRange(timeFrame, offset: offset);

    List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
      startTime: dateRange.start,
      endTime: dateRange.end,
      types: [type],
    );

    // Remove duplicates
    healthData = _health.removeDuplicates(healthData);

    return healthData;
  }

  Future<bool> checkAndRequestPermissions() async {
    // Check if permissions are already granted
    _isAuthorized = await _health.hasPermissions(_dataTypes) == true;
    if (!_isAuthorized) {
      // Request permissions
      _isAuthorized = await _health.requestAuthorization(_dataTypes);
    }
    return _isAuthorized;
  }

  // Fetch Weight
  Future<HealthValue?> getLatestWeight() async {
    final now = DateTime.now();
    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WEIGHT],
      startTime: now.subtract(Duration(days: 30)),
      endTime: now,
    );

    if (data.isNotEmpty) {
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final latest = data.first;
      return latest.value;
    } else {
      return null;
    }
  }

  // Fetch Body Fat Percentage
  Future<HealthValue?> getLatestBodyFatPercentage() async {
    final now = DateTime.now();
    final data = await _health.getHealthDataFromTypes(
      startTime: now.subtract(Duration(days: 30)),
      endTime: now,
      types: [HealthDataType.BODY_FAT_PERCENTAGE],
    );

    if (data.isNotEmpty) {
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final latest = data.first;
      return latest.value;
    } else {
      return null;
    }
  }
}
