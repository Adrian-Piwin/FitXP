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
import 'package:provider/provider.dart';
import 'package:healthxp/services/db_service.dart';

class HomeController extends ChangeNotifier with WidgetsBindingObserver {
  final HealthFetcherService _healthFetcherService = HealthFetcherService();
  final DBService _dbService = DBService();
  late final HealthDataCache _healthDataCache;
  late final WidgetConfigurationService _widgetConfigurationService;
  final BuildContext context;

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation
  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  bool get isLoading => _isLoading;

  // Default widget order
  List<HealthItem> get defaultHealthItems => [
        HealthItemDefinitions.expendedEnergy,
        HealthItemDefinitions.dietaryCalories,
        HealthItemDefinitions.netCalories,
        HealthItemDefinitions.activeCalories,
        HealthItemDefinitions.steps,
        HealthItemDefinitions.proteinIntake,
        HealthItemDefinitions.sleepDuration,
        HealthItemDefinitions.exerciseTime,
        HealthItemDefinitions.weight,
        HealthItemDefinitions.bodyFat,
      ];

  List<HealthEntity> healthItemEntities = [];
  List<Widget> displayWidgets = [];

  HomeController(this.context) {
    WidgetsBinding.instance.addObserver(this);
    _widgetConfigurationService = Provider.of<WidgetConfigurationService>(context, listen: false);
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      await _healthFetcherService.initialize();
      _healthDataCache = await HealthDataCache.getInstance();

      // Get the saved configuration first
      final config = await _dbService.getDocument('widget_configuration', 'default_config');
      
      // Create a list of all health items we need to initialize
      List<HealthItem> itemsToInitialize = [...defaultHealthItems];
      
      if (config != null) {
        final List<dynamic> headerOrder = config['headerOrder'] ?? [];
        final List<dynamic> order = config['order'] ?? [];
        final List<String> savedTypes = [...headerOrder, ...order];
        
        // Add any additional items from saved configuration
        final allAvailableItems = [
          HealthItemDefinitions.expendedEnergy,
          HealthItemDefinitions.dietaryCalories,
          HealthItemDefinitions.netCalories,
          HealthItemDefinitions.activeCalories,
          HealthItemDefinitions.steps,
          HealthItemDefinitions.proteinIntake,
          HealthItemDefinitions.sleepDuration,
          HealthItemDefinitions.exerciseTime,
          HealthItemDefinitions.weight,
          HealthItemDefinitions.bodyFat,
          HealthItemDefinitions.workoutTime,
          HealthItemDefinitions.dietaryCarbs,
          HealthItemDefinitions.dietaryFats,
          HealthItemDefinitions.dietaryFiber,
          HealthItemDefinitions.dietarySugar,
          HealthItemDefinitions.water,
          HealthItemDefinitions.mindfulness,
          HealthItemDefinitions.flightsClimbed,
          HealthItemDefinitions.distanceWalkingRunning,
          HealthItemDefinitions.distanceCycling,
        ];
        
        // Add any saved items that aren't in our default set
        for (String type in savedTypes) {
          final matchingItem = allAvailableItems.firstWhere(
            (item) => item.itemType.toString().split('.').last == type,
            orElse: () => defaultHealthItems[0]
          );
          if (!itemsToInitialize.contains(matchingItem)) {
            itemsToInitialize.add(matchingItem);
          }
        }
      }
      
      // Initialize all entities at once
      healthItemEntities = await initializeWidgets(itemsToInitialize, _healthFetcherService);
      
      // Initialize the widget configuration service with all entities
      await _widgetConfigurationService.initializeWithEntities(healthItemEntities);
      
      // Listen to widget configuration changes
      _widgetConfigurationService.addListener(_onWidgetConfigurationChanged);
      
      // Set initial display widgets
      displayWidgets = _widgetConfigurationService.getWidgets();

      // Add listeners to each entity
      for (var entity in healthItemEntities) {
        entity.addListener(() {
          _updateDisplayWidgets();
        });
      }

      // Fetch initial data
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

  void _onWidgetConfigurationChanged() {
    _updateDisplayWidgets();
  }

  void _updateDisplayWidgets() {
    displayWidgets = _widgetConfigurationService.getWidgets();
    notifyListeners();
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

  Future<void> fetchHealthData() async {
    if (_isLoading) return;

    for (var widget in healthItemEntities) {
      widget.isLoading = true;
    }
    _updateDisplayWidgets();

    try {
      await setDataPerWidgetWithTimeframe(healthItemEntities, _selectedTimeFrame, _offset);
      _updateDisplayWidgets();
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      for (var widget in healthItemEntities) {
        widget.isLoading = false;
      }
      _updateDisplayWidgets();
    }
  }

  Future<void> refresh(bool hardRefresh) async {
    if (_isLoading) return;
    
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
    _widgetConfigurationService.removeListener(_onWidgetConfigurationChanged);
    super.dispose();
  }
}
