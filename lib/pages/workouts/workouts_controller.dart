import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/data_points/workout_data_point.model.dart';
import 'package:healthxp/models/health_entities/workout_health_entity.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/health_fetcher_service.dart';

class WorkoutsController extends ChangeNotifier {
  final HealthFetcherService _healthFetcherService = HealthFetcherService();
  late final WorkoutHealthEntity _workoutEntity;
  late final HealthDataCache _healthDataCache;
  bool _isLoading = false;
  TimeFrame _selectedTimeFrame = TimeFrame.month;
  int _offset = 0;
  List<WorkoutDataPoint> _workouts = [];

  bool get isLoading => _isLoading;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  List<WorkoutDataPoint> get workouts => _workouts;
  List<TimeFrame> get timeFrameOptions => const [TimeFrame.month, TimeFrame.year];

  // Workout Summary Getters
  int get workoutCount => _workouts.length;
  double get totalDuration => _workouts.fold(0, (sum, w) => sum + w.value);
  double get totalCalories => _workouts.fold(0, (sum, w) => sum + (w.energyBurned ?? 0));

  WorkoutsController() {
    _workoutEntity = WorkoutHealthEntity(
      HealthItemDefinitions.workoutTime,
      6,
      _healthFetcherService,
    );
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _healthFetcherService.initialize();
      _healthDataCache = await HealthDataCache.getInstance();
      await _workoutEntity.initialize();
      await _fetchData();
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        'Error during initialization: $e',
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchData() async {
    try {
      _workoutEntity.updateQuery(_selectedTimeFrame, _offset);
      await _workoutEntity.updateData();
      _workouts = _workoutEntity.workoutDataPoints(_workoutEntity.data)
        ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    } catch (e) {
      await ErrorLogger.logError('Error fetching workouts: $e');
    }
    notifyListeners();
  }

  Future<void> updateTimeFrame(TimeFrame timeFrame) async {
    _selectedTimeFrame = timeFrame;
    _offset = 0;
    _workoutEntity.timeframe = timeFrame;
    await _fetchData();
  }

  Future<void> updateOffset(int newOffset) async {
    _offset = newOffset;
    _workoutEntity.offset = newOffset;
    await _fetchData();
  }

  Future<void> refresh() async {
    _offset = 0;
    await _healthDataCache.clearTodaysCache();
    await _fetchData();
  }

  @override
  void dispose() {
    _workoutEntity.dispose();
    super.dispose();
  }
} 
