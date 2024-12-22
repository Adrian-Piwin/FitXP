import 'package:flutter/material.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/utility/health.utility.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../models/health_entities/health_entity.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../services/db_goals_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final DBGoalsService _goalsService = DBGoalsService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation

  HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = false;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

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
      headerWidgets = await initializeWidgets(_goalsService, headerHealthItems);
      displayWidgets = await initializeWidgets(_goalsService, healthItems);

      // Deplay so our widgets are loaded before we fetch data
      await Future.delayed(const Duration(milliseconds: 100));

      await fetchHealthData();
      _isLoading = false;
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

  Future<void> fetchHealthData() async {
    for (var widget in _allRequiredHealthEntities) {
      widget.isLoading = true;
    }
    notifyListeners();

    try {
      await setDataPerWidget(_healthFetcherService, _allRequiredHealthEntities, _selectedTimeFrame, _offset);
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      for (var widget in _allRequiredHealthEntities) {
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
