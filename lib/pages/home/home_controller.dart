import 'package:flutter/material.dart';
import '../../services/health_service.dart';
import '../../enums/timeframe.enum.dart';

class HomeController extends ChangeNotifier {
  final HealthService _healthService = HealthService();

  // State variables
  TimeFrame _selectedTimeFrame = TimeFrame.day;
  int _offset = 0; // Offset for date navigation
  double _activeCalories = 0.0;
  double _restingCalories = 0.0;
  double _dietaryCalories = 0.0;
  double _protein = 0.0;
  bool _isLoading = true;

  // Getters
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  double get activeCalories => _activeCalories;
  double get restingCalories => _restingCalories;
  double get dietaryCalories => _dietaryCalories;
  double get protein => _protein;
  bool get isLoading => _isLoading;

  HomeController() {
    fetchCalorieData();
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

  // Fetch data from HealthService
  Future<void> fetchCalorieData() async {
    _isLoading = true;
    notifyListeners();

    try {
      double activeCalories = await _healthService.getActiveCaloriesBurned(_selectedTimeFrame, offset: _offset);
      double restingCalories = await _healthService.getRestingCaloriesBurned(_selectedTimeFrame, offset: _offset);
      double dietaryCalories = await _healthService.getDietaryCaloriesConsumed(_selectedTimeFrame, offset: _offset);
      double protein = await _healthService.getProteinIntake(_selectedTimeFrame, offset: _offset);

      _activeCalories = activeCalories;
      _restingCalories = restingCalories;
      _dietaryCalories = dietaryCalories;
      _protein = protein;
    } catch (e) {
      // Handle errors as needed
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
