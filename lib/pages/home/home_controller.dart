import 'package:flutter/material.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/widget_configuration_service.dart';
import 'package:healthxp/utility/health.utility.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../models/health_entities/health_entity.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier with WidgetsBindingObserver {
  HealthFetcherService _healthFetcherService = HealthFetcherService();
  late final HealthDataCache _healthDataCache;
  late WidgetConfigurationService _widgetConfigurationService;

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation
  bool _isLoading = false;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  bool get isLoading => _isLoading;

  // Widgets
  List<HealthItem> get healthItems => [
        HealthItemDefinitions.expendedEnergy,
        HealthItemDefinitions.dietaryCalories,
        HealthItemDefinitions.netCalories,
        HealthItemDefinitions.activeCalories,
        HealthItemDefinitions.steps,
        HealthItemDefinitions.proteinIntake,
        HealthItemDefinitions.sleepDuration,
        HealthItemDefinitions.exerciseTime,
        HealthItemDefinitions.workoutTime,
        HealthItemDefinitions.weight,
        HealthItemDefinitions.bodyFat,
      ];

  List<HealthEntity> healthItemEntities = [];
  List<Widget> displayWidgets = [];

  HomeController(BuildContext context) {
    WidgetsBinding.instance.addObserver(this);
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
    await _healthFetcherService.initialize();
    _healthDataCache = await HealthDataCache.getInstance();
    _isLoading = true;
    notifyListeners();

    try {
      healthItemEntities = await initializeWidgets(healthItems, _healthFetcherService);
      _widgetConfigurationService = WidgetConfigurationService(healthItemEntities);

      // Add listeners to each entity
      for (var entity in healthItemEntities) {
        entity.addListener(() {
          displayWidgets = _widgetConfigurationService.getWidgets();
          notifyListeners();
        });
      }

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
    for (var widget in healthItemEntities) {
      widget.isLoading = true;
    }
    displayWidgets = _widgetConfigurationService.getWidgets();
    notifyListeners();

    try {
      await setDataPerWidgetWithTimeframe(healthItemEntities, _selectedTimeFrame, _offset);
      displayWidgets = _widgetConfigurationService.getWidgets();
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      for (var widget in healthItemEntities) {
        widget.isLoading = false;
      }
      displayWidgets = _widgetConfigurationService.getWidgets();
      notifyListeners();
    }
  }

  Future<void> refresh(bool hardRefresh) async {
    _selectedTimeFrame = TimeFrame.day;
    _offset = 0;
    if (hardRefresh) {
      await _healthDataCache.clearTodaysCache();
    }
    await fetchHealthData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove listeners when disposing
    for (var entity in healthItemEntities) {
      entity.dispose();
    }
    super.dispose();
  }
}
