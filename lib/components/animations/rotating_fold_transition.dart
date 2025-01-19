import 'package:flutter/material.dart';

enum FoldDirection { left, right }

class RotatingFoldTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final FoldDirection direction;
  final bool showing;

  const RotatingFoldTransition({
    super.key,
    required this.child,
    required this.animation,
    required this.direction,
    required this.showing,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // For left fold: 0 -> 90 degrees when hiding (folding outward), 90 -> 0 degrees when showing
        // For right fold: 90 -> 0 degrees when showing, 0 -> 90 degrees when hiding
        final rotateValue = direction == FoldDirection.left
            ? 90 * animation.value  // Rotate outward from left hinge
            : 90 * (1 - animation.value); // Right fold remains the same

        // When showing, we want opacity 1, when hiding we want opacity 0
        final opacity = direction == FoldDirection.left
            ? 1 - animation.value // Fade out for left fold
            : animation.value; // Fade in for right fold

        return Opacity(
          opacity: opacity,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(rotateValue * (3.14159 / 180)),
            alignment: direction == FoldDirection.left 
                ? Alignment.centerLeft  // Hinge on left side
                : Alignment.centerRight, // Hinge on right side
            child: child,
          ),
        );
      },
      child: child,
    );
  }
} 
