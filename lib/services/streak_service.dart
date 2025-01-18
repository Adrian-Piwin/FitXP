import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/services/health_fetcher_service.dart';

class StreakService {
  final HealthFetcherService _healthFetcher;

  StreakService(this._healthFetcher);

  Future<int> getStreak(HealthEntity entity, double goalValue) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    
    print('Calculating streak from ${now.toString()} back to ${startDate.toString()}');
    print('Goal value: $goalValue');
    
    entity.queryDateRange = DateTimeRange(
      start: startDate,
      end: now,
    );
    
    final data = await _healthFetcher.fetchBatchData([entity]);
    print('Fetched data types: ${data.keys.toString()}');
    
    int streak = 0;
    DateTime currentDate = now;
    
    while (currentDate.isAfter(startDate)) {
      bool metGoalForDay = false;
      print('\nChecking date: ${currentDate.toString().split(' ')[0]}');
      
      for (var type in entity.healthItem.dataType) {
        final dayData = data[type]?.where((point) => 
          point.dayOccurred.year == currentDate.year &&
          point.dayOccurred.month == currentDate.month &&
          point.dayOccurred.day == currentDate.day
        ).toList() ?? [];
        
        print('Data type: ${type.name}');
        print('Points found for day: ${dayData.length}');
        
        if (dayData.isEmpty) {
          print('No data found for this day and type');
          metGoalForDay = false;
          break;
        }
        
        double dailyTotal = 0;
        for (var point in dayData) {
          dailyTotal += point.value;
        }
        print('Daily total: $dailyTotal');
        
        if (dailyTotal >= goalValue) {
          print('Goal met for this type');
          metGoalForDay = true;
        } else {
          print('Goal not met for this type');
          metGoalForDay = false;
          break;
        }
      }
      
      if (!metGoalForDay) {
        print('Breaking streak at ${currentDate.toString().split(' ')[0]}');
        break;
      }
      
      print('Adding to streak');
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    print('Final streak: $streak');
    return streak;
  }
} 
