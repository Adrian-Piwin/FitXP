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
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/utility/health.utility.dart';

class WidgetConfigurationService extends ChangeNotifier {
  List<HealthEntity> healthEntities = [];
  final DBService _dbService = DBService();
  final HealthFetcherService _healthFetcherService = HealthFetcherService();
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

  Future<List<HealthEntity>> getAvailableWidgets() async {
    final allHealthItems = [
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

    final List<HealthEntity> allEntities = [];
    for (var item in allHealthItems) {
      if (!healthEntities.any((e) => e.healthItem.itemType == item.itemType)) {
        final entity = await initializeWidgets([item], _healthFetcherService);
        allEntities.addAll(entity);
      }
    }
    return allEntities;
  }

  bool canRemoveWidget(HealthEntity entity) {
    return healthEntities.length > 4;
  }

  Future<void> addWidget(HealthEntity entity) async {
    if (!healthEntities.any((e) => e.healthItem.itemType == entity.healthItem.itemType)) {
      healthEntities.add(entity);
      await saveConfiguration();
      notifyListeners();
    }
  }

  Future<void> removeWidget(HealthEntity entity) async {
    if (healthEntities.length <= 4) return; // Prevent removing if we only have header widgets
    
    if (healthEntities.contains(entity)) {
      healthEntities.remove(entity);
      await saveConfiguration();
      notifyListeners();
    }
  }

  Future<void> _loadConfiguration() async {
    try {
      final config = await _dbService.getDocument(_configCollectionName, _configDocumentId);
      if (config != null) {
        final List<dynamic> order = config['order'] ?? [];
        final List<dynamic> headerOrder = config['headerOrder'] ?? [];
        final List<String> enabledTypes = [...headerOrder, ...order];
        
        // If we have a saved configuration
        if (enabledTypes.isNotEmpty) {
          // Create a map of all current entities by type
          final Map<String, HealthEntity> entityMap = {
            for (var e in healthEntities)
              e.healthItem.itemType.toString().split('.').last: e
          };
          
          // Reorder entities based on saved configuration
          List<HealthEntity> reorderedEntities = [];
          
          // First add header widgets in order
          for (String itemType in headerOrder) {
            if (entityMap.containsKey(itemType)) {
              reorderedEntities.add(entityMap[itemType]!);
            }
          }
          
          // Then add body widgets in order
          for (String itemType in order) {
            if (entityMap.containsKey(itemType)) {
              reorderedEntities.add(entityMap[itemType]!);
            }
          }
          
          // If we don't have enough header widgets, add from remaining entities
          while (reorderedEntities.length < 4 && entityMap.isNotEmpty) {
            for (var entity in entityMap.values) {
              if (!reorderedEntities.contains(entity)) {
                reorderedEntities.add(entity);
                break;
              }
            }
          }
          
          if (reorderedEntities.length >= 4) {
            healthEntities = reorderedEntities;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error loading widget configuration: $e');
    }
  }

  Future<void> saveConfiguration() async {
    try {
      if (healthEntities.length < 4) {
        print('Cannot save configuration with less than 4 widgets');
        return;
      }

      final headerEntities = healthEntities.take(4).toList();
      final bodyEntities = healthEntities.skip(4).toList();

      await _dbService.setDocument(
        _configCollectionName,
        _configDocumentId,
        {
          'headerOrder': headerEntities.map((e) => e.healthItem.itemType.toString().split('.').last).toList(),
          'order': bodyEntities.map((e) => e.healthItem.itemType.toString().split('.').last).toList(),
        },
      );
      notifyListeners();
    } catch (e) {
      print('Error saving widget configuration: $e');
    }
  }

  Future<void> updateWidgetOrder(List<HealthEntity> newOrder) async {
    if (newOrder.length < 4) {
      print('Cannot update widget order with less than 4 widgets');
      return;
    }
    healthEntities = newOrder;
    await saveConfiguration();
    notifyListeners();
  }

  List<Widget> getWidgets() {
    if (healthEntities.length < 4) return [];
    
    var bodyWidgets = healthEntities.sublist(4).map((entity) => getWidget(entity)).toList();
    var headerWidgets = healthEntities.sublist(0, 4);
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
