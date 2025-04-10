import 'package:flutter/material.dart';
import 'package:healthcore/models/health_item.model.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/services/health_data_cache_service.dart';
import 'package:healthcore/services/widget_configuration_service.dart';
import 'package:healthcore/utility/health.utility.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../models/health_entities/health_entity.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../enums/timeframe.enum.dart';
import 'package:provider/provider.dart';
import 'package:healthcore/services/db_service.dart';

class HomeController extends ChangeNotifier with WidgetsBindingObserver {
  late final HealthFetcherService _healthFetcherService;
  final DBService _dbService = DBService();
  late final HealthDataCache _healthDataCache;
  late final WidgetConfigurationService _widgetConfigurationService;
  final BuildContext context;

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation
  bool _isLoading = true;
  bool _isFirstTimeLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  bool get isLoading => _isLoading;

  List<HealthEntity> healthItemEntities = [];
  List<Widget> displayWidgets = [];

  HomeController(this.context) {
    WidgetsBinding.instance.addObserver(this);
    _widgetConfigurationService = Provider.of<WidgetConfigurationService>(context, listen: false);
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      _healthFetcherService = await HealthFetcherService.getInstance();
      _healthDataCache = await HealthDataCache.getInstance();

      // Get the saved configuration first
      final config = await _dbService.getDocument('widget_configuration', 'default_config');
      
      // Start with default items
      List<HealthItem> itemsToInitialize = [
        ...HealthItemDefinitions.defaultHeaderItems,
        ...HealthItemDefinitions.defaultBodyItems
      ];
      
      if (config != null) {
        final List<dynamic> order = config['order'] ?? [];
        
        // Add any additional items from saved configuration that aren't in our defaults
        for (String itemType in order) {
          final matchingItem = HealthItemDefinitions.allHealthItems.firstWhere(
            (item) => item.itemType.toString().split('.').last == itemType,
            orElse: () => HealthItemDefinitions.defaultBodyItems.first // Fallback to a default item
          );
          
          if (!itemsToInitialize.any((item) => item.itemType == matchingItem.itemType)) {
            itemsToInitialize.add(matchingItem);
          }
        }
      }

      // Initialize all health entities
      healthItemEntities = await initializeWidgets(itemsToInitialize, _healthFetcherService);
      
      // Initialize widget configuration service with the initialized entities
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
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      await ErrorLogger.logError('Error during initialization in HomeController: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<HealthEntity> addWidget(HealthItem item) async {
    final entity = (await initializeWidgets([item], _healthFetcherService)).first;
    await _widgetConfigurationService.addWidget(entity);
    entity.addListener(() {
      _updateDisplayWidgets();
    });
    
    // Update only the new widget instead of all widgets
    entity.updateQuery(_selectedTimeFrame, _offset);
    await entity.updateData();
    
    return entity;
  }

  Future<void> removeWidget(HealthEntity entity) async {
    await _widgetConfigurationService.removeWidget(entity);
    // Clean up properly
    entity.removeListener(() {
      _updateDisplayWidgets();
    });
    entity.dispose();
  }

  Future<List<HealthItem>> getAvailableItems() async {
    return _widgetConfigurationService.getAvailableItems();
  }

  Future<void> updateWidgetOrder(List<HealthEntity> newOrder) async {
    await _widgetConfigurationService.updateWidgetOrder(newOrder);
    // No need to fetch data again as we're just changing the order
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
    fetchHealthData(forceUpdate: true);
  }

  void updateOffset(int newOffset) {
    _offset = newOffset;
    fetchHealthData(forceUpdate: true);
  }

  Future<void> fetchHealthData({bool forceUpdate = false}) async {
    if (_isLoading && !_isFirstTimeLoading && !forceUpdate) return;
    _isFirstTimeLoading = false;

    _isLoading = true;
    notifyListeners();

    try {
      await setDataPerWidgetWithTimeframe(healthItemEntities, _selectedTimeFrame, _offset);
    } catch (e) {
      await ErrorLogger.logError('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(bool hardRefresh) async {
    _selectedTimeFrame = TimeFrame.day;
    _offset = 0;
    if (hardRefresh) {
      await _healthDataCache.clearTodaysCache();
    }
    await fetchHealthData(forceUpdate: true);
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
