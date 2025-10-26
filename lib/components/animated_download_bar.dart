import 'package:flutter/material.dart';

/// Modern animated download progress bar
class AnimatedDownloadBar extends StatefulWidget {
  final String fileName;
  final String fileSize;
  final double progress; // 0.0 to 1.0
  final Function()? onCancel;
  final Function()? onPause;
  final Function()? onResume;
  final DownloadState state;
  final Color? primaryColor;
  final Color? accentColor;

  const AnimatedDownloadBar({
    Key? key,
    required this.fileName,
    required this.fileSize,
    required this.progress,
    this.onCancel,
    this.onPause,
    this.onResume,
    this.state = DownloadState.downloading,
    this.primaryColor,
    this.accentColor,
  }) : super(key: key);

  @override
  State<AnimatedDownloadBar> createState() => _AnimatedDownloadBarState();
}

enum DownloadState {
  downloading,
  paused,
  completed,
  error,
}

class _AnimatedDownloadBarState extends State<AnimatedDownloadBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _checkController;
  late Animation<double> _progressAnimation;
  late Animation<double> _checkAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    ));

    _currentProgress = widget.progress;
    _progressController.forward();
  }

  @override
  void didUpdateWidget(final AnimatedDownloadBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _currentProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ));
      _currentProgress = widget.progress;
      _progressController.forward(from: 0.0);

      if (widget.state == DownloadState.completed) {
        _checkController.forward();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  IconData _getStateIcon() {
    switch (widget.state) {
      case DownloadState.downloading:
        return Icons.pause_rounded;
      case DownloadState.paused:
        return Icons.play_arrow_rounded;
      case DownloadState.completed:
        return Icons.check_rounded;
      case DownloadState.error:
        return Icons.refresh_rounded;
    }
  }

  Color _getStateColor(final bool isDark) {
    switch (widget.state) {
      case DownloadState.downloading:
        return widget.primaryColor ?? Theme.of(context).primaryColor;
      case DownloadState.paused:
        return Colors.orange;
      case DownloadState.completed:
        return Colors.green;
      case DownloadState.error:
        return Colors.red;
    }
  }

  void _handleAction() {
    switch (widget.state) {
      case DownloadState.downloading:
        widget.onPause?.call();
        break;
      case DownloadState.paused:
        widget.onResume?.call();
        break;
      case DownloadState.completed:
        break;
      case DownloadState.error:
        widget.onResume?.call();
        break;
    }
  }

  @override
  Widget build(final BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.primaryColor ?? Theme.of(context).primaryColor;
    final accentColor = widget.accentColor ?? Colors.blue;
    final stateColor = _getStateColor(isDark);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: stateColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with file info
              Row(
                children: [
                  // File icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.state == DownloadState.completed
                        ? ScaleTransition(
                            scale: _checkAnimation,
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        : const Icon(
                            Icons.insert_drive_file_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // File details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.fileName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.state == DownloadState.completed
                              ? 'Download complete'
                              : widget.state == DownloadState.error
                                  ? 'Download failed'
                                  : widget.fileSize,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.state == DownloadState.error
                                ? Colors.red
                                : (isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      if (widget.state != DownloadState.completed) ...[
                        InkWell(
                          onTap: _handleAction,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: stateColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStateIcon(),
                              color: stateColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      InkWell(
                        onTap: widget.onCancel,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.state == DownloadState.completed
                                ? Icons.folder_open_rounded
                                : Icons.close_rounded,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress bar
              Stack(
                children: [
                  // Background track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Animated progress
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return widget.state == DownloadState.downloading
                          ? AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(double.infinity, 8),
                                  painter: _DownloadProgressPainter(
                                    progress: _progressAnimation.value,
                                    shimmer: _shimmerController.value,
                                    primaryColor: primaryColor,
                                    accentColor: accentColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 8,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: stateColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress percentage and speed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Text(
                        '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: stateColor,
                        ),
                      );
                    },
                  ),
                  if (widget.state == DownloadState.downloading)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final speed = 2.5 + (_pulseController.value * 0.5);
                        return Row(
                          children: [
                            Icon(
                              Icons.download_rounded,
                              size: 14,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${speed.toStringAsFixed(1)} MB/s',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  else if (widget.state == DownloadState.paused)
                    Text(
                      'Paused',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadProgressPainter extends CustomPainter {
  final double progress;
  final double shimmer;
  final Color primaryColor;
  final Color accentColor;

  _DownloadProgressPainter({
    required this.progress,
    required this.shimmer,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final progressWidth = size.width * progress;

    // Draw gradient progress
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      const Radius.circular(10),
    );

    final gradient = LinearGradient(
      colors: [primaryColor, accentColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, progressWidth, size.height),
      );

    canvas.drawRRect(progressRect, paint);

    // Draw shimmer effect
    final shimmerPosition = shimmer * progressWidth;
    final shimmerGradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final shimmerPaint = Paint()
      ..shader = shimmerGradient.createShader(
        Rect.fromLTWH(shimmerPosition - 30, 0, 60, size.height),
      );

    if (shimmerPosition > 0 && shimmerPosition < progressWidth) {
      canvas.drawRRect(progressRect, shimmerPaint);
    }
  }

  @override
  bool shouldRepaint(_DownloadProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.shimmer != shimmer;
  }
}
