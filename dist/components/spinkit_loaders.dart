import 'package:flutter/material.dart';
import 'dart:math' as math;

/// SpinKit-style loading indicators with beautiful animations
class SpinKitLoaders {
  /// Rotating circle loader
  static Widget rotatingCircle({
    Color color = Colors.blue,
    double size = 50.0,
  }) {
    return _RotatingCircleLoader(color: color, size: size);
  }

  /// Pulsing dots loader
  static Widget pulsingDots({
    Color color = Colors.blue,
    double size = 50.0,
  }) {
    return _PulsingDotsLoader(color: color, size: size);
  }

  /// Wave loader
  static Widget wave({
    Color color = Colors.blue,
    double size = 50.0,
  }) {
    return _WaveLoader(color: color, size: size);
  }

  /// Rotating square loader
  static Widget rotatingSquare({
    Color color = Colors.blue,
    double size = 50.0,
  }) {
    return _RotatingSquareLoader(color: color, size: size);
  }
}

// Rotating Circle Loader
class _RotatingCircleLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _RotatingCircleLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_RotatingCircleLoader> createState() => _RotatingCircleLoaderState();
}

class _RotatingCircleLoaderState extends State<_RotatingCircleLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              painter: _CirclePainter(
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;

  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pulsing Dots Loader
class _PulsingDotsLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDotsLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingDotsLoader> createState() => _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState extends State<_PulsingDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value - delay).clamp(0.0, 1.0);
              final scale = (math.sin(value * math.pi * 2) * 0.5 + 0.5);

              return Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: widget.size / 6,
                  height: widget.size / 6,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.7 + scale * 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// Wave Loader
class _WaveLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _WaveLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<_WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.1;
                final value = (_controller.value - delay).clamp(0.0, 1.0);
                final height =
                    (math.sin(value * math.pi * 2) * 0.5 + 0.5) * widget.size;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: widget.size / 10,
                  height: height * 0.8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// Rotating Square Loader
class _RotatingSquareLoader extends StatefulWidget {
  final Color color;
  final double size;

  const _RotatingSquareLoader({
    required this.color,
    required this.size,
  });

  @override
  State<_RotatingSquareLoader> createState() => _RotatingSquareLoaderState();
}

class _RotatingSquareLoaderState extends State<_RotatingSquareLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(2, (index) {
              final angle =
                  _controller.value * 2 * math.pi + (index * math.pi / 2);
              final scale = 0.5 +
                  (math.sin(_controller.value * 2 * math.pi + index * math.pi) *
                      0.3);

              return Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size * 0.6,
                    height: widget.size * 0.6,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
