import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

class StreakService {
  Future<int> getStreak(HealthEntity entity, double goalValue) async {
    DateTime currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    int streak = 0;
    bool isFirstDay = true;

    while (true) {
      final dayData = await entity.getData(DateTimeRange(
        start: currentDate,
        end: currentDate.add(const Duration(days: 1)),
      ));
      
      if (dayData.isEmpty && !isFirstDay) break;
      
      double dailyTotal = entity.aggregateData(dayData).fold(
        0.0, 
        (sum, point) => sum + point.value
      );
      
      if (dailyTotal.abs() >= goalValue.abs()) {
        streak++;
      } else if (!isFirstDay) {
        break;
      }
      
      isFirstDay = false;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
} 
