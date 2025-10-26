import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A beautiful animated theme toggle button that switches between light and dark mode
class ThemeToggleButton extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggle;
  final double size;
  final Duration animationDuration;

  const ThemeToggleButton({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
    this.size = 60,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rayController;
  late Animation<double> _sunMoonAnimation;
  late Animation<double> _rayAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _rayController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _sunMoonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _rayAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_rayController);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    if (widget.isDarkMode) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(final ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      if (widget.isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rayController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onToggle(!widget.isDarkMode);
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _rayController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFFFDB813), // Sun yellow
                      const Color(0xFF1E3A8A), // Dark blue
                      _sunMoonAnimation.value,
                    )!,
                    Color.lerp(
                      const Color(0xFFFFA726), // Sun orange
                      const Color(0xFF0F172A), // Very dark blue
                      _sunMoonAnimation.value,
                    )!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      Colors.orange.withOpacity(0.5),
                      Colors.blue.withOpacity(0.5),
                      _sunMoonAnimation.value,
                    )!,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Sun rays
                  if (_sunMoonAnimation.value < 0.5)
                    CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _SunRaysPainter(
                        rayAngle: _rayAnimation.value,
                        opacity: 1.0 - (_sunMoonAnimation.value * 2),
                      ),
                    ),

                  // Main icon (Sun/Moon transition)
                  Center(
                    child: CustomPaint(
                      size: Size(widget.size * 0.5, widget.size * 0.5),
                      painter: _SunMoonPainter(
                        progress: _sunMoonAnimation.value,
                      ),
                    ),
                  ),

                  // Stars for dark mode
                  if (_sunMoonAnimation.value > 0.5) ..._buildStars(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildStars() {
    final opacity = (_sunMoonAnimation.value - 0.5) * 2;
    return [
      Positioned(
        top: widget.size * 0.15,
        right: widget.size * 0.2,
        child: _buildStar(4, opacity),
      ),
      Positioned(
        top: widget.size * 0.25,
        left: widget.size * 0.15,
        child: _buildStar(3, opacity * 0.8),
      ),
      Positioned(
        bottom: widget.size * 0.2,
        right: widget.size * 0.25,
        child: _buildStar(3.5, opacity * 0.9),
      ),
    ];
  }

  Widget _buildStar(final double size, final double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity.clamp(0.0, 1.0)),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(opacity.clamp(0.0, 0.5)),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  final double rayAngle;
  final double opacity;

  _SunRaysPainter({
    required this.rayAngle,
    required this.opacity,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0))
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rayCount = 8;
    final rayLength = size.width * 0.15;
    final rayStartRadius = size.width * 0.3;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i + rayAngle;
      final startX = center.dx + rayStartRadius * math.cos(angle);
      final startY = center.dy + rayStartRadius * math.sin(angle);
      final endX = center.dx + (rayStartRadius + rayLength) * math.cos(angle);
      final endY = center.dy + (rayStartRadius + rayLength) * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SunMoonPainter extends CustomPainter {
  final double progress;

  _SunMoonPainter({required this.progress});

  @override
  void paint(final Canvas canvas, final Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (progress < 0.5) {
      // Draw sun (full circle)
      canvas.drawCircle(center, radius, paint);
    } else {
      // Draw moon (circle with crescent)
      canvas.drawCircle(center, radius, paint);

      // Draw the shadow to create crescent effect
      final crescentProgress = (progress - 0.5) * 2;
      final shadowOffset = Offset(
        radius * 0.6 * crescentProgress,
        -radius * 0.2,
      );

      final shadowPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFA726),
          const Color(0xFF0F172A),
          progress,
        )!
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        center + shadowOffset,
        radius * 0.9,
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
