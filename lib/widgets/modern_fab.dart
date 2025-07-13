import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class ModernFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final Color backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool isExtended;
  final double? elevation;

  const ModernFAB({
    super.key,
    this.onPressed,
    this.icon,
    required this.label,
    this.backgroundColor = DesignTokens.primaryIndigo,
    this.foregroundColor,
    this.isLoading = false,
    this.isExtended = true,
    this.elevation,
  });

  @override
  State<ModernFAB> createState() => _ModernFABState();
}

class _ModernFABState extends State<ModernFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

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

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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
    if (widget.onPressed != null && !widget.isLoading) {
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
    final foregroundColor = widget.foregroundColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: widget.isExtended
                ? _buildExtendedFAB(theme, foregroundColor)
                : _buildRegularFAB(theme, foregroundColor),
          ),
        );
      },
    );
  }

  Widget _buildExtendedFAB(ThemeData theme, Color foregroundColor) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: Spacing.borderRadiusFull,
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: DesignTokens.shadowDark.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: Spacing.iconMd,
                height: Spacing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            else if (widget.icon != null)
              Icon(
                widget.icon,
                color: foregroundColor,
                size: Spacing.iconMd,
              ),
            if ((widget.icon != null || widget.isLoading) && widget.label.isNotEmpty)
              Spacing.horizontalSpaceSm,
            if (widget.label.isNotEmpty)
              Text(
                widget.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegularFAB(ThemeData theme, Color foregroundColor) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: Spacing.borderRadiusFull,
          boxShadow: [
            BoxShadow(
              color: widget.backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: DesignTokens.shadowDark.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: Spacing.iconMd,
                  height: Spacing.iconMd,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Icon(
                  widget.icon ?? Icons.add_rounded,
                  color: foregroundColor,
                  size: Spacing.iconMd,
                ),
        ),
      ),
    );
  }
}

// Specialized FAB variants
class PulseFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color? foregroundColor;

  const PulseFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.backgroundColor = DesignTokens.primaryIndigo,
    this.foregroundColor,
  });

  @override
  State<PulseFAB> createState() => _PulseFABState();
}

class _PulseFABState extends State<PulseFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: ModernFAB(
            onPressed: widget.onPressed,
            icon: widget.icon,
            label: '',
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            isExtended: false,
          ),
        );
      },
    );
  }
}

// Morphing FAB that changes between states
class MorphingFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final String primaryLabel;
  final String secondaryLabel;
  final bool isSecondaryState;
  final Color backgroundColor;
  final Color? foregroundColor;

  const MorphingFAB({
    super.key,
    this.onPressed,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.primaryLabel,
    required this.secondaryLabel,
    this.isSecondaryState = false,
    this.backgroundColor = DesignTokens.primaryIndigo,
    this.foregroundColor,
  });

  @override
  State<MorphingFAB> createState() => _MorphingFABState();
}

class _MorphingFABState extends State<MorphingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _morphController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      duration: DesignTokens.animationMedium,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _morphController,
      curve: DesignTokens.curveEaseOut,
    ));
  }

  @override
  void didUpdateWidget(MorphingFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSecondaryState != oldWidget.isSecondaryState) {
      if (widget.isSecondaryState) {
        _morphController.forward();
      } else {
        _morphController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        final progress = _morphController.value;
        final currentIcon = progress < 0.5 ? widget.primaryIcon : widget.secondaryIcon;
        final currentLabel = progress < 0.5 ? widget.primaryLabel : widget.secondaryLabel;

        return Transform.rotate(
          angle: _rotationAnimation.value * 3.14159, // 180 degrees
          child: ModernFAB(
            onPressed: widget.onPressed,
            icon: currentIcon,
            label: currentLabel,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
          ),
        );
      },
    );
  }
}
