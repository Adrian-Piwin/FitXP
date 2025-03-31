import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/components/animated_value_controller.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/rank_definitions.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/constants/xp.constants.dart';
import 'package:healthcore/enums/rank.enum.dart';
import 'package:healthcore/services/xp_service.dart';
import 'package:provider/provider.dart';

class RankWidgetController extends ChangeNotifier {
  final BuildContext context;
  bool _isLoading = true;
  late final XpService _xpService;
  late final AnimatedValueController _animationController;

  RankWidgetController(this.context) {
    _animationController = AnimatedValueController();
    _animationController.addListener(_onAnimationUpdate);
    _initialize();
  }

  bool get isLoading => _isLoading;
  int get currentAnimatedRank => (_animationController.currentAnimatedValue / rankUpXPAmt).floor();
  double get currentAnimatedXP => _animationController.currentAnimatedValue % rankUpXPAmt;
  double get rankProgress => _animationController.currentAnimatedPercent;
  
  String get rankName => switch (currentAnimatedRank) {
    < 1 => Rank.bronze.displayName,
    < 2 => Rank.silver.displayName,
    < 3 => Rank.gold.displayName,
    _ => Rank.diamond.displayName,
  };

  Color get rankColor => switch (currentAnimatedRank) {
    < 1 => CoreColors.coreBronze,
    < 2 => CoreColors.coreSilver,
    < 3 => CoreColors.coreGold,
    _ => CoreColors.coreDiamond,
  };

  IconData get rankIcon => switch (currentAnimatedRank) {
    < 1 => FontAwesomeIcons.medal,
    < 2 => FontAwesomeIcons.medal,
    < 3 => FontAwesomeIcons.medal,
    _ => FontAwesomeIcons.gem,
  };

  void _onAnimationUpdate() {
    notifyListeners();
  }

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Wait for XP service to be fully initialized
      _xpService = Provider.of<XpService>(context, listen: false);
      await _xpService.initialize();
      await _xpService.waitForInitialization();
      
      // Set initial values
      _animationController.setInitialValues(
        value: _xpService.rankXP.toDouble(),
        percent: (_xpService.rankXpToNextRank / rankUpXPAmt).clamp(0.0, 1.0),
      );
      
      // Listen for XP service changes
      _xpService.addListener(_onXpServiceChanged);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing RankWidgetController: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onXpServiceChanged() {
    _animationController.updateValues(
      value: _xpService.rankXP.toDouble(),
      percent: (_xpService.rankXpToNextRank / rankUpXPAmt).clamp(0.0, 1.0),
    );
  }

  void showRankDetails(BuildContext context) {
    // Initialize selected rank outside the builder
    late Rank selectedRank;

    showDialog(
      context: context,
      builder: (context) {
        // Initialize on first build
        selectedRank = _xpService.currentRank;

        return StatefulBuilder(
          builder: (context, setState) {
            final selectedRankModel = RankDefinitions.ranks[selectedRank]!;

            return AlertDialog(
              title: const Text('Rank Details', style: TextStyle(fontSize: FontSizes.xlarge, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selected Rank Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rank Icon and Name
                      Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: CoreColors.foregroundColor,
                              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                            ),
                            child: Center(
                              child: FaIcon(
                                selectedRankModel.icon,
                                size: IconSizes.xlarge,
                                color: selectedRankModel.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: GapSizes.small),
                          Text(
                            selectedRank.displayName,
                            style: const TextStyle(
                              fontSize: FontSizes.medium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: GapSizes.large),
                      // Rank Fact
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(PaddingSizes.medium),
                          decoration: BoxDecoration(
                            color: CoreColors.foregroundColor,
                            borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                          ),
                          child: Text(
                            selectedRankModel.fact,
                            style: const TextStyle(fontSize: FontSizes.medium),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GapSizes.xxxlarge),
                  // All Ranks Display
                  const Text(
                    'Available Ranks',
                    style: TextStyle(
                      fontSize: FontSizes.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: GapSizes.xlarge),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: Rank.values.map((rank) {
                      final rankModel = RankDefinitions.ranks[rank]!;
                      final isSelected = rank == selectedRank;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRank = rank;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: CoreColors.foregroundColor,
                                borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                                border: isSelected ? Border.all(
                                  color: rankModel.color,
                                  width: 2,
                                ) : null,
                              ),
                              child: Center(
                                child: FaIcon(
                                  rankModel.icon,
                                  size: IconSizes.medium,
                                  color: rankModel.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: GapSizes.small),
                            Text(
                              rank.displayName,
                              style: TextStyle(
                                fontSize: FontSizes.small,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? rankModel.color : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    _xpService.removeListener(_onXpServiceChanged);
    super.dispose();
  }
} 
