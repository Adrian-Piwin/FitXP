import 'package:healthcore/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/enums/unit_system.enum.dart';
import 'settings_controller.dart';
import '../../services/error_logger.service.dart';

class SettingsView extends StatefulWidget {
  static const routeName = '/settings';
  
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final SettingsController controller = SettingsController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await controller.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(PaddingSizes.xlarge),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: controller.clearPreferences,
                    child: const Text('Clear Preferences'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: controller.clearCache,
                    child: const Text('Clear Cache'),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Unit System',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  SegmentedButton<UnitSystem>(
                    segments: const [
                      ButtonSegment(
                        value: UnitSystem.metric,
                        label: Text('Metric'),
                      ),
                      ButtonSegment(
                        value: UnitSystem.imperial,
                        label: Text('Imperial'),
                      ),
                    ],
                    selected: {controller.unitSystem},
                    onSelectionChanged: (Set<UnitSystem> selected) {
                      controller.updateUnitSystem(selected.first);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      await controller.logout(context);
                    },
                    child: const Text('Sign Out'),  
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'Error Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _ErrorLogsWidget(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorLogsWidget extends StatefulWidget {
  @override
  State<_ErrorLogsWidget> createState() => _ErrorLogsWidgetState();
}

class _ErrorLogsWidgetState extends State<_ErrorLogsWidget> {
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
    if (logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No errors logged'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () async {
            await ErrorLogger.clearLogs();
            _loadLogs();
          },
          child: const Text('Clear Logs'),
        ),
        const SizedBox(height: 8.0),
        ...logs.map((log) => Card(
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
        )),
      ],
    );
  }
}
