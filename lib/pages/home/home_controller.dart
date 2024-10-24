import 'package:flutter/material.dart';
import '../../services/health_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  double _activeCalories = 0.0;
  double _restingCalories = 0.0;
  double _dietaryCalories = 0.0;
  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  double get activeCalories => _activeCalories;
  double get restingCalories => _restingCalories;
  double get dietaryCalories => _dietaryCalories;
  bool get isLoading => _isLoading;

  HomeController() {
    fetchCalorieData();
  }

  // Method to update the selected TimeFrame
  void updateTimeFrame(TimeFrame newTimeFrame) {
    _selectedTimeFrame = newTimeFrame;
    fetchCalorieData();
  }

  // Fetch data from HealthService
  Future<void> fetchCalorieData() async {
    _isLoading = true;
    notifyListeners();

    try {
      double activeCalories =
          await _healthService.getActiveCaloriesBurned(_selectedTimeFrame);
      double restingCalories =
          await _healthService.getRestingCaloriesBurned(_selectedTimeFrame);
      double dietaryCalories =
          await _healthService.getDietaryCaloriesConsumed(_selectedTimeFrame);

      _activeCalories = activeCalories;
      _restingCalories = restingCalories;
      _dietaryCalories = dietaryCalories;
    } catch (e) {
      // Handle errors as needed
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
