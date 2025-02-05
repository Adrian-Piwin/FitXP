import 'package:healthxp/components/timeframe_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';

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
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Consumer<HomeController>(
              builder: (context, controller, _) {
                return TimeFrameTabBar(
                  selectedTimeFrame: controller.selectedTimeFrame,
                  onChanged: (newTimeFrame) {
                    controller.updateTimeFrame(newTimeFrame);
                  },
                );
              },
            ),
          ),
          body: Consumer<HomeController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.displayWidgets.isEmpty) {
                return Center(
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
                );
              }

              return DateSelector(
                selectedTimeFrame: controller.selectedTimeFrame,
                offset: controller.offset,
                onOffsetChanged: controller.updateOffset,
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: GridLayout(
                      widgets: controller.displayWidgets,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    );
  }
}
