import 'package:flutter/material.dart';
import 'package:healthxp/components/timeframe_tabbar.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/pages/workouts/components/workout_list_item.dart';
import 'package:healthxp/pages/workouts/components/workout_summary.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/components/date_selector.dart';
import 'workouts_controller.dart';

class WorkoutsView extends StatefulWidget {
  static const routeName = '/workouts';
  
  const WorkoutsView({super.key});

  @override
  State<WorkoutsView> createState() => _WorkoutsViewState();
}

class _WorkoutsViewState extends State<WorkoutsView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late WorkoutsController _controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider(
      create: (context) {
        _controller = WorkoutsController();
        return _controller;
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Consumer<WorkoutsController>(
            builder: (context, controller, _) {
              return TimeFrameTabBar(
                selectedTimeFrame: controller.selectedTimeFrame,
                onChanged: controller.updateTimeFrame,
                timeFrameOptions: controller.timeFrameOptions,
              );
            },
          ),
        ),
        body: Consumer<WorkoutsController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return DateSelector(
              selectedTimeFrame: controller.selectedTimeFrame,
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
                        child: Padding(
                          padding: const EdgeInsets.all(PaddingSizes.medium),
                          child: Column(
                            children: [
                              WorkoutSummary(
                                workoutCount: controller.workoutCount,
                                totalDuration: controller.totalDuration,
                                totalCalories: controller.totalCalories,
                              ),
                              const SizedBox(height: GapSizes.medium),
                              ...controller.workouts.map((workout) => Padding(
                                padding: const EdgeInsets.only(bottom: GapSizes.medium),
                                child: WorkoutListItem(workout: workout),
                              )),
                            ],
                          ),
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
    );
  }
}
