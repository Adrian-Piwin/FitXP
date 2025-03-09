import 'package:healthxp/components/timeframe_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';
import 'package:healthxp/pages/widget_configuration/widget_configuration_page.dart';
import 'package:healthxp/services/widget_configuration_service.dart';

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
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: GridLayout(
                              widgets: controller.displayWidgets,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WidgetConfigurationPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.edit),
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
