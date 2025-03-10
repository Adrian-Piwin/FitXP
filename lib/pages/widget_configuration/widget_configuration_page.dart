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
  List<HealthEntity> availableWidgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWidgets();
  }

  Future<void> _loadWidgets() async {
    final widgetService = context.read<WidgetConfigurationService>();
    headerWidgets = widgetService.healthEntities.take(4).toList();
    bodyWidgets = widgetService.healthEntities.skip(4).toList();
    availableWidgets = await widgetService.getAvailableWidgets();
    setState(() {
      isLoading = false;
    });
  }

  void _onReorderHeader(int oldIndex, int newIndex) {
    final widgetService = context.read<WidgetConfigurationService>();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = headerWidgets.removeAt(oldIndex);
      headerWidgets.insert(newIndex, item);
    });
    widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
  }

  void _onReorderBody(int oldIndex, int newIndex) {
    final widgetService = context.read<WidgetConfigurationService>();
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = bodyWidgets.removeAt(oldIndex);
      bodyWidgets.insert(newIndex, item);
    });
    widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
  }

  void _saveConfiguration() {
    final widgetService = context.read<WidgetConfigurationService>();
    widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
    Navigator.pop(context);
  }

  Future<void> _removeWidget(HealthEntity entity) async {
    final widgetService = context.read<WidgetConfigurationService>();
    
    if (headerWidgets.contains(entity)) {
      if (availableWidgets.isNotEmpty) {
        final replacement = availableWidgets.removeAt(0);
        setState(() {
          headerWidgets[headerWidgets.indexOf(entity)] = replacement;
          availableWidgets.add(entity);
        });
        await widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
      }
    } else if (bodyWidgets.contains(entity)) {
      setState(() {
        bodyWidgets.remove(entity);
        availableWidgets.add(entity);
      });
      await widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
    }
  }

  Future<void> _addWidget(HealthEntity entity) async {
    final widgetService = context.read<WidgetConfigurationService>();
    setState(() {
      bodyWidgets.add(entity);
      availableWidgets.remove(entity);
    });
    await widgetService.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
  }

  Widget _buildDragTarget({
    required List<HealthEntity> list,
    required String title,
    required bool isHeader,
    required Function(int, int) onReorder,
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
                trailing: !isHeader || (isHeader && availableWidgets.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeWidget(list[index]),
                    )
                  : null,
              ),
          ],
          onReorder: onReorder,
        ),
      ],
    );
  }

  Widget _buildAvailableWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Available Widgets',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableWidgets.length,
          itemBuilder: (context, index) {
            final widget = availableWidgets[index];
            return ListTile(
              leading: Icon(
                widget.healthItem.icon,
                color: widget.healthItem.color,
              ),
              title: Text(widget.healthItem.title),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _addWidget(widget),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              onReorder: _onReorderHeader,
            ),
            const Divider(height: 32),
            _buildDragTarget(
              list: bodyWidgets,
              title: 'Body Widgets',
              isHeader: false,
              onReorder: _onReorderBody,
            ),
            const Divider(height: 32),
            _buildAvailableWidgets(),
          ],
        ),
      ),
    );
  }
} 
