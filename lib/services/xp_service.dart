import 'package:fitxp/services/db_goals_service.dart';
import 'package:fitxp/services/health_fetcher_service.dart';

import '../models/goal.model.dart';

class XpService {
  final HealthFetcherService _healthService = HealthFetcherService();
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

  //Function _getXPFromHealthItem = (List<Heal) {};
}
