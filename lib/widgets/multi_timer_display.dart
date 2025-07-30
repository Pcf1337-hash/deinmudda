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
/// 
/// This widget automatically hides expired timers to prevent clutter
/// and uses responsive design to prevent overflow on different screen sizes.
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
  
  /// Builds the main timer content with automatic expired timer filtering.
  /// 
  /// This method filters out expired timers so they don't appear in the main
  /// timer area. Expired timers should appear in the "Recent Entries" section instead.
  Widget _buildTimerContent(BuildContext context) {
    try {
      return Consumer2<TimerService, PsychedelicThemeService>(
        builder: (context, timerService, psychedelicService, child) {
          // Early return if widget is not mounted or disposed
          if (!mounted || _isDisposed) {
            return const SizedBox.shrink();
          }
          
          final allActiveTimers = timerService.activeTimers;
          final isPsychedelicMode = psychedelicService.isPsychedelicMode;
          
          // Filter out expired timers to ensure only truly active timers are shown
          // This prevents expired timers from appearing in the main timer area
          final actuallyActiveTimers = allActiveTimers.where((timer) => 
            timer.isTimerActive && !timer.isTimerExpired
          ).toList();
          
          // Hide the entire widget if no active timers remain
          if (actuallyActiveTimers.isEmpty) {
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
                    child: _buildTimerTiles(context, actuallyActiveTimers, isPsychedelicMode),
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

  /// Determines the layout based on number of active timers.
  /// 
  /// - Single timer: Uses full-width card for better visibility
  /// - Multiple timers: Uses horizontal scrollable tiles to save space
  Widget _buildTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode) {
    if (activeTimers.length == 1) {
      // Single timer - use full width card
      return _buildSingleTimerCard(context, activeTimers.first, isPsychedelicMode);
    } else {
      // Multiple timers - use horizontal scrollable tiles
      return _buildMultipleTimerTiles(context, activeTimers, isPsychedelicMode);
    }
  }

  /// Builds a responsive single timer card that adapts to screen size.
  /// 
  /// Uses LayoutBuilder to calculate appropriate dimensions and prevent overflow.
  /// Implements Material Design 3 principles with psychedelic theme support.
  Widget _buildSingleTimerCard(BuildContext context, Entry timer, bool isPsychedelicMode) {
    final theme = Theme.of(context);
    final progress = timer.timerProgress;
    final progressColor = _getProgressBasedColor(progress, isPsychedelicMode);
    final textColor = _getTextColorForBackground(progressColor);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive height calculation to prevent overflow
        // Base height scales with available space but stays within bounds
        final double cardHeight = (constraints.maxWidth * 0.15).clamp(60.0, 90.0);
        
        return GestureDetector(
          onTap: widget.onTimerTap,
          child: Container(
            width: double.infinity,
            height: cardHeight,
            decoration: BoxDecoration(
              // Material Design 3 inspired gradient with psychedelic theme support
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  progressColor.withOpacity(0.12), // MD3 surface tint opacity
                  progressColor.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16), // MD3 large container radius
              border: Border.all(
                color: progressColor.withOpacity(0.25),
                width: 1.0, // Thinner border for MD3 aesthetic
              ),
              boxShadow: [
                // MD3 elevation shadow style
                BoxShadow(
                  color: progressColor.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                if (isPsychedelicMode) ...[
                  // Additional psychedelic glow effect
                  BoxShadow(
                    color: progressColor.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ],
            ),
            child: Stack(
              children: [
                // Subtle progress background indicator
                Container(
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        progressColor.withOpacity(0.2),
                        progressColor.withOpacity(0.05),
                      ],
                      stops: [0.0, progress], // Progress-based gradient stop
                    ),
                  ),
                ),
                // Main content with flexible padding
                Padding(
                  padding: EdgeInsets.all(cardHeight * 0.15), // Responsive padding
                  child: Row(
                    children: [
                      // Timer icon with responsive sizing
                      Container(
                        padding: EdgeInsets.all(cardHeight * 0.08),
                        decoration: BoxDecoration(
                          color: progressColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.timer_rounded,
                          color: progressColor,
                          size: (cardHeight * 0.25).clamp(16.0, 24.0), // Responsive icon size
                        ),
                      ),
                      SizedBox(width: cardHeight * 0.2), // Responsive spacing
                      // Flexible content area prevents overflow
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Substance name with overflow protection
                            Flexible(
                              child: Text(
                                timer.substanceName ?? 'Unbekannte Substanz',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (cardHeight * 0.2).clamp(14.0, 18.0), // Responsive font
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: cardHeight * 0.05),
                            // Timer status with responsive font size
                            Flexible(
                              child: Text(
                                _formatTimerText(timer.formattedRemainingTime),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  fontSize: (cardHeight * 0.16).clamp(12.0, 16.0), // Responsive font
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Responsive progress indicator
                      SizedBox(
                        width: cardHeight * 0.5,
                        height: cardHeight * 0.5,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              backgroundColor: progressColor.withOpacity(0.2),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).toInt()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: (cardHeight * 0.12).clamp(8.0, 12.0), // Responsive font
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
      },
    );
  }

  /// Builds responsive multiple timer tiles layout.
  /// 
  /// Uses LayoutBuilder to calculate appropriate dimensions and prevent overflow.
  /// Creates a compact header and horizontal scrollable list of timer tiles.
  Widget _buildMultipleTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions to prevent overflow
        final double maxContainerHeight = constraints.maxHeight * 0.3; // Max 30% of available height
        final double headerHeight = 40; // Fixed header height
        final double tileHeight = (maxContainerHeight - headerHeight).clamp(80.0, 120.0);
        final double totalHeight = headerHeight + tileHeight;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            // Compact header with timer count
            Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: DesignTokens.accentCyan,
                    size: 16, // Smaller icon for compact header
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${activeTimers.length} aktive Timer',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: DesignTokens.accentCyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Fixed readable size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Compact "View All" button
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
                        'Alle',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DesignTokens.accentCyan,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Responsive horizontal scrollable timer tiles
            Container(
              height: tileHeight,
              constraints: BoxConstraints(
                maxHeight: tileHeight,
                minHeight: 80, // Minimum usable height
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: activeTimers.length,
                itemBuilder: (context, index) {
                  final timer = activeTimers[index];
                  // Calculate responsive tile width based on screen size
                  final double tileWidth = (constraints.maxWidth * 0.4).clamp(140.0, 180.0);
                  
                  return Container(
                    width: tileWidth,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildTimerTile(context, timer, isPsychedelicMode, index, tileHeight),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds individual timer tile with responsive design.
  /// 
  /// Each tile adjusts its content size based on the provided height parameter
  /// to ensure consistent appearance across different screen sizes.
  Widget _buildTimerTile(BuildContext context, Entry timer, bool isPsychedelicMode, int index, double tileHeight) {
    final theme = Theme.of(context);
    final progress = timer.timerProgress;
    final progressColor = _getProgressBasedColor(progress, isPsychedelicMode);
    final textColor = _getTextColorForBackground(progressColor);
    
    return GestureDetector(
      onTap: widget.onTimerTap,
      child: Container(
        height: tileHeight,
        decoration: BoxDecoration(
          // Material Design 3 inspired styling with psychedelic support
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              progressColor.withOpacity(0.12), // MD3 surface tint
              progressColor.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(12), // MD3 medium container radius
          border: Border.all(
            color: progressColor.withOpacity(0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: progressColor.withOpacity(0.12),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(tileHeight * 0.1), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and progress - responsive layout
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(tileHeight * 0.05),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.timer_rounded,
                      color: progressColor,
                      size: (tileHeight * 0.15).clamp(12.0, 16.0), // Responsive icon size
                    ),
                  ),
                  const Spacer(),
                  // Responsive circular progress indicator
                  SizedBox(
                    width: tileHeight * 0.25,
                    height: tileHeight * 0.25,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      backgroundColor: progressColor.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: tileHeight * 0.1), // Responsive spacing
              // Substance name with flexible sizing
              Expanded(
                flex: 2,
                child: Text(
                  timer.substanceName ?? 'Unbekannt',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: (tileHeight * 0.14).clamp(12.0, 16.0), // Responsive font
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Flexible spacer
              const Spacer(),
              // Time remaining with responsive font
              Text(
                _formatTimerText(timer.formattedRemainingTime),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: (tileHeight * 0.12).clamp(10.0, 14.0), // Responsive font
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tileHeight * 0.02),
              // Progress percentage with responsive font
              Text(
                '${(progress * 100).toInt()}% fertig',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textColor.withOpacity(0.6),
                  fontSize: (tileHeight * 0.1).clamp(8.0, 12.0), // Responsive font
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
  /// Formats timer text to be more compact and readable.
  /// 
  /// Converts long German text like "2 Stunden 30 Minuten" to "2h 30m"
  /// and handles special cases like expired timers.
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