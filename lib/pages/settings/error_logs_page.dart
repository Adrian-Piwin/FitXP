import 'package:flutter/material.dart';
import 'package:healthcore/services/error_logger.service.dart';

class ErrorLogsPage extends StatefulWidget {
  static const routeName = '/error-logs';
  
  const ErrorLogsPage({super.key});

  @override
  State<ErrorLogsPage> createState() => _ErrorLogsPageState();
}

class _ErrorLogsPageState extends State<ErrorLogsPage> {
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final newLogs = await ErrorLogger.getLogs();
    setState(() {
      logs = newLogs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ErrorLogger.clearLogs();
              _loadLogs();
            },
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text('No errors logged'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateTime.parse(log['timestamp']).toLocal().toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          log['error'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (log['stackTrace'] != null) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            log['stackTrace'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 
