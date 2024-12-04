import 'dart:ui';

class BarData {
  final double x;
  final double y;
  final String label;
  final Color? color;
  final int? order;
  final double? totalDuration;
  final String? timeLabel;
  final DateTime? dateFrom;

  BarData({
    required this.x,
    required this.y,
    required this.label,
    this.color,
    this.order,
    this.totalDuration,
    this.timeLabel,
    this.dateFrom,
  });
}
