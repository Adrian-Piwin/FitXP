import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/pages/character/character_view.dart';
import '../pages/home/home_view.dart';
import '../pages/settings/settings_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    String route = '/';
    switch (index) {
      case 0:
        route = HomeView.routeName;
      case 1:
        route = CharacterView.routeName;
      case 2:
        route = SettingsView.routeName;
    }

    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: CoreColors.navBarColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(IconTypes.homeIcon),
          label: localizations.navBarHome,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconTypes.characterIcon),
          label: localizations.navBarCharacter,
        ),
        BottomNavigationBarItem(
          icon: Icon(IconTypes.settingsIcon),
          label: localizations.navBarSettings,
        ),
      ],
    );
  }
}
