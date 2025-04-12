import 'package:healthcore/components/icon_info_widget.dart';
import 'package:healthcore/components/line_chart_widget.dart';
import 'package:healthcore/components/loading_widget.dart';
import 'package:healthcore/constants/icons.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/bar_data.model.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/utility/chart.utility.dart';
import 'package:healthcore/utility/health.utility.dart';

class TrendHealthEntity extends HealthEntity {
  TrendHealthEntity(super.healthItem, super.widgetSize, super.healthFetcherService);

  DataPoint? get mostRecentDataPoint {
    if (getCurrentData.isEmpty) return null;
    return getCurrentData.reduce(
      (a, b) => a.dateFrom.isAfter(b.dateFrom) ? a : b
    );
  }

  String get getDisplayGoalWithUnitProgress {
    if (mostRecentDataPoint == null) return "--";
    final value = (mostRecentDataPoint!.value - goal).abs();
    return "${healthItem.doesGoalSupportDecimals ? value.toStringAsFixed(1) : value.toStringAsFixed(0)}${healthItem.unit} away";
  }

  @override
  List<TimeFrame> get supportedTimeFrames => [TimeFrame.week, TimeFrame.month, TimeFrame.year];

  @override
  double get getGoalPercent{
    return -1;
  }

  @override
  double get average {
    cachedAverage ??= getTrendHealthAverage(getCurrentData);
    return cachedAverage!;
  }

  // We only want the most recent data point for each day
  @override
  List<DataPoint> get getCurrentData {
    List<DataPoint> data = super.getCurrentData;
    return getLatestPointPerDay(data);
  }

  // Include the past 30 days so we can get the most recent data point
  @override
  void updateQuery(TimeFrame newTimeFrame, int newOffset) {
    if (!supportedTimeFrames.contains(newTimeFrame)) {
      newTimeFrame = supportedTimeFrames.first;
    }
    super.updateQuery(newTimeFrame, newOffset);
  }

  @override
  String get getDisplayValueWithUnit {
    if (showLoading) return "--";
    if (mostRecentDataPoint == null) return "--";
    
    final value = mostRecentDataPoint!.value;
    return "${healthItem.doesGoalSupportDecimals ? value.toStringAsFixed(1) : value.toStringAsFixed(0)}${healthItem.unit}";
  }

  @override
  String get getDisplaySubtitle {
    if (showLoading) return "--";
    if (getCurrentData.isEmpty) return "No data";

    return "${healthItem.doesGoalSupportDecimals ? average.toStringAsFixed(1) : average.toStringAsFixed(0)}${healthItem.unit} avg";
  }

  @override
  List<BarData> get getBarchartData {
    var graphData = aggregateData(data);
    if (graphData.isEmpty) return [];
    
    // Get latest point per day or month
    graphData = timeframe == TimeFrame.month 
      ? getLatestPointPerDay(graphData) 
      : getLatestPointPerMonth(graphData);

    return ChartUtility.groupDataByTimeFrame(graphData, timeframe, offset);
  }

  @override
  Widget get getGraphWidget {
    // TODO: Fix the weird loading state where it shows briefly
    // It works fine for health entity using showLoading, but for this there is no data inbetween the loading
    if (isLoading) return LoadingWidget(size: 6, height: WidgetSizes.largeHeight); 

    return LineChartWidget(
      groupedData: getBarchartData,
      lineColor: healthItem.color,
      getXAxisLabel: getXAxisLabel,
      targetValue: goal,
      targetValueText: getDisplayGoalWithUnit,
      unit: healthItem.unit,
    );
  }

  @override
  List<Widget> get getInfoWidgets {
    return [
      IconInfoWidget(
        title: "Average",
        displayValue: getDisplayAverage,
        icon: IconTypes.averageIcon,
        iconColor: healthItem.color,
      ),
      IconInfoWidget(
        title: "Minimum",
        displayValue: "${healthItem.doesGoalSupportDecimals ? minimum.toStringAsFixed(1) : minimum.toStringAsFixed(0)}${healthItem.unit}",
        icon: IconTypes.minimumIcon,
        iconColor: healthItem.color,
      ),
      IconInfoWidget(
        title: "Maximum",
        displayValue: "${healthItem.doesGoalSupportDecimals ? maximum.toStringAsFixed(1) : maximum.toStringAsFixed(0)}${healthItem.unit}",
        icon: IconTypes.maximumIcon,
        iconColor: healthItem.color,
      ),
    ];
  }

  @override
  HealthEntity clone() {
    return TrendHealthEntity(healthItem, widgetSize, healthFetcherService)..data = data;
  }
}
