import 'package:flutter/material.dart';

/// A beautiful animated toggle switch with smooth transitions
class AnimatedToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;

  const AnimatedToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.width = 60,
    this.height = 32,
  });

  @override
  State<AnimatedToggleSwitch> createState() => _AnimatedToggleSwitchState();
}

class _AnimatedToggleSwitchState extends State<AnimatedToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _toggleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _toggleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _updateColorAnimation();

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (oldWidget.activeColor != widget.activeColor ||
        oldWidget.inactiveColor != widget.inactiveColor) {
      _updateColorAnimation();
    }
  }

  void _updateColorAnimation() {
    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: (_colorAnimation.value ?? Colors.grey).withOpacity(
                    0.3,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _toggleAnimation.value * (widget.width - widget.height),
                  top: 0,
                  child: Container(
                    width: widget.height,
                    height: widget.height,
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.value
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: widget.activeColor,
                            )
                          : Icon(
                              Icons.close,
                              size: 16,
                              color: widget.inactiveColor,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
