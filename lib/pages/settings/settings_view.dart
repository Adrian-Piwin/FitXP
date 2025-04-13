import 'package:healthcore/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/enums/unit_system.enum.dart';
import 'package:healthcore/pages/settings/about_page.dart';
import 'package:healthcore/pages/settings/contact_us_page.dart';
import 'settings_controller.dart';

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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                    child: const Text('About'),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ContactUsPage(),
                        ),
                      );
                    },
                    child: const Text('Contact Us'),
                  ),
                  const SizedBox(height: 24.0),
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
