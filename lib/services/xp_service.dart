import 'package:healthxp/constants/health_item_definitions.constants.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/health_item.model.dart';
import 'package:healthxp/models/monthly_medal.model.dart';
import 'package:healthxp/services/health_fetcher_service.dart';
import 'package:healthxp/utility/health.utility.dart';
import 'package:healthxp/models/entity_xp.model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthxp/constants/medal_definitions.constants.dart';
import 'package:healthxp/services/db_service.dart';
import 'package:healthxp/enums/rank.enum.dart';

class XpService {
  static const String _xpBoxName = 'monthly_xp_cache';
  static const String _medalsBoxName = 'earned_medals_cache';
  final HealthFetcherService _healthFetcherService = HealthFetcherService();
  final DBService _dbService = DBService();
  late Box<List<dynamic>> _xpBox;
  late Box<List<String>> _medalsBox;
  bool _isInitialized = false;
  List<EntityXP>? _cachedAllTimeXP;
  List<EntityXP> xpEntities = []; // Xp entities for the current month

  // Private constructor
  XpService._();

  // Static instance
  static XpService? _instance;

  // Factory constructor
  static Future<XpService> getInstance() async {
    if (_instance == null) {
      _instance = XpService._();
      await _instance!._initHive();
    }
    return _instance!;
  }

  Future<void> _initHive() async {
    if (!_isInitialized) {
      _xpBox = await Hive.openBox<List>(_xpBoxName);
      _medalsBox = await Hive.openBox<List<String>>(_medalsBoxName);
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initHive();
    }
  }

  List<HealthItem> valueEntities = [
    HealthItemDefinitions.workoutTime,
    HealthItemDefinitions.steps,
    HealthItemDefinitions.proteinIntake,
    HealthItemDefinitions.sleepDuration,
  ];

  int _rankXP = 0;
  int get rank => (_rankXP / rankUpXPAmt).floor();
  int get rankXP => _rankXP;
  int get rankXpToNextRank => _rankXP - (rank * rankUpXPAmt);
  String get rankName => switch (rank) {
    < 1 => Rank.bronze.displayName,
    < 2 => Rank.silver.displayName,
    < 3 => Rank.gold.displayName,
    < 4 => Rank.platinum.displayName,
    _ => Rank.diamond.displayName,
  };

  Rank get currentRank => switch (rank) {
    < 1 => Rank.bronze,
    < 2 => Rank.silver,
    < 3 => Rank.gold,
    < 4 => Rank.platinum,
    _ => Rank.diamond,
  };

