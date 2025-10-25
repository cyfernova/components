import 'package:flutter/material.dart';

/// Notification item model
class NotificationItem {
  final String title;
  final String message;
  final String? avatarUrl;
  final IconData? icon;
  final DateTime timestamp;
  final bool isRead;
  final Color? color;
  final VoidCallback? onTap;

  NotificationItem({
    required this.title,
    required this.message,
    this.avatarUrl,
    this.icon,
    required this.timestamp,
    this.isRead = false,
    this.color,
    this.onTap,
  });
}

/// Modern in-app notification showcase component
class InAppNotificationCard extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(int)? onNotificationTap;
  final Function(int)? onNotificationDismiss;
  final Color? primaryColor;
  final bool showTimeAgo;
  final bool enableSwipeToDismiss;

  const InAppNotificationCard({
    Key? key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationDismiss,
    this.primaryColor,
    this.showTimeAgo = true,
    this.enableSwipeToDismiss = true,
  }) : super(key: key);

  @override
  State<InAppNotificationCard> createState() => _InAppNotificationCardState();
}

class _InAppNotificationCardState extends State<InAppNotificationCard>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<Offset>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    for (int i = 0; i < widget.notifications.length; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 400 + (i * 50)),
        vsync: this,
      );

      final slideAnimation = Tween<Offset>(
        begin: const Offset(1, 0),
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

      _controllers.add(controller);
      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);

      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted) {
          controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }

  void _dismissNotification(int index) {
    _controllers[index].reverse().then((_) {
      widget.onNotificationDismiss?.call(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.notifications.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Notifications list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                if (index >= _controllers.length) return const SizedBox.shrink();

                final notification = widget.notifications[index];
                return SlideTransition(
                  position: _slideAnimations[index],
                  child: FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: _NotificationTile(
                      notification: notification,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      showTimeAgo: widget.showTimeAgo,
                      timeAgo: _getTimeAgo(notification.timestamp),
                      enableSwipeToDismiss: widget.enableSwipeToDismiss,
                      onTap: () {
                        widget.onNotificationTap?.call(index);
                        notification.onTap?.call();
                      },
                      onDismiss: () => _dismissNotification(index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatefulWidget {
  final NotificationItem notification;
  final bool isDark;
  final Color primaryColor;
  final bool showTimeAgo;
  final String timeAgo;
  final bool enableSwipeToDismiss;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.primaryColor,
    required this.showTimeAgo,
    required this.timeAgo,
    required this.enableSwipeToDismiss,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final content = InkWell(
      onTap: widget.onTap,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          color: widget.notification.isRead
              ? null
              : widget.primaryColor.withOpacity(0.05),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar or Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (widget.notification.color ?? widget.primaryColor)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.notification.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.notification.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            widget.notification.icon ?? Icons.notifications,
                            color:
                                widget.notification.color ?? widget.primaryColor,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(
                        widget.notification.icon ?? Icons.notifications,
                        color: widget.notification.color ?? widget.primaryColor,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: widget.notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: widget.isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!widget.notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: widget.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.showTimeAgo) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.isDark
                              ? Colors.grey[500]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.enableSwipeToDismiss) {
      return Dismissible(
        key: ValueKey(widget.notification.timestamp),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => widget.onDismiss(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: content,
      );
    }

    return content;
  }
}
