import 'package:flutter/material.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/pages/character/character_controller.dart';
import 'package:healthxp/components/character_model_viewer.dart';
import 'package:healthxp/components/three_d_circular_progress.dart';

class CharacterView extends StatefulWidget {
  CharacterView({super.key});

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _modelViewerKey = GlobalKey<CharacterModelViewerState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<CharacterController>(
      create: (context) => CharacterController(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CharacterController>(
            builder: (context, controller, _) => Column(
              children: [
                const SizedBox(height: GapSizes.huge),
                
                SizedBox(
                  height: 550,
                  child: Stack(
                    children: [
                      // Progress rings layer
                      Positioned(
                        top: 0,
                        bottom: -280,
                        left: 110,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ring (Rank)
                              ThreeDCircularProgress(
                                progress: controller.xpRankProgressPercent * 100,
                                radius: 100,
                                color: CoreColors.coreGold,
                                backgroundColor: CoreColors.coreGold.withOpacity(0.3),
                                strokeWidth: 14,
                              ),
                              // Inner ring (Level)
                              ThreeDCircularProgress(
                                progress: controller.xpLevelProgressPercent * 100,
                                radius: 120,
                                color: CoreColors.coreBlue,
                                backgroundColor: CoreColors.coreBlue.withOpacity(0.3),
                                strokeWidth: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Model viewer layer
                      Positioned(
                        right: -50,
                        top: 0,
                        bottom: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: CharacterModelViewer(key: _modelViewerKey),
                      ),
                      
                      // Text overlay layer
                      Positioned(
                        left: 0,
                        top: 20,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Level section
                              const Text(
                                'LEVEL',
                                style: TextStyle(
                                  fontSize: FontSizes.large,
                                  fontWeight: FontWeight.w400,
                                  color: CoreColors.textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                controller.level,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: FontSizes.huge,
                                  height: 0.9,
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Rank section
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Rank icon
                                  SizedBox(
                                    height: 40,
                                    width: 20,
                                    child: Center(
                                      child: Icon(
                                        IconTypes.medalIcon,
                                        color: CoreColors.coreGold,
                                        size: 35,
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 28),
                                  
                                  // Rank text
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.rank,
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontSize: FontSizes.xlarge,
                                          fontWeight: FontWeight.bold,
                                          height: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      const Text(
                                        'Rank',
                                        style: TextStyle(
                                          fontSize: FontSizes.medium,
                                          fontWeight: FontWeight.w400,
                                          color: CoreColors.textColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity == null) return;
                            
                            if (details.primaryVelocity! < 0) {
                              _modelViewerKey.currentState?.animateToSideView();
                            } else if (details.primaryVelocity! > 0) {
                              _modelViewerKey.currentState?.animateToFrontView();
                            }
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                ElevatedButton(
                  onPressed: controller.refreshXP,
                  child: const Text('Refresh XP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
