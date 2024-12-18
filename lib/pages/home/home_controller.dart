import 'package:flutter/material.dart';
import 'package:healthxp/services/error_logger.service.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../models/goal.model.dart';
import '../../models/health_entities/health_entity.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../services/db_goals_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final DBGoalsService _goalsService = DBGoalsService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation

  Goal? _goals;
  HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  Goal? get goals => _goals;
  bool get isLoading => _isLoading;

  // Widgets
  List<HealthItem> get headerHealthItems => [
        HealthItemDefinitions.expendedEnergy,
        HealthItemDefinitions.dietaryCalories,
        HealthItemDefinitions.netCalories,
        HealthItemDefinitions.steps,
      ];

  List<HealthItem> get healthItems => [
        HealthItemDefinitions.proteinIntake,
        HealthItemDefinitions.exerciseTime,
        HealthItemDefinitions.sleepDuration,
        HealthItemDefinitions.steps,
        HealthItemDefinitions.expendedEnergy,
        HealthItemDefinitions.dietaryCalories,
        HealthItemDefinitions.netCalories,
        HealthItemDefinitions.weight,
        HealthItemDefinitions.bodyFat,
      ];

  List<HealthEntity> headerWidgets = [];
  List<HealthEntity> displayWidgets = [];

  List<HealthEntity> get _allRequiredHealthEntities {
    return [...headerWidgets, ...displayWidgets];
  }

  HomeController(BuildContext context) {
    _initialize();
  }

  void updateTimeFrame(TimeFrame newTimeFrame) {
    _selectedTimeFrame = newTimeFrame;
    _offset = 0;
    fetchHealthData();
  }

  void updateOffset(int newOffset) {
    _offset = newOffset;
    fetchHealthData();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await fetchGoalsData();
      
      if (_goals == null) {
        throw Exception('Failed to load goals');
      }

      headerWidgets = headerHealthItems.map((healthItem) {
        return healthItem.widgetFactory(
          healthItem,
          _goals!,
          2,
        );
      }).toList();

      displayWidgets = healthItems.map((healthItem) {
        return healthItem.widgetFactory(
          healthItem,
          _goals!,
          2,
        );
      }).toList();

      // Deplay so our widgets are loaded before we fetch data
      await Future.delayed(const Duration(milliseconds: 50));

      await fetchHealthData();
    } catch (e, stackTrace) {
      await ErrorLogger.logError(
        'Error during initialization: $e', 
        stackTrace: stackTrace
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGoalsData() async {
    Goal? goals = await _goalsService.getGoals();
    if (goals != null) {
      _goals = goals;
    } else {
      throw Exception('Failed to load goals data');
    }
  }

  Future<void> fetchHealthData() async {
    _isLoading = true;
    for (var widget in [...headerWidgets, ...displayWidgets]) {
      widget.isLoading = true;
    }
    notifyListeners();

    try {
      for (var widget in [...headerWidgets, ...displayWidgets]) {
        widget.updateQuery(_selectedTimeFrame, _offset);
      }
      final batchData = await _healthFetcherService.fetchBatchData(_allRequiredHealthEntities);

      for (var widget in [...headerWidgets, ...displayWidgets]) {
        widget.updateData(batchData);
      }
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      _isLoading = false;
      for (var widget in [...headerWidgets, ...displayWidgets]) {
        widget.isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _healthFetcherService.clearCache();
    await fetchHealthData();
  }

  Future<void> refreshToday() async {
    await _healthFetcherService.clearCacheForKey(TimeFrame.day, 0);
    await fetchHealthData();
  }
}
