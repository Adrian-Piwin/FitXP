import 'package:flutter/material.dart';
import '../../constants/health_item_definitions.constants.dart';
import '../../models/goal.model.dart';
import '../../models/health_widget.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../services/db_goals_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final DBGoalsService _goalsService = DBGoalsService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation

  Goal? _goals;
  HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  Goal? get goals => _goals;
  bool get isLoading => _isLoading;

  // Widgets
  List<HealthItem> get headerHealthItems => [
        HealthItemDefinitions.expendedEnergy,
        HealthItemDefinitions.dietaryCalories,
        HealthItemDefinitions.netCalories,
        HealthItemDefinitions.steps,
      ];

  List<HealthItem> get healthItems => [
        HealthItemDefinitions.proteinIntake,
        HealthItemDefinitions.exerciseTime,
        HealthItemDefinitions.sleepDuration,
        HealthItemDefinitions.steps,
      ];

  List<HealthWidget> headerWidgets = [];
  List<HealthWidget> displayWidgets = [];

  HomeController(BuildContext context) {
    _initialize();
  }

  void updateTimeFrame(TimeFrame newTimeFrame) {
    _selectedTimeFrame = newTimeFrame;
    _offset = 0;
    fetchHealthData();
  }

  void updateOffset(int newOffset) {
    _offset = newOffset;
    fetchHealthData();
  }

  Future<void> _initialize() async {
    try {
      await fetchGoalsData();
    } catch (e) {
      print('Error fetching goals: $e');
    }

    for (var healthItem in headerHealthItems) {
      var widgetFactory = healthItem.widgetFactory;
      HealthWidget widget = widgetFactory(
        _healthFetcherService,
        healthItem,
        _goals!,
        2,
      );
      headerWidgets.add(widget);
    }

    for (var healthItem in healthItems) {
      var widgetFactory = healthItem.widgetFactory;
      HealthWidget widget = widgetFactory(
        _healthFetcherService,
        healthItem,
        _goals!,
        2,
      );
      displayWidgets.add(widget);
    }

    await fetchHealthData();
  }

  Future<void> fetchGoalsData() async {
    if (_goals != null) return;

    Goal? goals = await _goalsService.getGoals();
    if (goals != null) {
      _goals = goals;
    }
  }

  Future<void> fetchHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      for (var widget in headerWidgets) {
        widget.update(_selectedTimeFrame, _offset);
        await widget.fetchData();
      }

      for (var widget in displayWidgets) {
        widget.update(_selectedTimeFrame, _offset);
        await widget.fetchData();
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _healthFetcherService.clearCache();
    await fetchHealthData();
  }
}
