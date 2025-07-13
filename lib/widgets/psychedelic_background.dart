import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/design_tokens.dart';

class PsychedelicBackground extends StatefulWidget {
  final Widget child;
  final bool isEnabled;
  
  const PsychedelicBackground({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<PsychedelicBackground> createState() => _PsychedelicBackgroundState();
}

class _PsychedelicBackgroundState extends State<PsychedelicBackground>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: DesignTokens.backgroundAnimation,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveHypnotic,
    ));
    
    if (widget.isEnabled) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PsychedelicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat();
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return Container(
        decoration: const BoxDecoration(
          color: DesignTokens.psychedelicBackground,
        ),
        child: widget.child,
      );
    }
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: _buildAnimatedGradient(),
          ),
          child: CustomPaint(
            painter: PsychedelicPatternPainter(
              animation: _animation.value,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }

  Gradient _buildAnimatedGradient() {
    final t = _animation.value;
    final phase = math.sin(t * math.pi * 2) * 0.5 + 0.5;
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(
          DesignTokens.psychedelicBackground,
          const Color(0xFF1A0A1A),
          phase * 0.3,
        )!,
        Color.lerp(
          DesignTokens.psychedelicBackground,
          const Color(0xFF0A1A1A),
          (1 - phase) * 0.3,
        )!,
        Color.lerp(
          DesignTokens.psychedelicBackground,
          const Color(0xFF0A0A1A),
          phase * 0.2,
        )!,
      ],
      stops: [
        0.0,
        0.5 + math.sin(t * math.pi * 4) * 0.1,
        1.0,
      ],
    );
  }
}

class PsychedelicPatternPainter extends CustomPainter {
  final double animation;
  
  PsychedelicPatternPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.5;
    
    // Draw subtle animated circles
    for (int i = 0; i < 3; i++) {
      final t = (animation + i * 0.33) % 1.0;
      final currentRadius = radius * t * 0.8;
      final opacity = (1 - t) * 0.05;
      
      paint.color = DesignTokens.neonPurple.withOpacity(opacity);
      canvas.drawCircle(center, currentRadius, paint);
    }
    
    // Draw flowing wave pattern
    final path = Path();
    final waveAmplitude = 30.0;
    final waveFrequency = 0.02;
    
    for (double x = 0; x < size.width; x++) {
      final y = size.height * 0.7 + 
               waveAmplitude * math.sin(x * waveFrequency + animation * math.pi * 2);
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    paint.color = DesignTokens.psychedelicGlowPurple.withOpacity(0.05);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PsychedelicPatternPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}