import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthxp/constants/magic_numbers.constants.dart';
import 'package:healthxp/models/monthly_medal.model.dart';
import 'package:healthxp/services/xp_service.dart';

class InsightsController extends ChangeNotifier {
  late final XpService _xpService;
  bool _isLoading = false;
  bool _showLoading = false;
  bool _isInitializing = true;
  Timer? _loadingTimer;

  bool get isLoading => _isLoading;
  bool get showLoading => _showLoading;
  bool get isInitializing => _isInitializing;
  int get offset => _isInitializing ? 0 : _xpService.offset;
  List<Medal> get medals => _xpService.getEarnedMedals();
  String get rankName => _xpService.rankName;
  int get currentXP => _xpService.rankXpToNextRank;
  int get requiredXP => _xpService.rankXP;

  InsightsController() {
    _initialize();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _loadingTimer?.cancel();
      _loadingTimer = Timer(loadingDelay, () {
        _showLoading = true;
        notifyListeners();
      });
    } else {
      _loadingTimer?.cancel();
      _showLoading = false;
    }
    notifyListeners();
  }

  Future<void> _initialize() async {
    _isInitializing = true;
    notifyListeners();

    try {
      _xpService = await XpService.getInstance();
      await _xpService.initialize();
    } catch (e) {
      print('Error initializing InsightsController: $e');
    }

    _isInitializing = false;
    notifyListeners();
  }

  void updateOffset(int newOffset) async {
    if (_isInitializing) return;
    
    _setLoading(true);
    
    try {
      _xpService.setOffset(newOffset);
      await _xpService.updateData();
    } catch (e) {
      print('Error updating offset: $e');
    }
    
    _setLoading(false);
  }

  Future<void> refresh() async {
    if (_isInitializing) return;
    
    _setLoading(true);

    try {
      await _xpService.updateData();
    } catch (e) {
      print('Error refreshing insights: $e');
    }

    _setLoading(false);
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }
} 
