import 'package:flutter/material.dart';

/// A beautiful side navigation drawer with staggered animations
class AnimatedSideDrawer extends StatefulWidget {
  final List<DrawerItem> items;
  final String headerTitle;
  final String headerSubtitle;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const AnimatedSideDrawer({
    super.key,
    required this.items,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.onItemTap,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.blue,
    this.unselectedColor = Colors.grey,
    this.selectedIndex = 0,
  });

  @override
  State<AnimatedSideDrawer> createState() => _AnimatedSideDrawerState();
}

class _AnimatedSideDrawerState extends State<AnimatedSideDrawer>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _itemsController;
  late List<Animation<double>> _itemAnimations;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _itemsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOut,
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: Curves.easeOut,
      ),
    );

    _itemAnimations = List.generate(
      widget.items.length,
      (index) {
        final delay = index * 0.1;
        return Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _itemsController,
            curve: Interval(
              delay,
              1.0,
              curve: Curves.easeOutBack,
            ),
          ),
        );
      },
    );

    _headerController.forward();
    _itemsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      child: Container(
        color: widget.backgroundColor,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: widget.items.length,
                itemBuilder: (context, index) => _buildDrawerItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: SlideTransition(
            position: _headerSlideAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.selectedColor,
                    widget.selectedColor.withOpacity(0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.headerTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.headerSubtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(final int index) {
    final item = widget.items[index];
    final isSelected = index == widget.selectedIndex;

    return AnimatedBuilder(
      animation: _itemsController,
      builder: (context, child) {
        final animation = _itemAnimations[index];
        return Transform.translate(
          offset: Offset(-50 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    widget.onItemTap(index);
                    Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? widget.selectedColor.withOpacity(0.3)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: isSelected
                              ? widget.selectedColor
                              : widget.unselectedColor,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              color: isSelected
                                  ? widget.selectedColor
                                  : widget.unselectedColor,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (item.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isSelected)
                          Icon(
                            Icons.arrow_forward_ios,
                            color: widget.selectedColor,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String? badge;

  DrawerItem({
    required this.icon,
    required this.title,
    this.badge,
  });
}
