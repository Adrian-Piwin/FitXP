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
import 'package:flutter/foundation.dart';
import 'dart:async';

class XpService extends ChangeNotifier {
  static const String _xpBoxName = 'monthly_xp_cache';
  static const String _medalsBoxName = 'earned_medals_cache';
  late final HealthFetcherService _healthFetcherService;
  final DBService _dbService = DBService();
  late Box<List<dynamic>> _xpBox;
  late Box<List<String>> _medalsBox;
  bool _isInitialized = false;
  bool _isInitializing = false;
  List<EntityXP> xpEntities = []; // XP entities for the current month
  int _offset = 0;
  final _initCompleter = Completer<void>();

  // Private constructor
  XpService._();

  // Static instance
  static XpService? _instance;

  // Getters
  int get offset => _offset;
  void setOffset(int newOffset) {
    _offset = newOffset;
  }

  bool get isInitialized => _isInitialized;
  Future<void> waitForInitialization() => _initCompleter.future;

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
    }
  }

  Future<void> initialize() async {
    if (_isInitializing) {
      return await waitForInitialization();
    }
    if (_isInitialized) {
      return;
    }

    _isInitializing = true;
    try {
      _healthFetcherService = await HealthFetcherService.getInstance();
      await _fetchMonthData();
      await _syncEarnedMedals();
      _isInitialized = true;
      _initCompleter.complete();
      notifyListeners();
    } catch (e) {
      print('Error initializing XP Service: $e');
      _initCompleter.completeError(e);
      rethrow;
    } finally {
      _isInitializing = false;
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
    _ => Rank.diamond.displayName,
  };

  Rank get currentRank => switch (rank) {
    < 1 => Rank.bronze,
    < 2 => Rank.silver,
    < 3 => Rank.gold,
    _ => Rank.diamond,
  };

  Future<void> _fetchMonthData() async {
    final monthKey = _getMonthKey(DateTime.now().subtract(Duration(days: _offset * 30)));
    
    try {
      // Try to get cached data first
      if (_xpBox.containsKey(monthKey)) {
        final List<dynamic> monthlyData = _xpBox.get(monthKey)!;
        xpEntities = monthlyData.map((data) {
          final Map<String, dynamic> entityData = Map<String, dynamic>.from(data);
          return EntityXP(
            entityName: entityData['type'].toString(),
            value: (entityData['value'] as num).toDouble(),
            rawTotal: (entityData['rawTotal'] as num).toDouble(),
            rawAverage: (entityData['rawAverage'] as num).toDouble(),
            date: DateTime.parse(entityData['date'].toString()),
          );
        }).toList();
      } else {
        // Fetch and cache new data
        xpEntities = await _getXPForValue(valueEntities, TimeFrame.month, _offset);
        
        final List<Map<String, dynamic>> serializedXP = xpEntities.map((xp) => {
          'type': xp.entityName,
          'value': xp.value,
          'rawTotal': xp.rawTotal,
          'rawAverage': xp.rawAverage,
          'date': xp.date.toIso8601String(),
        }).toList();
        
        await _xpBox.put(monthKey, serializedXP);
      }

      // Calculate rank XP from current month's data
      _rankXP = await getRankXP(xpEntities);
      notifyListeners();
    } catch (e) {
      print('Error fetching month data: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    try {
      await _xpBox.clear();
      await _medalsBox.clear();
      xpEntities.clear();
      _rankXP = 0;
    } catch (e) {
      print('Error clearing XP cache: $e');
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    if (_isInitialized) {
      if (_xpBox.isOpen) await _xpBox.close();
      if (_medalsBox.isOpen) await _medalsBox.close();
      _isInitialized = false;
    }
  }

  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _syncEarnedMedals() async {
    final userId = _dbService.userId;
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
    final userId = _dbService.userId;
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
    final monthKey = _getMonthKey(DateTime.now().subtract(Duration(days: _offset * 30)));
    final earnedMedalIds = _medalsBox.get('earned', defaultValue: <String>[])!;

    // Get monthly totals and averages from current xpEntities
    final Map<HealthItemType, double> monthlyTotals = {};
    final Map<HealthItemType, double> monthlyAverages = {};
    
    for (var entityXP in xpEntities) {
      final type = HealthItemType.values.firstWhere(
        (e) => e.toString() == entityXP.entityName
      );
      monthlyTotals[type] = entityXP.rawTotal;
      monthlyAverages[type] = entityXP.rawAverage;
    }

    List<Medal> allMedals = [
      ...MedalDefinitions.getMonthlyAverageMedals(monthKey, monthlyAverages),
      ...MedalDefinitions.getMonthlyTotalMedals(monthKey, monthlyTotals),
    ];

    // Check for newly earned medals
    for (var medal in allMedals) {
      if (medal.isEarned && !earnedMedalIds.contains(medal.id)) {
        _saveEarnedMedal(medal.id);
      }
    }

    // Get only earned medals
    List<Medal> earnedMedals = allMedals.where((medal) => medal.isEarned).toList();

    // Group medals by their base type (removing tier and month from ID)
    final Map<String, Medal> highestTierMedals = {};
    
    for (var medal in earnedMedals) {
      // Extract base medal ID (everything before the first underscore)
      String baseId = medal.id.split('_').first;
      
      // If we haven't seen this medal type yet, or if this medal has a higher tier
      if (!highestTierMedals.containsKey(baseId) || 
          medal.tier > highestTierMedals[baseId]!.tier) {
        highestTierMedals[baseId] = medal;
      }
    }

    // Return the list of highest tier medals, sorted by tier
    return highestTierMedals.values.toList()
      ..sort((a, b) => b.tier.compareTo(a.tier));
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

  Future<void> updateData() async {
    if (!_isInitialized) {
      await initialize();
      return;
    }

    try {
      await _fetchMonthData();
      await _syncEarnedMedals();
      notifyListeners();
    } catch (e) {
      print('Error updating XP data: $e');
      rethrow;
    }
  }
}
