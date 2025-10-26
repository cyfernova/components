import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A floating action menu that expands with beautiful animations
class FloatingActionMenu extends StatefulWidget {
  final IconData mainIcon;
  final List<FloatingActionMenuItem> items;
  final Color mainColor;

  const FloatingActionMenu({
    super.key,
    required this.mainIcon,
    required this.items,
    this.mainColor = Colors.deepPurple,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final delay = index * 0.1;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final animation = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
                    );

                    return Transform.scale(
                      scale: animation.value,
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: animation.value,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Colors.white,
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    item.label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              FloatingActionButton(
                                heroTag: 'fab_$index',
                                mini: true,
                                backgroundColor: item.color,
                                onPressed: () {
                                  item.onTap();
                                  _toggle();
                                },
                                child: Icon(item.icon, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        FloatingActionButton(
          heroTag: 'main_fab',
          backgroundColor: widget.mainColor,
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi / 2,
                child: Icon(
                  _isExpanded ? Icons.close : widget.mainIcon,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FloatingActionMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  FloatingActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
  });
}
