import 'package:flutter/material.dart';
import '../pages/home/home_view.dart';
import '../pages/goals/goals_view.dart';
import '../pages/settings/settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    // Determine which page to navigate to
    String route = '/';
    switch (index) {
      case 0:
        route = HomeView.routeName;
      case 1:
        route = GoalsView.routeName;
      case 2:
        route = SettingsView.routeName;
    }

    // Navigate to the selected page
    // Avoid pushing the same route again
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Localizations
    final localizations = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: localizations.navBarHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: localizations.navBarGoals,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: localizations.navBarSettings,
        ),
      ],
    );
  }
}
