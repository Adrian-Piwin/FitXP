import 'package:healthxp/enums/xp_type.enum.dart';

const int levelUpXPAmt = 1000;
const int rankUpXPAmt = 5000;

final Map<XPType, double> xpMapping = {
  XPType.protein: 0.25,
  XPType.exerciseTime: 0.5,
  XPType.steps: 0.03,
};

final Map<XPType, double> xpGoalMapping = {
  XPType.hitProteinGoal: 200,
  XPType.hitNetCaloriesGoal: 200,
  XPType.hitSleepGoal: 200,
  XPType.minuteOfCardio: 5,
  XPType.minuteOfStrengthTraining: 10,
  XPType.steps: 0.03,
};
