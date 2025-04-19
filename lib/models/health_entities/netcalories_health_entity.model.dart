import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthcore/components/net_calories_progress_widget.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/utility/general.utility.dart';

class NetCaloriesHealthEntity extends HealthEntity {
  NetCaloriesHealthEntity(
    super.healthItem,
    super.timeFrame,
    super.healthFetcherService,
  );

  double currentBMR = 0;
  double _remainingBMR = 0;

  double getRemainingBMR() {
    int minutesLeftInDay = getMinutesLeftInDay();
    int minutesPassedToday = getMinutesPassedToday();
    return ((currentBMR / minutesPassedToday) * minutesLeftInDay);
  }

  @override
  List<DataPoint> aggregateData(Map<HealthDataType, List<DataPoint>> data) {
    Map<HealthDataType, List<DataPoint>> newData = Map.from(data);

    if (data.containsKey(HealthDataType.ACTIVE_ENERGY_BURNED)) {
      newData[HealthDataType.ACTIVE_ENERGY_BURNED] = data[HealthDataType.ACTIVE_ENERGY_BURNED]!
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo,
                dayOccurred: point.dayOccurred,
              ))
          .toList();
    }
    if (data.containsKey(HealthDataType.BASAL_ENERGY_BURNED)) {
      // Calculate BMR sum before negating values
      currentBMR = data[HealthDataType.BASAL_ENERGY_BURNED]!
          .fold(0.0, (sum, point) => sum + point.value);

      newData[HealthDataType.BASAL_ENERGY_BURNED] = data[HealthDataType.BASAL_ENERGY_BURNED]!
          .map((point) => DataPoint(
                value: -point.value,
                dateFrom: point.dateFrom,
                dateTo: point.dateTo,
                dayOccurred: point.dayOccurred,
              ))
          .toList();
    }

    // Calculate remaining BMR after we have the current BMR value
    if (timeframe == TimeFrame.day && offset == 0 && currentBMR > 0) {
      _remainingBMR = getRemainingBMR();
    }
    return newData.values.expand((list) => list).toList();
  }

  @override
  double get getGoalPercent {
    if (goal == 0) return 0.0;

    double total = this.total;
    if (goal < 0) {
      if (total > 0) {
        return 0;
      }
      total = total.abs();
    }
    return (total / goal.abs()).clamp(0, 1.0);
  }

  @override
  List<Widget> get getInfoWidgets {
    if (timeframe != TimeFrame.day || offset != 0) {
      return super.getInfoWidgets;
    }

    return [
      ...super.getInfoWidgets,
      NetCaloriesProgressWidget(
        currentNetCalories: total, 
        projectedNetCalories: (_remainingBMR * -1) + total
      ),
    ];
  }

  @override
  HealthEntity clone() {
    final clone = NetCaloriesHealthEntity(healthItem, widgetSize, healthFetcherService);
    clone.data = data;
    clone.currentBMR = currentBMR;
    clone._remainingBMR = _remainingBMR;
    return clone;
  }
}
