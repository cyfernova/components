import 'package:flutter/material.dart';
import 'dart:async';

/// Type of notification
enum NotificationType {
  success,
  error,
  warning,
  info,
}

/// Position of notification
enum NotificationPosition {
  top,
  bottom,
}

/// Modern animated notification bar (toast/snackbar)
class AnimatedNotificationBar extends StatefulWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final NotificationPosition position;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showProgressBar;
  final IconData? customIcon;
  final Color? customColor;

  const AnimatedNotificationBar({
    Key? key,
    required this.message,
    this.title,
    this.type = NotificationType.info,
    this.position = NotificationPosition.top,
    this.duration = const Duration(seconds: 3),
    this.onTap,
    this.onDismiss,
    this.showProgressBar = true,
    this.customIcon,
    this.customColor,
  }) : super(key: key);

  /// Show notification as overlay
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    NotificationType type = NotificationType.info,
    NotificationPosition position = NotificationPosition.top,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    bool showProgressBar = true,
    IconData? customIcon,
    Color? customColor,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        message: message,
        title: title,
        type: type,
        position: position,
        duration: duration,
        showProgressBar: showProgressBar,
        customIcon: customIcon,
        customColor: customColor,
        onTap: onTap,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<AnimatedNotificationBar> createState() =>
      _AnimatedNotificationBarState();
}

class _AnimatedNotificationBarState extends State<AnimatedNotificationBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.position == NotificationPosition.top ? -1 : 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
    if (widget.showProgressBar) {
      _progressController.forward();
    }

    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Color _getColor() {
    if (widget.customColor != null) return widget.customColor!;
    
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    if (widget.customIcon != null) return widget.customIcon!;
    
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          _dismiss();
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity!.abs() > 500) {
            _dismiss();
          }
        },
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIcon(),
                          color: color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null) ...[
                              Text(
                                widget.title!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              widget.message,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: _dismiss,
                      ),
                    ],
                  ),
                ),

                // Progress bar
                if (widget.showProgressBar)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: 1 - _progressController.value,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationOverlay extends StatelessWidget {
  final String message;
  final String? title;
  final NotificationType type;
  final NotificationPosition position;
  final Duration duration;
  final bool showProgressBar;
  final IconData? customIcon;
  final Color? customColor;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.message,
    this.title,
    required this.type,
    required this.position,
    required this.duration,
    required this.showProgressBar,
    this.customIcon,
    this.customColor,
    this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position == NotificationPosition.top ? 0 : null,
      bottom: position == NotificationPosition.bottom ? 0 : null,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedNotificationBar(
          message: message,
          title: title,
          type: type,
          position: position,
          duration: duration,
          showProgressBar: showProgressBar,
          customIcon: customIcon,
          customColor: customColor,
          onTap: onTap,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}
