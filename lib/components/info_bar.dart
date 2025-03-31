import 'package:flutter/material.dart';
import 'package:healthcore/components/animated_value_controller.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class InfoBar extends StatefulWidget {
  final String title;
  final Function(double value) formatValue;
  final double value;
  final String goal;
  final double percent;
  final Color color;
  final Color textColor;
  final bool animateChanges;
  final String? unit;

  const InfoBar({
    super.key,
    required this.title,
    required this.formatValue,
    required this.value,
    required this.goal,
    required this.percent,
    required this.color,
    required this.textColor,
    this.animateChanges = false,
    this.unit,
  });

  @override
  State<InfoBar> createState() => _InfoBarState();
}

class _InfoBarState extends State<InfoBar> {
  late final AnimatedValueController _animationController;
  late String _displayValue;
  bool _isFirstUpdate = true;

  @override
  void initState() {
    super.initState();
    _displayValue = "";
    _animationController = AnimatedValueController();
    _animationController.addListener(_onAnimationUpdate);
    _updateAnimationValues(isInitial: true);
  }

  @override
  void didUpdateWidget(InfoBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.percent != oldWidget.percent) {
      _updateAnimationValues(isInitial: false);
    }
  }

  void _updateAnimationValues({required bool isInitial}) {
    final numericValue = widget.value;
    
    if (isInitial || !widget.animateChanges) {
      _animationController.setInitialValues(
        value: numericValue,
        percent: widget.percent,
      );
      _displayValue = widget.formatValue(numericValue);
    } else {
      _animationController.updateValues(
        value: numericValue,
        percent: widget.percent,
      );
    }
  }

  void _onAnimationUpdate() {
    if (!mounted) return;
    setState(() {
      if (widget.animateChanges && !_isFirstUpdate) {
        final animatedValue = _animationController.currentAnimatedValue;
        _displayValue = widget.formatValue(animatedValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // After first build, allow animations
    _isFirstUpdate = false;
    
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: FontSizes.xlarge,
                  fontWeight: FontWeight.w700
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _displayValue,
                      style: const TextStyle(
                        fontSize: FontSizes.large,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    TextSpan(
                      text: '/${widget.goal}${widget.unit ?? ''}',
                      style: TextStyle(
                        fontSize: FontSizes.large,
                        color: widget.textColor,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GapSizes.medium),
          RepaintBoundary(
            child: LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: PercentIndicatorSizes.lineHeightLarge,
              percent: widget.animateChanges 
                  ? _animationController.currentAnimatedPercent.clamp(0.0, 1.0)
                  : widget.percent.clamp(0.0, 1.0),
              backgroundColor: widget.color.withOpacity(0.2),
              progressColor: widget.color,
              barRadius: const Radius.circular(PercentIndicatorSizes.barRadius),
              animation: false,
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    super.dispose();
  }
}
