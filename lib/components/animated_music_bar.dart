import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Modern animated music player bar with controls
class AnimatedMusicBar extends StatefulWidget {
  final String songTitle;
  final String artistName;
  final String? albumArt;
  final Duration? duration;
  final Function()? onPlay;
  final Function()? onPause;
  final Function()? onNext;
  final Function()? onPrevious;
  final Color? primaryColor;
  final Color? accentColor;

  const AnimatedMusicBar({
    Key? key,
    required this.songTitle,
    required this.artistName,
    this.albumArt,
    this.duration,
    this.onPlay,
    this.onPause,
    this.onNext,
    this.onPrevious,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  State<AnimatedMusicBar> createState() => _AnimatedMusicBarState();
}

class _AnimatedMusicBarState extends State<AnimatedMusicBar>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  double _progress = 0.0;
  late AnimationController _playButtonController;
  late AnimationController _waveController;
  late AnimationController _rotationController;
  late Animation<double> _playButtonAnimation;

  @override
  void initState() {
    super.initState();

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _playButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playButtonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _playButtonController.dispose();
    _waveController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _playButtonController.forward();
      _rotationController.repeat();
      widget.onPlay?.call();
    } else {
      _playButtonController.reverse();
      _rotationController.stop();
      widget.onPause?.call();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final accentColor = widget.accentColor ?? Colors.purple;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Album art and visualizer
              Row(
                children: [
                  // Rotating album art
                  RotationTransition(
                    turns: _isPlaying
                        ? _rotationController
                        : const AlwaysStoppedAnimation(0),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Song info and wave visualizer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.songTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.artistName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Wave visualizer
                        AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(double.infinity, 30),
                              painter: _WaveVisualizerPainter(
                                animation: _waveController.value,
                                isPlaying: _isPlaying,
                                color: primaryColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: primaryColor,
                      inactiveTrackColor:
                          isDark ? Colors.grey[800] : Colors.grey[300],
                      thumbColor: primaryColor,
                      overlayColor: primaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _progress,
                      onChanged: (value) {
                        setState(() {
                          _progress = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(Duration(
                            seconds: (_progress * 180).toInt(),
                          )),
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.duration != null
                              ? _formatDuration(widget.duration!)
                              : '3:00',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  _ControlButton(
                    icon: Icons.skip_previous_rounded,
                    onPressed: widget.onPrevious,
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    iconColor: isDark ? Colors.white : Colors.grey[800]!,
                  ),

                  const SizedBox(width: 20),

                  // Play/Pause button
                  AnimatedBuilder(
                    animation: _playButtonAnimation,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [primaryColor, accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _playButtonAnimation,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 20),

                  // Next button
                  _ControlButton(
                    icon: Icons.skip_next_rounded,
                    onPressed: widget.onNext,
                    color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                    iconColor: isDark ? Colors.white : Colors.grey[800]!,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(final int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final Color iconColor;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(final BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }
}

class _WaveVisualizerPainter extends CustomPainter {
  final double animation;
  final bool isPlaying;
  final Color color;

  _WaveVisualizerPainter({
    required this.animation,
    required this.isPlaying,
    required this.color,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final normalizedI = i / barCount;
      final animatedValue =
          math.sin((normalizedI * math.pi * 4) + (animation * math.pi * 2));

      final height = isPlaying
          ? (size.height * 0.5) + (animatedValue * size.height * 0.3)
          : size.height * 0.2;

      final x = i * barWidth + barWidth / 2;
      final startY = (size.height - height) / 2;
      final endY = startY + height;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveVisualizerPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.isPlaying != isPlaying;
  }
}
