import 'package:healthxp/enums/xp_type.enum.dart';

const int levelUpXPAmt = 1000;

final Map<XPType, double> xpMapping = {
  XPType.hitProteinGoal: 200,
  XPType.hitNetCaloriesGoal: 200,
  XPType.hitSleepGoal: 200,
  XPType.minuteOfCardio: 5,
  XPType.minuteOfStrengthTraining: 10,
  XPType.steps: 0.03,
};
