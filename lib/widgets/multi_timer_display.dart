import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/entry.dart';
import '../services/timer_service.dart';
import '../services/psychedelic_theme_service.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';
import '../utils/safe_navigation.dart';
import '../utils/error_handler.dart';
import '../utils/crash_protection.dart';
import '../utils/impeller_helper.dart';

/// A modern multi-timer display widget that shows multiple active timers
/// in an attractive tile-based layout with glassmorphism design.
class MultiTimerDisplay extends StatefulWidget {
  final VoidCallback? onTimerTap;
  final VoidCallback? onEmptyStateTap;

  const MultiTimerDisplay({
    super.key,
    this.onTimerTap,
    this.onEmptyStateTap,
  });

  @override
  State<MultiTimerDisplay> createState() => _MultiTimerDisplayState();
}

class _MultiTimerDisplayState extends State<MultiTimerDisplay>
    with SingleTickerProviderStateMixin, SafeStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    
    try {
      ErrorHandler.logTimer('INIT', 'MultiTimerDisplay initialisiert');
      
      // Get animation settings based on Impeller status
      final animationSettings = ImpellerHelper.getTimerAnimationSettings();
      final duration = animationSettings['animationDuration'] as Duration;
      
      _animationController = AnimationController(
        duration: duration,
        vsync: this,
      );
      
      _slideAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      
      // Start animation if Impeller supports it
      if (ImpellerHelper.shouldEnableFeature('slideAnimations')) {
        _animationController.forward();
      } else {
        _animationController.value = 1.0;
      }
      
      ErrorHandler.logSuccess('MULTI_TIMER_DISPLAY', 'Animation Controller erfolgreich initialisiert');
    } catch (e, stackTrace) {
      ErrorHandler.logError('MULTI_TIMER_DISPLAY', 'Fehler beim Initialisieren: $e');
      ErrorHandler.logError('MULTI_TIMER_DISPLAY', 'Stack trace: $stackTrace');
      
      // Log potential Impeller issue
      ImpellerHelper.logPerformanceIssue('MULTI_TIMER_DISPLAY', 'Animation initialization failed: $e');
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    ErrorHandler.logDispose('MULTI_TIMER_DISPLAY', 'MultiTimerDisplay dispose gestartet');
    
    try {
      _animationController.stop();
      _animationController.dispose();
      ErrorHandler.logSuccess('MULTI_TIMER_DISPLAY', 'AnimationController erfolgreich disposed');
    } catch (e, stackTrace) {
      ErrorHandler.logError('MULTI_TIMER_DISPLAY', 'Fehler beim Dispose des AnimationController: $e');
      ErrorHandler.logError('MULTI_TIMER_DISPLAY', 'Stack trace: $stackTrace');
    }
    
    ErrorHandler.logSuccess('MULTI_TIMER_DISPLAY', 'MultiTimerDisplay dispose abgeschlossen');
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Early return if widget is not mounted or disposed
    if (!mounted || _isDisposed) {
      return const SizedBox.shrink();
    }
    
    return CrashProtectionWrapper(
      context: 'MultiTimerDisplay',
      fallbackWidget: _buildErrorFallback(context),
      child: _buildTimerContent(context),
    );
  }
  
  Widget _buildErrorFallback(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: Spacing.borderRadiusLg,
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          SizedBox(width: Spacing.sm),
          Text('Timer nicht verfügbar - siehe Log', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
  
  Widget _buildTimerContent(BuildContext context) {
    try {
      return Consumer2<TimerService, PsychedelicThemeService>(
        builder: (context, timerService, psychedelicService, child) {
          // Early return if widget is not mounted or disposed
          if (!mounted || _isDisposed) {
            return const SizedBox.shrink();
          }
          
          final activeTimers = timerService.activeTimers;
          final isPsychedelicMode = psychedelicService.isPsychedelicMode;
          
          if (activeTimers.isEmpty) {
            return const SizedBox.shrink();
          }
          
          return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Early return if widget is not mounted or disposed
              if (!mounted || _isDisposed) {
                return const SizedBox.shrink();
              }
              
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _slideAnimation.value)),
                child: Opacity(
                  opacity: _slideAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    child: _buildTimerTiles(context, activeTimers, isPsychedelicMode),
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      ErrorHandler.logError('MULTI_TIMER_DISPLAY', 'Fehler beim Erstellen der MultiTimerDisplay: $e');
      
      // Fallback widget
      return _buildErrorFallback(context);
    }
  }

  Widget _buildTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode) {
    if (activeTimers.length == 1) {
      // Single timer - use full width card
      return _buildSingleTimerCard(context, activeTimers.first, isPsychedelicMode);
    } else {
      // Multiple timers - use horizontal scrollable tiles
      return _buildMultipleTimerTiles(context, activeTimers, isPsychedelicMode);
    }
  }

  Widget _buildSingleTimerCard(BuildContext context, Entry timer, bool isPsychedelicMode) {
    final theme = Theme.of(context);
    final progress = timer.timerProgress;
    final progressColor = _getProgressBasedColor(progress, isPsychedelicMode);
    final textColor = _getTextColorForBackground(progressColor);
    
    return GestureDetector(
      onTap: widget.onTimerTap,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              progressColor.withOpacity(0.15),
              progressColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: progressColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: progressColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (isPsychedelicMode) ...[
              BoxShadow(
                color: progressColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ],
        ),
        child: Stack(
          children: [
            // Progress background
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    progressColor.withOpacity(0.3),
                    progressColor.withOpacity(0.1),
                  ],
                  stops: [0.0, progress],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: progressColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timer.substanceName ?? 'Unbekannte Substanz',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimerText(timer.formattedRemainingTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          backgroundColor: progressColor.withOpacity(0.2),
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with timer count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(
                Icons.timer_rounded,
                color: DesignTokens.accentCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${activeTimers.length} aktive Timer',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: DesignTokens.accentCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onTimerTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.accentCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DesignTokens.accentCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Alle anzeigen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DesignTokens.accentCyan,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable timer tiles
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: activeTimers.length,
            itemBuilder: (context, index) {
              final timer = activeTimers[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildTimerTile(context, timer, isPsychedelicMode, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerTile(BuildContext context, Entry timer, bool isPsychedelicMode, int index) {
    final theme = Theme.of(context);
    final progress = timer.timerProgress;
    final progressColor = _getProgressBasedColor(progress, isPsychedelicMode);
    final textColor = _getTextColorForBackground(progressColor);
    
    return GestureDetector(
      onTap: widget.onTimerTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              progressColor.withOpacity(0.15),
              progressColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: progressColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: progressColor.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and progress
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: progressColor,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      backgroundColor: progressColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Substance name
              Text(
                timer.substanceName ?? 'Unbekannt',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Time remaining
              Text(
                _formatTimerText(timer.formattedRemainingTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Progress percentage
              Text(
                '${(progress * 100).toInt()}% abgeschlossen',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).slideX(
      begin: 0.3,
      end: 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ).fadeIn(
      duration: const Duration(milliseconds: 400),
    );
  }

  // Helper method to determine text color based on luminance
  Color _getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // Helper method to get progress-based color with enhanced color transitions
  Color _getProgressBasedColor(double progress, bool isPsychedelicMode) {
    if (isPsychedelicMode) {
      // Use psychedelic colors in trippy mode
      if (progress < 0.3) {
        return Color.lerp(DesignTokens.accentCyan, DesignTokens.successGreen, 0.3)!;
      } else if (progress < 0.7) {
        return Color.lerp(DesignTokens.accentCyan, DesignTokens.warningOrange, 0.3)!;
      } else {
        return Color.lerp(DesignTokens.accentCyan, DesignTokens.errorRed, 0.3)!;
      }
    }
    
    // Enhanced color transitions based on progress (smooth gradients)
    if (progress < 0.2) {
      return DesignTokens.successGreen;
    } else if (progress < 0.4) {
      return Color.lerp(DesignTokens.successGreen, DesignTokens.accentCyan, (progress - 0.2) / 0.2)!;
    } else if (progress < 0.6) {
      return Color.lerp(DesignTokens.accentCyan, DesignTokens.warningYellow, (progress - 0.4) / 0.2)!;
    } else if (progress < 0.8) {
      return Color.lerp(DesignTokens.warningYellow, DesignTokens.warningOrange, (progress - 0.6) / 0.2)!;
    } else {
      return Color.lerp(DesignTokens.warningOrange, DesignTokens.errorRed, (progress - 0.8) / 0.2)!;
    }
  }

  // Helper method to format timer text for better display
  String _formatTimerText(String originalText) {
    // Handle "abgelaufen" case specifically
    if (originalText.toLowerCase().contains('abgelaufen') || 
        originalText.toLowerCase().contains('expired')) {
      return 'Abgelaufen';
    }
    
    // Shorten common time formats
    String formatted = originalText
        .replaceAll('Stunde', 'h')
        .replaceAll('Std', 'h')
        .replaceAll('Minute', 'm')
        .replaceAll('Min', 'm')
        .replaceAll(' ', '');
    
    // If still too long, truncate further
    if (formatted.length > 8) {
      // Try to extract just numbers and units
      final regex = RegExp(r'(\d+)([hm])');
      final matches = regex.allMatches(formatted);
      if (matches.isNotEmpty) {
        final parts = matches.map((m) => '${m.group(1)}${m.group(2)}').take(2);
        formatted = parts.join(' ');
      }
    }
    
    return formatted;
  }
}