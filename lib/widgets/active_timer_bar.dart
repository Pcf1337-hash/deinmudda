import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/entry.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class ActiveTimerBar extends StatefulWidget {
  final Entry timer;
  final VoidCallback? onTap;

  const ActiveTimerBar({
    super.key,
    required this.timer,
    this.onTap,
  });

  @override
  State<ActiveTimerBar> createState() => _ActiveTimerBarState();
}

class _ActiveTimerBarState extends State<ActiveTimerBar>
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
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
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
    final progress = widget.timer.timerProgress;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.all(Spacing.md),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        colors: [
                          DesignTokens.accentCyan.withOpacity(0.1),
                          DesignTokens.accentCyan.withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          DesignTokens.accentCyan.withOpacity(0.15),
                          DesignTokens.accentCyan.withOpacity(0.08),
                        ],
                      ),
                borderRadius: Spacing.borderRadiusLg,
                border: Border.all(
                  color: DesignTokens.accentCyan.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.accentCyan.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentCyan.withOpacity(0.2),
                          borderRadius: Spacing.borderRadiusMd,
                        ),
                        child: Icon(
                          Icons.timer_rounded,
                          color: DesignTokens.accentCyan,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.timer.substanceName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: DesignTokens.accentCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Timer läuft',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.timer.formattedRemainingTime,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: DesignTokens.accentCyan,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: DesignTokens.accentCyan.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.accentCyan),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}