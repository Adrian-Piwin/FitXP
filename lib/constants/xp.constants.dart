import 'package:healthcore/enums/health_item_type.enum.dart';

const int rankUpXPAmt = 5000;

final Map<HealthItemType, double> xpMapping = {
  HealthItemType.steps: 0.01,
  HealthItemType.strengthTrainingTime: 30.0,
  HealthItemType.cardioTime: 15.0,
  HealthItemType.proteinIntake: 1.0,
  HealthItemType.sleep: 0.3,
  HealthItemType.netCalories: 0.15,
};

// Average 10k steps = 300,000 * 0.01multi = 3000 xp
// Average 3 hours strength training per week = (3hr * 60min) * 30multi = 5400 xp
// Average 5 hours cardio per week = (5hr * 60min) * 15multi = 4500 xp
// Average 150g protein intake = 150 * 30days = 4500g * 1multi = 4500 xp
// Average 8 hours sleep = (8hr * 60min) = 480 * 30days = 14400 * 0.3multi = 4320 xp
// Average -500 calorie deficit = 500 * 30days = 15000 * 0.15multi = 2250 xp

// Total = 20,470 xp
// 20,470 xp / 4 = 5117.5 xp per rank
