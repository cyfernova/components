import 'package:flutter/material.dart';
import 'components/animated_notification_bar.dart';
import 'components/in_app_notification_card.dart';
import 'components/animated_action_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Components Set 4',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const ComponentsSet4Demo(),
    );
  }
}

class ComponentsSet4Demo extends StatefulWidget {
  const ComponentsSet4Demo({Key? key}) : super(key: key);

  @override
  State<ComponentsSet4Demo> createState() => _ComponentsSet4DemoState();
}

class _ComponentsSet4DemoState extends State<ComponentsSet4Demo> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'New Message',
      message: 'Sarah sent you a message: "Hey, how are you?"',
      icon: Icons.message,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'Friend Request',
      message: 'John Doe wants to connect with you',
      icon: Icons.person_add,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      color: Colors.green,
    ),
    NotificationItem(
      title: 'New Like',
      message: 'Emma liked your photo',
      icon: Icons.favorite,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
      color: Colors.red,
    ),
    NotificationItem(
      title: 'Comment',
      message: 'Michael commented: "Great post!"',
      icon: Icons.comment,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      color: Colors.orange,
    ),
    NotificationItem(
      title: 'Update Available',
      message: 'A new version of the app is available',
      icon: Icons.system_update,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      color: Colors.purple,
    ),
  ];

  void _showNotification(NotificationType type) {
    String message = '';
    String title = '';

    switch (type) {
      case NotificationType.success:
        title = 'Success';
        message = 'Operation completed successfully!';
        break;
      case NotificationType.error:
        title = 'Error';
        message = 'Something went wrong. Please try again.';
        break;
      case NotificationType.warning:
        title = 'Warning';
        message = 'Please check your internet connection.';
        break;
      case NotificationType.info:
        title = 'Info';
        message = 'You have 3 unread notifications.';
        break;
    }

    AnimatedNotificationBar.show(
      context,
      title: title,
      message: message,
      type: type,
      position: NotificationPosition.top,
      duration: const Duration(seconds: 3),
      onTap: () {
        print('Notification tapped!');
      },
    );
  }

  void _showActionSheet() {
    AnimatedActionSheet.show(
      context,
      title: 'Choose Action',
      subtitle: 'Select an option from below',
      primaryColor: Colors.blue,
      actions: [
        ActionSheetItem(
          title: 'Share',
          icon: Icons.share,
          color: Colors.blue,
          onTap: () {
            _showNotification(NotificationType.success);
            print('Share tapped');
          },
        ),
        ActionSheetItem(
          title: 'Edit',
          icon: Icons.edit,
          color: Colors.orange,
          onTap: () {
            _showNotification(NotificationType.info);
            print('Edit tapped');
          },
        ),
        ActionSheetItem(
          title: 'Download',
          icon: Icons.download,
          color: Colors.green,
          onTap: () {
            _showNotification(NotificationType.success);
            print('Download tapped');
          },
        ),
        ActionSheetItem(
          title: 'Copy Link',
          icon: Icons.link,
          color: Colors.purple,
          onTap: () {
            _showNotification(NotificationType.info);
            print('Copy link tapped');
          },
        ),
        ActionSheetItem(
          title: 'Report',
          icon: Icons.flag,
          color: Colors.orange,
          onTap: () {
            _showNotification(NotificationType.warning);
            print('Report tapped');
          },
        ),
        ActionSheetItem(
          title: 'Delete',
          icon: Icons.delete,
          isDestructive: true,
          onTap: () {
            _showNotification(NotificationType.error);
            print('Delete tapped');
          },
        ),
      ],
    );
  }

  void _showCustomActionSheet() {
    AnimatedActionSheet.show(
      context,
      title: 'Profile Options',
      primaryColor: Colors.deepPurple,
      actions: [
        ActionSheetItem(
          title: 'View Profile',
          icon: Icons.person,
          color: Colors.blue,
          onTap: () => print('View profile'),
        ),
        ActionSheetItem(
          title: 'Settings',
          icon: Icons.settings,
          color: Colors.grey,
          onTap: () => print('Settings'),
        ),
        ActionSheetItem(
          title: 'Logout',
          icon: Icons.logout,
          isDestructive: true,
          onTap: () => print('Logout'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Custom Components Set 4',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Notification Bar
            _SectionTitle(title: '1. Animated Notification Bar'),
            const SizedBox(height: 16),
            Text(
              'Toast/Snackbar style notifications with animations',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Notification buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _NotificationButton(
                  label: 'Success',
                  color: Colors.green,
                  icon: Icons.check_circle,
                  onPressed: () => _showNotification(NotificationType.success),
                ),
                _NotificationButton(
                  label: 'Error',
                  color: Colors.red,
                  icon: Icons.error,
                  onPressed: () => _showNotification(NotificationType.error),
                ),
                _NotificationButton(
                  label: 'Warning',
                  color: Colors.orange,
                  icon: Icons.warning,
                  onPressed: () => _showNotification(NotificationType.warning),
                ),
                _NotificationButton(
                  label: 'Info',
                  color: Colors.blue,
                  icon: Icons.info,
                  onPressed: () => _showNotification(NotificationType.info),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Custom notification examples
            ElevatedButton.icon(
              onPressed: () {
                AnimatedNotificationBar.show(
                  context,
                  title: 'Custom Notification',
                  message: 'This is a bottom notification!',
                  type: NotificationType.info,
                  position: NotificationPosition.bottom,
                  customIcon: Icons.celebration,
                  customColor: Colors.purple,
                );
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Bottom Notification'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            const SizedBox(height: 40),

            // Section 2: In-App Notification Card
            _SectionTitle(title: '2. In-App Notification Card'),
            const SizedBox(height: 16),
            Text(
              'Social media style notification showcase',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            InAppNotificationCard(
              notifications: _notifications,
              primaryColor: Colors.blue,
              showTimeAgo: true,
              enableSwipeToDismiss: true,
              onNotificationTap: (index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped: ${_notifications[index].title}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              onNotificationDismiss: (index) {
                setState(() {
                  _notifications.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification dismissed'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Section 3: Action Sheet
            _SectionTitle(title: '3. Animated Action Sheet'),
            const SizedBox(height: 16),
            Text(
              'Bottom modal with customizable actions',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showActionSheet,
                    icon: const Icon(Icons.more_vert),
                    label: const Text('Full Action Sheet'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showCustomActionSheet,
                    icon: const Icon(Icons.person),
                    label: const Text('Profile Sheet'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Features section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✨ Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    icon: Icons.notifications,
                    title: 'Notification Bar',
                    description:
                        'Toast-style notifications with 4 types (success, error, warning, info), top/bottom positioning, progress bar, swipe to dismiss, and custom colors',
                  ),
                  _FeatureItem(
                    icon: Icons.notifications_active,
                    title: 'In-App Notifications',
                    description:
                        'Social media style notification cards with unread indicators, time ago display, swipe to dismiss, avatars, and staggered entrance animations',
                  ),
                  _FeatureItem(
                    icon: Icons.menu,
                    title: 'Action Sheet',
                    description:
                        'Bottom modal with customizable actions, destructive actions, icons, colors, staggered animations, and drag handle',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Customization tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Customization Tips',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _TipItem(
                    text:
                        '• Notification Bar: Use customIcon & customColor for branded notifications',
                  ),
                  _TipItem(
                    text:
                        '• In-App Notifications: Swipe left to dismiss individual notifications',
                  ),
                  _TipItem(
                    text:
                        '• Action Sheet: Set isDestructive=true for delete/remove actions',
                  ),
                  _TipItem(
                    text: '• All components support dark mode automatically',
                  ),
                  _TipItem(
                    text: '• Use primaryColor prop to match your app\'s theme',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _NotificationButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
    );
  }
}
