import 'package:flutter/material.dart';
import 'package:healthxp/constants/animations.constants.dart';

enum SlideDirection {
  left,
  right,
  up,
  down
}

class FadeTransitionSwitcher extends StatefulWidget {
  final Widget child;
  final bool showChild;
  final Duration duration;
  final Duration fadeInDelay;
  final Duration fadeOutDelay;
  final double fadeInSlideDistance;
  final double fadeOutSlideDistance;
  final SlideDirection fadeInSlideDirection;
  final SlideDirection fadeOutSlideDirection;
  
  const FadeTransitionSwitcher({
    super.key,
    required this.child,
    required this.showChild,
    this.duration = const Duration(milliseconds: FadeTransitionSwitcherAnimations.duration),
    this.fadeInDelay = Duration.zero,
    this.fadeOutDelay = Duration.zero,
    this.fadeInSlideDistance = 0,
    this.fadeOutSlideDistance = 0,
    this.fadeInSlideDirection = SlideDirection.right,
    this.fadeOutSlideDirection = SlideDirection.left,
  });

  @override
  State<FadeTransitionSwitcher> createState() => _FadeTransitionSwitcherState();
}

class _FadeTransitionSwitcherState extends State<FadeTransitionSwitcher> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _setupAnimations();
    if (widget.showChild) {
      _controller.value = 1.0;
    }
  }

  void _setupAnimations() {
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    final Offset beginOffset = _getOffsetForDirection(
      widget.showChild ? widget.fadeInSlideDirection : widget.fadeOutSlideDirection,
      widget.showChild ? widget.fadeInSlideDistance : widget.fadeOutSlideDistance,
    );
    final Offset endOffset = widget.showChild ? Offset.zero : _getOffsetForDirection(
      widget.fadeOutSlideDirection,
      widget.fadeOutSlideDistance,
    );

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  Offset _getOffsetForDirection(SlideDirection direction, double distance) {
    switch (direction) {
      case SlideDirection.left:
        return Offset(-distance, 0);
      case SlideDirection.right:
        return Offset(distance, 0);
      case SlideDirection.up:
        return Offset(0, -distance);
      case SlideDirection.down:
        return Offset(0, distance);
    }
  }

  @override
  void didUpdateWidget(FadeTransitionSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showChild != widget.showChild) {
      _setupAnimations(); // Reset animations with new values
      final delay = widget.showChild ? widget.fadeInDelay : widget.fadeOutDelay;
      Future.delayed(delay, () {
        if (mounted) {
          if (widget.showChild) {
            _controller.forward();
          } else {
            _controller.reverse();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}
