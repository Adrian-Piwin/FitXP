import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/bar_data.model.dart';

class LineChartWidget extends WidgetFrame {
  final List<BarData> groupedData;
  final Color lineColor;
  final Function(double) getXAxisLabel;
  final double? targetValue;
  final String? targetValueText;
  final String? unit;

  const LineChartWidget({
    super.key,
    required this.groupedData,
    required this.lineColor,
    required this.getXAxisLabel,
    this.targetValue,
    this.targetValueText,
    this.unit,
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
    
    // Adjust min/max to include target value if present
    final effectiveMaxY = targetValue != null ? max(maxY, targetValue!) : maxY;
    final effectiveMinY = targetValue != null ? min(minY, targetValue!) : minY;
    
    // Calculate rounded values with custom logic
    double roundToNearest(double value, {bool isMax = false}) {
      if (value <= 0) return 0;
      
      // For values between 0-50, round to nearest 2
      if (value <= 50) {
        if (isMax) {
          return (value.ceil() + 1).toDouble();
        } else {
          return (value.floor() - 1).toDouble();
        }
      }
      
      // For values above 50, round to nearest 10
      if (isMax) {
        return ((value.ceil() + 9) ~/ 10) * 10.0;
      } else {
        return ((value.floor() - 9) ~/ 10) * 10.0;
      }
    }
    
    final roundedBottom = roundToNearest(effectiveMinY, isMax: false);
    final roundedTop = roundToNearest(effectiveMaxY, isMax: true);
    
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
      padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              LineChart(
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
                    if (targetValue != null)
                      LineChartBarData(
                        spots: [
                          FlSpot(-0.5, targetValue!),
                          FlSpot(groupedData.length - 0.5, targetValue!),
                        ],
                        isCurved: false,
                        color: lineColor.withOpacity(0.5),
                        barWidth: 1,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
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
                        reservedSize: 40,
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
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (value) => CoreColors.backgroundColor,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      fitInsideVertically: false,
                      fitInsideHorizontally: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          // Ignore edge points (extended spots)
                          if (touchedSpot.x < 0 || touchedSpot.x >= groupedData.length) {
                            return null;
                          }
                          
                          final index = touchedSpot.x.toInt();
                          return LineTooltipItem(
                            '${groupedData[index].label}\n',
                            const TextStyle(
                              color: CoreColors.textColor,
                              fontSize: FontSizes.small,
                            ),
                            children: [
                              TextSpan(
                                text: '${touchedSpot.y.toStringAsFixed(1)}${unit ?? ''}',
                                style: const TextStyle(
                                  color: CoreColors.textColor,
                                  fontSize: FontSizes.large,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    // Add touch callback to handle edge cases
                    handleBuiltInTouches: true,
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        // Don't show indicator for edge points
                        if (spotIndex < 1 || spotIndex >= groupedData.length + 1) {
                          return null;
                        }
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: lineColor.withOpacity(0.2),
                            strokeWidth: 2,
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: lineColor,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
              if (targetValue != null && targetValueText != null)
                Positioned(
                  left: 0,
                  right: 0,
                  top: _calculateYPosition(
                    targetValue!,
                    roundedBottom.toDouble(),
                    roundedTop.toDouble(),
                    constraints.maxHeight,
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 45),
                    child: Text(
                      targetValueText!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: lineColor.withOpacity(0.5),
                        fontSize: FontSizes.xsmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _calculateYPosition(
    double targetValue,
    double minY,
    double maxY,
    double height,
  ) {
    final percentage = 1 - ((targetValue - minY) / (maxY - minY));
    return (percentage * (height - 40)) + 8;
  }
} 
