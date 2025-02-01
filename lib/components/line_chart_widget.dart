import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/bar_data.model.dart';

class LineChartWidget extends WidgetFrame {
  final List<BarData> groupedData;
  final Color lineColor;
  final Function(double) getXAxisLabel;

  const LineChartWidget({
    super.key,
    required this.groupedData,
    required this.lineColor,
    required this.getXAxisLabel,
  }) : super(
          size: 6,
          height: WidgetSizes.largeHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
    if (groupedData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Find min and max Y values BEFORE filtering
    final maxY = groupedData.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final minY = groupedData.map((d) => d.y).where((y) => y > 0).reduce((a, b) => a < b ? a : b);
    
    // Calculate bottom value: 10% lower than minY, rounded down to nearest 10
    final bottomValue = (minY * 0.9).floor(); // 90% of minimum value
    final roundedBottom = ((bottomValue - 9) ~/ 10) * 10; // Round down to nearest 10
    
    // Calculate top value
    final paddedMaxY = (maxY * 1.1).ceil();
    final roundedTop = ((paddedMaxY + 9) ~/ 10) * 10;
    
    // Calculate interval based on the full range
    final range = roundedTop - roundedBottom;
    final interval = max(1, (range / 4).ceil());

    // Now create validSpots after calculating the ranges
    final validSpots = groupedData.asMap().entries
        .where((entry) => entry.value.y > 0)
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.y))
        .toList();

    if (validSpots.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final extendedSpots = [
      FlSpot(-0.5, validSpots.first.y),
      ...validSpots,
      FlSpot(groupedData.length - 0.5, validSpots.last.y),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: extendedSpots,
              isCurved: true,
              curveSmoothness: 0.2,
              preventCurveOverShooting: true,
              gradient: LinearGradient(
                colors: [
                  lineColor,
                  lineColor.withOpacity(0.8),
                ],
              ),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  if (index == 0 || index == extendedSpots.length - 1) {
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                      strokeWidth: 0,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 2.5,
                    color: Colors.white,
                    strokeWidth: 1.5,
                    strokeColor: lineColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.3),
                    lineColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ],
          gridData: FlGridData(
            show: false,
            drawVerticalLine: false,
            drawHorizontalLine: false,
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final valueInt = value.round();
                  final lastIndex = groupedData.length - 1;
                  final middleIndex = lastIndex ~/ 2;

                  if (valueInt == 0 || valueInt == middleIndex || valueInt == lastIndex) {
                    if (valueInt >= 0 && valueInt < groupedData.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          getXAxisLabel(valueInt.toDouble()),
                          style: const TextStyle(
                            fontSize: FontSizes.xsmall,
                            color: CoreColors.textColor,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1, // Show all possible values
                getTitlesWidget: (value, meta) {
                  // Calculate our three target values
                  final bottomValue = roundedBottom.toDouble();
                  final topValue = roundedTop.toDouble();
                  final middleValue = ((bottomValue + topValue) / 2).roundToDouble();
                  
                  // Create list of values we want to show
                  final targetValues = [bottomValue, middleValue, topValue];
                  
                  // Only show label if value matches one of our target values
                  if (targetValues.contains(value)) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.xsmall,
                          color: CoreColors.textColor,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minY: roundedBottom.toDouble(),
          maxY: roundedTop.toDouble(),
          minX: -0.5,
          maxX: groupedData.length - 0.5,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (value) => CoreColors.backgroundColor,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              fitInsideVertically: false,
              fitInsideHorizontally: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  return LineTooltipItem(
                    '${groupedData[index].label}\n${touchedSpot.y.toStringAsFixed(1)}',
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
} 
