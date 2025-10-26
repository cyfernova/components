import 'package:flutter/material.dart';

/// A notification badge with pulse animation
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final int count;
  final Color badgeColor;
  final Color textColor;
  final double size;
  final bool showPulse;
  final bool showBadge;

  const NotificationBadge({
    super.key,
    required this.child,
    this.count = 0,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.size = 20,
    this.showPulse = true,
    this.showBadge = true,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.0),
        weight: 100,
      ),
    ]).animate(_controller);

    if (widget.showPulse && widget.showBadge && widget.count > 0) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(final NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPulse && widget.showBadge && widget.count > 0) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.showBadge && widget.count > 0)
          Positioned(
            right: -8,
            top: -8,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse effect
                    if (widget.showPulse)
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: widget.size * 1.5,
                          height: widget.size * 1.5,
                          decoration: BoxDecoration(
                            color: widget.badgeColor.withOpacity(
                              _opacityAnimation.value * 0.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    // Badge
                    Container(
                      constraints: BoxConstraints(
                        minWidth: widget.size,
                        minHeight: widget.size,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        shape: widget.count > 99
                            ? BoxShape.rectangle
                            : BoxShape.circle,
                        borderRadius: widget.count > 99
                            ? BorderRadius.circular(widget.size / 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: widget.badgeColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.count > 99 ? '99+' : '${widget.count}',
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: widget.size * 0.6,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
