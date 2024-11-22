import 'package:xpfitness/enums/phase_type.enum.dart';

class Goal {
  PhaseType phaseType; // Using PhaseType enum
  double caloriesInGoal; // e.g., 2000
  double caloriesOutGoal; // e.g., 2000
  double exerciseMinutesGoal; // e.g., 50
  double weightGoal; // e.g., 200.0
  double bodyFatGoal; // e.g., 10.0
  double proteinGoal; // e.g., 150
  double stepsGoal; // e.g., 10000
  Duration sleepGoal; // e.g., Duration(hours: 8, minutes: 30)

  Goal({
    this.caloriesInGoal = 0,
    this.caloriesOutGoal = 0,
    this.exerciseMinutesGoal = 0,
    this.weightGoal = 0.0,
    this.bodyFatGoal = 0.0,
    this.proteinGoal = 0,
    this.stepsGoal = 0,
    this.sleepGoal = const Duration(hours: 0),
  }) : phaseType = _determinePhaseType(caloriesInGoal, caloriesOutGoal);

  Goal copyWith({
    double? caloriesInGoal,
    double? caloriesOutGoal,
    double? exerciseMinutesGoal,
    double? weightGoal,
    double? bodyFatGoal,
    double? proteinGoal,
    double? stepsGoal,
    Duration? sleepGoal,
  }) {
    final newcaloriesInGoal = caloriesInGoal ?? this.caloriesInGoal;
    final newcaloriesOutGoal = caloriesOutGoal ?? this.caloriesOutGoal;
    return Goal(
      caloriesInGoal: newcaloriesInGoal,
      caloriesOutGoal: newcaloriesOutGoal,
      exerciseMinutesGoal: exerciseMinutesGoal ?? this.exerciseMinutesGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      bodyFatGoal: bodyFatGoal ?? this.bodyFatGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sleepGoal: sleepGoal ?? this.sleepGoal,
    );
  }

  static PhaseType _determinePhaseType(double caloriesInGoal, double caloriesOutGoal) {
    if (caloriesInGoal > caloriesOutGoal) {
      return PhaseType.bulking;
    } else if (caloriesInGoal < caloriesOutGoal) {
      return PhaseType.cutting;
    } else {
      return PhaseType.none;
    }
  }

  // Convert Goal to Map for Firestore and local storage
  Map<String, dynamic> toMap() {
    return {
      'phaseType': phaseType.name,
      'caloriesInGoal': caloriesInGoal,
      'caloriesOutGoal': caloriesOutGoal,
      'exerciseMinutesGoal': exerciseMinutesGoal,
      'weightGoal': weightGoal,
      'bodyFatGoal': bodyFatGoal,
      'proteinGoal': proteinGoal,
      'stepsGoal': stepsGoal,
      'sleepGoal': sleepGoal.inMinutes,
    };
  }

  // Create Goal from Map (Firestore data)
  factory Goal.fromMap(Map<String, dynamic> map) {
    final caloriesInGoal = (map['caloriesInGoal'] ?? 0).toDouble();
    final caloriesOutGoal = (map['caloriesOutGoal'] ?? 0).toDouble();
    return Goal(
      caloriesInGoal: caloriesInGoal,
      caloriesOutGoal: caloriesOutGoal,
      exerciseMinutesGoal: (map['exerciseMinutesGoal'] ?? 0).toDouble(),
      weightGoal: (map['weightGoal'] ?? 0).toDouble(),
      bodyFatGoal: (map['bodyFatGoal'] ?? 0).toDouble(),
      proteinGoal: (map['proteinGoal'] ?? 0).toDouble(),
      stepsGoal: (map['stepsGoal'] ?? 0).toDouble(),
      sleepGoal: Duration(minutes: (map['sleepGoal'] ?? 0).toDouble().toInt()),
    );
  }
}
