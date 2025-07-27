import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/design_tokens.dart';

/// Enhanced DosageCard widget with Glassmorphism + Material 3 design
/// 
/// A modern, high-quality dose tile with glass effects, gradients, and animations.
/// Designed for mobile devices with responsive layout and dark mode support.
class DosageCard extends StatefulWidget {
  final String title;
  final String doseText;
  final String durationText;
  final IconData? icon;
  final List<Color> gradientColors;
  final bool isOral;
  final VoidCallback? onTap;

  const DosageCard({
    super.key,
    required this.title,
    required this.doseText,
    required this.durationText,
    this.icon,
    required this.gradientColors,
    required this.isOral,
    this.onTap,
  });

  @override
  State<DosageCard> createState() => _DosageCardState();
}

class _DosageCardState extends State<DosageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    // Soft shadow for depth
                    BoxShadow(
                      color: widget.gradientColors.first.withOpacity(
                        isDark ? 0.3 : 0.2,
                      ),
                      blurRadius: _isHovered ? 25 : 20,
                      offset: const Offset(0, 8),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                    // Glow effect when hovered
                    if (_isHovered)
                      BoxShadow(
                        color: widget.gradientColors.first.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 0),
                        spreadRadius: 3,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 15,
                      sigmaY: 15,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildGradient(isDark),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(
                            isDark ? 0.2 : 0.3,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onTap,
                          borderRadius: BorderRadius.circular(24),
                          splashColor: widget.gradientColors.first.withOpacity(0.2),
                          highlightColor: widget.gradientColors.first.withOpacity(0.1),
                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            child: _buildCardContent(context, isDark, isSmallScreen),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _buildGradient(bool isDark) {
    final baseOpacity = isDark ? 0.15 : 0.25;
    final glassOpacity = isDark ? 0.1 : 0.2;
    
    if (widget.isOral) {
      // Warm gradient for oral administration
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.gradientColors.first.withOpacity(baseOpacity),
          widget.gradientColors.last.withOpacity(baseOpacity * 0.8),
          Colors.orange.withOpacity(baseOpacity * 0.6),
          Colors.white.withOpacity(glassOpacity),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    } else {
      // Cool gradient for nasal administration
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.gradientColors.first.withOpacity(baseOpacity),
          widget.gradientColors.last.withOpacity(baseOpacity * 0.8),
          Colors.cyan.withOpacity(baseOpacity * 0.6),
          Colors.white.withOpacity(glassOpacity),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
    }
  }

  Widget _buildCardContent(BuildContext context, bool isDark, bool isSmallScreen) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon and administration route
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with glow effect
            if (widget.icon != null)
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: widget.gradientColors.first.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.gradientColors.first.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon!,
                  color: widget.gradientColors.first,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            
            const Spacer(),
            
            // Administration route badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isOral 
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.cyan.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isOral 
                      ? Colors.orange.withOpacity(0.4)
                      : Colors.cyan.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isOral ? Icons.medication : Icons.air,
                    size: 12,
                    color: widget.isOral ? Colors.orange : Colors.cyan,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.isOral ? 'Oral' : 'Nasal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: widget.isOral ? Colors.orange : Colors.cyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Substance title
        Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.grey[800],
            shadows: [
              Shadow(
                color: widget.gradientColors.first.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Dosage display
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: widget.gradientColors.first.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.gradientColors.first.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.first.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Optimale Dosis',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.gradientColors.first,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.doseText,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  color: widget.gradientColors.first,
                  shadows: [
                    Shadow(
                      color: widget.gradientColors.first.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Duration display with enhanced typography
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: isDark 
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.durationText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: isDark 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Factory methods for creating substance-specific DosageCards
extension DosageCardFactory on DosageCard {
  /// Creates a MDMA dosage card with heart icon and warm gradient
  static DosageCard mdma({
    required String doseText,
    required String durationText,
    VoidCallback? onTap,
  }) {
    return DosageCard(
      title: 'MDMA',
      doseText: doseText,
      durationText: durationText,
      icon: Icons.favorite_rounded,
      gradientColors: [
        DesignTokens.substanceMDMA,
        Colors.pinkAccent,
      ],
      isOral: true,
      onTap: onTap,
    );
  }

  /// Creates a LSD dosage card with psychology icon and cool gradient
  static DosageCard lsd({
    required String doseText,
    required String durationText,
    VoidCallback? onTap,
  }) {
    return DosageCard(
      title: 'LSD',
      doseText: doseText,
      durationText: durationText,
      icon: Icons.psychology_rounded,
      gradientColors: [
        DesignTokens.substanceLSD,
        Colors.deepPurpleAccent,
      ],
      isOral: true,
      onTap: onTap,
    );
  }

  /// Creates a Ketamine dosage card with medical icon and cool gradient
  static DosageCard ketamine({
    required String doseText,
    required String durationText,
    VoidCallback? onTap,
  }) {
    return DosageCard(
      title: 'Ketamin',
      doseText: doseText,
      durationText: durationText,
      icon: Icons.medical_services_rounded,
      gradientColors: [
        DesignTokens.substanceKetamine,
        Colors.blueAccent,
      ],
      isOral: false, // Typically nasal
      onTap: onTap,
    );
  }

  /// Creates a Cocaine dosage card with warning icon and cool gradient
  static DosageCard cocaine({
    required String doseText,
    required String durationText,
    VoidCallback? onTap,
  }) {
    return DosageCard(
      title: 'Kokain',
      doseText: doseText,
      durationText: durationText,
      icon: Icons.warning_rounded,
      gradientColors: [
        Colors.red,
        Colors.redAccent,
      ],
      isOral: false, // Typically nasal
      onTap: onTap,
    );
  }
}