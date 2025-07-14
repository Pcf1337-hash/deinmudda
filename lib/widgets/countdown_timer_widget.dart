import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final String title;
  final VoidCallback? onComplete;
  final bool showProgress;
  final Color? accentColor;

  const CountdownTimerWidget({
    super.key,
    required this.endTime,
    required this.title,
    this.onComplete,
    this.showProgress = true,
    this.accentColor,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
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
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
    _pulseController.dispose();
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
      _calculateRemainingTime();
      
      if (_remainingTime.inSeconds <= 0) {
        _timer?.cancel();
        if (!_isCompleted) {
          _isCompleted = true;
          widget.onComplete?.call();
          _pulseController.repeat(reverse: true);
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

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isCompleted ? _pulseAnimation.value : 1.0,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isCompleted 
                            ? Colors.green.withOpacity(0.2)
                            : accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isCompleted 
                            ? Icons.check_circle_outline_rounded
                            : Icons.timer_rounded,
                        color: _isCompleted ? Colors.green : accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isCompleted ? 'Abgeschlossen' : 'Läuft',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _isCompleted 
                                  ? Colors.green
                                  : accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Countdown Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeSegment(
                      context,
                      _remainingTime.inDays,
                      'Tage',
                      isDark,
                    ),
                    _buildTimeSegment(
                      context,
                      _remainingTime.inHours % 24,
                      'Std',
                      isDark,
                    ),
                    _buildTimeSegment(
                      context,
                      _remainingTime.inMinutes % 60,
                      'Min',
                      isDark,
                    ),
                    _buildTimeSegment(
                      context,
                      _remainingTime.inSeconds % 60,
                      'Sek',
                      isDark,
                    ),
                  ],
                ),
                
                if (widget.showProgress && !_isCompleted) ...[
                  const SizedBox(height: 16),
                  _buildProgressBar(context, isDark, accentColor),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSegment(BuildContext context, int value, String unit, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _isCompleted 
                  ? Colors.green
                  : (widget.accentColor ?? DesignTokens.accentCyan),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, bool isDark, Color accentColor) {
    final totalDuration = widget.endTime.difference(widget.endTime.subtract(_remainingTime));
    final progress = totalDuration.inSeconds > 0 
        ? (1.0 - (_remainingTime.inSeconds / totalDuration.inSeconds)).clamp(0.0, 1.0)
        : 0.0;

    // Calculate contrast text color based on the fill color
    final brightness = accentColor.computeLuminance();
    final contrastTextColor = brightness > 0.5 ? Colors.black : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fortschritt',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 8,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: contrastTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Utility class for creating custom countdown timers
class CountdownTimer {
  static Widget createEffectTimer({
    required String substanceName,
    required DateTime startTime,
    required Duration effectDuration,
    VoidCallback? onComplete,
  }) {
    final endTime = startTime.add(effectDuration);
    
    return CountdownTimerWidget(
      endTime: endTime,
      title: '$substanceName - Wirkungsdauer',
      onComplete: onComplete,
      accentColor: DesignTokens.accentPurple,
    );
  }

  static Widget createCustomTimer({
    required String title,
    required DateTime endTime,
    VoidCallback? onComplete,
    Color? accentColor,
    bool showProgress = true,
  }) {
    return CountdownTimerWidget(
      endTime: endTime,
      title: title,
      onComplete: onComplete,
      accentColor: accentColor,
      showProgress: showProgress,
    );
  }
}