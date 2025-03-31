import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedValueController extends ChangeNotifier {
  late AnimationController _controller;
  late Animation<double> _valueAnimation;
  late Animation<double> _percentAnimation;

  double _currentValue = 0;
  double _currentPercent = 0;
  double _targetValue = 0;
  double _targetPercent = 0;

  double get currentAnimatedValue => _valueAnimation.value;
  double get currentAnimatedPercent => _percentAnimation.value;

  AnimatedValueController() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: _DummyTickerProvider(),
    )..addListener(notifyListeners);
  }

  void updateValues({required double value, required double percent}) {
    _targetValue = value;
    _targetPercent = percent;

    _valueAnimation = Tween<double>(
      begin: _currentValue,
      end: _targetValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _percentAnimation = Tween<double>(
      begin: _currentPercent,
      end: _targetPercent,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _currentValue = value;
    _currentPercent = percent;

    _controller.forward(from: 0);
  }

  void setInitialValues({required double value, required double percent}) {
    _currentValue = value;
    _currentPercent = percent;
    _targetValue = value;
    _targetPercent = percent;

    _valueAnimation = AlwaysStoppedAnimation(value);
    _percentAnimation = AlwaysStoppedAnimation(percent);
    
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Helper class to provide vsync for the animation controller
class _DummyTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
} 
