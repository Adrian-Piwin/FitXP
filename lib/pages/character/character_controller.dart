import 'package:flutter/foundation.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/services/xp_service.dart';
import 'package:healthxp/utility/general.utility.dart';

class CharacterController extends ChangeNotifier {
  final XpService _xpService = XpService();
  
  int _level = 0;
  int _xpLevelProgress = 0;
  int _xpLevelRequired = 0;
  String _rank = '';
  int _xpRankProgress = 0;
  int _xpRankRequired = 0;
  
  // Getters
  String get level => formatNumber(_level);
  String get xpLevelProgress => formatNumber(_xpLevelProgress);
  String get xpLevelRequired => formatNumber(_xpLevelRequired);
  double get xpLevelProgressPercent => (_xpLevelProgress / _xpLevelRequired).clamp(0, 1);

  String get rank => _rank;
  String get xpRankProgress => formatNumber(_xpRankProgress);
  String get xpRankRequired => formatNumber(_xpRankRequired);
  double get xpRankProgressPercent => (_xpRankProgress / _xpRankRequired).clamp(0, 1);
  
  CharacterController() {
    initialize();
  }

  Future<void> initialize() async {
    await _xpService.initialize();
    updateXPData();
  }
  
  Future<void> updateXPData() async {
    _level = _xpService.level;
    _xpLevelProgress = _xpService.xpToNextLevel;
    _xpLevelRequired = levelUpXPAmt;
    
    // Calculate rank based on rankXP
    _xpRankProgress = _xpService.rankXpToNextRank;
    _xpRankRequired = rankUpXPAmt;
    _rank = _xpService.rankName;
    notifyListeners();
  }
  
  Future<void> refreshXP() async {
    await _xpService.reset();
    await updateXPData();
  }
}
