import 'package:fitxp/enums/xp_type.enum.dart';

const int levelUpXPAmt = 1000;

final Map<XPType, int> xpMapping = {
  XPType.hitProteinGoal: 200,
  XPType.hundredCalorieDeficit: 50,
  XPType.hundredCalorieSurplus: 50,
  XPType.hitSleepGoal: 200,
  XPType.minuteOfCardio: 5,
  XPType.minuteOfStrengthTraining: 10,
  XPType.thousandSteps: 30,
};
