import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/models/monthly_medal.model.dart';
import 'package:healthxp/services/xp_service.dart';

class RankWidgetController extends ChangeNotifier {
  late final XpService _xpService;
  List<Medal> _earnedMedals = [];
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String get rankName => _xpService.rankName;
  int get currentXP => _xpService.rankXpToNextRank;
  int get requiredXP => rankUpXPAmt;
  double get rankProgress => currentXP / requiredXP;

  List<Medal> get topFiveMedals => _earnedMedals
    .where((medal) => medal.isEarned)
    .take(5)
    .toList();
    
  List<Medal> get allMedals => _earnedMedals
    .where((medal) => medal.isEarned)
    .toList();

  RankWidgetController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _xpService = await XpService.getInstance();
    await _xpService.initialize();

    // Get all medals and filter earned ones
    _earnedMedals = _xpService.getEarnedMedals()
        .where((medal) => medal.isEarned)
        .toList()
        ..sort((a, b) => b.tier.compareTo(a.tier));  // Sort by tier descending

    _isLoading = false;
    notifyListeners();
  }

  void showAllMedals(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earned Medals', style: TextStyle(fontSize: FontSizes.xlarge, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allMedals.map((medal) => _buildMedalTile(medal)).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalTile(Medal medal) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: CoreColors.foregroundColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.small),
        ),
        child: Center(
          child: FaIcon(
            medal.icon,
            color: medal.color,
            size: IconSizes.medium,
          ),
        ),
      ),
      title: Text(medal.title),
      subtitle: Text(medal.description),
    );
  }
} 
