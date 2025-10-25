import 'package:flutter/material.dart';
import 'package:my_custom_component/components/animated_card_component.dart';
import 'package:my_custom_component/components/glassmorphic_button_component.dart';
import 'package:my_custom_component/components/gradient_progress_card.dart';
import 'package:my_custom_component/components/floating_action_menu.dart';
import 'package:my_custom_component/components/shimmer_loading_card.dart';
import 'package:my_custom_component/components/animated_toggle_switch.dart';

/// Example usage of all custom components
/// Copy this code to your project to see how to use each component
class ComponentUsageExample extends StatefulWidget {
  const ComponentUsageExample({super.key});

  @override
  State<ComponentUsageExample> createState() => _ComponentUsageExampleState();
}

class _ComponentUsageExampleState extends State<ComponentUsageExample> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  double _volumeLevel = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Usage Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Animated Card Component
          const Text(
            'Animated Card Component',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedCardComponent(
            title: 'Profile Settings',
            subtitle: 'Manage your account',
            icon: Icons.person,
            iconColor: Colors.white,
            gradientColors: const [Colors.purple, Colors.deepPurple],
            onTap: () {
              // Navigate to profile settings
              debugPrint('Profile settings tapped');
            },
          ),
          const SizedBox(height: 24),

          // Example 2: Glassmorphic Buttons
          const Text(
            'Glassmorphic Buttons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GlassmorphicButton(
                  text: 'Save',
                  icon: Icons.save,
                  color: Colors.green,
                  onPressed: () {
                    debugPrint('Save button pressed');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassmorphicButton(
                  text: 'Cancel',
                  icon: Icons.cancel,
                  color: Colors.red,
                  onPressed: () {
                    debugPrint('Cancel button pressed');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Example 3: Gradient Progress Cards
          const Text(
            'Gradient Progress Cards',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GradientProgressCard(
            title: 'Volume Level',
            subtitle: 'Current audio volume',
            progress: _volumeLevel,
            icon: Icons.volume_up,
            gradientColors: const [Colors.orange, Colors.deepOrange],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _volumeLevel,
            onChanged: (value) {
              setState(() => _volumeLevel = value);
            },
          ),
          const SizedBox(height: 24),

          // Example 4: Shimmer Loading Cards
          const Text(
            'Shimmer Loading Card',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this while loading data:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const ShimmerLoadingCard(height: 100),
          const SizedBox(height: 24),

          // Example 5: Animated Toggle Switches
          const Text(
            'Animated Toggle Switches',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dark Mode',
                      style: TextStyle(fontSize: 16),
                    ),
                    AnimatedToggleSwitch(
                      value: _isDarkMode,
                      activeColor: Colors.purple,
                      onChanged: (value) {
                        setState(() => _isDarkMode = value);
                        debugPrint('Dark mode: $value');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                    AnimatedToggleSwitch(
                      value: _notificationsEnabled,
                      activeColor: Colors.blue,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        debugPrint('Notifications: $value');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Example 6: Floating Action Menu
          const Text(
            'Floating Action Menu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check the bottom-right corner for the expandable menu!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: FloatingActionMenu(
        mainIcon: Icons.add,
        mainColor: Colors.deepPurple,
        items: [
          FloatingActionMenuItem(
            icon: Icons.edit,
            label: 'Edit',
            onTap: () => debugPrint('Edit tapped'),
            color: Colors.blue,
          ),
          FloatingActionMenuItem(
            icon: Icons.share,
            label: 'Share',
            onTap: () => debugPrint('Share tapped'),
            color: Colors.green,
          ),
          FloatingActionMenuItem(
            icon: Icons.delete,
            label: 'Delete',
            onTap: () => debugPrint('Delete tapped'),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
