import 'package:flutter/material.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/pages/home/components/basic_health_widget.dart';
import 'package:healthxp/pages/home/components/circular_health_widget.dart';
import 'package:healthxp/pages/home/components/header_widget_item.dart';
import 'package:healthxp/pages/insights/components/basic_weekly_health_widget.dart';
import 'package:healthxp/pages/insights/components/rank_widget.dart';
import 'package:healthxp/services/db_service.dart';

class WidgetConfigurationService extends ChangeNotifier {
  List<HealthEntity> healthEntities = [];
  final DBService _dbService = DBService();
  static const String _configCollectionName = 'widget_configuration';
  static const String _configDocumentId = 'default_config';

  WidgetConfigurationService(this.healthEntities) {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final config = await _dbService.getDocument(_configCollectionName, _configDocumentId);
      if (config != null) {
        final List<dynamic> order = config['order'] ?? [];
        final List<dynamic> headerOrder = config['headerOrder'] ?? [];
        
        // Reorder entities based on saved configuration
        List<HealthEntity> reorderedEntities = [];
        
        // First add header widgets in order
        for (String itemType in headerOrder) {
          final entity = healthEntities.firstWhere(
            (e) => e.healthItem.itemType.toString() == itemType,
            orElse: () => healthEntities[0],
          );
          reorderedEntities.add(entity);
        }
        
        // Then add body widgets in order
        for (String itemType in order) {
          final entity = healthEntities.firstWhere(
            (e) => e.healthItem.itemType.toString() == itemType,
            orElse: () => healthEntities[0],
          );
          if (!reorderedEntities.contains(entity)) {
            reorderedEntities.add(entity);
          }
        }
        
        // Add any remaining entities that weren't in the saved order
        for (var entity in healthEntities) {
          if (!reorderedEntities.contains(entity)) {
            reorderedEntities.add(entity);
          }
        }
        
        healthEntities = reorderedEntities;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading widget configuration: $e');
    }
  }

  Future<void> saveConfiguration() async {
    try {
      final headerEntities = healthEntities.take(4).toList();
      final bodyEntities = healthEntities.skip(4).toList();

      await _dbService.setDocument(
        _configCollectionName,
        _configDocumentId,
        {
          'headerOrder': headerEntities.map((e) => e.healthItem.itemType.toString()).toList(),
          'order': bodyEntities.map((e) => e.healthItem.itemType.toString()).toList(),
        },
      );
    } catch (e) {
      print('Error saving widget configuration: $e');
    }
  }

  Future<void> updateWidgetOrder(List<HealthEntity> newOrder) async {
    healthEntities = newOrder;
    await saveConfiguration();
    notifyListeners();
  }

  List<Widget> getWidgets() {
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
