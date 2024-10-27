import 'package:fitxp/enums/phasetype.enum.dart';

class Goal {
  PhaseType phaseType; // Using PhaseType enum
  int calorieGoal; // e.g., 2000
  int exerciseMinutesGoal; // e.g., 50
  double weightGoal; // e.g., 200.0
  double bodyFatGoal; // e.g., 10.0
  int proteinGoal; // e.g., 150
  int stepsGoal; // e.g., 10000
  Duration sleepGoal; // e.g., Duration(hours: 8, minutes: 30)

  Goal({
    required this.phaseType,
    required this.calorieGoal,
    required this.exerciseMinutesGoal,
    required this.weightGoal,
    required this.bodyFatGoal,
    required this.proteinGoal,
    required this.stepsGoal,
    required this.sleepGoal,
  });

  Goal copyWith({
    PhaseType? phaseType,
    int? calorieGoal,
    int? exerciseMinutesGoal,
    double? weightGoal,
    double? bodyFatGoal,
    int? proteinGoal,
    int? stepsGoal,
    Duration? sleepGoal,
  }) {
    return Goal(
      phaseType: phaseType ?? this.phaseType,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      exerciseMinutesGoal: exerciseMinutesGoal ?? this.exerciseMinutesGoal,
      weightGoal: weightGoal ?? this.weightGoal,
      bodyFatGoal: bodyFatGoal ?? this.bodyFatGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      sleepGoal: sleepGoal ?? this.sleepGoal,
    );
  }

  // Convert Goal to Map for Firestore and local storage
  Map<String, dynamic> toMap() {
    return {
      'phaseType': phaseType.name,
      'calorieGoal': calorieGoal,
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
    return Goal(
      phaseType: phaseTypeFromString(map['phaseType'] ?? 'none'),
      calorieGoal: map['calorieGoal'] ?? 0,
      exerciseMinutesGoal: map['exerciseMinutesGoal'] ?? 0,
      weightGoal: (map['weightGoal'] ?? 0).toDouble(),
      bodyFatGoal: (map['bodyFatGoal'] ?? 0).toDouble(),
      proteinGoal: map['proteinGoal'] ?? 0,
      stepsGoal: map['stepsGoal'] ?? 0,
      sleepGoal: Duration(minutes: map['sleepGoal'] ?? 0),
    );
  }
}
