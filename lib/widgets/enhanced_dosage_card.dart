import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/enhanced_substance.dart';
import '../models/dosage_calculator_substance.dart';

/// Enhanced DosageCard Widget with Rich Information Display
/// 
/// A comprehensive card widget for displaying detailed substance dosage information
/// with glassmorphism effects, gradients, risk indicators, and enhanced content.
/// 
/// Features:
/// - All original glassmorphism design features
/// - Risk level indicators with appropriate colors
/// - Chemical effect summaries
/// - Key side effects display
/// - Safety warnings
/// - Dosage range information
/// - Expandable sections for detailed info
class EnhancedDosageCard extends StatefulWidget {
  /// The enhanced substance with detailed information
  final EnhancedSubstance substance;
  
  /// The user's weight for dosage calculations
  final double userWeight;
  
  /// The icon to display in the top left
  final IconData icon;
  
  /// The gradient colors for the card background
  final List<Color> gradientColors;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;

  const EnhancedDosageCard({
    super.key,
    required this.substance,
    required this.userWeight,
    required this.icon,
    required this.gradientColors,
    this.onTap,
  });

  @override
  State<EnhancedDosageCard> createState() => _EnhancedDosageCardState();
}

class _EnhancedDosageCardState extends State<EnhancedDosageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isExpanded = false;

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
    
    if (widget.onTap != null) {
      widget.onTap!();
    }
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
    
    // Calculate responsive dimensions with expandable height
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 2 cards per row with padding
    final baseHeight = cardWidth * 0.95;
    final expandedHeight = _isExpanded ? baseHeight * 1.6 : baseHeight;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: cardWidth,
              height: expandedHeight,
              margin: const EdgeInsets.all(6.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
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
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row with icon, title, and risk indicator
                            _buildHeader(context, theme, isDarkMode),
                            
                            const SizedBox(height: 8),
                            
                            // Dosage information
                            _buildDosageInfo(context, theme, isDarkMode),
                            
                            const SizedBox(height: 8),
                            
                            // Chemical effect summary
                            _buildChemicalEffect(context, theme, isDarkMode),
                            
                            const SizedBox(height: 6),
                            
                            // Safety warning if any
                            _buildSafetyWarning(context, theme, isDarkMode),
                            
                            // Expandable content
                            if (_isExpanded) ...[
                              const SizedBox(height: 8),
                              _buildExpandedContent(context, theme, isDarkMode),
                            ],
                            
                            // Expand/collapse button
                            const SizedBox(height: 6),
                            _buildExpandButton(context, theme, isDarkMode),
                          ],
                        ),
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

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    final riskLevel = widget.substance.riskLevel;
    
    return Row(
      children: [
        // Icon container
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.icon,
            color: isDarkMode
                ? Colors.white.withOpacity(0.9)
                : Colors.white,
            size: 18,
          ),
        ),
        
        const SizedBox(width: 6),
        
        // Title
        Expanded(
          child: Text(
            widget.substance.name,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.95)
                  : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Risk level indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: riskLevel.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: riskLevel.color.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                riskLevel.icon,
                color: riskLevel.color,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                riskLevel.displayName,
                style: TextStyle(
                  color: riskLevel.color,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDosageInfo(BuildContext context, ThemeData theme, bool isDarkMode) {
    final normalDose = widget.substance.calculateDosage(widget.userWeight, DosageIntensity.normal);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main dosage
        Text(
          '${normalDose.toStringAsFixed(1)} mg',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDarkMode
                ? Colors.white.withOpacity(0.95)
                : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Duration and administration route
        Row(
          children: [
            Text(
              widget.substance.durationDisplay,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.substance.administrationRoute == 'oral' ? 'Oral' : 'Nasal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChemicalEffect(BuildContext context, ThemeData theme, bool isDarkMode) {
    final effect = widget.substance.abbreviatedChemicalEffect;
    if (effect.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.science,
            color: isDarkMode
                ? Colors.white.withOpacity(0.7)
                : Colors.white.withOpacity(0.8),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              effect,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.9),
                fontSize: 10,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyWarning(BuildContext context, ThemeData theme, bool isDarkMode) {
    final normalDose = widget.substance.calculateDosage(widget.userWeight, DosageIntensity.normal);
    final warning = widget.substance.getSafetyWarning(normalDose, widget.userWeight);
    
    if (warning == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange,
            size: 12,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(
                color: Colors.orange.shade100,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dosage ranges
        _buildDosageRanges(context, theme, isDarkMode),
        
        const SizedBox(height: 8),
        
        // Key side effects
        _buildKeySideEffects(context, theme, isDarkMode),
        
        const SizedBox(height: 8),
        
        // Safety notes
        _buildSafetyNotes(context, theme, isDarkMode),
      ],
    );
  }

  Widget _buildDosageRanges(BuildContext context, ThemeData theme, bool isDarkMode) {
    final ranges = widget.substance.getFormattedDosageRange(widget.userWeight);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dosisbereiche:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ...ranges.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                Text(
                  entry.value,
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildKeySideEffects(BuildContext context, ThemeData theme, bool isDarkMode) {
    final keySideEffects = widget.substance.keySideEffects;
    if (keySideEffects.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.health_and_safety,
                color: Colors.red,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'Nebenwirkungen:',
                style: TextStyle(
                  color: Colors.red.shade100,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...keySideEffects.map((effect) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• $effect',
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 9,
                height: 1.1,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSafetyNotes(BuildContext context, ThemeData theme, bool isDarkMode) {
    final notes = widget.substance.abbreviatedSafetyNotes;
    if (notes.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.blue,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'Sicherheitshinweise:',
                style: TextStyle(
                  color: Colors.blue.shade100,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: TextStyle(
              color: Colors.blue.shade100,
              fontSize: 9,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Center(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isExpanded ? 'Weniger' : 'Mehr',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Determines effective gradient colors based on administration route and theme
  List<Color> _getEffectiveGradientColors(bool isDarkMode) {
    final isOral = widget.substance.administrationRoute.toLowerCase() == 'oral';
    
    if (isOral) {
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