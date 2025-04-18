import 'package:healthcore/constants/health_data_types.constants.dart';
import 'package:healthcore/enums/timeframe.enum.dart';
import 'package:healthcore/models/data_points/data_point.model.dart';
import 'package:health/health.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/models/health_item.model.dart';
import 'package:healthcore/services/health_fetcher_service.dart';

double getHealthAverage(List<DataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of health points for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dayOccurred.year, point.dayOccurred.month, point.dayOccurred.day);

    // Add the value to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + point.value;
    } else {
      dailySums[date] = point.value;
    }
  }

  // Calculate the total sum of health points
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
}

// Use this for when we may measure the same thing multiple times in a day
double getTrendHealthAverage(List<DataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Get latest point per day and calculate average
  final latestPoints = getLatestPointPerDay(data);
  final totalSum = latestPoints.fold(0.0, (sum, point) => sum + point.value);
  return totalSum / latestPoints.length;
}

double getHealthTotal(List<DataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.value,
  );
}

double getWorkoutMinutesTotal(List<DataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.dateTo.difference(element.dateFrom).inMinutes,
  );
}

double getWorkoutMinutesAverage(List<DataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of workout minutes for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);

    // Calculate the workout minutes for the current point
    double workoutMinutes = point.dateTo.difference(point.dateFrom).inMinutes.toDouble();

    // Add the workout minutes to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + workoutMinutes;
    } else {
      dailySums[date] = workoutMinutes;
    }
  }

  // Calculate the total sum of workout minutes
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
}

double getWorkoutEnergyBurned(List<HealthDataPoint> data) {
  return data.fold(
    0.0,
    (previousValue, element) =>
        previousValue + element.workoutSummary!.totalEnergyBurned,
  );
}

double getWorkoutEnergyBurnedAverage(List<HealthDataPoint> data) {
  if (data.isEmpty) return 0.0;

  // Create a map to store the sum of workout energy burned for each day
  Map<DateTime, double> dailySums = {};

  for (var point in data) {
    // Extract the date part from dateFrom
    DateTime date = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);

    // Add the workout energy burned to the corresponding day in the map
    if (dailySums.containsKey(date)) {
      dailySums[date] = dailySums[date]! + point.workoutSummary!.totalEnergyBurned;
    } else {
      dailySums[date] = point.workoutSummary!.totalEnergyBurned.toDouble();
    }
  }

  // Calculate the total sum of workout energy burned
  double totalSum = dailySums.values.reduce((a, b) => a + b);

  // Calculate the average by dividing the total sum by the number of unique days
  return totalSum / dailySums.length;
}

// Extract strength training minutes
List<HealthDataPoint> extractStrengthTrainingMinutes(List<HealthDataPoint> dataPoints) {
  return dataPoints
      .where((point) =>
          strengthTrainingTypes.contains(point.workoutSummary?.workoutType))
      .toList();
}

// Extract cardio minutes
List<HealthDataPoint> extractCardioMinutes(List<HealthDataPoint> dataPoints) {
  return dataPoints
      .where((point) =>
          !strengthTrainingTypes.contains(point.workoutSummary?.workoutType))
      .toList();
}

List<HealthDataPoint> removeOverlappingData(List<HealthDataPoint> points) {
  if (points.isEmpty) return points;

  // Group points by type to handle each type separately
  Map<HealthDataType, List<HealthDataPoint>> pointsByType = {};
  for (var point in points) {
    if (!pointsByType.containsKey(point.type)) {
      pointsByType[point.type] = [];
    }
    pointsByType[point.type]!.add(point);
  }

  List<HealthDataPoint> result = [];

  // Process each type separately
  for (var type in pointsByType.keys) {
    var typePoints = pointsByType[type]!;

    // Get unique sources for this type
    Set<String> sources = typePoints.map((p) => p.sourceName).toSet();

    // If only one source, add all points for this type
    if (sources.length <= 1) {
      result.addAll(typePoints);
      continue;
    }

    // Group points by source
    Map<String, List<HealthDataPoint>> pointsBySource = {};
    for (var point in typePoints) {
      if (!pointsBySource.containsKey(point.sourceName)) {
        pointsBySource[point.sourceName] = [];
      }
      pointsBySource[point.sourceName]!.add(point);
    }

    // Count points per source
    Map<String, int> sourceCount = {};
    for (var source in sources) {
      sourceCount[source] = pointsBySource[source]!.length;
    }

    // Sort sources by count
    final sortedSources = sourceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Create priority map
    Map<String, int> sourcePriority = {};
    for (var i = 0; i < sortedSources.length; i++) {
      sourcePriority[sortedSources[i].key] = i;
    }

    // Process each source's points separately
    for (var source in sources) {
      var sourcePoints = pointsBySource[source]!;
      
      // For each point from this source, check if it overlaps with higher priority sources
      for (var point in sourcePoints) {
        bool hasOverlap = false;
        
        // Check against points from higher priority sources
        for (var otherSource in sources) {
          if (sourcePriority[otherSource]! < sourcePriority[source]!) {
            for (var otherPoint in pointsBySource[otherSource]!) {
              if (point.dateFrom.isBefore(otherPoint.dateTo) && 
                  point.dateTo.isAfter(otherPoint.dateFrom)) {
                hasOverlap = true;
                break;
              }
            }
            if (hasOverlap) break;
          }
        }
        
        if (!hasOverlap) {
          result.add(point);
        }
      }
    }
  }

  return result;
}

