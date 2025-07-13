import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/design_tokens.dart';

class ReflectiveAppBarLogo extends StatefulWidget {
  const ReflectiveAppBarLogo({super.key});

  @override
  State<ReflectiveAppBarLogo> createState() => _ReflectiveAppBarLogoState();
}

class _ReflectiveAppBarLogoState extends State<ReflectiveAppBarLogo>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  
  static const double _sensitivity = 0.3;
  static const double _maxRotation = 0.5;
  static const double _maxOffset = 10.0;

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller for pulsing effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Setup gyroscope listener
    _setupGyroscopeListener();
  }

  void _setupGyroscopeListener() {
    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          if (mounted) {
            setState(() {
              // Apply gyroscope data with sensitivity and limits
              _rotationX = (event.x * _sensitivity).clamp(-_maxRotation, _maxRotation);
              _rotationY = (event.y * _sensitivity).clamp(-_maxRotation, _maxRotation);
              _offsetX = (event.y * _sensitivity * 20).clamp(-_maxOffset, _maxOffset);
              _offsetY = (event.x * _sensitivity * 20).clamp(-_maxOffset, _maxOffset);
            });
          }
        },
        onError: (error) {
          // Handle gyroscope errors gracefully
          debugPrint('Gyroscope error: $error');
        },
      );
    } catch (e) {
      // Handle initialization errors
      debugPrint('Gyroscope initialization error: $e');
    }
  }

  @override
  void dispose() {
    _gyroscopeSubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTrippyMode = theme.brightness == Brightness.dark && 
                         theme.colorScheme.primary == DesignTokens.neonPink;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateX(_rotationX)
            ..rotateY(_rotationY)
            ..translate(_offsetX, _offsetY),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: isTrippyMode ? BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neonPink.withOpacity(0.3 * _pulseAnimation.value),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                ),
                BoxShadow(
                  color: DesignTokens.neonCyan.withOpacity(0.2 * _pulseAnimation.value),
                  blurRadius: 30 * _pulseAnimation.value,
                  spreadRadius: 2 * _pulseAnimation.value,
                ),
              ],
            ) : null,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                if (isTrippyMode) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignTokens.neonPink,
                      DesignTokens.neonCyan,
                      DesignTokens.electricBlue,
                      DesignTokens.neonPink,
                    ],
                    stops: [
                      0.0,
                      0.3 + (_pulseAnimation.value * 0.2),
                      0.7 + (_pulseAnimation.value * 0.2),
                      1.0,
                    ],
                    transform: GradientRotation(
                      _rotationY * 2 + (_animationController.value * 2 * math.pi),
                    ),
                  ).createShader(bounds);
                } else {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                      theme.colorScheme.primary,
                    ],
                    stops: [0.0, 0.5, 1.0],
                    transform: GradientRotation(_rotationY),
                  ).createShader(bounds);
                }
              },
              child: Text(
                'Konsum Tracker Pro',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                  shadows: isTrippyMode ? [
                    Shadow(
                      color: DesignTokens.neonPink.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                    Shadow(
                      color: DesignTokens.neonCyan.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ] : [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}