import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

class StreakService {
  Future<int> getStreak(HealthEntity entity, double goalValue) async {
    final now = DateTime.now().subtract(const Duration(days: 1));
    final startDate = now.subtract(const Duration(days: 30));

    var rawData = await entity.getData(DateTimeRange(
      start: startDate,
      end: now,
    ));
    var data = entity.aggregateData(rawData);

    int streak = 0;
    DateTime currentDate = now;

    while (currentDate.isAfter(startDate)) {
      final dayData = data.where((point) => 
        point.dayOccurred.year == currentDate.year &&
        point.dayOccurred.month == currentDate.month &&
        point.dayOccurred.day == currentDate.day
      ).toList();
      
      if (dayData.isEmpty) break;
      
      double dailyTotal = 0;
      for (var point in dayData) {
        dailyTotal += point.value;
      }
      
      if (dailyTotal.abs() >= goalValue.abs()) {
        streak++;
      } else {
        break;
      }
      
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
} 
