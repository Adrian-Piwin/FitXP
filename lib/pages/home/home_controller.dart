import 'package:fitxp/models/health_data.model.dart';
import 'package:fitxp/services/health_widget_builder_service.dart';
import 'package:flutter/material.dart';
import '../../constants/healthdatatypes.constants.dart';
import '../../models/goal.model.dart';
import '../../services/health_fetcher_service.dart';
import '../../services/db_goals_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final DBGoalsService _goalsService = DBGoalsService();
  final HealthWidgetBuilderService _healthWidgetBuilderService = HealthWidgetBuilderService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation

  Goal _goals = Goal();
  HealthData _healthData = HealthData(HealthFetcherService());

  bool _isLoading = true;

  // Getters
  HealthWidgetBuilderService get healthWidgetBuilderService => _healthWidgetBuilderService;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  Goal get goals => _goals;
  HealthData get healthData => _healthData;
  bool get isLoading => _isLoading;

  HomeController(BuildContext context) {
    _healthWidgetBuilderService.context = context;
    fetchHealthData();
    fetchGoalsData();
  }

  // Method to update the selected TimeFrame
  void updateTimeFrame(TimeFrame newTimeFrame) {
    _selectedTimeFrame = newTimeFrame;
    _offset = 0; // Reset offset when TimeFrame changes
    fetchHealthData();
  }

  // Method to update the offset
  void updateOffset(int newOffset) {
    _offset = newOffset;
    fetchHealthData();
  }

  // Fetch data from GoalsService
  Future<void> fetchGoalsData() async {
    // Fetch goals data
    // For now, we'll just hardcode the goal calories
    Goal? goals = await _goalsService.getGoals();
    if (goals != null) {
      _goals = goals;
    }
  }

  // Fetch data from HealthService
  Future<void> fetchHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _healthData.healthService.setTimeFrameAndOffset(_selectedTimeFrame, _offset);
      _healthData.averages = _selectedTimeFrame != TimeFrame.day; // Show averages when time frame is not day
      await healthData.healthService.fetchData(healthDataTypes);
    } catch (e) {
      // Handle errors as needed
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
