import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/components/grid_layout.dart';
import 'insights_controller.dart';

class InsightsView extends StatefulWidget {
  static const routeName = '/insights';
  
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) => InsightsController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Insights'),
        ),
        body: Consumer<InsightsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: GridLayout(
                  widgets: controller.displayWidgets,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
