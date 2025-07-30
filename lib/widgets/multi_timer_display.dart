import 'dart:async';
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
import '../utils/multi_timer_performance_helper.dart';

/// A modern multi-timer display widget that shows multiple active timers
/// in an attractive tile-based layout with glassmorphism design.
/// 
/// This widget automatically hides expired timers to prevent clutter
/// and uses responsive design to prevent overflow on different screen sizes.
/// 
/// Performance optimizations:
/// - Shared animation controller for memory efficiency
/// - Debounced timer updates to prevent excessive rebuilds
/// - Efficient timer filtering with early returns
/// - Animation optimizations for multiple concurrent timers
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
  
  // Performance optimization: debounce timer updates
  Timer? _updateDebounceTimer;
  bool _pendingUpdate = false;
  
  // Memory optimization: cache for improved performance with many timers
  List<Entry>? _cachedActiveTimers;
  DateTime? _lastCacheUpdate;

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
      
      // Only use animations if Impeller supports them and we have < 5 active timers
      // This prevents performance issues with many concurrent animations
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
      // Cancel any pending updates
      _updateDebounceTimer?.cancel();
      _updateDebounceTimer = null;
      
      _animationController.stop();
      _animationController.dispose();
      
      // Clear cache to free memory
      _cachedActiveTimers = null;
      
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
  /// Efficiently filters and caches active timers to improve performance
  /// with multiple concurrent timers.
  /// 
  /// Uses performance helper for optimized filtering and caching strategies.
  List<Entry> _getFilteredActiveTimers(List<Entry> allActiveTimers) {
    final now = DateTime.now();
    
    // Use cache if it's recent (within 5 seconds) to reduce processing
    if (_cachedActiveTimers != null && _lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!).inSeconds < 5) {
      return _cachedActiveTimers!;
    }
    
    // Use performance helper for optimized filtering
    final filtered = MultiTimerPerformanceHelper.filterActiveTimers(allActiveTimers);
    
    // Update cache
    _cachedActiveTimers = filtered;
    _lastCacheUpdate = now;
    
    return filtered;
  }
  
  /// Debounced timer update to prevent excessive rebuilds when multiple
  /// timers are updating their states simultaneously.
  void _scheduleUpdate() {
    if (_isDisposed) return;
    
    _pendingUpdate = true;
    _updateDebounceTimer?.cancel();
    _updateDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (_pendingUpdate && !_isDisposed && mounted) {
        setState(() {
          // Invalidate cache to force refresh
          _cachedActiveTimers = null;
        });
        _pendingUpdate = false;
      }
    });
  }
  /// Builds the main timer content with automatic expired timer filtering.
  /// 
  /// This method filters out expired timers so they don't appear in the main
  /// timer area. Expired timers should appear in the "Recent Entries" section instead.
  /// 
  /// Performance optimizations:
  /// - Uses cached filtering for repeated calls
  /// - Debounced updates to prevent excessive rebuilds
  /// - Early returns to minimize computation
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
          
          // Use optimized filtering with caching
          final actuallyActiveTimers = _getFilteredActiveTimers(allActiveTimers);
          
          // Hide the entire widget if no active timers remain
          if (actuallyActiveTimers.isEmpty) {
            return const SizedBox.shrink();
          }
          
          // Get performance analysis for optimization decisions
          final perfAnalysis = MultiTimerPerformanceHelper.analyzeTimerPerformance(actuallyActiveTimers);
          final shouldUseSimplified = perfAnalysis['shouldUseSimplifiedUI'] as bool;
          final animSettings = perfAnalysis['animationSettings'] as Map<String, dynamic>;
          
          // Schedule debounced update if we have many timers
          if (actuallyActiveTimers.length > 3) {
            _scheduleUpdate();
          }
          
          return AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              // Early return if widget is not mounted or disposed
              if (!mounted || _isDisposed) {
                return const SizedBox.shrink();
              }
              
              // Reduce animation complexity for many timers to improve performance
              final useSimpleAnimation = shouldUseSimplified || !animSettings['enableAnimations'];
              
              return Transform.translate(
                offset: useSimpleAnimation 
                    ? Offset.zero // No offset animation for many timers
                    : Offset(0, 50 * (1 - _slideAnimation.value)),
                child: Opacity(
                  opacity: _slideAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    child: RepaintBoundary(
                      // Use RepaintBoundary for better performance with multiple timers
                      child: _buildTimerTiles(context, actuallyActiveTimers, isPsychedelicMode, perfAnalysis),
                    ),
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
  /// 
  /// Performance optimization: Uses perfAnalysis to optimize rendering.
  Widget _buildTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode, Map<String, dynamic> perfAnalysis) {
    if (activeTimers.length == 1) {
      // Single timer - use full width card
      return _buildSingleTimerCard(context, activeTimers.first, isPsychedelicMode);
    } else {
      // Multiple timers - use horizontal scrollable tiles
      return _buildMultipleTimerTiles(context, activeTimers, isPsychedelicMode, perfAnalysis);
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
                  child: LayoutBuilder(
                    builder: (context, contentConstraints) {
                      return Row(
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
                          SizedBox(width: cardHeight * 0.15), // Reduced spacing for more content space
                          // Optimized content area with FittedBox for better text scaling
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, textConstraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Substance name with FittedBox for optimal scaling
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: textConstraints.maxWidth * 0.7, // Reserve space for progress
                                            maxWidth: textConstraints.maxWidth * 0.7,
                                          ),
                                          child: Text(
                                            timer.substanceName ?? 'Unbekannte Substanz',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: (cardHeight * 0.22).clamp(14.0, 20.0), // Optimized responsive font
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: cardHeight * 0.03),
                                    // Timer status with better scaling
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _formatTimerText(timer.formattedRemainingTime),
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: textColor.withOpacity(0.8),
                                            fontWeight: FontWeight.w500,
                                            fontSize: (cardHeight * 0.18).clamp(12.0, 16.0), // Optimized responsive font
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          // Compact responsive progress indicator
                          SizedBox(
                            width: cardHeight * 0.45,
                            height: cardHeight * 0.45,
                            child: Stack(
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                                  backgroundColor: progressColor.withOpacity(0.2),
                                ),
                                Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${(progress * 100).toInt()}%',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: (cardHeight * 0.14).clamp(8.0, 14.0), // Optimized responsive font
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
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
  /// 
  /// Performance optimization: Uses perfAnalysis for optimized rendering decisions.
  Widget _buildMultipleTimerTiles(BuildContext context, List<Entry> activeTimers, bool isPsychedelicMode, Map<String, dynamic> perfAnalysis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions with optimized height allocation
        final double maxContainerHeight = constraints.maxHeight * 0.35; // Increased from 30% to 35%
        final double headerHeight = 35; // Slightly reduced header height
        final double tileHeight = (maxContainerHeight - headerHeight).clamp(90.0, 140.0); // Increased max height
        final double totalHeight = headerHeight + tileHeight;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          children: [
            // Optimized compact header with timer count
            Container(
              height: headerHeight,
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: DesignTokens.accentCyan,
                    size: 14, // Compact icon for efficient space use
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${activeTimers.length} Timer aktiv',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: DesignTokens.accentCyan,
                          fontWeight: FontWeight.w600,
                          fontSize: 13, // Optimized readable size
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Compact "View All" button
                  GestureDetector(
                    onTap: widget.onTimerTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: DesignTokens.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: DesignTokens.accentCyan.withOpacity(0.3),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Alle',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: DesignTokens.accentCyan,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
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
                  // Calculate optimized tile width for better content visibility
                  final double tileWidth = (constraints.maxWidth * 0.4).clamp(140.0, 180.0);
                  
                  return Container(
                    width: tileWidth,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildTimerTile(context, timer, isPsychedelicMode, index, tileHeight, activeTimers, perfAnalysis),
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
  /// 
  /// Performance optimization: Animation complexity is reduced when many timers
  /// are active to maintain smooth performance.
  Widget _buildTimerTile(BuildContext context, Entry timer, bool isPsychedelicMode, int index, double tileHeight, List<Entry> activeTimers, Map<String, dynamic> perfAnalysis) {
    final theme = Theme.of(context);
    final progress = timer.timerProgress;
    final progressColor = _getProgressBasedColor(progress, isPsychedelicMode);
    final textColor = _getTextColorForBackground(progressColor);
    
    // Get animation settings from performance analysis
    final animSettings = perfAnalysis['animationSettings'] as Map<String, dynamic>;
    final enableAnimations = animSettings['enableAnimations'] as bool;
    final animDuration = animSettings['animationDuration'] as int;
    final animDelay = animSettings['animationDelay'] as int;
    
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
        child: LayoutBuilder(
          builder: (context, tileConstraints) {
            return Padding(
              padding: EdgeInsets.all(tileHeight * 0.08), // Slightly reduced padding for more content space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Optimized header with compact layout
                  SizedBox(
                    height: tileHeight * 0.2, // Fixed height for header
                    child: Row(
                      children: [
                        // Compact timer icon
                        Container(
                          padding: EdgeInsets.all(tileHeight * 0.04),
                          decoration: BoxDecoration(
                            color: progressColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.timer_rounded,
                            color: progressColor,
                            size: (tileHeight * 0.12).clamp(10.0, 14.0), // Smaller icon
                          ),
                        ),
                        SizedBox(width: tileConstraints.maxWidth * 0.02),
                        // Compact progress indicator
                        SizedBox(
                          width: tileHeight * 0.18,
                          height: tileHeight * 0.18,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                            backgroundColor: progressColor.withOpacity(0.2),
                          ),
                        ),
                        const Spacer(),
                        // Progress percentage moved to header for space efficiency
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                            fontSize: (tileHeight * 0.1).clamp(8.0, 11.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: tileHeight * 0.06),
                  // Optimized substance name with FittedBox for better scaling
                  Flexible(
                    flex: 3, // Increased flex for more space
                    child: LayoutBuilder(
                      builder: (context, nameConstraints) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: nameConstraints.maxWidth,
                              maxWidth: nameConstraints.maxWidth,
                            ),
                            child: Text(
                              timer.substanceName ?? 'Unbekannt',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: (tileHeight * 0.16).clamp(12.0, 18.0), // Larger base font
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Flexible spacer for balance
                  const Spacer(),
                  // Compact time remaining display
                  Flexible(
                    flex: 1,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatTimerText(timer.formattedRemainingTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: (tileHeight * 0.13).clamp(10.0, 14.0),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).animate(
      // Use performance-optimized animation settings
      delay: enableAnimations ? Duration(milliseconds: animDelay * index) : Duration.zero,
    ).slideX(
      begin: enableAnimations ? 0.3 : 0.0,
      end: 0.0,
      duration: Duration(milliseconds: animDuration),
      curve: Curves.easeOutCubic,
    ).fadeIn(
      duration: Duration(milliseconds: animDuration),
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