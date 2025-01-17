import 'package:flutter/material.dart';
import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/utility/health.utility.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthxp/models/entity_xp.model.dart';

class XpService {
  final HealthFetcherService _healthFetcherService = HealthFetcherService();

  late Box _xpBox;
  static const String _boxName = 'xp_cache';
  static const String _allTimeXPKey = 'all_time_xp';
  static const String _rankXPKey = 'rank_xp';
  static const String _allTimeXPLastFetchedKey = 'all_time_xp_last_fetched';
  static const String _rankXPLastFetchedKey = 'rank_xp_last_fetched';

  static final DateTimeRange _defaultDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 365)),
    end: DateTime.now(),
  );

  static List<HealthItem> goalEntities = [
    HealthItemDefinitions.sleepDuration,
    HealthItemDefinitions.netCalories,
    HealthItemDefinitions.proteinIntake,
  ];

  List<HealthItem> valueEntities = [
    HealthItemDefinitions.exerciseTime,
    HealthItemDefinitions.steps,
    HealthItemDefinitions.proteinIntake,
  ];

  int? _xp = 0;
  int? _rankXP = 0;

  int get level => (_xp! / levelUpXPAmt).floor() + 1;
  int get xp => _xp!;
  int get xpToNextLevel => _xp! - ((level-1) * levelUpXPAmt);

  int get rank => (_rankXP! / rankUpXPAmt).floor();
  int get rankXP => _rankXP!;
  int get rankXpToNextRank => _rankXP! - (rank * rankUpXPAmt);
  String get rankName => switch (rank) {
    < 1 => 'Bronze',
    < 2 => 'Silver',
    < 3 => 'Gold',
    < 4 => 'Platinum',
    < 5 => 'Diamond',
    _ => 'Legend',
  };

  Future<void> initialize() async {
    await Hive.initFlutter();
    _xpBox = await Hive.openBox(_boxName);
    
    final cachedAllTimeXP = _xpBox.get(_allTimeXPKey);
    final cachedRankXP = _xpBox.get(_rankXPKey);
    // final lastAllTimeFetched = _xpBox.get(_allTimeXPLastFetchedKey);
    // final lastRankFetched = _xpBox.get(_rankXPLastFetchedKey);

    // final now = DateTime.now();
    const cacheValid = true;

    if (cachedAllTimeXP != null && cachedRankXP != null && cacheValid) {
      _xp = cachedAllTimeXP;
      _rankXP = cachedRankXP;
    } else {
      var allXPs = await _getXPForValue(valueEntities, TimeFrame.year);
      _xp = await getAllTimeXP(allXPs);
      _rankXP = await getRankXP(allXPs);
    }
  }

  Future<void> reset() async {
    await _xpBox.clear();
    var allXPs = await _getXPForValue(valueEntities, TimeFrame.year);
    _xp = await getAllTimeXP(allXPs);
    _rankXP = await getRankXP(allXPs);
  }

  Future<int> getAllTimeXP(List<EntityXP> entityXPs) async {
    final totalXP = entityXPs.fold<double>(0, (sum, xp) => sum + xp.value).toInt();
    
    // Cache the results
    await _xpBox.put(_allTimeXPKey, totalXP);
    await _xpBox.put(_allTimeXPLastFetchedKey, DateTime.now().toIso8601String());
    
    return totalXP;
  }

  Future<int> getRankXP(List<EntityXP> entityXPs) async {
    var now = DateTime.now();
    var oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    final totalXP = entityXPs
        .where((xp) => xp.date.isAfter(oneMonthAgo))
        .fold<double>(0, (sum, xp) => sum + xp.value)
        .toInt();
    
    // Cache the results
    await _xpBox.put(_rankXPKey, totalXP);
    await _xpBox.put(_rankXPLastFetchedKey, DateTime.now().toIso8601String());
    
    return totalXP;
  }

  Future<List<EntityXP>> _getXPForValue(List<HealthItem> healthItems, TimeFrame timeframe) async {
    List<HealthEntity> entities = await initializeWidgets(healthItems);
    await setDataPerWidgetWithDateRange(_healthFetcherService, entities, _defaultDateRange);

    List<EntityXP> entityXPs = [];
    for (var entity in entities) {
      entityXPs.add(EntityXP(
          entity: entity,
          value: xpMapping[entity.healthItem.xpType]! * entity.total,
          date: DateTime.now(),
        ));
    }
    return entityXPs;
  }

  Future<List<EntityXP>> _getXPForReachedGoal(List<HealthItem> healthItems, TimeFrame timeframe) async {
    List<HealthEntity> entities = await initializeWidgets(healthItems);
    await setDataPerWidgetWithDateRange(_healthFetcherService, entities, _defaultDateRange);

    List<EntityXP> entityXPs = [];
    for (var entity in entities) {
      Map<DateTime, double> dailyData = getDailyData(entity.getCombinedData);
      for (MapEntry<DateTime, double> data in dailyData.entries) {
        if (data.value.abs() >= entity.goal.abs()) {
          entityXPs.add(EntityXP(
            entity: entity,
            value: xpGoalMapping[entity.healthItem.xpType]!,
            date: data.key,
          ));
        }
      }
    }

    return entityXPs;
  }
}
