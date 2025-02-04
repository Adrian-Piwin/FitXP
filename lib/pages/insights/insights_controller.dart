import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/services/widget_configuration_service.dart';
import 'package:healthxp/utility/health.utility.dart';

class InsightsController extends ChangeNotifier {
  HealthFetcherService _healthFetcherService = HealthFetcherService();
  late final HealthDataCache _healthDataCache;
  late WidgetConfigurationService _widgetConfigurationService;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<HealthItem> get healthItems => [
        HealthItemDefinitions.steps,
        HealthItemDefinitions.workoutTime,
        HealthItemDefinitions.sleepDuration,
        HealthItemDefinitions.proteinIntake,
      ];

  List<HealthEntity> healthItemEntities = [];
  List<Widget> displayWidgets = [];

  InsightsController() {
    _initialize();
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
          displayWidgets = _widgetConfigurationService.getWeeklyInsightWidgets();
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
    displayWidgets = _widgetConfigurationService.getWeeklyInsightWidgets();
    notifyListeners();

    try {
      await setDataPerWidgetWithTimeframe(healthItemEntities, TimeFrame.week, 0);
      displayWidgets = _widgetConfigurationService.getWeeklyInsightWidgets();
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      for (var widget in healthItemEntities) {
        widget.isLoading = false;
      }
      displayWidgets = _widgetConfigurationService.getWeeklyInsightWidgets();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _healthDataCache.clearTodaysCache();
    await fetchHealthData();
  }

  @override
  void dispose() {
    for (var entity in healthItemEntities) {
      entity.dispose();
    }
    super.dispose();
  }
} 
