import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

class StreakService {
  Future<int> getStreak(HealthEntity entity, double goalValue) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    final data = await entity.getData(DateTimeRange(
      start: startDate,
      end: now,
    ));
    
    int streak = 0;
    DateTime currentDate = now;
    
    while (currentDate.isAfter(startDate)) {
      bool metGoalForDay = false;
      
      for (var type in entity.healthItem.dataType) {
        final dayData = data[type]?.where((point) => 
          point.dayOccurred.year == currentDate.year &&
          point.dayOccurred.month == currentDate.month &&
          point.dayOccurred.day == currentDate.day
        ).toList() ?? [];
        
        if (dayData.isEmpty) {
          metGoalForDay = false;
          break;
        }
        
        double dailyTotal = 0;
        for (var point in dayData) {
          dailyTotal += point.value;
        }
        
        if (dailyTotal >= goalValue) {
          metGoalForDay = true;
        } else {
          metGoalForDay = false;
          break;
        }
      }
      
      if (!metGoalForDay) {
        break;
      }
      
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
} 