  Future<void> initialize() async {
    try {
      await _ensureInitialized();
      await _healthFetcherService.initialize();
      xpEntities = await _getXPForValue(valueEntities, TimeFrame.month, 0);
      
      await _cacheLastMonth();
      await _syncEarnedMedals();
      
      _rankXP = await getRankXP(getAllTimeXP());
    } catch (e) {
      print('Error initializing XP Service: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      await _xpBox.clear();
      await _medalsBox.clear();
      xpEntities.clear();
      _rankXP = 0;
    } catch (e) {
      print('Error clearing XP cache: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      if (_xpBox.isOpen) await _xpBox.close();
      if (_medalsBox.isOpen) await _medalsBox.close();
      _isInitialized = false;
    }
  }

  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _cacheLastMonth() async {
    final String monthKey = _getMonthKey(DateTime.now().subtract(const Duration(days: 30)));
    
    // Check if last month is already cached
    if (!_xpBox.containsKey(monthKey)) {
      List<EntityXP> xpEntities = await _getXPForValue(valueEntities, TimeFrame.month, -1);

      final List<Map<String, dynamic>> serializedXP = xpEntities.map((xp) => {
        'type': xp.entityName,
        'rawTotal': xp.rawTotal,
        'rawAverage': xp.rawAverage,
        'date': xp.date.toIso8601String(),
      }).toList();
      
      await _xpBox.put(monthKey, serializedXP);
    }
  }

  List<EntityXP> getAllTimeXP() {
    if (_cachedAllTimeXP != null) {
      return _cachedAllTimeXP!;
    }

    List<EntityXP> allXP = [...xpEntities];  // Current month's XP
    
    // Add cached months' XP
    for (var monthlyData in _xpBox.values) {
      try {
        // Fix type casting
        final List<dynamic> monthlyXP = monthlyData;
        
        for (var data in monthlyXP) {
          // Ensure proper type casting of Map
          final Map<String, dynamic> entityData = Map<String, dynamic>.from(data);
          
          // Safely handle potential null values
          final rawTotal = entityData['rawTotal'];
          final rawAverage = entityData['rawAverage'];
          final type = entityData['type'];
          final date = entityData['date'];
          
          // Skip invalid entries
          if (rawTotal == null || rawAverage == null || type == null || date == null) {
            continue;
          }
          
          allXP.add(EntityXP(
            entityName: type.toString(),
            value: (rawTotal as num).toDouble(),
            rawTotal: (rawTotal).toDouble(),
            rawAverage: (rawAverage as num).toDouble(),
            date: DateTime.parse(date.toString()),
          ));
        }
      } catch (e) {
        print('Error processing cached XP data: $e');
        continue;  // Skip problematic entries
      }
    }
    
    _cachedAllTimeXP = allXP;
    return allXP;
  }

  Future<int> getRankXP(List<EntityXP> entityXPs) async {
    return entityXPs
        .fold<double>(0, (sum, xp) => sum + xp.value)
        .toInt();
  }

  Future<List<EntityXP>> _getXPForValue(List<HealthItem> healthItems, TimeFrame timeframe, int offset) async {
    List<HealthEntity> entities = await initializeWidgets(healthItems, _healthFetcherService);
    await setDataPerWidgetWithTimeframe(entities, timeframe, offset);

    List<EntityXP> entityXPs = [];
    for (var entity in entities) {
      final xpMultiplier = xpMapping[entity.healthItem.itemType] ?? 1.0;
      entityXPs.add(EntityXP(
          entityName: entity.healthItem.itemType.toString(),
          value: xpMultiplier * entity.total,
          rawTotal: entity.total,
          rawAverage: entity.average,
          date: entity.queryDateRange!.start,
        ));
    }
    return entityXPs;
  }

  Map<HealthItemType, double> getMonthlyTotals() {
    Map<HealthItemType, double> totals = {};
    List<EntityXP> allXP = getAllTimeXP();
    
    // Group and sum by HealthItemType
    for (var entityXP in allXP) {
      final type = HealthItemType.values.firstWhere((e) => e.toString() == entityXP.entityName);
      totals[type] = (totals[type] ?? 0) + entityXP.rawTotal;
    }
    
    return totals;
  }

  Future<void> _syncEarnedMedals() async {
    final userId = _dbService.getUserId();
    if (userId == null) return;

    try {
      // Create the document if it doesn't exist
      await _dbService.createDocument(
        collectionPath: 'users',
        documentId: userId,
        data: {
          'medals': {
            'earned': {
              'medalIds': [],
            }
          }
        },
      );

      // Then read the document
      final doc = await _dbService.readDocument(
        collectionPath: 'users',
        documentId: userId,
      );

      final medalData = doc.data()?['medals']?['earned']?['medalIds'] as List<dynamic>? ?? [];
      final earnedMedalIds = medalData.map((e) => e.toString()).toList();
      await _medalsBox.put('earned', earnedMedalIds);
    } catch (e) {
      print('Error syncing medals: $e');
      // Initialize with empty list if there's an error
      await _medalsBox.put('earned', <String>[]);
    }
  }

  Future<void> _saveEarnedMedal(String medalId) async {
    final userId = _dbService.getUserId();
    if (userId == null) return;

    try {
      final earnedMedalIds = _medalsBox.get('earned', defaultValue: <String>[])!;
      if (!earnedMedalIds.contains(medalId)) {
        earnedMedalIds.add(medalId);
        await _medalsBox.put('earned', earnedMedalIds);
        
        // Save to Firebase with proper document structure
        await _dbService.updateDocument(
          collectionPath: 'users',
          documentId: userId,
          data: {
            'medals': {
              'earned': {
                'medalIds': earnedMedalIds,
              }
            }
          },
        );
      }
    } catch (e) {
      print('Error saving medal: $e');
    }
  }

  List<Medal> getEarnedMedals() {
    final allTimeTotals = getAllTimeTotals();
    final monthlyTotals = getMonthlyTotals();
    final monthlyAverages = getMonthlyAverages();
    final earnedMedalIds = _medalsBox.get('earned', defaultValue: <String>[])!;

    List<Medal> allMedals = [
      ...MedalDefinitions.getAllTimeMedals(allTimeTotals),
      ...getAllMonthlyMedals(monthlyTotals, monthlyAverages),
    ];

    // Check for newly earned medals
    for (var medal in allMedals) {
      if (medal.isEarned && !earnedMedalIds.contains(medal.id)) {
        _saveEarnedMedal(medal.id);
      }
    }

    return allMedals
        .where((medal) => earnedMedalIds.contains(medal.id))
        .toList()
        ..sort((a, b) => b.tier.compareTo(a.tier));
  }

  List<Medal> getAllMonthlyMedals(
    Map<HealthItemType, double> monthlyTotals,
    Map<HealthItemType, double> monthlyAverages,
  ) {
    List<Medal> medals = [];
    
    // Get all month keys from cached data
    final monthKeys = _xpBox.keys.toList();
    
    for (String monthKey in monthKeys) {
      medals.addAll([
        ...MedalDefinitions.getMonthlyAverageMedals(monthKey, monthlyAverages),
        ...MedalDefinitions.getMonthlyTotalMedals(monthKey, monthlyTotals),
      ]);
    }
    
    return medals;
  }

  Map<HealthItemType, double> getAllTimeTotals() {
    Map<HealthItemType, double> totals = {};
    List<EntityXP> allXP = getAllTimeXP();
    
    // Group and sum by HealthItemType
    for (var entityXP in allXP) {
      final type = HealthItemType.values.firstWhere(
        (e) => e.toString() == entityXP.entityName
      );
      totals[type] = (totals[type] ?? 0) + entityXP.rawTotal;
    }
    
    return totals;
  }

  Map<HealthItemType, double> getMonthlyAverages() {
    Map<HealthItemType, double> averages = {};
    Map<HealthItemType, int> monthCounts = {};
    
    // Process current month's data
    for (var entityXP in xpEntities) {
      final type = HealthItemType.values.firstWhere(
        (e) => e.toString() == entityXP.entityName
      );
      averages[type] = (averages[type] ?? 0) + entityXP.rawAverage;
      monthCounts[type] = (monthCounts[type] ?? 0) + 1;
    }
    
    // Process cached months' data
    for (var monthlyData in _xpBox.values) {
      try {
        // Fix type casting
        final List<dynamic> monthlyXP = monthlyData;
        
        for (var data in monthlyXP) {
          // Ensure proper type casting of Map
          final Map<String, dynamic> entityData = Map<String, dynamic>.from(data);
          
          // Safely handle potential null values
          final rawAverage = entityData['rawAverage'];
          final type = entityData['type'];
          
          // Skip invalid entries
          if (rawAverage == null || type == null) {
            continue;
          }

          final healthType = HealthItemType.values.firstWhere(
            (e) => e.toString() == type.toString()
          );
          
          averages[healthType] = (averages[healthType] ?? 0) + (rawAverage as num).toDouble();
          monthCounts[healthType] = (monthCounts[healthType] ?? 0) + 1;
        }
      } catch (e) {
        print('Error processing monthly averages: $e');
        continue;  // Skip problematic entries
      }
    }
    
    // Calculate final averages
    for (var type in averages.keys) {
      averages[type] = averages[type]! / monthCounts[type]!;
    }
    
    return averages;
  }
}
