class DailyGoalStatus {
  final String dayLetter;
  final double value;
  final double goalValue;
  final bool isCompleted;
  final DateTime date;

  DailyGoalStatus({
    required this.dayLetter,
    required this.value,
    required this.goalValue,
    required this.date,
  }) : isCompleted = value >= goalValue;

  double get percentageTowardsGoal => 
    goalValue > 0 ? (value / goalValue).clamp(0.0, 1.0) : 0.0;
} 
