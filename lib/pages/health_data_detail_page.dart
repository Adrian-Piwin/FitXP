import 'package:flutter/material.dart';
import 'package:xpfitness/models/health_widget_config.model.dart';

class HealthDataDetailPage extends StatelessWidget {
  final HealthWidgetConfig config;

  const HealthDataDetailPage({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(config.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: config.data.length,
        itemBuilder: (context, index) {
          final item = config.data[index];
          return Card(
            child: ListTile(
              title: Text(item.value.toString()),
              subtitle: Text('${item.dateFrom} - ${item.dateTo}\n${item.activityType}'),
            ),
          );
        },
      ),
    );
  }
} 
