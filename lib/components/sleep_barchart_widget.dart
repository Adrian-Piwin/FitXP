import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/utility/general.utility.dart';

class SleepBarChartWidget extends WidgetFrame {
  final List<BarData> barDataList;
  final DateTime? earliestDate;
  final DateTime? latestDate;

  const SleepBarChartWidget({
    super.key,
    required this.barDataList,
    this.earliestDate,
    this.latestDate,
  }) : super(size: 6, height: WidgetSizes.largeHeight);

  @override
  Widget buildContent(BuildContext context) {
    return _SleepBarChartState(
      barDataList: barDataList,
      earliestDate: earliestDate,
      latestDate: latestDate,
    );
  }
}

class _SleepBarChartState extends StatefulWidget {
  final List<BarData> barDataList;
  final DateTime? earliestDate;
  final DateTime? latestDate;

  const _SleepBarChartState({
    required this.barDataList,
    this.earliestDate,
    this.latestDate,
  });

  @override
  _SleepBarChartStateState createState() => _SleepBarChartStateState();
}

class _SleepBarChartStateState extends State<_SleepBarChartState> {
  BarTouchResponse? _barTouchResponse;

  @override
  Widget build(BuildContext context) {
    if (widget.barDataList.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final totalDuration = widget.barDataList.first.totalDuration ?? 0;
    final earliestStartMinutes = widget.barDataList
        .map((data) => data.x)
        .reduce((min, value) => value < min ? value : min);
        
    final latestEndMinutes = widget.barDataList
        .map((data) => data.x + (data.y))
        .reduce((max, value) => value > max ? value : max);

    // Calculate 3-hour intervals (180 minutes)
    const intervalMinutes = 180;
    final startInterval = (earliestStartMinutes / intervalMinutes).floor() * intervalMinutes;
    final endInterval = ((latestEndMinutes / intervalMinutes).ceil() * intervalMinutes);
    
    // Generate list of interval points, excluding the last one
    final intervalPoints = List.generate(
      ((endInterval - startInterval) / intervalMinutes).ceil(),
      (index) => startInterval + (index * intervalMinutes),
    );

    final Map<String, List<BarData>> stageGroups = {};

    for (var data in widget.barDataList) {
      stageGroups.putIfAbsent(data.label, () => []).add(data);
    }

    final List<MapEntry<String, List<BarData>>> stageEntries = stageGroups.entries.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: RotatedBox(
        quarterTurns: 1,
        child: BarChart(
          BarChartData(
            maxY: latestEndMinutes,
            minY: earliestStartMinutes,
            groupsSpace: 35,
            alignment: BarChartAlignment.center,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value < 0 || value >= stageEntries.length) {
                      return const SizedBox();
                    }
                    return RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        stageEntries[value.toInt()].key,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: intervalMinutes.toDouble(),
                  getTitlesWidget: (value, meta) {
                    // Skip the last label
                    if (value % intervalMinutes != 0) return const SizedBox();
                    
                    final dateTime = widget.earliestDate!.add(Duration(minutes: value.toInt()));
                    final hour = dateTime.hour;
                    final isPM = hour >= 12;
                    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
                    
                    return RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        '$displayHour${isPM ? "pm" : "am"}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                  reservedSize: 15,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: intervalMinutes.toDouble(),
              checkToShowHorizontalLine: (value) => intervalPoints.contains(value),
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(stageEntries.length, (index) {
              final stageData = stageEntries[index].value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: totalDuration,
                    color: Colors.grey.withOpacity(0.3),
                    width: 25,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                    rodStackItems: stageData
                        .map((data) => BarChartRodStackItem(
                              data.x,
                              data.x + data.y,
                              data.color ?? Colors.blue,
                            ))
                        .toList(),
                  ),
                ],
              );
            }),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: -150,
                direction: TooltipDirection.top,
                rotateAngle: 270,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final touchedSpot = _barTouchResponse?.spot;
                  if (touchedSpot == null) return null;

                  final touchedStack = touchedSpot.touchedStackItem;
                  if (touchedStack != null) {
                    final stackDuration = touchedStack.toY - touchedStack.fromY;
                    return BarTooltipItem(
                      formatMinutes(stackDuration.toInt()),
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }

                  final rodData = touchedSpot.touchedRodData;
                  return BarTooltipItem(
                    '${(rodData.toY / 60).toStringAsFixed(1)} hours',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
              touchCallback: (event, response) {
                setState(() {
                  _barTouchResponse = response;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
