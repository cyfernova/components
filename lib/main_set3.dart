import 'package:flutter/material.dart';
import 'components/animated_calendar.dart';
import 'components/animated_music_bar.dart';
import 'components/animated_chat_box.dart';
import 'components/animated_download_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Custom Components Set 3',
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
      home: const ComponentsSet3Demo(),
    );
  }
}

class ComponentsSet3Demo extends StatefulWidget {
  const ComponentsSet3Demo({Key? key}) : super(key: key);

  @override
  State<ComponentsSet3Demo> createState() => _ComponentsSet3DemoState();
}

class _ComponentsSet3DemoState extends State<ComponentsSet3Demo> {
  final List<ChatMessage> _messages = [
    ChatMessage(
      message: 'Hey! How are you?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      senderName: 'Alex',
    ),
    ChatMessage(
      message: 'I\'m doing great! Just working on some new Flutter components.',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      message: 'That sounds awesome! What kind of components?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      senderName: 'Alex',
    ),
    ChatMessage(
      message: 'Calendar, music player, chat box, and download bar!',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  double _downloadProgress = 0.65;
  DownloadState _downloadState = DownloadState.downloading;

  void _handleSendMessage(final String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          message: message,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Simulate response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              message: 'Thanks for sharing! These components look amazing! 🎉',
              isMe: false,
              timestamp: DateTime.now(),
              senderName: 'Alex',
            ),
          );
        });
      }
    });
  }

  void _toggleDownloadState() {
    setState(() {
      if (_downloadState == DownloadState.downloading) {
        _downloadState = DownloadState.paused;
      } else if (_downloadState == DownloadState.paused) {
        _downloadState = DownloadState.downloading;
      }
    });
  }

  void _simulateDownload() {
    if (_downloadState == DownloadState.downloading &&
        _downloadProgress < 1.0) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _downloadState == DownloadState.downloading) {
          setState(() {
            _downloadProgress += 0.01;
            if (_downloadProgress >= 1.0) {
              _downloadProgress = 1.0;
              _downloadState = DownloadState.completed;
            }
          });
          if (_downloadProgress < 1.0) {
            _simulateDownload();
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _simulateDownload();
  }

  @override
  Widget build(final BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Custom Components Set 3',
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
            // Calendar Component
            _SectionTitle(title: '1. Animated Calendar'),
            const SizedBox(height: 16),
            AnimatedCalendar(
              initialDate: DateTime.now(),
              onDateSelected: (date) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selected: ${date.day}/${date.month}/${date.year}',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              primaryColor: Colors.blue,
              accentColor: Colors.purple,
            ),

            const SizedBox(height: 40),

            // Music Bar Component
            _SectionTitle(title: '2. Animated Music Bar'),
            const SizedBox(height: 16),
            AnimatedMusicBar(
              songTitle: 'Beautiful Symphony',
              artistName: 'Flutter Orchestra',
              duration: const Duration(minutes: 3, seconds: 45),
              onPlay: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Playing...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onPause: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paused'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onNext: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Next track'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onPrevious: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Previous track'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              primaryColor: Colors.deepPurple,
              accentColor: Colors.purple,
            ),

            const SizedBox(height: 40),

            // Chat Box Component
            _SectionTitle(title: '3. Animated Chat Box'),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: AnimatedChatBox(
                messages: _messages,
                currentUserName: 'Alex',
                onSendMessage: _handleSendMessage,
                myMessageColor: Colors.blue,
                otherMessageColor: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
            ),

            const SizedBox(height: 40),

            // Download Bar Component
            _SectionTitle(title: '4. Animated Download Bar'),
            const SizedBox(height: 16),
            AnimatedDownloadBar(
              fileName: 'flutter_components_v3.zip',
              fileSize: '125.8 MB',
              progress: _downloadProgress,
              state: _downloadState,
              onPause: _toggleDownloadState,
              onResume: () {
                _toggleDownloadState();
                _simulateDownload();
              },
              onCancel: () {
                setState(() {
                  _downloadProgress = 0.0;
                  _downloadState = DownloadState.downloading;
                });
                _simulateDownload();
              },
              primaryColor: Colors.green,
              accentColor: Colors.teal,
            ),

            const SizedBox(height: 20),

            // Additional download examples
            AnimatedDownloadBar(
              fileName: 'document.pdf',
              fileSize: '2.4 MB',
              progress: 1.0,
              state: DownloadState.completed,
              primaryColor: Colors.blue,
              accentColor: Colors.purple,
            ),

            const SizedBox(height: 20),

            AnimatedDownloadBar(
              fileName: 'video_tutorial.mp4',
              fileSize: '450.2 MB',
              progress: 0.35,
              state: DownloadState.paused,
              primaryColor: Colors.orange,
              accentColor: Colors.deepOrange,
            ),

            const SizedBox(height: 40),

            // Features info
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
                    icon: Icons.calendar_today,
                    title: 'Calendar',
                    description:
                        'Interactive calendar with month navigation, date selection, gradient header, and smooth slide animations',
                  ),
                  _FeatureItem(
                    icon: Icons.music_note,
                    title: 'Music Bar',
                    description:
                        'Music player with rotating album art, wave visualizer, play/pause animation, and progress slider',
                  ),
                  _FeatureItem(
                    icon: Icons.chat_bubble,
                    title: 'Chat Box',
                    description:
                        'Chat interface with message bubbles, typing indicator, slide-in animations, and emoji support',
                  ),
                  _FeatureItem(
                    icon: Icons.download,
                    title: 'Download Bar',
                    description:
                        'Download progress with gradient bar, shimmer effect, pause/resume controls, and state management',
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
  Widget build(final BuildContext context) {
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
  Widget build(final BuildContext context) {
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
