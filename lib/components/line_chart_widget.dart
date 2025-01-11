import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/data_points/data_point.model.dart';

class LineChartWidget extends WidgetFrame {
  final List<DataPoint> dataPoints;
  final Color lineColor;
  final Function(double) getXAxisLabel;
  final Function(double) getYAxisValue;

  const LineChartWidget({
    super.key,
    required this.dataPoints,
    required this.lineColor,
    required this.getXAxisLabel,
    required this.getYAxisValue,
  }) : super(
          size: 6,
          height: WidgetSizes.largeHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort data points by date
    final sortedPoints = List<DataPoint>.from(dataPoints)
      ..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    final maxY = sortedPoints.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minY = sortedPoints.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            fitInsideVertically: false,
            fitInsideHorizontally: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = getXAxisLabel(spot.x);
                final value = getYAxisValue(spot.y);
                return LineTooltipItem(
                  '$date\n$value',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                final isFirst = index == 0;
                final isLast = index == sortedPoints.length - 1;
                final isMiddle = index == (sortedPoints.length - 1) ~/ 2;
                
                if (isFirst || isMiddle || isLast) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      getXAxisLabel(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: minY - ((maxY - minY) * 0.1), // Add 10% padding
        maxY: maxY + ((maxY - minY) * 0.1),
        lineBarsData: [
          LineChartBarData(
            spots: sortedPoints.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.value,
              );
            }).toList(),
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: lineColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
