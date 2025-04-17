import 'package:flutter/material.dart';
import 'package:healthcore/constants/health_item_definitions.constants.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/data_points/workout_data_point.model.dart';
import 'package:healthcore/models/health_entities/workout_health_entity.model.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/services/health_data_cache_service.dart';
import 'package:healthcore/services/health_fetcher_service.dart';

class WorkoutsController extends ChangeNotifier {
  late final HealthFetcherService _healthFetcherService;
  late final WorkoutHealthEntity _workoutEntity;
  late final HealthDataCache _healthDataCache;
  bool _isLoading = false;
  TimeFrame _selectedTimeFrame = TimeFrame.week;
  int _offset = 0;
  List<WorkoutDataPoint> _workouts = [];
  Set<String> _selectedWorkoutTypes = {};
  Set<String> _availableWorkoutTypes = {};

  bool get isLoading => _isLoading;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  List<WorkoutDataPoint> get workouts => _selectedWorkoutTypes.isEmpty 
    ? _workouts 
    : _workouts.where((w) => _selectedWorkoutTypes.contains(w.workoutType)).toList();
  List<TimeFrame> get timeFrameOptions => const [TimeFrame.week, TimeFrame.month, TimeFrame.year];
  Set<String> get selectedWorkoutTypes => _selectedWorkoutTypes;
  Set<String> get availableWorkoutTypes => _availableWorkoutTypes;

  // Workout Summary Getters
  int get workoutCount => workouts.length;
  double get totalDuration => workouts.fold(0, (sum, w) => sum + w.value);
  double get totalCalories => workouts.fold(0, (sum, w) => sum + (w.energyBurned ?? 0));

  WorkoutsController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthFetcherService = await HealthFetcherService.getInstance();
      _healthDataCache = await HealthDataCache.getInstance();
      _workoutEntity = WorkoutHealthEntity(
        HealthItemDefinitions.workoutTime,
        6,
        _healthFetcherService,
      );
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
      
      // Update available workout types
      _availableWorkoutTypes = _workouts
        .where((w) => w.workoutType != null)
        .map((w) => w.workoutType!)
        .toSet();
      
      // Remove selected types that are no longer available
      _selectedWorkoutTypes.removeWhere(
        (type) => !_availableWorkoutTypes.contains(type)
      );
    } catch (e) {
      await ErrorLogger.logError('Error fetching workouts: $e');
    }
    notifyListeners();
  }

  void toggleWorkoutType(String type) {
    if (_selectedWorkoutTypes.contains(type)) {
      _selectedWorkoutTypes.remove(type);
    } else {
      _selectedWorkoutTypes.add(type);
    }
    notifyListeners();
  }

  void selectAllWorkoutTypes() {
    _selectedWorkoutTypes = Set.from(_availableWorkoutTypes);
    notifyListeners();
  }

  void clearWorkoutTypes() {
    _selectedWorkoutTypes.clear();
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
    try {
      _offset = 0;
      // Ensure cache is initialized before using it
      await _healthDataCache.clearTodaysCache();
      await _fetchData();
    } catch (e) {
      await ErrorLogger.logError('Error refreshing workouts: $e');
    }
  }

  @override
  void dispose() {
    _workoutEntity.dispose();
    super.dispose();
  }
} 
