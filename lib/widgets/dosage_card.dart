import 'dart:ui';
import 'package:flutter/material.dart';

/// DosageCard Widget with Glassmorphism Design
/// 
/// A modern card widget for displaying substance dosage information
/// with glassmorphism effects, gradients, and Material 3 design principles.
/// 
/// Features:
/// - Glassmorphism effect with BackdropFilter and blur
/// - Dynamic gradients based on administration route (oral vs nasal)
/// - Responsive design with automatic dark mode support
/// - Tap animations and modern typography
/// - Performance-optimized with minimal rebuilds
class DosageCard extends StatefulWidget {
  /// The title of the substance (e.g., "MDMA", "LSD")
  final String title;
  
  /// The dosage text (e.g., "56.0 mg")
  final String doseText;
  
  /// The duration text (e.g., "4–6 Stunden")
  final String durationText;
  
  /// The icon to display in the top left
  final IconData icon;
  
  /// The gradient colors for the card background
  final List<Color> gradientColors;
  
  /// Whether the administration is oral (affects color scheme)
  final bool isOral;

  const DosageCard({
    super.key,
    required this.title,
    required this.doseText,
    required this.durationText,
    required this.icon,
    required this.gradientColors,
    required this.isOral,
  });

  @override
  State<DosageCard> createState() => _DosageCardState();
}

class _DosageCardState extends State<DosageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Determine gradient colors based on isOral and theme
    final List<Color> effectiveGradientColors = _getEffectiveGradientColors(isDarkMode);
    
    // Calculate responsive dimensions with more compact height
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 2 cards per row with padding
    final cardHeight = cardWidth * 0.95; // Reduced aspect ratio from 1.2 to 0.95 for more compact look

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              margin: const EdgeInsets.all(6.0), // Reduced from 8.0 for tighter layout
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18), // Reduced from 24 for better visual harmony
                child: Stack(
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: effectiveGradientColors,
                        ),
                      ),
                    ),
                    
                    // Glassmorphism effect
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.2),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    
                    // Content with improved spacing
                    Padding(
                      padding: const EdgeInsets.all(14.0), // Reduced from 16.0 to 14.0
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon and title row with improved spacing
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7), // Reduced from 8
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(10), // Reduced from 12
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.white,
                                  size: 18, // Reduced from 20
                                ),
                              ),
                              const SizedBox(width: 6), // Reduced from 8
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.95)
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15, // Reduced from 16
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Dosage information with improved layout
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doseText,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.95)
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22, // Reduced from 24
                                ),
                              ),
                              const SizedBox(height: 3), // Reduced from 4
                              Text(
                                widget.durationText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.9),
                                  fontSize: 13, // Reduced from 14
                                ),
                              ),
                              const SizedBox(height: 6), // Reduced from 8
                              // Administration route indicator with refined styling
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7, // Reduced from 8
                                  vertical: 3, // Reduced from 4
                                ),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(7), // Reduced from 8
                                ),
                                child: Text(
                                  widget.isOral ? 'Oral' : 'Nasal',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.white,
                                    fontSize: 11, // Reduced from 12
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Shimmer effect overlay when pressed
                    if (_isPressed)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                        ),
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

  /// Determines effective gradient colors based on isOral and theme
  List<Color> _getEffectiveGradientColors(bool isDarkMode) {
    if (widget.isOral) {
      // Warm colors for oral administration
      if (isDarkMode) {
        return widget.gradientColors.map((color) => 
          Color.lerp(color, Colors.orange, 0.2)!.withOpacity(0.7)
        ).toList();
      } else {
        return widget.gradientColors.map((color) => 
          Color.lerp(color, Colors.deepOrange, 0.1)!
        ).toList();
      }
    } else {
      // Cool colors for nasal administration
      if (isDarkMode) {
        return widget.gradientColors.map((color) => 
          Color.lerp(color, Colors.blue, 0.2)!.withOpacity(0.7)
        ).toList();
      } else {
        return widget.gradientColors.map((color) => 
          Color.lerp(color, Colors.indigo, 0.1)!
        ).toList();
      }
    }
  }
}