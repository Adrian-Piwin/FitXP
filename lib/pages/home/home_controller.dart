import 'package:fitxp/utility/health.utility.dart';
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

  double _activeCalories = 0.0;
  double _restingCalories = 0.0;
  double _dietaryCalories = 0.0;
  double _protein = 0.0;
  double _exerciseMinutes = 0.0;
  double _strengthTrainingMinutes = 0.0;
  double _cardioMinutes = 0.0;
  double _steps = 0.0;
  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;

  Goal get goals => _goals;

  double get activeCalories => _activeCalories;
  double get restingCalories => _restingCalories;
  double get dietaryCalories => _dietaryCalories;
  double get protein => _protein;
  double get exerciseMinutes => _exerciseMinutes;
  double get strengthTrainingMinutes => _strengthTrainingMinutes;
  double get cardioMinutes => _cardioMinutes;
  double get steps => _steps;
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
      List<HealthDataPoint> activeCalories = await _healthService.fetchData(
          HealthDataType.ACTIVE_ENERGY_BURNED, _selectedTimeFrame,
          offset: _offset);
      List<HealthDataPoint> restingCalories = await _healthService.fetchData(
          HealthDataType.BASAL_ENERGY_BURNED, _selectedTimeFrame,
          offset: _offset);
      List<HealthDataPoint> dietaryCalories = await _healthService.fetchData(
          HealthDataType.DIETARY_ENERGY_CONSUMED, _selectedTimeFrame,
          offset: _offset);
      List<HealthDataPoint> protein = await _healthService.fetchData(
          HealthDataType.DIETARY_PROTEIN_CONSUMED, _selectedTimeFrame,
          offset: _offset);
      List<HealthDataPoint> excerciseMinutes = await _healthService.fetchData(
          HealthDataType.EXERCISE_TIME, _selectedTimeFrame,
          offset: _offset);
      List<HealthDataPoint> steps = await _healthService
          .fetchData(HealthDataType.STEPS, _selectedTimeFrame, offset: _offset);
      List<HealthDataPoint> workouts = await _healthService.fetchData(
          HealthDataType.WORKOUT, _selectedTimeFrame,
          offset: _offset);

      if (_selectedTimeFrame == TimeFrame.day) {
        _activeCalories = getHealthTotal(activeCalories);
        _restingCalories = getHealthTotal(restingCalories);
        _dietaryCalories = getHealthTotal(dietaryCalories);
        _protein = getHealthTotal(protein);
        _exerciseMinutes = getHealthTotal(excerciseMinutes);
        _steps = getHealthTotal(steps);
        _strengthTrainingMinutes =
            getWorkoutMinutesTotal(extractStrengthTrainingMinutes(workouts));
        _cardioMinutes =
            getWorkoutMinutesTotal(extractCardioMinutes(workouts));
      } else {
        _activeCalories = getHealthAverage(activeCalories);
        _restingCalories = getHealthAverage(restingCalories);
        _dietaryCalories = getHealthAverage(dietaryCalories);
        _protein = getHealthAverage(protein);
        _exerciseMinutes = getHealthAverage(excerciseMinutes);
        _steps = getHealthAverage(steps);
        _strengthTrainingMinutes =
            getWorkoutMinutesAverage(extractStrengthTrainingMinutes(workouts));
        _cardioMinutes =
            getWorkoutMinutesAverage(extractCardioMinutes(workouts));
      }
    } catch (e) {
      // Handle errors as needed
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
