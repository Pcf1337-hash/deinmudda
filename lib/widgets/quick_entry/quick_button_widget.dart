import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quick_button_config.dart';
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
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
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
                                fontSize: 10,
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
                                fontSize: 9,
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
        margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: DesignTokens.primaryIndigo,
              size: Spacing.iconLg,
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
                    fontSize: 9,
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