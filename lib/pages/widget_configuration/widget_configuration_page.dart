import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/services/widget_configuration_service.dart';
import 'package:provider/provider.dart';

class WidgetConfigurationPage extends StatefulWidget {
  const WidgetConfigurationPage({super.key});

  @override
  State<WidgetConfigurationPage> createState() => _WidgetConfigurationPageState();
}

class _WidgetConfigurationPageState extends State<WidgetConfigurationPage> {
  late List<HealthEntity> headerWidgets;
  late List<HealthEntity> bodyWidgets;

  @override
  void initState() {
    super.initState();
    final widgetService = context.read<WidgetConfigurationService>();
    headerWidgets = widgetService.healthEntities.take(4).toList();
    bodyWidgets = widgetService.healthEntities.skip(4).toList();
  }

  void _onReorder(int oldIndex, int newIndex, List<HealthEntity> list) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
    });
  }

  void _saveConfiguration() {
    final widgetService = context.read<WidgetConfigurationService>();
    widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
    Navigator.pop(context);
  }

  Widget _buildDragTarget({
    required List<HealthEntity> list,
    required String title,
    required bool isHeader,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int index = 0; index < list.length; index++)
              ListTile(
                key: ValueKey(list[index].hashCode),
                leading: Icon(
                  list[index].healthItem.icon,
                  color: list[index].healthItem.color,
                ),
                title: Text(list[index].healthItem.title),
                subtitle: Text(isHeader && index == 0 
                  ? 'Header Bar Widget'
                  : isHeader 
                    ? 'Header Sub Widget'
                    : 'Body Widget'),
              ),
          ],
          onReorder: (oldIndex, newIndex) {
            _onReorder(oldIndex, newIndex, list);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Widgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveConfiguration,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDragTarget(
              list: headerWidgets,
              title: 'Header Widgets',
              isHeader: true,
            ),
            const Divider(height: 32),
            _buildDragTarget(
              list: bodyWidgets,
              title: 'Body Widgets',
              isHeader: false,
            ),
          ],
        ),
      ),
    );
  }
} 
