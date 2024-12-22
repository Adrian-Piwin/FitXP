import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/services/db_goals_service.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/utility/health.utility.dart';

import '../models/goal.model.dart';

class XpService {
  final HealthFetcherService _healthFetcherService = HealthFetcherService();
  final DBGoalsService _goalsService = DBGoalsService();

  Goal _goals = Goal();
  int _xp = 0;
  int _level = 0;

  XpService._();

  static Future<XpService> create() async {
    XpService instance = XpService._();
    Goal? goals = await instance._goalsService.getGoals();
    instance._goals = goals ?? Goal(); 
    return instance;
  }

  Future<Map<HealthEntity, double>> _getXPForReachedGoal(List<HealthItem> healthItems, TimeFrame timeframe) async {
    List<HealthEntity> entities = await initializeWidgets(_goalsService, healthItems);
    await setDataPerWidget(_healthFetcherService, entities, timeframe, 0);

    Map<HealthEntity, double> xpPerEntity = {};
    for (var entity in entities) {
      Map<DateTime, double> dailyData = getDailyData(entity.getCombinedData);
      for (MapEntry<DateTime, double> data in dailyData.entries) {
        if (data.value >= entity.goal) {
          xpPerEntity[entity] = xpMapping[entity.healthItem.xpType]!;
        }
      }
    }
    
    return xpPerEntity;
  }
}
