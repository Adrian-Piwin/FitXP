import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthxp/models/bar_data.model.dart';

class HealthDetailsBarChart extends StatelessWidget {
  final List<BarData> groupedData;
  final Color barColor;
  final Function(double) getXAxisLabel;

  const HealthDetailsBarChart({
    super.key,
    required this.groupedData,
    required this.barColor,
    required this.getXAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = groupedData.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final minY = groupedData.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    
    // Calculate bar width based on number of bars
    // Ensure minimum gap of 4 pixels between bars
    final barWidth = (MediaQuery.of(context).size.width - 32) / groupedData.length - 4;
    // Cap maximum bar width at 16
    final adjustedBarWidth = barWidth.clamp(4.0, 16.0);
    
    return Stack(
      children: [
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY * 1.2,
            minY: minY < 0 ? minY * 1.2 : 0, // Add space below for negative values
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                fitInsideVertically: false, // Prevents tooltip from being constrained vertically
                fitInsideHorizontally: true,
                direction: TooltipDirection.top, // Forces tooltip to always show above
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${groupedData[groupIndex].label}\n${rod.toY.toStringAsFixed(1)}',
                    const TextStyle(color: Colors.white),
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
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
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
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: value == 0 ? maxY * 0.02 : value, // Show tiny bar for zero values
                    color: value == 0 ? Colors.grey.withOpacity(0.3) : barColor,
                    width: adjustedBarWidth,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
