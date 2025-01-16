import 'package:flutter/material.dart';
import 'package:healthxp/components/bottom_nav_bar.dart';
import 'package:healthxp/components/info_bar.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/pages/character/character_controller.dart';
import 'package:healthxp/components/character_model_viewer.dart';

class CharacterView extends StatelessWidget {
  CharacterView({super.key});
  static const routeName = '/character';

  final _modelViewerKey = GlobalKey<CharacterModelViewerState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CharacterController>(
      create: (context) => CharacterController(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CharacterController>(
            builder: (context, controller, _) => Column(
              children: [
                const SizedBox(height: GapSizes.xxxlarge),
        
                InfoBar(
                  title: 'Level ${controller.level}',
                  value: controller.xpLevelProgress,
                  goal: controller.xpLevelRequired,
                  percent: controller.xpLevelProgressPercent,
                  color: CoreColors.coreBlue,
                  textColor: CoreColors.coreOffBlue,
                ),
                
                const SizedBox(height: 20),
                
                SizedBox(
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -100,
                        bottom: -100,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: CharacterModelViewer(key: _modelViewerKey),
                      ),
                      
                      Positioned(
                        left: 0,
                        top: 20,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Text(
                            'LVL ${controller.level}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: FontSizes.xxxlarge,
                              fontWeight: FontWeight.bold,
                              height: 0.9,
                            ),
                            textAlign: TextAlign.left,
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
                
                const SizedBox(height: 20),
                
                // Rank section
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: InfoBar(
                        title: '${controller.rank} Rank',
                        value: controller.xpRankProgress,
                        goal: controller.xpRankRequired,
                        percent: controller.xpRankProgressPercent,
                        color: CoreColors.coreGold,
                        textColor: CoreColors.coreGold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: controller.refreshXP,
                  child: const Text('Refresh XP'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}
