import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key, 
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: CoreColors.navBarColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: false,
        selectedItemColor: CoreColors.textColor,
        unselectedItemColor: CoreColors.textColor.withOpacity(0.5),
        items: [
          BottomNavigationBarItem(
            icon: Material(
              type: MaterialType.transparency,
              child: Icon(IconTypes.homeIcon),
            ),
            label: localizations.navBarHome,
          ),
          BottomNavigationBarItem(
            icon: Material(
              type: MaterialType.transparency,
              child: Icon(IconTypes.workoutIcon),
            ),
            label: "Workouts",
          ),
          BottomNavigationBarItem(
            icon: Material(
              type: MaterialType.transparency,
              child: Icon(IconTypes.medalIcon),
            ),
            label: "Insights",
          ),
          BottomNavigationBarItem(
            icon: Material(
              type: MaterialType.transparency,
              child: Icon(IconTypes.settingsIcon),
            ),
            label: localizations.navBarSettings,
          ),
        ],
      ),
    );
  }
}