List<DataPoint> mergeDataPoints(Map<HealthDataType, List<DataPoint>> points) {
  // Flatten all points into a single list
  List<DataPoint> allPoints = points.values.expand((x) => x).toList();
  
  // Sort points by start date
  allPoints.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

  List<DataPoint> result = [];
  
  if (allPoints.isEmpty) {
    return result;
  }

  DataPoint current = allPoints[0];
  double combinedValue = current.value;
  
  for (int i = 1; i < allPoints.length; i++) {
    DataPoint next = allPoints[i];
    
    // Check if points overlap
    if (current.dateTo.isAfter(next.dateFrom)) {
      // Combine values and extend end date if needed
      combinedValue += next.value;
      if (next.dateTo.isAfter(current.dateTo)) {
        current = DataPoint(
          value: combinedValue,
          dateFrom: current.dateFrom,
          dateTo: next.dateTo,
          dayOccurred: current.dayOccurred,
        );
      }
    } else {
      // No overlap - add current point and start new one
      result.add(DataPoint(
        value: combinedValue,
        dateFrom: current.dateFrom,
        dateTo: current.dateTo,
        dayOccurred: current.dayOccurred,
      ));
      current = next;
      combinedValue = next.value;
    }
  }
  
  // Add final point
  result.add(DataPoint(
    value: combinedValue,
    dateFrom: current.dateFrom,
    dateTo: current.dateTo,
    dayOccurred: current.dayOccurred,
  ));

  return result;
}

List<DataPoint> getLatestPointPerDay(List<DataPoint> data) {
  // Create a map using dayOccurred as the key
  Map<DateTime, DataPoint> latestPointPerDay = {};
  
  for (var point in data) {
    // Normalize the date to remove time component
    DateTime normalizedDate = DateTime(
      point.dayOccurred.year,
      point.dayOccurred.month,
      point.dayOccurred.day,
    );
    
    // Only update if this point is more recent than the existing one
    if (!latestPointPerDay.containsKey(normalizedDate) ||
        point.dateFrom.isAfter(latestPointPerDay[normalizedDate]!.dateFrom)) {
      latestPointPerDay[normalizedDate] = point;
    }
  }
  
  // Convert map values back to list
  return latestPointPerDay.values.toList();
}

List<DataPoint> getLatestPointPerMonth(List<DataPoint> data) {
  // Group data by month
  Map<DateTime, List<DataPoint>> dataByMonth = {};
  for (var point in data) {
    var monthKey = DateTime(point.dayOccurred.year, point.dayOccurred.month);
    if (!dataByMonth.containsKey(monthKey)) {
      dataByMonth[monthKey] = [];
    }
    dataByMonth[monthKey]!.add(point);
  }
  
  // Get latest point for each month
  Map<DateTime, DataPoint> latestPointPerMonth = {};
  for (var entry in dataByMonth.entries) {
    var latestPoint = entry.value.reduce((a, b) => 
      a.dateFrom.isAfter(b.dateFrom) ? a : b);
    latestPointPerMonth[entry.key] = latestPoint;
  }
  
  return latestPointPerMonth.values.toList();
}

// Get daily data for a list of data points
Map<DateTime, double> getDailyData(List<DataPoint> data) {
  // Group data by dayOccurred
  Map<DateTime, List<DataPoint>> dataByDay = {};
  for (var point in data) {
    dataByDay[point.dayOccurred] = [point];
  }
  return dataByDay.map((key, value) => MapEntry(key, value.fold(0.0, (sum, point) => sum + point.value)));
}

Future<List<HealthEntity>> initializeWidgets(List<HealthItem> healthItems, HealthFetcherService healthFetcherService) async {
  List<HealthEntity> entities = healthItems.map((healthItem) {
    var entity = healthItem.widgetFactory(
      healthItem,
      2,
      healthFetcherService,
    );
    return entity;
  }).toList();

  for (var entity in entities) {
    await entity.initialize();
  }

  return entities;
}

Future<void> setDataPerWidgetWithTimeframe(List<HealthEntity> entities, TimeFrame timeframe, int offset) async {
  for (var widget in entities) {
    widget.updateQuery(timeframe, offset);
    widget.isLoading = true;
  }

  for (var widget in entities) {
    await widget.updateData();
  }

  for (var widget in entities) {
    widget.isLoading = false;
  }
}
