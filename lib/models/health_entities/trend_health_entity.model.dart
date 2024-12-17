import 'package:healthxp/components/loading_widget.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/components/line_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/utility/timeframe.utility.dart';

class TrendHealthEntity extends HealthEntity {
  TrendHealthEntity(super.healthItem, super.goals, super.widgetSize);

  DataPoint? get mostRecentDataPoint {
    return getCombinedData.reduce(
      (a, b) => a.dateFrom.isAfter(b.dateFrom) ? a : b
    );
  }

  @override
  String get getDisplayValue {
    if (isLoading) return "--";
    if (getCombinedData.isEmpty) return "--";
    
    return mostRecentDataPoint!.value.toStringAsFixed(1);
  }

  @override
  String get getDisplaySubtitle {
    if (isLoading) return "--";
    if (getCombinedData.isEmpty) return "No data";

    return "Avg: ${average.toStringAsFixed(1)}${healthItem.unit}";
  }

  @override
  Widget get getGraphWidget {
    if (isLoading) return LoadingWidget(size: widgetSize, height: WidgetSizes.mediumHeight);

    return LineChartWidget(
      dataPoints: getCombinedData,
      lineColor: healthItem.color,
      getXAxisLabel: (value) => getXAxisLabel(value),
      getYAxisValue: (value) => "${value.toStringAsFixed(1)}${healthItem.unit}",
    );
  }

  @override
  List<DataPoint> get getCombinedData {
    DateTimeRange dateRange = calculateDateRange(timeframe, offset);
    return super.getCombinedData.where((point) => point.dateFrom.isAfter(dateRange.start) && point.dateFrom.isBefore(dateRange.end)).toList();
  }
}
