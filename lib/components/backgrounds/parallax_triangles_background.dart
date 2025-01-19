import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:healthxp/constants/colors.constants.dart';

class ParallaxTrianglesBackground extends StatefulWidget {
  final Color triangleColor;
  
  const ParallaxTrianglesBackground({
    super.key,
    this.triangleColor = CoreColors.accentAltColor,
  });

  @override
  State<ParallaxTrianglesBackground> createState() => _ParallaxTrianglesBackgroundState();
}

class _ParallaxTrianglesBackgroundState extends State<ParallaxTrianglesBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Mountain> mountains;
  final random = math.Random();

  List<Mountain> _generateMountains() {
    final mountains = <Mountain>[];
    const numMountainsBig = 1;    // Total number of big mountains
    const numMountainsSmall = 2;  // Total number of small mountains
    const speed = 0.2;            // Consistent speed for all mountains
    const baseLevel = 350.0;      // Consistent base level for all triangles
    
    // Generate large mountains first
    for (int i = 0; i < numMountainsBig; i++) {
      const baseWidth = 300.0;
      final height = random.nextDouble() * 40 + 190;
      final opacity = random.nextDouble() * 0.12 + 0.07;
      
      mountains.add(Mountain(
        baseWidth: baseWidth,
        height: height,
        speed: speed,
        yOffset: baseLevel - height,
        opacity: opacity,
        startOffset: 0.0,  // Start at beginning
      ));
    }
    
    // Generate small mountains with fixed spacing
    for (int i = 0; i < numMountainsSmall; i++) {
      const baseWidth = 100.0;
      final height = random.nextDouble() * 40 + 70;
      final opacity = random.nextDouble() * 0.1 + 0.04;
      
      mountains.add(Mountain(
        baseWidth: baseWidth,
        height: height,
        speed: speed,
        yOffset: baseLevel - height,
        opacity: opacity,
        startOffset: 0.4 + (i * 0.3),  // Space out small triangles evenly after big one
      ));
    }
    
    // Sort by baseWidth so larger triangles are drawn first
    mountains.sort((a, b) => b.baseWidth.compareTo(a.baseWidth));
    return mountains;
  }

  @override
  void initState() {
    super.initState();
    mountains = _generateMountains();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: MountainsPainter(
                progress: _controller.value,
                triangleColor: widget.triangleColor,
                mountains: mountains,
              ),
            );
          },
        );
      },
    );
  }
}

class Mountain {
  final double baseWidth;
  final double height;
  final double speed;
  final double yOffset;
  final double opacity;
  final double startOffset;

  Mountain({
    required this.baseWidth,
    required this.height,
    required this.speed,
    required this.yOffset,
    required this.opacity,
    required this.startOffset,
  });
}

class MountainsPainter extends CustomPainter {
  final double progress;
  final Color triangleColor;
  final List<Mountain> mountains;

  MountainsPainter({
    required this.progress,
    required this.triangleColor,
    required this.mountains,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate a single movement offset for all mountains
    final totalWidth = size.width + 400; // Enough width to ensure smooth looping
    final moveOffset = -progress * totalWidth;
    
    for (var mountain in mountains) {
      final paint = Paint()
        ..color = triangleColor.withOpacity(mountain.opacity)
        ..style = PaintingStyle.fill;

      // Calculate base position with fixed spacing
      final basePosition = mountain.startOffset * totalWidth;
      var xOffset = (moveOffset + basePosition) % totalWidth;
      
      // Ensure triangles wrap around properly
      if (xOffset > size.width) {
        xOffset -= totalWidth;
      }
      
      // Draw the triangle
      _drawTriangle(canvas, paint, xOffset, mountain, size);
      
      // Draw duplicate for seamless looping if needed
      if (xOffset + mountain.baseWidth < 0) {
        _drawTriangle(canvas, paint, xOffset + totalWidth, mountain, size);
      }
      if (xOffset < 0) {
        _drawTriangle(canvas, paint, xOffset + totalWidth, mountain, size);
      }
    }
  }

  void _drawTriangle(Canvas canvas, Paint paint, double xOffset, Mountain mountain, Size size) {
    final path = Path();
    final baseY = mountain.yOffset + mountain.height;
    final peakX = xOffset + mountain.baseWidth / 2;
    final peakY = mountain.yOffset;
    
    path.moveTo(xOffset, baseY);
    path.lineTo(xOffset + mountain.baseWidth, baseY);
    path.lineTo(peakX, peakY);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(MountainsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
} 
