import 'package:flutter/material.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/components/sleep_barchart_widget.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:healthxp/utility/general.utility.dart';

class SleepHealthEntity extends HealthEntity {
  SleepHealthEntity(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );

  @override
  String get getDisplaySubtitle {
    if (isLoading) return "--";
    if (timeframe == TimeFrame.day && goal != -1) {
      int sleepGoalMinutes = goal.toInt();
      int actualSleepMinutes = total.toInt();
      int differenceMinutes = (sleepGoalMinutes - actualSleepMinutes).abs();

      return goal - total >= 0 ? 
          "${formatMinutes(differenceMinutes)} left" : 
          "${formatMinutes(differenceMinutes)} over";
    }

    return "${formatMinutes(average.toInt())} avg";
  }

  @override
  String get getDisplayValue {
    if (isLoading) return "--";

    int totalMinutes = total.toInt();
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')} hrs";
  }

  @override
  String getBarchartValue(double value) {
    return formatMinutes(value.toInt());
  }

  @override
  List<BarData> get getBarchartData {
    if (getCombinedData.isEmpty) return [];

    if (timeframe == TimeFrame.day) {
      return ChartUtility.getSleepBarData(data);
    }
    return super.getBarchartData;
  }

  @override
  Widget get getGraphWidget {
    if (isLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.mediumHeight);

    return timeframe == TimeFrame.day ?
      SleepBarChartWidget(
        barDataList: getBarchartData,
      ) : BarChartWidget(
        groupedData: getBarchartData,
        barColor: healthItem.color,
        getXAxisLabel: getXAxisLabel,
        getBarchartValue: getBarchartValue,
      );
  }

  @override
  HealthEntity clone() {
    return SleepHealthEntity(healthItem, goals, widgetSize)..data = data;
  }
}
