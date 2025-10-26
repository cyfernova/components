import 'package:flutter/material.dart';

/// Action item for action sheet
class ActionSheetItem {
  final String title;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  final bool isDestructive;

  ActionSheetItem({
    required this.title,
    required this.icon,
    this.color,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// Modern animated action sheet (bottom modal)
class AnimatedActionSheet extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final List<ActionSheetItem> actions;
  final bool showCancelButton;
  final String cancelText;
  final Color? primaryColor;
  final double? height;

  const AnimatedActionSheet({
    Key? key,
    this.title,
    this.subtitle,
    required this.actions,
    this.showCancelButton = true,
    this.cancelText = 'Cancel',
    this.primaryColor,
    this.height,
  }) : super(key: key);

  /// Show action sheet as bottom modal
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    required List<ActionSheetItem> actions,
    bool showCancelButton = true,
    String cancelText = 'Cancel',
    Color? primaryColor,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AnimatedActionSheet(
        title: title,
        subtitle: subtitle,
        actions: actions,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
        primaryColor: primaryColor,
        height: height,
      ),
    );
  }

  @override
  State<AnimatedActionSheet> createState() => _AnimatedActionSheetState();
}

class _AnimatedActionSheetState extends State<AnimatedActionSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _itemControllers = [];
  final List<Animation<Offset>> _itemSlideAnimations = [];
  final List<Animation<double>> _itemFadeAnimations = [];

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Initialize item animations
    for (int i = 0; i < widget.actions.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      _itemControllers.add(controller);
      _itemSlideAnimations.add(slideAnimation);
      _itemFadeAnimations.add(fadeAnimation);
    }

    _slideController.forward();
    _fadeController.forward();

    // Animate items with stagger
    Future.delayed(const Duration(milliseconds: 200), () {
      for (int i = 0; i < _itemControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          if (mounted) {
            _itemControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _close() {
    _slideController.reverse();
    _fadeController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _close,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: GestureDetector(
            onTap: () {}, // Prevent tap through
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: widget.height ??
                          MediaQuery.of(context).size.height * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Header
                        if (widget.title != null || widget.subtitle != null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                if (widget.title != null)
                                  Text(
                                    widget.title!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                if (widget.subtitle != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.subtitle!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          ),

                        // Actions list
                        Flexible(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: List.generate(
                                widget.actions.length,
                                (index) {
                                  if (index >= _itemControllers.length) {
                                    return const SizedBox.shrink();
                                  }
                                  
                                  return SlideTransition(
                                    position: _itemSlideAnimations[index],
                                    child: FadeTransition(
                                      opacity: _itemFadeAnimations[index],
                                      child: _ActionSheetTile(
                                        action: widget.actions[index],
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        onTap: () {
                                          widget.actions[index].onTap();
                                          _close();
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Cancel button
                        if (widget.showCancelButton)
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _close,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    widget.cancelText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Bottom safe area
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSheetTile extends StatefulWidget {
  final ActionSheetItem action;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ActionSheetTile({
    required this.action,
    required this.isDark,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_ActionSheetTile> createState() => _ActionSheetTileState();
}

class _ActionSheetTileState extends State<_ActionSheetTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.action.isDestructive
        ? Colors.red
        : (widget.action.color ?? widget.primaryColor);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.grey[850]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.action.icon,
                        color: color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.action.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.action.isDestructive
                              ? Colors.red
                              : (widget.isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: widget.isDark
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
