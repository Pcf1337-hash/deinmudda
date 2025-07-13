import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/design_tokens.dart';

class PulsatingWidget extends StatefulWidget {
  final Widget child;
  final bool isEnabled;
  final Color? glowColor;
  final double intensity;
  final Duration duration;
  
  const PulsatingWidget({
    super.key,
    required this.child,
    this.isEnabled = true,
    this.glowColor,
    this.intensity = 1.0,
    this.duration = DesignTokens.pulseAnimation,
  });

  @override
  State<PulsatingWidget> createState() => _PulsatingWidgetState();
}

class _PulsatingWidgetState extends State<PulsatingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curvePulse,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curvePulse,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveGlow,
    ));
    
    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PulsatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedOpacity(
            opacity: _opacityAnimation.value,
            duration: const Duration(milliseconds: 50),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (widget.glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(_glowAnimation.value * 0.3 * widget.intensity),
                    blurRadius: 20 * _glowAnimation.value * widget.intensity,
                    spreadRadius: 5 * _glowAnimation.value * widget.intensity,
                  ),
                  BoxShadow(
                    color: (widget.glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(_glowAnimation.value * 0.1 * widget.intensity),
                    blurRadius: 40 * _glowAnimation.value * widget.intensity,
                    spreadRadius: 10 * _glowAnimation.value * widget.intensity,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class PulsatingIcon extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final bool isEnabled;
  final Color? glowColor;
  
  const PulsatingIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24.0,
    this.isEnabled = true,
    this.glowColor,
  });

  @override
  State<PulsatingIcon> createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.pulseAnimation,
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curvePulse,
    ));
    
    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PulsatingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return Icon(
        widget.icon,
        color: widget.color ?? DesignTokens.textPsychedelicPrimary,
        size: widget.size,
      );
    }
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size / 2),
            boxShadow: [
              BoxShadow(
                color: (widget.glowColor ?? widget.color ?? DesignTokens.neonPurple)
                    .withOpacity(_glowAnimation.value * 0.4),
                blurRadius: 15 * _glowAnimation.value,
                spreadRadius: 3 * _glowAnimation.value,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: widget.color ?? DesignTokens.textPsychedelicPrimary,
            size: widget.size,
          ),
        );
      },
    );
  }
}

class GlowingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? glowColor;
  final EdgeInsets padding;
  final bool isEnabled;
  
  const GlowingButton({
    super.key,
    required this.child,
    this.onPressed,
    this.glowColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.isEnabled = true,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isPressed = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.transitionAnimation,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveDefault,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveGlow,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onPressed,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: DesignTokens.psychedelicGlassGradient,
                border: Border.all(
                  color: DesignTokens.psychedelicGlassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(_glowAnimation.value * 0.3),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: (widget.glowColor ?? DesignTokens.neonPurple)
                        .withOpacity(_glowAnimation.value * 0.1),
                    blurRadius: 40 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}