import 'package:health/health.dart';
import 'package:fitxp/utility/health.utility.dart';

class HealthData{
  List<HealthDataPoint> _activeCalories = [];
  List<HealthDataPoint> _restingCalories = [];
  List<HealthDataPoint> _dietaryCalories = [];
  List<HealthDataPoint> _protein = [];
  List<HealthDataPoint> _exerciseMinutes = [];
  List<HealthDataPoint> _strengthTrainingMinutes = [];
  List<HealthDataPoint> _cardioMinutes = [];
  List<HealthDataPoint> _steps = [];

  // decide if we should return the average or the total
  bool averages = true;

  double get getActiveCalories => averages ? getHealthAverage(_activeCalories) : getHealthTotal(_activeCalories);
  double get getRestingCalories => averages ? getHealthAverage(_restingCalories) : getHealthTotal(_restingCalories);
  double get getDietaryCalories => averages ? getHealthAverage(_dietaryCalories) : getHealthTotal(_dietaryCalories);
  double get getProtein => averages ? getHealthAverage(_protein) : getHealthTotal(_protein);
  double get getExerciseMinutes => averages ? getHealthAverage(_exerciseMinutes) : getHealthTotal(_exerciseMinutes);
  double get getStrengthTrainingMinutes => averages ? getWorkoutMinutesAverage(extractStrengthTrainingMinutes(_strengthTrainingMinutes)) : getWorkoutMinutesTotal(extractStrengthTrainingMinutes(_strengthTrainingMinutes));
  double get getCardioMinutes => averages ? getWorkoutMinutesAverage(extractCardioMinutes(_cardioMinutes)) : getWorkoutMinutesTotal(extractCardioMinutes(_cardioMinutes));
  double get getSteps => averages ? getHealthAverage(_steps) : getHealthTotal(_steps);

  void clearData(){
    _activeCalories.clear();
    _restingCalories.clear();
    _dietaryCalories.clear();
    _protein.clear();
    _exerciseMinutes.clear();
    _strengthTrainingMinutes.clear();
    _cardioMinutes.clear();
    _steps.clear();
  }  

  void assignData(List<HealthDataPoint> data) {
    for (var point in data) {
      switch (point.type) {
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          _activeCalories.add(point);
        case HealthDataType.BASAL_ENERGY_BURNED:
          _restingCalories.add(point);
        case HealthDataType.DIETARY_ENERGY_CONSUMED:
          _dietaryCalories.add(point);
        case HealthDataType.STEPS:
          _steps.add(point);
        case HealthDataType.EXERCISE_TIME:
          _exerciseMinutes.add(point);
        case HealthDataType.DIETARY_PROTEIN_CONSUMED:
          _protein.add(point);
        case HealthDataType.WORKOUT:
            _strengthTrainingMinutes.add(point);
            _cardioMinutes.add(point);
        default:
          break;
      }
    }
  }
}
