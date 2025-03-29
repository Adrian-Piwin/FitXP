import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/bar_data.model.dart';

class BarChartWidget extends WidgetFrame {
  final List<BarData> groupedData;
  final Color barColor;
  final Function(double) getXAxisLabel;
  final Function(double) getBarchartValue;
  final String? unit;

  const BarChartWidget({
    super.key,
    required this.groupedData,
    required this.barColor,
    required this.getXAxisLabel,
    required this.getBarchartValue,
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

    // Find min and max Y values
    final maxY = groupedData.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final minY = groupedData.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    
    // Calculate bar width based on number of bars
    // Ensure minimum gap of 4 pixels between bars
    final barWidth = (MediaQuery.of(context).size.width - 32) / groupedData.length - 4;
    // Cap maximum bar width at 16
    final adjustedBarWidth = barWidth.clamp(4.0, 16.0);
    
    // Calculate top value: 10% higher than maxY, rounded up to nearest 10
    final paddedMaxY = (maxY * 1.1).ceil();
    final roundedTop = ((paddedMaxY + 9) ~/ 10) * 10;
    
    // Calculate bottom value: 10% lower than minY, rounded down to nearest 10
    final paddedMinY = (minY * 1.1).floor();
    final roundedBottom = ((paddedMinY - 9) ~/ 10) * 10;
    
    // Calculate middle value
    final middleValue = ((roundedTop + roundedBottom) / 2).roundToDouble();

    return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: roundedTop.toDouble(),
                minY: roundedBottom.toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (value) => CoreColors.backgroundColor,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    fitInsideVertically: false,
                    fitInsideHorizontally: true,
                    direction: TooltipDirection.top,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final value = getBarchartValue(rod.toY);
                      return BarTooltipItem(
                        '${groupedData[groupIndex].label}\n',
                        const TextStyle(
                          color: CoreColors.textColor,
                          fontSize: FontSizes.small,
                        ),
                        children: [
                          TextSpan(
                            text: '$value${unit ?? ''}',
                            style: const TextStyle(
                              color: CoreColors.textColor,
                              fontSize: FontSizes.large,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final isFirst = value == 0;
                        final isLast = value == groupedData.length - 1;
                        final isMiddle = value == (groupedData.length - 1) ~/ 2;
                        
                        if (isFirst || isMiddle || isLast) {
                          final label = getXAxisLabel(value);
                          
                          // Check if the label is a time (hour) value
                          if (label.endsWith(':00')) {
                            final hour = int.tryParse(label.split(':')[0]);
                            if (hour != null) {
                              final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                              final period = hour < 12 ? 'AM' : 'PM';
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '$displayHour$period',
                                  style: const TextStyle(
                                    fontSize: FontSizes.xsmall,
                                    color: CoreColors.textColor,
                                  ),
                                ),
                              );
                            }
                          }
                          
                          // For non-time labels, display as is
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: FontSizes.xsmall,
                                color: CoreColors.textColor,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Calculate our three target values
                        final targetValues = [roundedBottom, middleValue, roundedTop.toDouble()];
                        
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
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: groupedData.asMap().entries.map((entry) {
                  final value = entry.value.y;
                  final isZeroOrNull = value == 0;
                  
                  // Calculate stub height based on total range rather than just top
                  final totalRange = roundedTop - roundedBottom;
                  final stubHeight = totalRange * 0.02;
                  
                  // For zero values, show a small positive stub regardless of data range
                  final displayValue = isZeroOrNull ? stubHeight : value;
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: displayValue,
                        fromY: 0, // Ensure bars start from zero
                        color: isZeroOrNull ? Colors.grey.withOpacity(0.3) : 
                               barColor,
                        width: adjustedBarWidth,
                        borderRadius: isZeroOrNull ? const BorderRadius.vertical(top: Radius.circular(4)) :
                                   value < 0 ? const BorderRadius.vertical(bottom: Radius.circular(4)) :
                                   const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
    );
  }
}
