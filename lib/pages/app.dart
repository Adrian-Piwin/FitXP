import 'package:healthxp/components/bottom_nav_bar.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/pages/auth/auth_gate.dart';
import 'package:healthxp/pages/character/character_view.dart';
import 'package:healthxp/pages/home/home_view.dart';
import 'package:healthxp/pages/insights/insights_view.dart';
import 'package:healthxp/pages/permissions/permissions_view.dart';
import 'package:healthxp/pages/settings/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

      theme: ThemeData(
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter'),
          displayMedium: TextStyle(fontFamily: 'Inter'),
          displaySmall: TextStyle(fontFamily: 'Inter'),
          headlineLarge: TextStyle(fontFamily: 'Inter'),
          headlineMedium: TextStyle(fontFamily: 'Inter'),
          headlineSmall: TextStyle(fontFamily: 'Inter'),
          titleLarge: TextStyle(fontFamily: 'Inter'),
          titleMedium: TextStyle(fontFamily: 'Inter'),
          titleSmall: TextStyle(fontFamily: 'Inter'),
          bodyLarge: TextStyle(fontFamily: 'Inter'),
          bodyMedium: TextStyle(fontFamily: 'Inter'),
          bodySmall: TextStyle(fontFamily: 'Inter'),
          labelLarge: TextStyle(fontFamily: 'Inter'),
          labelMedium: TextStyle(fontFamily: 'Inter'),
          labelSmall: TextStyle(fontFamily: 'Inter'),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        // Main background color
        scaffoldBackgroundColor: CoreColors.backgroundColor,
        
        // Primary color used across components
        primaryColor: Colors.white,
        
        // Color scheme affects many components
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: CoreColors.backgroundColor,
        ),
        
        // Text theme with Inter font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter'),
          displayMedium: TextStyle(fontFamily: 'Inter'),
          displaySmall: TextStyle(fontFamily: 'Inter'),
          headlineLarge: TextStyle(fontFamily: 'Inter'),
          headlineMedium: TextStyle(fontFamily: 'Inter'),
          headlineSmall: TextStyle(fontFamily: 'Inter'),
          titleLarge: TextStyle(fontFamily: 'Inter'),
          titleMedium: TextStyle(fontFamily: 'Inter'),
          titleSmall: TextStyle(fontFamily: 'Inter'),
          bodyLarge: TextStyle(fontFamily: 'Inter', color: CoreColors.textColor),
          bodyMedium: TextStyle(fontFamily: 'Inter', color: CoreColors.textColor),
          bodySmall: TextStyle(fontFamily: 'Inter', color: CoreColors.textColor),
          labelLarge: TextStyle(fontFamily: 'Inter'),
          labelMedium: TextStyle(fontFamily: 'Inter'),
          labelSmall: TextStyle(fontFamily: 'Inter'),
        ).apply(
          fontFamily: 'Inter',
          bodyColor: CoreColors.textColor,
          displayColor: CoreColors.textColor,
        ),
        
        // Dialog theme
        dialogTheme: DialogTheme(
          backgroundColor: CoreColors.backgroundColor,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: const TextStyle(
            fontFamily: 'Inter',
            color: CoreColors.textColor,
          ),
          contentTextStyle: const TextStyle(
            fontFamily: 'Inter',
            color: CoreColors.textColor,
          ),
        ),
        
        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CoreColors.accentAltColor,
            textStyle: const TextStyle(fontFamily: 'Inter'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: CoreColors.accentAltColor,
          ),
        ),
        
        // Add segmented button theme
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return CoreColors.accentAltColor;
                }
                return CoreColors.backgroundColor;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return CoreColors.textColor;
              },
            ),
            side: WidgetStateProperty.all(
              const BorderSide(color: CoreColors.accentAltColor),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthGate(),

      // Only keep routes for non-bottom-nav pages if needed
      onGenerateRoute: (RouteSettings routeSettings) {
        return PageRouteBuilder<void>(
          settings: routeSettings,
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            switch (routeSettings.name) {
              case PermissionsView.routeName:
                return const PermissionsView();
              case MainView.routeName:
                return const MainView();
              default:
                return const AuthGate();
            }
          },
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      },
    );
  }
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  static const routeName = '/main';

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedPageIndex = 0;
  late final PageController _pageController;
  
  final List<Widget> _pages = [
    const HomeView(),
    InsightsView(),
    SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          setState(() {
            _selectedPageIndex = index;
            _pageController.jumpToPage(index);
          });
        },
      ),
    );
  }
}
