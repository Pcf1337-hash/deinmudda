import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/psychedelic_theme_service.dart';
import '../theme/design_tokens.dart';
// removed unused import: ../theme/spacing.dart // cleaned by BereinigungsAgent

/// Unified FAB design with neon pink to gray gradient and glow effects
/// Used across all screens when in trippy mode
class TrippyFAB extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData? icon;
  final String label;
  final bool isExtended;
  final bool isLoading;
  final double? elevation;

  const TrippyFAB({
    super.key,
    this.onPressed,
    this.icon,
    required this.label,
    this.isExtended = true,
    this.isLoading = false,
    this.elevation,
  });

  @override
  State<TrippyFAB> createState() => _TrippyFABState();
}

class _TrippyFABState extends State<TrippyFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0, // 4x rotation as mentioned in problem statement
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut, // Elastic bounce as mentioned
    ));

    // Start continuous animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychedelicThemeService>(
      builder: (context, themeService, child) {
        final isPsychedelicMode = themeService.isPsychedelicMode;
        
        if (isPsychedelicMode) {
          return _buildTrippyFAB(themeService);
        } else {
          return _buildRegularFAB();
        }
      },
    );
  }

  Widget _buildTrippyFAB(PsychedelicThemeService themeService) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159 / 180, // Convert to radians
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isExtended ? 28 : 28),
                // Multiple glow effects for trippy appearance
                boxShadow: [
                  // Outer neon pink glow
                  BoxShadow(
                    color: DesignTokens.neonPink.withOpacity(0.6 * _glowAnimation.value * themeService.glowIntensity),
                    blurRadius: 20 * _glowAnimation.value * themeService.glowIntensity,
                    spreadRadius: 5 * _glowAnimation.value * themeService.glowIntensity,
                  ),
                  // Middle cyan glow
                  BoxShadow(
                    color: DesignTokens.neonCyan.withOpacity(0.4 * _glowAnimation.value * themeService.glowIntensity),
                    blurRadius: 15 * _glowAnimation.value * themeService.glowIntensity,
                    spreadRadius: 3 * _glowAnimation.value * themeService.glowIntensity,
                  ),
                  // Inner white glow
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3 * _glowAnimation.value * themeService.glowIntensity),
                    blurRadius: 10 * _glowAnimation.value * themeService.glowIntensity,
                    spreadRadius: 1 * _glowAnimation.value * themeService.glowIntensity,
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: widget.onPressed,
                child: Container(
                  padding: widget.isExtended 
                    ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                    : const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Neon pink to gray gradient
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        DesignTokens.neonPink,     // Neon pink outside
                        DesignTokens.neonMagenta,  // Transition
                        DesignTokens.neutral600,   // Gray inside
                        DesignTokens.neutral700,   // Darker gray center
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(widget.isExtended ? 28 : 28),
                    border: Border.all(
                      color: DesignTokens.neonPink.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  child: widget.isExtended ? _buildExtendedContent() : _buildCircularContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExtendedContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (widget.icon != null)
          Icon(
            widget.icon,
            color: Colors.white,
            size: 20,
            shadows: const [
              Shadow(
                color: DesignTokens.neonCyan,
                blurRadius: 8,
              ),
            ],
          ),
        if ((widget.icon != null || widget.isLoading) && widget.label.isNotEmpty)
          const SizedBox(width: 12),
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: DesignTokens.neonCyan,
                  blurRadius: 4,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCircularContent() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: widget.isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(
                widget.icon ?? Icons.add_rounded,
                color: Colors.white,
                size: 24,
                shadows: const [
                  Shadow(
                    color: DesignTokens.neonCyan,
                    blurRadius: 8,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegularFAB() {
    return FloatingActionButton.extended(
      onPressed: widget.onPressed,
      icon: widget.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.icon != null
              ? Icon(widget.icon)
              : null,
      label: widget.label.isNotEmpty ? Text(widget.label) : const SizedBox.shrink(),
      elevation: widget.elevation,
    );
  }
}