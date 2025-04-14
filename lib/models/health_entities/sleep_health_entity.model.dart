import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthcore/components/barchart_widget.dart';
import 'package:healthcore/components/icon_info_widget.dart';
import 'package:healthcore/components/loading_widget.dart';
import 'package:healthcore/components/sleep_barchart_widget.dart';
import 'package:healthcore/components/sleep_info_widget.dart';
import 'package:healthcore/constants/icons.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/sleep_stages.enum.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/bar_data.model.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/models/data_points/sleep_data_point.model.dart';
import 'package:healthcore/services/sleep_service.dart';
import 'package:healthcore/utility/chart.utility.dart';
import 'package:healthcore/utility/general.utility.dart';

class SleepHealthEntity extends HealthEntity {
  int? sleepScoreCache;

  SleepHealthEntity(
    super.healthItem,
    super.timeFrame,
    super.healthFetcherService,
  );

  @override
  List<DataPoint> aggregateData(Map<HealthDataType, List<DataPoint>> data) {
    if (data[HealthDataType.SLEEP_ASLEEP] == null || data[HealthDataType.SLEEP_ASLEEP]!.isEmpty) {
      return [];
    }
    
    return data[HealthDataType.SLEEP_ASLEEP]!.map((point) {
      if (point is SleepDataPoint) {
        return point;
      }
      // If it's a regular DataPoint, convert it to SleepDataPoint
      return SleepDataPoint(
        value: point.value,
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        dayOccurred: point.dayOccurred,
        sleepStage: SleepStage.unknown, // Default value if not available
      );
    }).toList();
  }
  
  List<SleepDataPoint> get sleepDataPoints {
    if (data[HealthDataType.SLEEP_ASLEEP] == null || data[HealthDataType.SLEEP_ASLEEP]!.isEmpty) {
      return [];
    }
    
    return data[HealthDataType.SLEEP_ASLEEP]!.map((point) {
      if (point is SleepDataPoint) {
        return point;
      }
      // If it's a regular DataPoint, convert it to SleepDataPoint
      return SleepDataPoint(
        value: point.value,
        dateFrom: point.dateFrom,
        dateTo: point.dateTo,
        dayOccurred: point.dayOccurred,
        sleepStage: SleepStage.unknown, // Default value if not available
      );
    }).toList();
  }

  int getSleepScore() {
    if (sleepScoreCache != null) return sleepScoreCache!;
    SleepService sleepService = SleepService(sleepDataPoints);
    sleepScoreCache = sleepService.calculateSleepScore();
    return sleepScoreCache!;
  }

  @override
  String get getDisplaySubtitle {
    if (showLoading) return "--";
    if (timeframe == TimeFrame.day && goal != -1) {
      return "${getSleepScore()} Sleep Score";
    }

    return "${formatMinutes(average.toInt())} avg";
  }

  @override
  String get getDisplayValueWithUnit {
    if (showLoading) return "--";
    return formatMinutes(total.toInt());
  }

  @override
  String get getDisplayAverage {
    if (showLoading) return "--";
    return formatMinutes(average.toInt());
  }

  @override
  String get getDisplayGoal {
    if (showLoading) return "--";
    return formatMinutes(goal.toInt());
  }

  @override
  String formatValue(double value) {
    return formatMinutes(value.toInt());
  }

  @override
  String formatValueWithUnit(double value) {
    return formatMinutes(value.toInt());
  }

  @override
  List<Widget> get getInfoWidgets {
    List<Widget> widgets = super.getInfoWidgets;
    widgets.addAll(
      [
        IconInfoWidget(
          title: "Sleep Score",
          displayValue: "${getSleepScore()} ${SleepService.getSleepQualityDescription(getSleepScore())}",
          icon: IconTypes.sleepScoreIcon,
          iconColor: healthItem.color,
        ),
        SleepInfoWidget(
          sleepStages: {
            'rem': {
              'duration': _getSleepStageDuration(SleepStage.rem),
              'percentage': _getSleepStagePercent(SleepStage.rem),
            },
            'deep': {
              'duration': _getSleepStageDuration(SleepStage.deep),
              'percentage': _getSleepStagePercent(SleepStage.deep),
            },
            'light': {
              'duration': _getSleepStageDuration(SleepStage.light),
              'percentage': _getSleepStagePercent(SleepStage.light),
            },
            'awake': {
              'duration': _getSleepStageDuration(SleepStage.awake),
              'percentage': _getSleepStagePercent(SleepStage.awake),
            },
          },
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
    if (getCurrentData.isEmpty) return [];

    if (timeframe == TimeFrame.day) {
      return ChartUtility.getSleepBarData(sleepDataPoints);
    }
    return super.getBarchartData;
  }

  @override
  Widget get getGraphWidget {
    if (showLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.largeHeight);

    return timeframe == TimeFrame.day ?
      SleepBarChartWidget(
        barDataList: getBarchartData,
        earliestDate: getCurrentData.isEmpty ? null : sleepDataPoints.reduce((a, b) => a.dateFrom.isBefore(b.dateFrom) ? a : b).dateFrom,
        latestDate: getCurrentData.isEmpty ? null : sleepDataPoints.reduce((a, b) => a.dateTo.isAfter(b.dateTo) ? a : b).dateTo,
      ) : BarChartWidget(
        groupedData: getBarchartData,
        barColor: healthItem.color,
        getXAxisLabel: getXAxisLabel,
        getBarchartValue: getBarchartValue,
      );
  }

  @override
  List<DataPoint> get getCurrentData {
    return sleepDataPoints.where((point) => point.sleepStage != SleepStage.awake).toList() as List<DataPoint>;
  }

  @override
  void clearCache() {
    sleepScoreCache = null;
    super.clearCache();
  }

  @override
  HealthEntity clone() {
    return SleepHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }

  double _getSleepStagePercent(SleepStage stage) {
    if (sleepDataPoints.isEmpty) return 0;
    
    // Get duration string for this stage and convert to minutes
    String stageDuration = _getSleepStageDuration(stage);
    int stageMinutes = int.parse(stageDuration.replaceAll(RegExp(r'[^0-9]'), ''));
    
    // Get total duration across all stages
    int totalMinutes = 0;
    for (SleepStage s in SleepStage.values) {
      String duration = _getSleepStageDuration(s);
      totalMinutes += int.parse(duration.replaceAll(RegExp(r'[^0-9]'), ''));
    }
    
    if (totalMinutes == 0) return 0;
    return (stageMinutes / totalMinutes * 100);
  }

  String _getSleepStageDuration(SleepStage stage) {
    List<SleepDataPoint> stageDataPoints = sleepDataPoints.where((point) => point.sleepStage == stage).toList();
    if (stageDataPoints.isEmpty) return "0min";
    
    int totalMinutes = stageDataPoints.fold(0, (sum, point) => 
      sum + point.dateTo.difference(point.dateFrom).inMinutes);
    return formatMinutes(totalMinutes);
  }
}
