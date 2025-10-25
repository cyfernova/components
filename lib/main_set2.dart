import 'package:flutter/material.dart';
import 'components/animated_bottom_nav_bar.dart';
import 'components/animated_side_drawer.dart';
import 'components/spinkit_loaders.dart';
import 'components/circular_progress_indicator.dart';
import 'components/animated_search_bar.dart';
import 'components/notification_badge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beautiful Components Set 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ComponentShowcaseScreen(),
    );
  }
}

class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  int _currentNavIndex = 0;
  int _selectedDrawerIndex = 0;
  double _circularProgress = 0.75;
  int _notificationCount = 5;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.search, label: 'Search'),
    BottomNavItem(icon: Icons.favorite, label: 'Favorites'),
    BottomNavItem(icon: Icons.person, label: 'Profile'),
  ];

  final List<DrawerItem> _drawerItems = [
    DrawerItem(icon: Icons.dashboard, title: 'Dashboard'),
    DrawerItem(icon: Icons.notifications, title: 'Notifications', badge: '12'),
    DrawerItem(icon: Icons.message, title: 'Messages', badge: '3'),
    DrawerItem(icon: Icons.settings, title: 'Settings'),
    DrawerItem(icon: Icons.help, title: 'Help & Support'),
    DrawerItem(icon: Icons.info, title: 'About'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beautiful Components Set 2',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NotificationBadge(
              count: _notificationCount,
              showPulse: true,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() {
                    _notificationCount = _notificationCount > 0 ? 0 : 5;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      drawer: AnimatedSideDrawer(
        items: _drawerItems,
        headerTitle: 'John Doe',
        headerSubtitle: 'john.doe@email.com',
        selectedIndex: _selectedDrawerIndex,
        onItemTap: (index) {
          setState(() => _selectedDrawerIndex = index);
        },
        selectedColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Search Bar Section
            _buildSectionTitle('Animated Search Bar'),
            const SizedBox(height: 16),
            Center(
              child: AnimatedSearchBar(
                hintText: 'Search components...',
                onChanged: (value) {
                  debugPrint('Search: $value');
                },
                onSearch: () {
                  debugPrint('Search triggered');
                },
              ),
            ),
            const SizedBox(height: 40),

            // Circular Progress Indicator Section
            _buildSectionTitle('Gradient Circular Progress'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GradientCircularProgress(
                  progress: _circularProgress,
                  size: 120,
                  strokeWidth: 12,
                  gradientColors: const [Colors.blue, Colors.purple],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _circularProgress =
                              (_circularProgress + 0.1).clamp(0.0, 1.0);
                        });
                      },
                      child: const Text('Increase'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _circularProgress =
                              (_circularProgress - 0.1).clamp(0.0, 1.0);
                        });
                      },
                      child: const Text('Decrease'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),

            // SpinKit Loaders Section
            _buildSectionTitle('SpinKit Loading Indicators'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SpinKitLoaders.rotatingCircle(
                            color: Colors.blue,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          const Text('Rotating Circle'),
                        ],
                      ),
                      Column(
                        children: [
                          SpinKitLoaders.pulsingDots(
                            color: Colors.green,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          const Text('Pulsing Dots'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          SpinKitLoaders.wave(
                            color: Colors.orange,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          const Text('Wave'),
                        ],
                      ),
                      Column(
                        children: [
                          SpinKitLoaders.rotatingSquare(
                            color: Colors.purple,
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          const Text('Rotating Square'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Notification Badge Examples
            _buildSectionTitle('Notification Badges'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NotificationBadge(
                  count: 3,
                  showPulse: true,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.email, color: Colors.white, size: 32),
                  ),
                ),
                NotificationBadge(
                  count: 99,
                  showPulse: false,
                  badgeColor: Colors.green,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.chat, color: Colors.white, size: 32),
                  ),
                ),
                NotificationBadge(
                  count: 150,
                  showPulse: true,
                  badgeColor: Colors.orange,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_cart,
                        color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Info Section
            _buildInfoCard(),
            const SizedBox(height: 80), // Space for bottom nav bar
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: _navItems,
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
        selectedColor: Colors.blue,
        unselectedColor: Colors.grey,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Component Features',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
              '✨ Animated Bottom Navigation Bar with smooth transitions'),
          _buildFeatureItem(
              '📱 Side Navigation Drawer with staggered animations'),
          _buildFeatureItem('⏳ SpinKit-style Loading Indicators (4 styles)'),
          _buildFeatureItem(
              '🎯 Circular Progress with gradient and animations'),
          _buildFeatureItem('🔍 Animated Search Bar that expands/collapses'),
          _buildFeatureItem('🔔 Notification Badge with pulse animation'),
          const SizedBox(height: 8),
          Text(
            'All components are built from scratch with no 3rd party dependencies!',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.5),
      ),
    );
  }
}
