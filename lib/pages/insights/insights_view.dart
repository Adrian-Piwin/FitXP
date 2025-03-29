import 'package:flutter/material.dart';
import 'package:healthcore/components/date_selector.dart';
import 'package:healthcore/components/loading_widget.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/pages/insights/components/medal_list_widget.dart';
import 'package:healthcore/pages/insights/components/rank_widget.dart';
import 'package:healthcore/services/xp_service.dart';
import 'package:provider/provider.dart';
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

  late InsightsController _controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<XpService>(
      future: XpService.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: ChangeNotifierProvider(
            create: (context) {
              _controller = InsightsController();
              return _controller;
            },
            child: Scaffold(
              appBar: AppBar(
                titleSpacing: 0,
                title: const Text('Your Achievements'),
              ),
              body: Consumer<InsightsController>(
                builder: (context, controller, _) {
                  if (controller.isInitializing) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return DateSelector(
                    selectedTimeFrame: TimeFrame.month,
                    offset: controller.offset,
                    onOffsetChanged: controller.updateOffset,
                    child: RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: RankWidget(),
                                  ),
                                  if (controller.showLoading)
                                    const LoadingWidget(
                                      size: 6,
                                      height: WidgetSizes.largeHeight,
                                      color: Colors.transparent,
                                      showShadow: false,
                                    )
                                  else
                                    MedalListWidget(medals: controller.medals),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
} 
