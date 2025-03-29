import 'package:flutter/material.dart';
import 'package:healthcore/components/timeframe_tabbar.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/workouts/components/workout_list_item.dart';
import 'package:healthcore/pages/workouts/components/workout_summary.dart';
import 'package:healthcore/pages/workouts/components/workout_type_filter.dart';
import 'package:provider/provider.dart';
import 'package:healthcore/components/date_selector.dart';
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
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(PaddingSizes.medium),
                              child: WorkoutSummary(
                                workoutCount: controller.workoutCount,
                                totalDuration: controller.totalDuration,
                                totalCalories: controller.totalCalories,
                              ),
                            ),
                            if (controller.availableWorkoutTypes.length > 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PaddingSizes.medium,
                                  vertical: 0,
                                ),
                                child: WorkoutTypeFilter(
                                  availableTypes: controller.availableWorkoutTypes,
                                  selectedTypes: controller.selectedWorkoutTypes,
                                  onToggleType: controller.toggleWorkoutType,
                                ),
                              ),
                            const SizedBox(height: GapSizes.small),
                            ...controller.workouts.map((workout) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PaddingSizes.medium,
                                vertical: GapSizes.small,
                              ),
                              child: WorkoutListItem(workout: workout),
                            )),
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
    );
  }
}
