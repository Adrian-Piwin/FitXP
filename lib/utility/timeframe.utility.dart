

import 'package:flutter/material.dart';
import '../enums/timeframe.enum.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

DateTimeRange calculateDateRange(TimeFrame timeFrame, {int offset = 0}) {
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
    case TimeFrame.allTime:
      // Assuming all-time starts from a very early date
      final start = DateTime(1970);
      final end = now;
      return DateTimeRange(start: start, end: end);
    default:
      return DateTimeRange(start: now, end: now);
  }
}

String timeFrameToString(BuildContext context, TimeFrame timeFrame) {
  final appLocalizations = AppLocalizations.of(context)!;
  switch (timeFrame) {
    case TimeFrame.day:
      return appLocalizations.timeFrameDay;
    case TimeFrame.week:
      return appLocalizations.timeFrameWeek;
    case TimeFrame.month:
      return appLocalizations.timeFrameMonth;
    case TimeFrame.year:
      return appLocalizations.timeFrameYear;
    case TimeFrame.allTime:
      return appLocalizations.timeFrameAllTime;
    default:
      return '';
  }
}
