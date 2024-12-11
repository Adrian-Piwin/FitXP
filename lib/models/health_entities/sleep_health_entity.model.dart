import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/components/barchart_widget.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/components/sleep_barchart_widget.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:healthxp/services/sleep_service.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:healthxp/utility/general.utility.dart';

class SleepHealthEntity extends HealthEntity {
  SleepHealthEntity(
    super.healthItem,
    super.goals,
    super.timeFrame,
  );
  
  List<SleepDataPoint> get sleepDataPoints => data[HealthDataType.SLEEP_ASLEEP] as List<SleepDataPoint>;

  int getSleepScore() {
    SleepService sleepService = SleepService(data);
    return sleepService.calculateSleepScore();
  }

  @override
  String get getDisplaySubtitle {
    if (isLoading) return "--";
    if (timeframe == TimeFrame.day && goal != -1) {
      return "${getSleepScore()} Sleep Score";
    }

    return "${formatMinutes(average.toInt())} avg";
  }

  @override
  String get getDisplayValue {
    if (isLoading) return "--";
    return formatMinutes(total.toInt());
  }

  @override
  String get getDisplayAverage {
    if (isLoading) return "--";
    return formatMinutes(average.toInt());
  }

  @override
  String get getDisplayGoal {
    if (isLoading) return "--";
    return formatMinutes(goal.toInt());
  }

  @override
  List<Widget> get getDetailWidgets {
    List<Widget> widgets = super.getDetailWidgets;
    widgets.addAll(
      [
        InfoWidget(
          title: "Sleep Score",
          displayValue: getSleepScore().toString(),
        ),
        InfoWidget(
          title: "REM ${_getSleepStagePercent(SleepStage.rem)}",
          displayValue: _getSleepStageDuration(SleepStage.rem),
        ),
        InfoWidget(
          title: "Deep ${_getSleepStagePercent(SleepStage.deep)}",
          displayValue: _getSleepStageDuration(SleepStage.deep),
        ),
        InfoWidget(
          title: "Light ${_getSleepStagePercent(SleepStage.light)}",
          displayValue: _getSleepStageDuration(SleepStage.light),
        ),
        InfoWidget(
          title: "Awake ${_getSleepStagePercent(SleepStage.awake)}",
          displayValue: _getSleepStageDuration(SleepStage.awake),
        ),
      ],
    );
    return widgets;
  }
  @override
  String getBarchartValue(double value) {
    return formatMinutes(value.toInt());
  }

  @override
  List<BarData> get getBarchartData {
    if (getCombinedData.isEmpty) return [];

    if (timeframe == TimeFrame.day) {
      return ChartUtility.getSleepBarData(sleepDataPoints);
    }
    return super.getBarchartData;
  }

  @override
  Widget get getGraphWidget {
    if (isLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.mediumHeight);

    return timeframe == TimeFrame.day ?
      SleepBarChartWidget(
        barDataList: getBarchartData,
        earliestDate: getCombinedData.isEmpty ? null : sleepDataPoints.reduce((a, b) => a.dateFrom.isBefore(b.dateFrom) ? a : b).dateFrom,
        latestDate: getCombinedData.isEmpty ? null : sleepDataPoints.reduce((a, b) => a.dateTo.isAfter(b.dateTo) ? a : b).dateTo,
      ) : BarChartWidget(
        groupedData: getBarchartData,
        barColor: healthItem.color,
        getXAxisLabel: getXAxisLabel,
        getBarchartValue: getBarchartValue,
      );
  }

  @override
  List<DataPoint> get getCombinedData {
    return sleepDataPoints.where((point) => point.sleepStage != SleepStage.awake).toList() as List<DataPoint>;
  }

  @override
  HealthEntity clone() {
    return SleepHealthEntity(healthItem, goals, widgetSize)..data = data;
  }

  String _getSleepStagePercent(SleepStage stage){
    List<SleepDataPoint> stageDataPoints = sleepDataPoints.where((point) => point.sleepStage == stage).toList();
    return "${(stageDataPoints.length / sleepDataPoints.length * 100).round()}%";
  }

  String _getSleepStageDuration(SleepStage stage) {
    List<SleepDataPoint> stageDataPoints = sleepDataPoints.where((point) => point.sleepStage == stage).toList();
    if (stageDataPoints.isEmpty) return "0min";
    
    int totalMinutes = stageDataPoints.fold(0, (sum, point) => 
      sum + point.dateTo.difference(point.dateFrom).inMinutes);
    return formatMinutes(totalMinutes);
  }
}
