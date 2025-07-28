import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with SingleTickerProviderStateMixin, SafeStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  final TextEditingController _timerInputController = TextEditingController();
  late TimerService _timerService;
  final FocusNode _focusNode = FocusNode();
  
  bool _showTimerInput = false;
  bool _isDisposed = false;
  final List<int> _suggestionMinutes = [15, 30, 45, 60, 90, 120];

  // Constants for UI layout
  static const double defaultFallbackHeight = 50.0;
  static const double kMinimumHeightFallback = 25.0;
  static const double _overflowAdjustment = 15.0; // Account for the 15-pixel overflow issue

  @override
  void initState() {
    super.initState();
    
    try {
      ErrorHandler.logTimer('INIT', 'ActiveTimerBar initialisiert für ${widget.timer.substanceName}');
      
      // Get TimerService from provider
      _timerService = Provider.of<TimerService>(context, listen: false);
      
      // Get animation settings based on Impeller status
      final animationSettings = ImpellerHelper.getTimerAnimationSettings();
      final duration = animationSettings['animationDuration'] as Duration;
      
      _animationController = AnimationController(
        duration: duration,
        vsync: this,
      );
      
      _pulseAnimation = Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      _progressAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      
      // Only start pulsing animation if Impeller supports it
      if (ImpellerHelper.shouldEnableFeature('pulsing')) {
        _animationController.repeat(reverse: true);
      } else {
        // Use a simple static state for problematic devices
        _animationController.value = 1.0;
      }
      
      ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'Animation Controller erfolgreich initialisiert');
    } catch (e, stackTrace) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Initialisieren: $e');
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Stack trace: $stackTrace');
      
      // Log potential Impeller issue
      ImpellerHelper.logPerformanceIssue('ACTIVE_TIMER_BAR', 'Animation initialization failed: $e');
    }
  }

  // Helper method to determine text color based on luminance
  Color _getTextColorForBackground(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // Helper method to get progress-based color with enhanced color transitions
  Color _getProgressBasedColor(double progress, PsychedelicThemeService? psychedelicService) {
    if (psychedelicService?.isPsychedelicMode == true) {
      final substanceColors = psychedelicService!.getCurrentSubstanceColors();
      final baseColor = substanceColors['primary'] ?? DesignTokens.accentCyan;
      
      // Apply progress-based intensity in trippy mode
      if (progress < 0.3) {
        return Color.lerp(baseColor, DesignTokens.successGreen, 0.3)!;
      } else if (progress < 0.7) {
        return Color.lerp(baseColor, DesignTokens.warningOrange, 0.3)!;
      } else {
        return Color.lerp(baseColor, DesignTokens.errorRed, 0.3)!;
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

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    
    ErrorHandler.logDispose('ACTIVE_TIMER_BAR', 'ActiveTimerBar dispose gestartet');
    
    try {
      _animationController.stop();
      _animationController.dispose();
      ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'AnimationController erfolgreich disposed');
    } catch (e, stackTrace) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Dispose des AnimationController: $e');
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Stack trace: $stackTrace');
    }
    
    try {
      _timerInputController.dispose();
      ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'TextEditingController erfolgreich disposed');
    } catch (e, stackTrace) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Dispose des TextEditingController: $e');
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Stack trace: $stackTrace');
    }
    
    try {
      _focusNode.dispose();
      ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'FocusNode erfolgreich disposed');
    } catch (e, stackTrace) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Dispose des FocusNode: $e');
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Stack trace: $stackTrace');
    }
    
    ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'ActiveTimerBar dispose abgeschlossen');
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Early return if widget is not mounted or disposed
    if (!mounted || _isDisposed) {
      return const SizedBox.shrink();
    }
    
    return CrashProtectionWrapper(
      context: 'ActiveTimerBar',
      fallbackWidget: _buildTimerErrorFallback(context),
      child: _buildTimerContent(context),
    );
  }
  
  Widget _buildTimerErrorFallback(BuildContext context) {
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
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final progress = widget.timer.timerProgress;
      
      // Additional safety check for timer
      if (widget.timer.timerEndTime == null) {
        ErrorHandler.logWarning('ACTIVE_TIMER_BAR', 'Timer hat keine EndTime');
        return const SizedBox.shrink();
      }
      
      return Consumer<PsychedelicThemeService>(
        builder: (context, psychedelicService, child) {
          // Early return if widget is not mounted or disposed
          if (!mounted || _isDisposed) {
            return const SizedBox.shrink();
          }
          
          // Safe access to psychedelic service
          final progressColor = _getProgressBasedColor(progress, psychedelicService);
          final textColor = _getTextColorForBackground(progressColor);
          final isPsychedelicMode = psychedelicService.isPsychedelicMode;
          
          return AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              // Early return if widget is not mounted or disposed
              if (!mounted || _isDisposed) {
                return const SizedBox.shrink();
              }
              
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: () {
                    if (mounted && !_isDisposed && widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Determine if we have enough space for full layout
                      final hasMinimalSpace = constraints.maxHeight >= 25;
                      
                      if (!hasMinimalSpace) {
                        // Return minimal compact version for very small constraints
                        return Container(
                          margin: EdgeInsets.all(Spacing.xs),
                          padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                          decoration: BoxDecoration(
                            color: progressColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: progressColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                color: progressColor,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.timer.substanceName ?? 'Timer',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTimerText(widget.timer.formattedRemainingTime),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // Regular layout for sufficient space
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                        constraints: BoxConstraints(
                          minHeight: 25, // Ensure minimum height
                          maxHeight: constraints.maxHeight.isFinite 
                              ? constraints.maxHeight - _overflowAdjustment // Subtract overflow amount to prevent issues
                              : defaultFallbackHeight, // Fallback height if infinite
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor.withOpacity(0.15),
                              progressColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: Spacing.borderRadiusLg,
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
                        child: ClipRRect(
                          borderRadius: Spacing.borderRadiusLg,
                          child: _buildTimerInnerContent(theme, progressColor, textColor, isPsychedelicMode, progress),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Erstellen der ActiveTimerBar: $e');
      
      // Fallback widget
      return _buildTimerErrorFallback(context);
    }
  }

  Widget _buildTimerInputField(Color progressColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.05),
        borderRadius: Spacing.borderRadiusMd,
        border: Border.all(
          color: progressColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timer anpassen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          
          // Custom time input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _timerInputController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'z.B. 64',
                    hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                    prefixIcon: Icon(Icons.timer_outlined, color: progressColor),
                    suffixText: 'Min',
                    suffixStyle: TextStyle(color: textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: progressColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: progressColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: progressColor.withOpacity(0.3)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: _onTimerInputChanged,
                  onSubmitted: (_) => _updateTimerDuration(),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              ElevatedButton(
                onPressed: _updateTimerDuration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: progressColor,
                  foregroundColor: _getTextColorForBackground(progressColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
          
          // Real-time conversion display
          if (_timerInputController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Text(
                'Entspricht: ${_formatInputTime(_timerInputController.text)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          const SizedBox(height: Spacing.sm),
          
          // Suggestion chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _suggestionMinutes.map((minutes) {
              return GestureDetector(
                onTap: () {
                  _timerInputController.text = minutes.toString();
                  _updateTimerDuration();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: progressColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${minutes}min',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _onTimerInputChanged(String value) {
    if (mounted && !_isDisposed) {
      safeSetState(() {}); // Trigger rebuild to update conversion display
    }
  }

  String _formatInputTime(String input) {
    final minutes = int.tryParse(input);
    if (minutes == null || minutes <= 0) return '';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '$hours Std${remainingMinutes > 0 ? ' $remainingMinutes Min' : ''}';
    } else {
      return '$minutes Min';
    }
  }

  Future<void> _updateTimerDuration() async {
    if (_isDisposed || !mounted) return;
    
    final inputText = _timerInputController.text.trim();
    if (inputText.isEmpty) return;
    
    final minutes = int.tryParse(inputText);
    if (minutes == null || minutes <= 0) {
      _showErrorMessage('Bitte gib eine gültige Anzahl Minuten ein');
      return;
    }
    
    try {
      ErrorHandler.logTimer('UPDATE', 'Timer wird auf $minutes Minuten angepasst');
      
      // Update the timer with new duration
      final newDuration = Duration(minutes: minutes);
      await _timerService.updateTimerDuration(widget.timer, newDuration);
      
      // Hide input field and clear text
      if (mounted && !_isDisposed) {
        safeSetState(() {
          _showTimerInput = false;
          _timerInputController.clear();
        });
      }
      
      // Unfocus the text field
      if (_focusNode.hasFocus) {
        _focusNode.unfocus();
      }
      
      // Show success message
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Timer auf ${_formatInputTime(inputText)} angepasst'),
              ],
            ),
            backgroundColor: DesignTokens.successGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      
      ErrorHandler.logSuccess('ACTIVE_TIMER_BAR', 'Timer erfolgreich angepasst');
    } catch (e) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Fehler beim Anpassen des Timers: $e');
      _showErrorMessage('Fehler beim Aktualisieren des Timers: $e');
    }
  }

  // Helper method to get responsive font size with height awareness
  double _getResponsiveFontSize(double availableWidth, {required bool isTitle, bool isSmallHeight = false}) {
    // Reduce all sizes for very small heights
    if (isSmallHeight) {
      return isTitle ? 11.0 : 9.0;
    }
    
    if (availableWidth < 280) {
      return isTitle ? 12.0 : 10.0; // Very small screens
    } else if (availableWidth < 350) {
      return isTitle ? 14.0 : 11.0; // Small screens
    } else {
      return isTitle ? 16.0 : 12.0; // Normal screens
    }
  }

  // Helper method to format timer text for better display
  String _formatTimerText(String originalText) {
    // Handle "abgelaufen" case specifically
    if (originalText.toLowerCase().contains('abgelaufen') || 
        originalText.toLowerCase().contains('expired')) {
      return 'Ende';
    }
    
    // Shorten common time formats more aggressively for small spaces
    String formatted = originalText
        .replaceAll('Stunde', 'h')
        .replaceAll('Std', 'h')
        .replaceAll('Minute', 'm')
        .replaceAll('Min', 'm')
        .replaceAll(' ', '');
    
    // If still too long, truncate further
    if (formatted.length > 6) {
      // Try to extract just numbers and units
      final regex = RegExp(r'(\d+)([hm])');
      final matches = regex.allMatches(formatted);
      if (matches.isNotEmpty) {
        final parts = matches.map((m) => '${m.group(1)}${m.group(2)}').take(2); // Only take first 2 parts
        formatted = parts.join('');
      }
    }
    
    // Final fallback - truncate if still too long
    if (formatted.length > 6) {
      formatted = formatted.substring(0, 6);
    }
    
    return formatted;
  }

  void _showErrorMessage(String message) {
    if (mounted && !_isDisposed) {
      ErrorHandler.logError('ACTIVE_TIMER_BAR', 'Zeige Fehlermeldung: $message');
      
      SafeNavigation.showDialogSafe(
        context,
        AlertDialog(
          title: const Text('Timer Fehler'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTimerInnerContent(ThemeData theme, Color progressColor, Color textColor, bool isPsychedelicMode, double progress) {
    if (!mounted || _isDisposed) {
      return const SizedBox.shrink();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure we have valid height constraints
        final safeHeight = constraints.maxHeight.isFinite 
            ? constraints.maxHeight 
            : kMinimumHeightFallback; // Fallback to minimum height
            
        return Stack(
          children: [
            // Animated progress background with constrained height
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Container(
                  height: safeHeight,
                  decoration: BoxDecoration(
                    borderRadius: Spacing.borderRadiusLg,
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
                );
              },
            ),
        // Content with proper constraints to prevent overflow
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs), // Further reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min to prevent overflow by not expanding beyond content size
            children: [
              // Compact row layout with proper flex distribution
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate available height for content
                  final availableHeight = constraints.maxHeight;
                  final isVerySmall = availableHeight < 40;
                  
                  return IntrinsicHeight(
                    child: Row(
                      children: [
                        // Icon container with reduced size for small heights
                        Container(
                          padding: EdgeInsets.all(isVerySmall ? Spacing.xxs : Spacing.xs),
                          decoration: BoxDecoration(
                            color: progressColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isVerySmall ? 4 : 6),
                          ),
                          child: Icon(
                            Icons.timer_rounded,
                            color: progressColor,
                            size: isVerySmall ? 14 : 16, // Smaller icon for tight constraints
                          ),
                        ),
                        SizedBox(width: isVerySmall ? Spacing.xs : Spacing.sm),
                        Expanded(
                          flex: 3, // Give more space to the substance name
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Prevent overflow
                            children: [
                              // Substance name with strict height control
                              Flexible(
                                child: Text(
                                  widget.timer.substanceName ?? 'Unbekannte Substanz',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: _getResponsiveFontSize(constraints.maxWidth, isTitle: true, isSmallHeight: isVerySmall),
                                  ),
                                  maxLines: isVerySmall ? 1 : 2, // Single line for very small heights
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Only show status text if there's enough space
                              if (!isVerySmall) 
                                Text(
                                  'Timer läuft',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: textColor.withOpacity(0.7),
                                    fontSize: _getResponsiveFontSize(constraints.maxWidth, isTitle: false, isSmallHeight: isVerySmall),
                                  ),
                                ),
                          ],
                        ),
                        ),
                        Flexible(
                          flex: 2, // Timer display area
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _formatTimerText(widget.timer.formattedRemainingTime),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: _getResponsiveFontSize(constraints.maxWidth, isTitle: true, isSmallHeight: isVerySmall),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (widget.timer.isTimerExpired && !isVerySmall) 
                                Text(
                                  'Abgelaufen',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: DesignTokens.errorRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: _getResponsiveFontSize(constraints.maxWidth, isTitle: false, isSmallHeight: isVerySmall),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        // Only show edit button if there's enough space
                        if (!isVerySmall) ...[
                          SizedBox(width: isVerySmall ? Spacing.xxs : Spacing.xs),
                          IconButton(
                            onPressed: () {
                              if (mounted && !_isDisposed) {
                                safeSetState(() {
                                  _showTimerInput = !_showTimerInput;
                                });
                              }
                            },
                            icon: Icon(
                              _showTimerInput ? Icons.keyboard_arrow_up : Icons.edit_rounded,
                              color: textColor,
                              size: 16, // Smaller icon
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              // Only show progress bar if there's enough vertical space
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final showProgressBar = availableHeight > 25; // Show only if enough space
                  
                  if (!showProgressBar) {
                    return const SizedBox.shrink();
                  }
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: availableHeight < 40 ? Spacing.xxs : Spacing.xs),
                      // Enhanced progress bar with animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: progress),
                        builder: (context, animatedProgress, child) {
                          return Container(
                            height: availableHeight < 40 ? 3 : 4, // Smaller bar for tight space
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: progressColor.withOpacity(0.2),
                            ),
                            child: Stack(
                              children: [
                                // Background progress
                                Container(
                                  height: availableHeight < 40 ? 3 : 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        progressColor,
                                        progressColor.withOpacity(0.8),
                                      ],
                                      stops: [0.0, animatedProgress],
                                    ),
                                  ),
                                ),
                                // Animated shine effect - only if Impeller supports it and there's space
                                if (isPsychedelicMode && ImpellerHelper.shouldEnableFeature('shine') && availableHeight >= 40)
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.3 * _pulseAnimation.value),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                            stops: [
                                              (animatedProgress - 0.1).clamp(0.0, 1.0),
                                              animatedProgress.clamp(0.0, 1.0),
                                              (animatedProgress + 0.1).clamp(0.0, 1.0),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              // Timer input field with animation - only shown if enough space
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final hasSpaceForInput = availableHeight > 50;
                  
                  if (!hasSpaceForInput) {
                    return const SizedBox.shrink();
                  }
                  
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _showTimerInput ? _buildTimerInputField(progressColor, textColor) : const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
      },
    );
  }
}