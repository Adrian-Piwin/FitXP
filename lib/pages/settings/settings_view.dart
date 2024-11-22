import 'package:xpfitness/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import '../../components/bottom_nav_bar.dart';
import 'settings_controller.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: Column(
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
              onPressed: controller.connectFitbit,
              child: const Text('Connect to fitbit'),
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
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2)
    );
  }
}
