import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../services/psychedelic_theme_service.dart';
import '../theme/design_tokens.dart';

/// Platform-adaptive FloatingActionButton with consistent styling
class PlatformAdaptiveFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final bool isExtended;
  final String? label;
  final bool mini;

  const PlatformAdaptiveFAB({
    super.key,
    this.onPressed,
    required this.child,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
    this.isExtended = false,
    this.label,
    this.mini = false,
  });

  @override
  State<PlatformAdaptiveFAB> createState() => _PlatformAdaptiveFABState();
}

class _PlatformAdaptiveFABState extends State<PlatformAdaptiveFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0, // 4 full rotations
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      // Platform-specific haptic feedback
      PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
      
      // Trigger animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final theme = Theme.of(context);
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        if (PlatformHelper.isIOS) {
          return _buildIOSFAB(context, theme, isPsychedelicMode);
        } else {
          return _buildMaterialFAB(context, theme, isPsychedelicMode);
        }
      },
    );
  }

  Widget _buildIOSFAB(BuildContext context, ThemeData theme, bool isPsychedelicMode) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: isPsychedelicMode ? _rotationAnimation.value : 0.0,
            child: Container(
              width: widget.mini ? 40.0 : 56.0,
              height: widget.mini ? 40.0 : 56.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.mini ? 20.0 : 28.0),
                gradient: isPsychedelicMode
                    ? _buildPsychedelicGradient()
                    : _buildNormalGradient(theme),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? theme.colorScheme.primary)
                        .withOpacity(0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                  if (isPsychedelicMode) ...[
                    BoxShadow(
                      color: DesignTokens.neonCyan.withOpacity(0.3),
                      blurRadius: 12.0,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: DesignTokens.neonPink.withOpacity(0.2),
                      blurRadius: 16.0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ],
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _handleTap,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMaterialFAB(BuildContext context, ThemeData theme, bool isPsychedelicMode) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: isPsychedelicMode ? _rotationAnimation.value : 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.mini ? 20.0 : 28.0),
                gradient: isPsychedelicMode
                    ? _buildPsychedelicGradient()
                    : null,
                boxShadow: isPsychedelicMode
                    ? [
                        BoxShadow(
                          color: DesignTokens.neonCyan.withOpacity(0.3),
                          blurRadius: 12.0,
                          offset: const Offset(0, 0),
                        ),
                        BoxShadow(
                          color: DesignTokens.neonPink.withOpacity(0.2),
                          blurRadius: 16.0,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : null,
              ),
              child: FloatingActionButton(
                onPressed: _handleTap,
                heroTag: widget.heroTag,
                backgroundColor: isPsychedelicMode 
                    ? Colors.transparent
                    : widget.backgroundColor,
                foregroundColor: widget.foregroundColor,
                elevation: widget.elevation ?? PlatformHelper.getPlatformElevation(),
                shape: widget.shape ?? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.mini ? 20.0 : 28.0),
                ),
                mini: widget.mini,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  Gradient _buildPsychedelicGradient() {
    return LinearGradient(
      colors: [
        DesignTokens.neonPink,
        DesignTokens.neonPurple,
        DesignTokens.neonCyan,
        DesignTokens.acidGreen,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
  }

  Gradient _buildNormalGradient(ThemeData theme) {
    return LinearGradient(
      colors: [
        theme.colorScheme.primary,
        theme.colorScheme.primary.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Platform-adaptive Extended FloatingActionButton
class PlatformAdaptiveExtendedFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Text label;
  final String? heroTag;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final ShapeBorder? shape;

  const PlatformAdaptiveExtendedFAB({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.heroTag,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychedelicThemeService>(
      builder: (context, psychedelicService, child) {
        final theme = Theme.of(context);
        final isPsychedelicMode = psychedelicService.isPsychedelicMode;
        
        if (PlatformHelper.isIOS) {
          return _buildIOSExtendedFAB(context, theme, isPsychedelicMode);
        } else {
          return _buildMaterialExtendedFAB(context, theme, isPsychedelicMode);
        }
      },
    );
  }

  Widget _buildIOSExtendedFAB(BuildContext context, ThemeData theme, bool isPsychedelicMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: isPsychedelicMode
            ? LinearGradient(
                colors: [
                  DesignTokens.neonPink,
                  DesignTokens.neonPurple,
                  DesignTokens.neonCyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? theme.colorScheme.primary)
                .withOpacity(0.3),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
          if (isPsychedelicMode) ...[
            BoxShadow(
              color: DesignTokens.neonCyan.withOpacity(0.3),
              blurRadius: 12.0,
              offset: const Offset(0, 0),
            ),
          ],
        ],
      ),
      child: CupertinoButton(
        onPressed: () {
          if (onPressed != null) {
            PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
            onPressed!();
          }
        },
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8.0),
            label,
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialExtendedFAB(BuildContext context, ThemeData theme, bool isPsychedelicMode) {
    return Container(
      decoration: isPsychedelicMode
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(28.0),
              gradient: LinearGradient(
                colors: [
                  DesignTokens.neonPink,
                  DesignTokens.neonPurple,
                  DesignTokens.neonCyan,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neonCyan.withOpacity(0.3),
                  blurRadius: 12.0,
                  offset: const Offset(0, 0),
                ),
              ],
            )
          : null,
      child: FloatingActionButton.extended(
        onPressed: () {
          if (onPressed != null) {
            PlatformHelper.performHapticFeedback(HapticFeedbackType.mediumImpact);
            onPressed!();
          }
        },
        icon: icon,
        label: label,
        heroTag: heroTag,
        backgroundColor: isPsychedelicMode ? Colors.transparent : backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation ?? PlatformHelper.getPlatformElevation(),
        shape: shape ?? RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
      ),
    );
  }
}