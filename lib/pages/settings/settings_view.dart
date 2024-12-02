import 'package:healthxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import '../../components/bottom_nav_bar.dart';
import 'settings_controller.dart';
import '../../services/error_logger.service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(PaddingSizes.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<ThemeMode>(
                // Read the selected themeMode from the controller
                value: controller.themeMode,
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: controller.updateThemeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Theme'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Theme'),
                  )
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: controller.clearPreferences,
                child: const Text('Clear Preferences'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: controller.isFitbitConnected 
                  ? controller.disconnectFitbit 
                  : controller.connectFitbit,
                child: Text(
                  controller.isFitbitConnected 
                    ? 'Disconnect Fitbit' 
                    : 'Connect to Fitbit'
                ),
              ),
              const SizedBox(height: 16.0),
              if (controller.isFitbitConnected) ...[
                const Text('Choose what to sync from fitbit'),
                SwitchListTile(
                  title: const Text('Food Intake'),
                  value: controller.syncFoodIntake,
                  onChanged: (bool value) {
                    controller.setSyncFoodIntake(value);
                  },
                ),
              ],
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
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2)
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
