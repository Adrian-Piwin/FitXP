import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthxp/components/widget_frame.dart';
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

    final maxY = groupedData.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final minChartValue = 10.0;
    
    final effectiveMaxY = maxY <= 0 ? minChartValue : maxY;
    final paddedMaxY = (effectiveMaxY * 1.1).ceil();
    final roundedMaxY = ((paddedMaxY + 9) ~/ 10) * 10;
    
    final interval = max(1, (roundedMaxY / 4).ceil());

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
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
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
            show: true,
            drawVerticalLine: true,
            horizontalInterval: interval.toDouble(),
            verticalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
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
                            fontSize: 10,
                            color: Colors.grey,
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
                getTitlesWidget: (value, meta) {
                  if (value == 0 || 
                      value == roundedMaxY || 
                      value == roundedMaxY / 2 || 
                      value == roundedMaxY / 4 || 
                      value == roundedMaxY * 3 / 4) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 32,
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
            show: true,
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          minY: 0,
          maxY: max(roundedMaxY, interval * 4).toDouble(),
          minX: -0.5,
          maxX: groupedData.length - 0.5,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
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
                      color: Colors.white,
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
