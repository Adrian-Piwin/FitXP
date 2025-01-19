import 'package:flutter/material.dart';

class SlidingTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool showing;
  final double slideDistance;

  const SlidingTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.showing,
    this.slideDistance = 300,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // When showing stats (showing = true), we want to slide from 0 to -slideDistance
        // When hiding stats (showing = false), we want to slide from -slideDistance to beyond
        final slideValue = -slideDistance * animation.value;

        return Opacity(
          opacity: 1 - animation.value,
          child: Transform.translate(
            offset: Offset(slideValue, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
} 
