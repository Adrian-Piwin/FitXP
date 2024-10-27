import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

enum TimeFrame {
  day,
  week,
  month,
  year,
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
    default:
      return '';
  }
}
