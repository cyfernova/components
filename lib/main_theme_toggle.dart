import 'package:flutter/material.dart';
import 'components/theme_toggle_button.dart';
import 'components/animated_bottom_nav_bar.dart';
import 'components/animated_card_component.dart';
import 'components/glassmorphic_button_component.dart';

void main() {
  runApp(const ThemeToggleApp());
}

class ThemeToggleApp extends StatefulWidget {
  const ThemeToggleApp({super.key});

  @override
  State<ThemeToggleApp> createState() => _ThemeToggleAppState();
}

class _ThemeToggleAppState extends State<ThemeToggleApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Toggle Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: ThemeToggleDemoScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (isDark) {
          setState(() => _isDarkMode = isDark);
        },
      ),
    );
  }
}

class ThemeToggleDemoScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ThemeToggleDemoScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<ThemeToggleDemoScreen> createState() => _ThemeToggleDemoScreenState();
}

class _ThemeToggleDemoScreenState extends State<ThemeToggleDemoScreen> {
  int _currentNavIndex = 0;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(icon: Icons.home, label: 'Home'),
    BottomNavItem(icon: Icons.palette, label: 'Themes'),
    BottomNavItem(icon: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Theme Toggle Component',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: ThemeToggleButton(
                isDarkMode: widget.isDarkMode,
                onToggle: widget.onThemeChanged,
                size: 50,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0F172A),
                    const Color(0xFF1E293B),
                  ]
                : [
                    Colors.grey[50]!,
                    Colors.grey[100]!,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section with Theme Toggle
              _buildHeroSection(isDark, colorScheme),
              const SizedBox(height: 32),

              // Features Section
              _buildSectionTitle('Component Features', colorScheme),
              const SizedBox(height: 16),
              _buildFeatureCards(isDark, colorScheme),
              const SizedBox(height: 32),

              // Interactive Demo Section
              _buildSectionTitle('Interactive Demo', colorScheme),
              const SizedBox(height: 16),
              _buildInteractiveDemo(isDark, colorScheme),
              const SizedBox(height: 32),

              // Theme Preview Cards
              _buildSectionTitle('Theme Preview', colorScheme),
              const SizedBox(height: 16),
              _buildThemePreviewCards(isDark, colorScheme),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavBar(
        items: _navItems,
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        selectedColor: colorScheme.primary,
        unselectedColor: colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: colorScheme.surface,
      ),
    );
  }

  Widget _buildHeroSection(bool isDark, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  colorScheme.primary.withOpacity(0.2),
                  colorScheme.secondary.withOpacity(0.2),
                ]
              : [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            isDark ? 'Dark Mode Active' : 'Light Mode Active',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button in the app bar to switch themes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ThemeToggleButton(
            isDarkMode: widget.isDarkMode,
            onToggle: widget.onThemeChanged,
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFeatureCards(bool isDark, ColorScheme colorScheme) {
    final features = [
      {
        'icon': Icons.animation,
        'title': 'Smooth Animation',
        'desc': '600ms smooth transition with cubic easing'
      },
      {
        'icon': Icons.wb_sunny,
        'title': 'Sun & Moon',
        'desc': 'Beautiful sun to moon morphing effect'
      },
      {
        'icon': Icons.star,
        'title': 'Dynamic Elements',
        'desc': 'Animated rays and stars appear dynamically'
      },
      {
        'icon': Icons.color_lens,
        'title': 'Color Transition',
        'desc': 'Smooth gradient color transitions'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'] as IconData,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                feature['desc'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveDemo(bool isDark, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Try Different Sizes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  ThemeToggleButton(
                    isDarkMode: widget.isDarkMode,
                    onToggle: widget.onThemeChanged,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Small',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ThemeToggleButton(
                    isDarkMode: widget.isDarkMode,
                    onToggle: widget.onThemeChanged,
                    size: 60,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Medium',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ThemeToggleButton(
                    isDarkMode: widget.isDarkMode,
                    onToggle: widget.onThemeChanged,
                    size: 80,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Large',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCards(bool isDark, ColorScheme colorScheme) {
    return Column(
      children: [
        AnimatedCardComponent(
          title: isDark ? '🌙 Dark Theme' : '☀️ Light Theme',
          subtitle: 'This card adapts to the current theme',
          icon: isDark ? Icons.dark_mode : Icons.light_mode,
          iconColor: Colors.white,
          gradientColors: isDark
              ? [Colors.indigo[900]!, Colors.purple[900]!]
              : [Colors.blue[400]!, Colors.purple[400]!],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassmorphicButton(
                text: 'Button',
                icon: Icons.check,
                onPressed: () {},
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassmorphicButton(
                text: 'Button',
                icon: Icons.favorite,
                onPressed: () {},
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
