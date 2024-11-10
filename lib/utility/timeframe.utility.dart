

import 'package:flutter/material.dart';
import '../enums/timeframe.enum.dart';

DateTimeRange calculateDateRange(TimeFrame timeFrame, int offset) {
  final now = DateTime.now();

  switch (timeFrame) {
    case TimeFrame.day:
      final start = DateTime(now.year, now.month, now.day).add(Duration(days: offset));
      final end = start.add(Duration(days: 1));
      return DateTimeRange(start: start, end: end);
    case TimeFrame.week:
      final currentWeekday = now.weekday;
      final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
          .add(Duration(days: offset * 7));
      final end = start.add(Duration(days: 7));
      return DateTimeRange(start: start, end: end);
    case TimeFrame.month:
      final start = DateTime(now.year, now.month + offset, 1);
      final end = DateTime(start.year, start.month + 1, 1);
      return DateTimeRange(start: start, end: end);
    case TimeFrame.year:
      final start = DateTime(now.year + offset, 1, 1);
      final end = DateTime(start.year + 1, 1, 1);
      return DateTimeRange(start: start, end: end);
    default:
      return DateTimeRange(start: now, end: now);
  }
}
