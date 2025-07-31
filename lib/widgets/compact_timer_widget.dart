import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

/// A compact timer widget that provides an elegant, streamlined timer display.
/// 
/// This widget is designed to be more visually appealing and space-efficient
/// compared to the full CountdownTimerWidget, while maintaining all
/// essential functionality.
class CompactTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final String title;
  final VoidCallback? onComplete;
  final Color? accentColor;
  final bool showStopButton;
  final VoidCallback? onStop;

  const CompactTimerWidget({
    super.key,
    required this.endTime,
    required this.title,
    this.onComplete,
    this.accentColor,
    this.showStopButton = true,
    this.onStop,
  });

  @override
  State<CompactTimerWidget> createState() => _CompactTimerWidgetState();
}

class _CompactTimerWidgetState extends State<CompactTimerWidget>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isCompleted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      _pulseController.dispose();
    }
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    if (widget.endTime.isAfter(now)) {
      _remainingTime = widget.endTime.difference(now);
    } else {
      _remainingTime = Duration.zero;
      _isCompleted = true;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      
      _calculateRemainingTime();
      
      if (_remainingTime.inSeconds <= 0) {
        _timer?.cancel();
        if (!_isCompleted) {
          _isCompleted = true;
          widget.onComplete?.call();
          if (mounted) {
            _pulseController.repeat(reverse: true);
          }
        }
      }
      
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = widget.accentColor ?? DesignTokens.accentCyan;
    final progress = _calculateProgress();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isCompleted ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.all(12), // Reduced from 16
              child: Row(
                children: [
                  // Compact icon container
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced from 8
                    decoration: BoxDecoration(
                      color: _isCompleted 
                          ? Colors.green.withOpacity(0.2)
                          : accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6), // Reduced from 8
                    ),
                    child: Icon(
                      _isCompleted 
                          ? Icons.check_circle_outline_rounded
                          : Icons.timer_rounded,
                      color: _isCompleted ? Colors.green : accentColor,
                      size: 16, // Reduced from 20
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced from 12
                  
                  // Title and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14, // Slightly smaller
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isCompleted ? 'Abgeschlossen' : _formatCompactTime(_remainingTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _isCompleted 
                                ? Colors.green
                                : accentColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Compact progress indicator
                  SizedBox(
                    width: 32, // Reduced from larger sizes
                    height: 32,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2, // Reduced from thicker
                          valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          backgroundColor: accentColor.withOpacity(0.2),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 8, // Very compact
                              fontWeight: FontWeight.w600,
                              color: _isCompleted ? Colors.green : accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Optional stop button
                  if (widget.showStopButton && !_isCompleted) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onStop,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.stop_rounded,
                          color: Colors.red,
                          size: 14, // Compact stop button
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateProgress() {
    if (_isCompleted) return 1.0;
    
    // Calculate progress based on original duration
    final now = DateTime.now();
    final totalDuration = widget.endTime.difference(now.subtract(_remainingTime));
    
    if (totalDuration.inSeconds <= 0) return 0.0;
    
    final elapsed = totalDuration.inSeconds - _remainingTime.inSeconds;
    return (elapsed / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  /// Formats time in a very compact way - shows only the most relevant units
  String _formatCompactTime(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Utility class for creating compact timers
class CompactTimer {
  static Widget createEffectTimer({
    required String substanceName,
    required DateTime startTime,
    required Duration effectDuration,
    VoidCallback? onComplete,
    VoidCallback? onStop,
  }) {
    final endTime = startTime.add(effectDuration);
    
    return CompactTimerWidget(
      endTime: endTime,
      title: '$substanceName - Wirkung',
      onComplete: onComplete,
      onStop: onStop,
      accentColor: DesignTokens.accentPurple,
    );
  }

  static Widget createCustomTimer({
    required String title,
    required DateTime endTime,
    VoidCallback? onComplete,
    VoidCallback? onStop,
    Color? accentColor,
  }) {
    return CompactTimerWidget(
      endTime: endTime,
      title: title,
      onComplete: onComplete,
      onStop: onStop,
      accentColor: accentColor,
    );
  }
}