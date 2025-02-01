import 'package:healthxp/components/icon_info_widget.dart';
import 'package:healthxp/components/line_chart_widget.dart';
import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/utility/chart.utility.dart';
import 'package:healthxp/utility/health.utility.dart';

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
    return "${(mostRecentDataPoint!.value - goal).abs().toStringAsFixed(0)}${healthItem.unit} away";
  }

  @override
  List<TimeFrame> get supportedTimeFrames => [TimeFrame.month, TimeFrame.year];

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
    
    return mostRecentDataPoint!.value.toStringAsFixed(1) + healthItem.unit;
  }

  @override
  String get getDisplaySubtitle {
    if (showLoading) return "--";
    if (getCurrentData.isEmpty) return "No data";

    return "${average.toStringAsFixed(1)}${healthItem.unit} avg";
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
        displayValue: minimum.toStringAsFixed(1) + healthItem.unit,
        icon: IconTypes.minimumIcon,
        iconColor: healthItem.color,
      ),
      IconInfoWidget(
        title: "Maximum",
        displayValue: maximum.toStringAsFixed(1) + healthItem.unit,
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
