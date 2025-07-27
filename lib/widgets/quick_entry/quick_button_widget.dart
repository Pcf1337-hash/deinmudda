import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/quick_button_config.dart';
import '../../services/timer_service.dart';
import '../../services/substance_service.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/app_icon_generator.dart';

class QuickButtonWidget extends StatefulWidget {
  final QuickButtonConfig config;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isDragging;
  final bool isEditing;

  const QuickButtonWidget({
    super.key,
    required this.config,
    this.onTap,
    this.onLongPress,
    this.isDragging = false,
    this.isEditing = false,
  });

  @override
  State<QuickButtonWidget> createState() => _QuickButtonWidgetState();
}

class _QuickButtonWidgetState extends State<QuickButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveEaseOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDragging && widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  // Helper method to format timer text for compact display
  String _formatTimerText(String originalText) {
    if (originalText.isEmpty) return '';
    
    // Handle "abgelaufen" case specifically
    if (originalText.toLowerCase().contains('abgelaufen') || 
        originalText.toLowerCase().contains('expired')) {
      return 'Ende';
    }
    
    // Shorten common time formats more aggressively
    String formatted = originalText
        .replaceAll('Stunde', 'h')
        .replaceAll('Std', 'h')
        .replaceAll('Minute', 'm')
        .replaceAll('Min', 'm')
        .replaceAll(' ', '');
    
    // If still too long, truncate further
    if (formatted.length > 5) {
      // Try to extract just numbers and units
      final regex = RegExp(r'(\d+)([hm])');
      final matches = regex.allMatches(formatted);
      if (matches.isNotEmpty) {
        formatted = matches.map((m) => '${m.group(1)}${m.group(2)}').take(1).join(); // Only first part
      }
    }
    
    // Final fallback
    if (formatted.length > 5) {
      formatted = formatted.substring(0, 5);
    }
    
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use stored icon/color if available, otherwise fall back to generated ones
    final substanceIcon = widget.config.icon ?? AppIconGenerator.getSubstanceIcon(widget.config.substanceName);
    final substanceColor = widget.config.color ?? AppIconGenerator.getSubstanceColor(widget.config.substanceName);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isDragging ? 1.1 : _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: Container(
              width: 80,
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 2.0), // Reduced margin for consistent spacing
              decoration: BoxDecoration(
                gradient: isDark
                    ? DesignTokens.glassGradientDark
                    : DesignTokens.glassGradientLight,
                borderRadius: Spacing.borderRadiusLg,
                border: Border.all(
                  color: widget.isEditing
                      ? DesignTokens.warningYellow
                      : substanceColor.withOpacity(0.3),
                  width: widget.isEditing ? 2 : 1,
                ),
                boxShadow: [
                  if (widget.isDragging || _glowAnimation.value > 0)
                    BoxShadow(
                      color: substanceColor.withOpacity(0.3 + (_glowAnimation.value * 0.2)),
                      blurRadius: 15 + (_glowAnimation.value * 10),
                      offset: const Offset(0, 5),
                    ),
                  BoxShadow(
                    color: isDark
                        ? DesignTokens.shadowDark.withOpacity(0.2)
                        : DesignTokens.shadowLight.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Main content
                  Padding(
                    padding: Spacing.paddingMd,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(Spacing.xs),
                          decoration: BoxDecoration(
                            color: substanceColor.withOpacity(0.1),
                            borderRadius: Spacing.borderRadiusSm,
                          ),
                          child: Icon(
                            substanceIcon,
                            color: substanceColor,
                            size: Spacing.iconMd,
                          ),
                        ),
                        
                        Spacing.verticalSpaceXs,
                        
                        // Substance name - improved overflow handling
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.config.substanceName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Increased from 10 for better readability
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        // Dosage - improved overflow handling  
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.config.formattedDosage,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: substanceColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 11, // Increased from 9 for better readability
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        
                        // Compact info row: cost and timer duration side by side
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Cost information - show if cost is set
                            if (widget.config.cost > 0) ...[
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: DesignTokens.accentEmerald.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${widget.config.cost.toStringAsFixed(2).replaceAll('.', ',')}€',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: DesignTokens.accentEmerald,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 9, // Increased from 7 for better readability
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.config.cost > 0) const SizedBox(width: 2), // Space between cost and timer
                            ],
                            
                            // Timer duration information - show planned duration from substance
                            Consumer<SubstanceService>(
                              builder: (context, substanceService, child) {
                                return FutureBuilder(
                                  future: substanceService.getSubstanceById(widget.config.substanceId),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData && snapshot.data?.duration != null) {
                                      final duration = snapshot.data!.duration!;
                                      final hours = duration.inHours;
                                      final minutes = duration.inMinutes.remainder(60);
                                      String durationText;
                                      
                                      if (hours > 0 && minutes > 0) {
                                        durationText = '${hours}h ${minutes}m';
                                      } else if (hours > 0) {
                                        durationText = '${hours}h';
                                      } else {
                                        durationText = '${minutes}m';
                                      }
                                      
                                      return Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: DesignTokens.accentPurple.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.timer_outlined,
                                                size: 6,
                                                color: DesignTokens.accentPurple,
                                              ),
                                              const SizedBox(width: 1),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  durationText,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: DesignTokens.accentPurple,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 9, // Increased from 7 for better readability
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Edit mode indicator
                  if (widget.isEditing)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: DesignTokens.warningYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.drag_indicator_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: Duration(milliseconds: widget.config.position * 100),
    ).slideX(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }
}

// Placeholder for adding new quick button
class AddQuickButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const AddQuickButtonWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 2.0), // Consistent margin with QuickButtonWidget
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.glassGradientDark
              : DesignTokens.glassGradientLight,
          borderRadius: Spacing.borderRadiusLg,
          border: Border.all(
            color: DesignTokens.primaryIndigo.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Padding(
          padding: Spacing.paddingMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: DesignTokens.primaryIndigo,
                size: Spacing.iconMd, // Use same icon size as regular buttons
              ),
              Spacing.verticalSpaceXs,
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Hinzufügen',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignTokens.primaryIndigo,
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Match regular button font size for consistency
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
      delay: const Duration(milliseconds: 500),
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveBack,
    );
  }
}