import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/entry.dart'; // cleaned by BereinigungsAgent - fixed import path
import '../services/timer_service.dart'; // cleaned by BereinigungsAgent - fixed import path
import '../theme/design_tokens.dart'; // cleaned by BereinigungsAgent - fixed import path
import '../theme/spacing.dart'; // cleaned by BereinigungsAgent - fixed import path

/// A visual indicator widget that displays timer status for consumption entries.
/// 
/// Shows different states (active, expired, completed) with appropriate colors,
/// icons, and animations. Includes a pulsing animation for active timers.
class TimerIndicator extends StatefulWidget {
  final Entry entry;
  final VoidCallback? onTimerComplete;

  /// Creates a timer indicator for the given entry.
  /// 
  /// The [entry] must have timer data to display anything.
  /// [onTimerComplete] is called when the timer expires.
  const TimerIndicator({
    super.key,
    required this.entry,
    this.onTimerComplete,
  });

  @override
  State<TimerIndicator> createState() => _TimerIndicatorState();
}

class _TimerIndicatorState extends State<TimerIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.entry.isTimerActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (!widget.entry.hasTimer) {
      return const SizedBox.shrink();
    }
    
    final isActive = widget.entry.isTimerActive;
    final isExpired = widget.entry.isTimerExpired;
    final progress = widget.entry.timerProgress;
    
    final Color indicatorColor;
    final IconData icon;
    final String statusText;
    
    if (isActive) {
      indicatorColor = DesignTokens.accentCyan;
      icon = Icons.timer_rounded;
      statusText = widget.entry.formattedRemainingTime;
    } else if (isExpired) {
      indicatorColor = DesignTokens.warningYellow;
      icon = Icons.timer_off_rounded;
      statusText = 'Timer abgelaufen';
    } else {
      indicatorColor = DesignTokens.successGreen;
      icon = Icons.check_circle_rounded;
      statusText = 'Timer beendet';
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Spacing.sm),
              border: Border.all(
                color: indicatorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: indicatorColor,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: indicatorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: Spacing.xs),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                      backgroundColor: indicatorColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A horizontal progress bar widget that shows timer completion progress.
/// 
/// Displays a colored progress bar indicating how much time has elapsed
/// or completed for a timer-enabled consumption entry.
class TimerProgressBar extends StatelessWidget {
  final Entry entry;
  final double height;

  /// Creates a timer progress bar for the given entry.
  /// 
  /// The [height] parameter controls the thickness of the progress bar.
  const TimerProgressBar({
    super.key,
    required this.entry,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (!entry.hasTimer) {
      return const SizedBox.shrink();
    }
    
    final progress = entry.timerProgress;
    final isActive = entry.isTimerActive;
    final isExpired = entry.isTimerExpired;
    
    final Color progressColor;
    if (isActive) {
      progressColor = DesignTokens.accentCyan;
    } else if (isExpired) {
      progressColor = DesignTokens.warningYellow;
    } else {
      progressColor = DesignTokens.successGreen;
    }
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

// hints reduziert durch HintOptimiererAgent