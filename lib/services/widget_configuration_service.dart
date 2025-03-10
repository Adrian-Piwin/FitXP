import 'package:flutter/material.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/pages/home/components/basic_health_widget.dart';
import 'package:healthxp/pages/home/components/circular_health_widget.dart';
import 'package:healthxp/pages/home/components/header_widget_item.dart';
import 'package:healthxp/pages/insights/components/basic_weekly_health_widget.dart';
import 'package:healthxp/pages/insights/components/rank_widget.dart';
import 'package:healthxp/services/db_service.dart';
import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/utility/health.utility.dart';

class WidgetConfigurationService extends ChangeNotifier {
  List<HealthEntity> healthEntities = [];
  final DBService _dbService = DBService();
  static const String _configCollectionName = 'widget_configuration';
  static const String _configDocumentId = 'default_config';
  bool _isInitialized = false;

  WidgetConfigurationService(this.healthEntities);

  Future<void> initializeWithEntities(List<HealthEntity> entities) async {
    if (_isInitialized) return;
    healthEntities = entities;
    await _loadConfiguration();
    _isInitialized = true;
  }

  Future<List<HealthItem>> getAvailableItems() async {
    return HealthItemDefinitions.allHealthItems.where((item) => 
      !healthEntities.any((e) => e.healthItem.itemType == item.itemType)
    ).toList();
  }

  bool canRemoveWidget(HealthEntity entity) {
    // Check if the widget is a header widget
    bool isHeaderWidget = HealthItemDefinitions.defaultHeaderItems
        .any((item) => item.itemType == entity.healthItem.itemType);
    
    // Cannot remove header widgets
    if (isHeaderWidget) return false;
    
    // Must have at least one body widget
    return healthEntities.length > HealthItemDefinitions.defaultHeaderItems.length + 1;
  }

  Future<void> addWidget(HealthEntity entity) async {
    if (!healthEntities.any((e) => e.healthItem.itemType == entity.healthItem.itemType)) {
      // Add new widgets after header widgets
      final headerWidgets = healthEntities.take(HealthItemDefinitions.defaultHeaderItems.length).toList();
      final bodyWidgets = healthEntities.skip(HealthItemDefinitions.defaultHeaderItems.length).toList();
      
      healthEntities = [...headerWidgets, ...bodyWidgets, entity];
      await saveConfiguration();
      notifyListeners();
    }
  }

  Future<void> removeWidget(HealthEntity entity) async {
    // Check if widget can be removed
    if (!canRemoveWidget(entity)) return;
    
    if (healthEntities.contains(entity)) {
      healthEntities.remove(entity);
      await saveConfiguration();
      notifyListeners();
    }
  }

  Future<void> _loadConfiguration() async {
    try {
      final config = await _dbService.getDocument(_configCollectionName, _configDocumentId);
      
      // Create a map of all current entities by type
      final Map<String, HealthEntity> entityMap = {
        for (var e in healthEntities)
          e.healthItem.itemType.toString().split('.').last: e
      };
      
      // Always start with default header widgets in the correct order
      List<HealthEntity> orderedEntities = [];
      for (var headerItem in HealthItemDefinitions.defaultHeaderItems) {
        String itemType = headerItem.itemType.toString().split('.').last;
        if (entityMap.containsKey(itemType)) {
          orderedEntities.add(entityMap[itemType]!);
          entityMap.remove(itemType);
        }
      }
      
      if (config != null) {
        final List<dynamic> order = config['order'] ?? [];
        
        // Add body widgets in saved order
        for (String itemType in order) {
          if (entityMap.containsKey(itemType)) {
            orderedEntities.add(entityMap[itemType]!);
            entityMap.remove(itemType);
          }
        }
      }
      
      // Add any remaining entities from the map
      orderedEntities.addAll(entityMap.values);
      
      // Only update if we have all header widgets
      if (orderedEntities.length >= HealthItemDefinitions.defaultHeaderItems.length) {
        healthEntities = orderedEntities;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading widget configuration: $e');
    }
  }

  Future<void> saveConfiguration() async {
    try {
      if (healthEntities.length < HealthItemDefinitions.defaultHeaderItems.length) {
        print('Cannot save configuration without all header widgets');
        return;
      }

      // Only save the order of body widgets
      final bodyEntities = healthEntities.skip(HealthItemDefinitions.defaultHeaderItems.length).toList();

      await _dbService.setDocument(
        _configCollectionName,
        _configDocumentId,
        {
          'order': bodyEntities.map((e) => e.healthItem.itemType.toString().split('.').last).toList(),
        },
      );
      notifyListeners();
    } catch (e) {
      print('Error saving widget configuration: $e');
    }
  }

  Future<void> updateWidgetOrder(List<HealthEntity> newOrder) async {
    // Ensure header widgets remain in their fixed positions
    final headerWidgets = healthEntities.take(HealthItemDefinitions.defaultHeaderItems.length).toList();
    final newBodyWidgets = newOrder.where((entity) => 
      !HealthItemDefinitions.defaultHeaderItems.any((item) => item.itemType == entity.healthItem.itemType)
    ).toList();
    
    healthEntities = [...headerWidgets, ...newBodyWidgets];
    await saveConfiguration();
    notifyListeners();
  }

  List<Widget> getWidgets() {
    if (healthEntities.length < HealthItemDefinitions.defaultHeaderItems.length) return [];
    
    final headerWidgets = healthEntities.take(HealthItemDefinitions.defaultHeaderItems.length).toList();
    final bodyWidgets = healthEntities.skip(HealthItemDefinitions.defaultHeaderItems.length)
        .map((entity) => getWidget(entity)).toList();
    
    return [
      HeaderWidgetItem(
        barWidget: headerWidgets[0],
        subWidgetFirst: headerWidgets[1],
        subWidgetSecond: headerWidgets[2],
        subWidgetThird: headerWidgets[3]
      ),
      ...bodyWidgets
    ];
  }

  Widget getWidget(HealthEntity healthEntity) {
    switch (healthEntity.healthItem.itemType) {
      case HealthItemType.dietaryCalories || HealthItemType.netCalories || HealthItemType.activeCalories:
        return CircularHealthWidget(widget: healthEntity);
      default:
        return BasicHealthWidget(widget: healthEntity);
    }
  }

  List<Widget> getWeeklyInsightWidgets() {
    return [RankWidget(), ...healthEntities.map((entity) => BasicWeeklyHealthWidget(widget: entity))];
  }
}
