import 'package:xpfitness/pages/auth/auth_gate.dart';
import 'package:xpfitness/pages/home/home_view.dart';
import 'package:xpfitness/pages/permissions/permissions_view.dart';
import 'package:xpfitness/pages/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'goals/goals_view.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,
          home: const AuthGate(),

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return PageRouteBuilder<void>(
              settings: routeSettings,
              pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case HomeView.routeName:
                    return const HomeView();
                  case GoalsView.routeName:
                    return const GoalsView();
                  case PermissionsView.routeName:
                    return const PermissionsView();
                  default:
                    return const AuthGate();
                }
              },
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            );
          },
        );
      },
    );
  }
}
