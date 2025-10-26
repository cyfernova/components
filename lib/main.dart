import 'package:flutter/material.dart';
import 'components/animated_card_component.dart';
import 'components/glassmorphic_button_component.dart';
import 'components/gradient_progress_card.dart';
import 'components/floating_action_menu.dart';
import 'components/shimmer_loading_card.dart';
import 'components/animated_toggle_switch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Custom Components Showcase',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ComponentShowcase(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ComponentShowcase extends StatefulWidget {
  const ComponentShowcase({super.key});

  @override
  State<ComponentShowcase> createState() => _ComponentShowcaseState();
}

class _ComponentShowcaseState extends State<ComponentShowcase> {
  bool toggleValue = false;

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beautiful Custom Components'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              '1. Animated Info Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AnimatedCardComponent(
              title: 'Premium Feature',
              subtitle: 'Unlock unlimited access',
              icon: Icons.star,
              iconColor: Colors.amber,
              gradientColors: const [Colors.orange, Colors.deepOrange],
              onTap: () => _showSnackbar(context, 'Animated Card Tapped!'),
            ),
            const SizedBox(height: 24),
            const Text(
              '2. Glassmorphic Buttons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlassmorphicButton(
                    text: 'Primary',
                    icon: Icons.rocket_launch,
                    onPressed: () => _showSnackbar(context, 'Primary Button'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GlassmorphicButton(
                    text: 'Secondary',
                    icon: Icons.favorite,
                    color: Colors.pink,
                    onPressed: () => _showSnackbar(context, 'Secondary Button'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '3. Gradient Progress Cards',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GradientProgressCard(
              title: 'Daily Goals',
              subtitle: 'Keep up the great work!',
              progress: 0.75,
              icon: Icons.emoji_events,
              gradientColors: const [Colors.green, Colors.teal],
            ),
            const SizedBox(height: 12),
            GradientProgressCard(
              title: 'Storage Used',
              subtitle: '7.5 GB of 10 GB',
              progress: 0.75,
              icon: Icons.storage,
              gradientColors: const [Colors.blue, Colors.cyan],
            ),
            const SizedBox(height: 24),
            const Text(
              '4. Shimmer Loading Card',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const ShimmerLoadingCard(height: 120),
            const SizedBox(height: 24),
            const Text(
              '5. Animated Toggle Switch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Toggle theme preference',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  AnimatedToggleSwitch(
                    value: toggleValue,
                    onChanged: (value) {
                      setState(() => toggleValue = value);
                      _showSnackbar(context, 'Toggle: ${value ? "ON" : "OFF"}');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '6. Floating Action Menu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Check the bottom-right corner! ↘️',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionMenu(
        mainIcon: Icons.add,
        items: [
          FloatingActionMenuItem(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => _showSnackbar(context, 'Camera Opened'),
            color: Colors.blue,
          ),
          FloatingActionMenuItem(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () => _showSnackbar(context, 'Gallery Opened'),
            color: Colors.green,
          ),
          FloatingActionMenuItem(
            icon: Icons.attach_file,
            label: 'Files',
            onTap: () => _showSnackbar(context, 'Files Opened'),
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  void _showSnackbar(final BuildContext context, final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
