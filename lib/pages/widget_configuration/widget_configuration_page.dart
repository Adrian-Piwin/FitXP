import 'package:flutter/material.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/models/health_item.model.dart';
import 'package:healthcore/pages/home/home_controller.dart';
import 'package:healthcore/services/widget_configuration_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcore/constants/health_item_definitions.constants.dart';

class WidgetConfigurationPage extends StatefulWidget {
  final HomeController homeController;
  
  const WidgetConfigurationPage({
    super.key,
    required this.homeController,
  });

  @override
  State<WidgetConfigurationPage> createState() => _WidgetConfigurationPageState();
}

class _WidgetConfigurationPageState extends State<WidgetConfigurationPage> {
  late List<HealthEntity> headerWidgets;
  late List<HealthEntity> bodyWidgets;
  List<HealthItem> availableItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWidgets();
  }

  Future<void> _loadWidgets() async {
    final widgetService = context.read<WidgetConfigurationService>();
    
    // Get header widgets based on the static list order
    headerWidgets = HealthItemDefinitions.defaultHeaderItems.map((item) {
      return widgetService.healthEntities.firstWhere(
        (entity) => entity.healthItem.itemType == item.itemType
      );
    }).toList();
    
    // Get body widgets (everything that's not a header widget)
    bodyWidgets = widgetService.healthEntities.where((entity) => 
      !HealthItemDefinitions.defaultHeaderItems.any(
        (item) => item.itemType == entity.healthItem.itemType
      )
    ).toList();
    
    // Get available items and sort them to match original order
    availableItems = await widget.homeController.getAvailableItems();
    availableItems.sort((a, b) {
      int indexA = HealthItemDefinitions.allHealthItems.indexWhere((item) => item.itemType == a.itemType);
      int indexB = HealthItemDefinitions.allHealthItems.indexWhere((item) => item.itemType == b.itemType);
      return indexA.compareTo(indexB);
    });
    
    setState(() {
      isLoading = false;
    });
  }

  void _onReorderBody(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = bodyWidgets.removeAt(oldIndex);
      bodyWidgets.insert(newIndex, item);
    });
    widget.homeController.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
  }

  void _saveConfiguration() {
    widget.homeController.updateWidgetOrder([...headerWidgets, ...bodyWidgets]);
    Navigator.pop(context);
  }

  Future<void> _removeWidget(HealthEntity entity) async {
    if (bodyWidgets.contains(entity)) {
      setState(() {
        bodyWidgets.remove(entity);
        availableItems.add(entity.healthItem);
        
        // Sort the available items to match the original order in allHealthItems
        availableItems.sort((a, b) {
          int indexA = HealthItemDefinitions.allHealthItems.indexWhere((item) => item.itemType == a.itemType);
          int indexB = HealthItemDefinitions.allHealthItems.indexWhere((item) => item.itemType == b.itemType);
          return indexA.compareTo(indexB);
        });
      });
      await widget.homeController.removeWidget(entity);
    }
  }

  Future<void> _addWidget(HealthItem item) async {
    final entity = await widget.homeController.addWidget(item);
    setState(() {
      bodyWidgets.add(entity);
      availableItems.remove(item);
      
      // No need to sort here as we're just removing an item from availableItems
      // The order of remaining items is preserved
    });
  }

  Widget _buildDragTarget({
    required List<HealthEntity> list,
    required String title,
    required bool isHeader,
    required Function(int, int)? onReorder,
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
        if (isHeader)
          ListView(
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
                  subtitle: Text(list[index].healthItem.shortDescription),
                ),
            ],
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: onReorder!,
            children: [
              for (int index = 0; index < list.length; index++)
                ListTile(
                  key: ValueKey(list[index].hashCode),
                  leading: Icon(
                    list[index].healthItem.icon,
                    color: list[index].healthItem.color,
                  ),
                  title: Text(list[index].healthItem.title),
                  subtitle: Text(list[index].healthItem.shortDescription),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeWidget(list[index]),
                  ),
                ),
            ],
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
          itemCount: availableItems.length,
          itemBuilder: (context, index) {
            final item = availableItems[index];
            return ListTile(
              leading: Icon(
                item.icon,
                color: item.color,
              ),
              title: Text(item.title),
              subtitle: Text(item.shortDescription),
              trailing: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _addWidget(item),
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
              onReorder: null,
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
