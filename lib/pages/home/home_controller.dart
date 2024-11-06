import 'package:fitxp/models/health_data.model.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../../models/goal.model.dart';
import '../../services/health_service.dart';
import '../../services/db_goals_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final HealthService _healthService = HealthService();
  final DBGoalsService _goalsService = DBGoalsService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation

  Goal _goals = Goal(
    caloriesInGoal: 0,
    caloriesOutGoal: 0,
    exerciseMinutesGoal: 0,
    weightGoal: 0.0,
    bodyFatGoal: 0.0,
    proteinGoal: 0,
    stepsGoal: 0,
    sleepGoal: Duration(hours: 0),
  );
  HealthData _healthData = HealthData();
  
  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  Goal get goals => _goals;
  HealthData get healthData => _healthData;
  bool get isLoading => _isLoading;

  HomeController() {
    fetchCalorieData();
    fetchGoalsData();
  }

  // Method to update the selected TimeFrame
  void updateTimeFrame(TimeFrame newTimeFrame) {
    _selectedTimeFrame = newTimeFrame;
    _offset = 0; // Reset offset when TimeFrame changes
    fetchCalorieData();
  }

  // Method to update the offset
  void updateOffset(int newOffset) {
    _offset = newOffset;
    fetchCalorieData();
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
  Future<void> fetchCalorieData() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<HealthDataPoint> data = await _healthService.fetchAll(_selectedTimeFrame, offset: _offset);
      _healthData.averages = _selectedTimeFrame != TimeFrame.day; // Show averages when time frame is not day
      _healthData.clearData();
      _healthData.assignData(data);
    } catch (e) {
      // Handle errors as needed
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
