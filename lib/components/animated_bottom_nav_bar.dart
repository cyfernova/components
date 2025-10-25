import 'package:flutter/material.dart';

/// A beautiful animated bottom navigation bar with smooth transitions
class AnimatedBottomNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double height;

  const AnimatedBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.height = 70,
  });

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(AnimatedBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated indicator
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final itemWidth =
                  MediaQuery.of(context).size.width / widget.items.length;
              final fromPosition = _previousIndex * itemWidth;
              final toPosition = widget.currentIndex * itemWidth;
              final currentPosition =
                  fromPosition + (toPosition - fromPosition) * _animation.value;

              return Positioned(
                left: currentPosition + itemWidth * 0.5 - 20,
                top: 0,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.selectedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
          // Nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isTransitioning = _controller.isAnimating &&
                (index == widget.currentIndex || index == _previousIndex);

            double scale = 1.0;
            if (isTransitioning) {
              if (index == widget.currentIndex) {
                scale = 0.9 + (0.1 * _animation.value);
              } else if (index == _previousIndex) {
                scale = 1.0 - (0.1 * _animation.value);
              }
            }

            return Transform.scale(
              scale: isSelected ? scale : 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 12 : 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? widget.selectedColor
                          : widget.unselectedColor,
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;

  BottomNavItem({
    required this.icon,
    required this.label,
  });
}
