import 'package:flutter/material.dart';
import 'package:healthxp/components/animations/rotating_fold_transition.dart';
import 'package:healthxp/components/animations/sliding_transition.dart';
import 'package:intl/intl.dart';
import './labeled_value_display.dart';
import './rank_display.dart';

class CharacterStatsDisplay extends StatefulWidget {
  final String level;
  final String rank;
  final bool showStats;

  const CharacterStatsDisplay({
    super.key,
    required this.level,
    required this.rank,
    required this.showStats,
  });

  @override
  State<CharacterStatsDisplay> createState() => _CharacterStatsDisplayState();
}

class _CharacterStatsDisplayState extends State<CharacterStatsDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _shouldShow = false; // Track visibility state separately

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shouldShow = widget.showStats;
    _controller.value = widget.showStats ? 0.0 : 1.0;
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        setState(() {
          _shouldShow = widget.showStats;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CharacterStatsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showStats != widget.showStats) {
      setState(() {
        if (!widget.showStats) _shouldShow = true; // Keep showing while animating out
      });
      
      if (widget.showStats) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);
    final day = DateFormat('d').format(now);

    return Positioned(
      left: 0,
      top: 20,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (_shouldShow || widget.showStats)
                  RotatingFoldTransition(
                    animation: _animation,
                    direction: FoldDirection.left,
                    showing: widget.showStats,
                    child: LabeledValueDisplay(
                      label: 'LEVEL',
                      value: widget.level,
                    ),
                  ),
                if (!_shouldShow || !widget.showStats)
                  RotatingFoldTransition(
                    animation: _animation,
                    direction: FoldDirection.right,
                    showing: !widget.showStats,
                    child: LabeledValueDisplay(
                      label: monthYear,
                      value: day,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_shouldShow || widget.showStats)
              SlidingTransition(
                animation: _animation,
                showing: widget.showStats,
                child: RankDisplay(rank: widget.rank),
              ),
          ],
        ),
      ),
    );
  }
} 
