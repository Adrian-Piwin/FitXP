import 'package:healthxp/enums/health_item_type.enum.dart';

const int levelUpXPAmt = 1000;
const int rankUpXPAmt = 50000;


final Map<HealthItemType, double> xpMapping = {
  HealthItemType.steps: 0.01,
  HealthItemType.workoutTime: 1.0,
  HealthItemType.proteinIntake: 1.0,
  HealthItemType.sleep: 1.0,
};
