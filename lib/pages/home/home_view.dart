import 'package:healthcore/components/timeframe_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';
import 'package:healthcore/services/widget_configuration_service.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/icons.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/components/premium_indicator.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/home';
  
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late HomeController _controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) {
        _controller = HomeController(context);
        return _controller;
      },
      child: Consumer2<HomeController, WidgetConfigurationService>(
        builder: (context, controller, widgetService, _) {
          if (controller.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.displayWidgets.isEmpty) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load widgets'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refresh(true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: TimeFrameTabBar(
                selectedTimeFrame: controller.selectedTimeFrame,
                onChanged: (newTimeFrame) {
                  controller.updateTimeFrame(newTimeFrame);
                },
              ),
            ),
            body: Stack(
              children: [
                DateSelector(
                  selectedTimeFrame: controller.selectedTimeFrame,
                  offset: controller.offset,
                  onOffsetChanged: controller.updateOffset,
                  child: RefreshIndicator(
                    onRefresh: () => controller.refresh(true),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - 80, // Subtract space for button
                                ),
                                child: GridLayout(
                                  widgets: controller.displayWidgets,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  onTap: () {
                                    controller.navigateToWidgetConfiguration();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: WidgetSizes.xxSmallHeight,
                                    decoration: BoxDecoration(
                                      color: CoreColors.accentAltColor,
                                      borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: PaddingSizes.medium,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Configure Widgets',
                                              style: TextStyle(
                                                fontSize: FontSizes.medium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (!controller.isPremiumUser) ...[
                                              const SizedBox(width: 6),
                                              const PremiumIndicator(mini: true),
                                            ],
                                          ],
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: Icon(
                                            IconTypes.editIcon,
                                            size: IconSizes.xsmall,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
