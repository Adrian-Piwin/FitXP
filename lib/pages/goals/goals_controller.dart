import 'package:flutter/material.dart';
import 'package:healthxp/services/error_logger.service.dart';
import '../../models/goal.model.dart';
import '../../services/db_goals_service.dart';
class GoalsController extends ChangeNotifier {
  final DBGoalsService _dbGoalsService = DBGoalsService();

  Goal? _goal;
  bool _isLoading = true;

  Goal? get goal => _goal;
  bool get isLoading => _isLoading;

  GoalsController() {
    loadGoals();
  }

  // Load goals from cache or Firebase
  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goal = await _dbGoalsService.getGoals();
      _goal ??= Goal(
          caloriesInGoal: 0,
          caloriesOutGoal: 0,
          exerciseMinutesGoal: 0,
          weightGoal: 0.0,
          bodyFatGoal: 0.0,
          proteinGoal: 0,
          stepsGoal: 0,
          sleepGoal: Duration(hours: 0),
        );
    } catch (e) {
      await ErrorLogger.logError('Error loading goals: $e');
      // Handle error as needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save goals to Firebase and cache
  Future<void> saveGoals() async {
    if (_goal == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _dbGoalsService.saveGoals(_goal!);
    } catch (e) {
      await ErrorLogger.logError('Error saving goals: $e');
      // Handle error as needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update goal field
  void updateGoalField(String fieldName, dynamic value) {
    if (_goal == null) return;

    final updatedGoal = _goal!.copyWith(
      caloriesInGoal: fieldName == 'caloriesInGoal' ? value : null,
      caloriesOutGoal: fieldName == 'caloriesOutGoal' ? value : null,
      exerciseMinutesGoal: fieldName == 'exerciseMinutesGoal' ? value : null,
      weightGoal: fieldName == 'weightGoal' ? value : null,
      bodyFatGoal: fieldName == 'bodyFatGoal' ? value : null,
      proteinGoal: fieldName == 'proteinGoal' ? value : null,
      stepsGoal: fieldName == 'stepsGoal' ? value : null,
      sleepGoal: fieldName == 'sleepGoal' ? value : null,
    );

    _goal = updatedGoal;
  }
}
