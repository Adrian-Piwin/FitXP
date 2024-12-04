import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/utility/general.utility.dart';

class SleepBarChartWidget extends StatefulWidget {
  final List<BarData> barDataList;

  const SleepBarChartWidget({super.key, required this.barDataList});

  @override
  _SleepBarChartWidgetState createState() => _SleepBarChartWidgetState();
}

class _SleepBarChartWidgetState extends State<SleepBarChartWidget> {
  BarTouchResponse? _barTouchResponse; // Store the touch response

  @override
  Widget build(BuildContext context) {
    if (widget.barDataList.isEmpty) return const SizedBox();

    final totalDuration = widget.barDataList.first.totalDuration ?? 0;
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
            maxY: totalDuration,
            minY: 0,
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
                    final stageName = stageEntries[value.toInt()].key;
                    return RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        stageName,
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
                  interval: totalDuration / 3,
                  getTitlesWidget: (value, meta) {
                    if (value != 0 &&
                        value != totalDuration &&
                        value != totalDuration / 3 &&
                        value != totalDuration * 2 / 3) {
                      return const SizedBox();
                    }
                    final time = DateTime(2024, 1, 1, (value ~/ 60) % 24);
                    return RotatedBox(
                      quarterTurns: -1,
                      child: Text(
                        '${time.hour == 0 ? "12" : (time.hour > 12 ? time.hour - 12 : time.hour)}${time.hour >= 12 ? "pm" : "am"}',
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
            gridData: const FlGridData(
              show: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(stageEntries.length, (index) {
              final entry = stageEntries[index];
              final stageData = entry.value;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: totalDuration,
                    color: Colors.grey.withOpacity(0.3),
                    width: 25,
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
                  _barTouchResponse = response; // Update the stored response
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
