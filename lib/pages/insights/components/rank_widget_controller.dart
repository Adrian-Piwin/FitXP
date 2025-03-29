import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool _isAnimating = false;
  int _currentAnimatedRank = 0;
  int _targetRank = 0;
  double _currentAnimatedXP = 0;
  double _targetXP = 0;
  late final XpService _xpService;

  RankWidgetController(this.context) {
    _xpService = Provider.of<XpService>(context, listen: false);
    _initialize();
  }

  bool get isLoading => _isLoading;
  bool get isAnimating => _isAnimating;
  int get currentAnimatedRank => _currentAnimatedRank;
  double get currentAnimatedXP => _currentAnimatedXP;
  
  String get rankName => switch (_currentAnimatedRank) {
    < 1 => Rank.bronze.displayName,
    < 2 => Rank.silver.displayName,
    < 3 => Rank.gold.displayName,
    _ => Rank.diamond.displayName,
  };

  Color get rankColor => switch (_currentAnimatedRank) {
    < 1 => CoreColors.coreBronze,
    < 2 => CoreColors.coreSilver,
    < 3 => CoreColors.coreGold,
    _ => CoreColors.coreDiamond,
  };

  IconData get rankIcon => switch (_currentAnimatedRank) {
    < 1 => FontAwesomeIcons.medal,
    < 2 => FontAwesomeIcons.medal,
    < 3 => FontAwesomeIcons.medal,
    _ => FontAwesomeIcons.gem,
  };

  double get rankProgress {
    if (_currentAnimatedRank == _targetRank) {
      return _currentAnimatedXP / rankUpXPAmt;
    }
    return _currentAnimatedXP / rankUpXPAmt;
  }

  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Wait for XP service to be fully initialized
      await _xpService.initialize();
      await _xpService.waitForInitialization();
      
      // Set initial values without animation
      _targetRank = _xpService.rank;
      _targetXP = _xpService.rankXpToNextRank.toDouble();
      _currentAnimatedRank = _targetRank;
      _currentAnimatedXP = _targetXP;
      
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
    if (_isAnimating) return;
    
    final newRank = _xpService.rank;
    final newXP = _xpService.rankXpToNextRank.toDouble();
    
    if (newRank != _targetRank || newXP != _targetXP) {
      _targetRank = newRank;
      _targetXP = newXP;
      _startAnimation();
    }
  }

  Future<void> _animateXP(double targetXP) async {
    const duration = Duration(milliseconds: 500);
    final startTime = DateTime.now();
    final startXP = _currentAnimatedXP;

    while (true) {
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime >= duration) {
        _currentAnimatedXP = targetXP;
        notifyListeners();
        break;
      }

      final progress = elapsedTime.inMilliseconds / duration.inMilliseconds;
      final curvedProgress = Curves.easeInOut.transform(progress);
      _currentAnimatedXP = startXP + (targetXP - startXP) * curvedProgress;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  void _startAnimation() async {
    if (_isAnimating) return;
    
    _isAnimating = true;
    final startRank = _currentAnimatedRank;
    final startXP = _currentAnimatedXP;
    
    try {
      if (startRank != _targetRank) {
        while (_currentAnimatedRank != _targetRank) {
          if (_currentAnimatedRank < _targetRank) {
            await _animateXP(rankUpXPAmt.toDouble());
            _currentAnimatedXP = 0;
            _currentAnimatedRank++;
          } else {
            _currentAnimatedXP = 0;
            _currentAnimatedRank--;
          }
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      
      await _animateXP(_targetXP);
    } catch (e) {
      print('Error during rank animation: $e');
      // Restore original values on error
      _currentAnimatedRank = startRank;
      _currentAnimatedXP = startXP;
      notifyListeners();
    } finally {
      _isAnimating = false;
    }
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
} 
