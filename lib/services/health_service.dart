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
    // Add other data types as needed
  ];

  HealthService() {
    _initialize();
  }

  Future<void> _initialize() async {
    // Request authorization
    _isAuthorized = await _health.hasPermissions(_dataTypes) == true;
  }

  Future<List<HealthDataPoint>> _fetchData(
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

  // Fetch Steps
  Future<int> getTotalSteps(TimeFrame timeFrame, {int offset = 0}) async {
    final dateRange = calculateDateRange(timeFrame, offset: offset);
    int? steps = await _health.getTotalStepsInInterval(
      dateRange.start,
      dateRange.end,
    );
    return steps ?? 0;
  }

  // Fetch Active Calories Burned
  Future<double> getActiveCaloriesBurned(TimeFrame timeFrame,
      {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.ACTIVE_ENERGY_BURNED,
      timeFrame,
      offset: offset,
    );

    double totalCalories = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.value as NumericHealthValue).numericValue,
    );

    return totalCalories;
  }

  // Fetch Resting Calories Burned (Basal Energy Burned)
  Future<double> getRestingCaloriesBurned(TimeFrame timeFrame,
      {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.BASAL_ENERGY_BURNED,
      timeFrame,
      offset: offset,
    );

    double totalCalories = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.value as NumericHealthValue).numericValue,
    );

    return totalCalories;
  }

  // Fetch Dietary Calories Eaten
  Future<double> getDietaryCaloriesConsumed(TimeFrame timeFrame,
      {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.DIETARY_ENERGY_CONSUMED,
      timeFrame,
      offset: offset,
    );

    double totalCalories = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.value as NumericHealthValue).numericValue,
    );

    return totalCalories;
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

  // Fetch Hours Slept
  Future<double> getSleepHours(TimeFrame timeFrame, {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.SLEEP_ASLEEP,
      timeFrame,
      offset: offset,
    );

    double totalMinutes = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + element.dateTo.difference(element.dateFrom).inMinutes,
    );

    return totalMinutes / 60.0; // Convert minutes to hours
  }

  // Fetch Exercise Minutes
  Future<double> getExerciseMinutes(TimeFrame timeFrame,
      {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.EXERCISE_TIME,
      timeFrame,
      offset: offset,
    );

    double totalMinutes = data.fold(
      0.0,
      (previousValue, element) =>
          previousValue + (element.value as NumericHealthValue).numericValue,
    );

    return totalMinutes;
  }

  // Fetch Protein Intake
  Future<double> getProteinIntake(TimeFrame timeFrame, {int offset = 0}) async {
    final data = await _fetchData(
      HealthDataType.DIETARY_PROTEIN_CONSUMED,
      timeFrame,
      offset: offset,
    );

    double totalProtein = 0.0;

    for (var point in data) {
      final value = point.value as NutritionHealthValue;
      totalProtein += value.protein ?? 0.0;
    }

    return totalProtein;
  }
}
