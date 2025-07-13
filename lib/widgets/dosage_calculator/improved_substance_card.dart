import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/dosage_calculator_substance.dart';
import '../../models/dosage_calculator_user.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/app_icon_generator.dart';

/// Improved substance card with glassmorphism design and neon effects
/// Based on demo_ui.html design but implemented 100% in Flutter
class ImprovedSubstanceCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final DosageCalculatorUser? user;
  final VoidCallback? onTap;
  final bool isCompact;

  const ImprovedSubstanceCard({
    super.key,
    required this.substance,
    this.user,
    this.onTap,
    this.isCompact = false,
  });

  @override
  State<ImprovedSubstanceCard> createState() => _ImprovedSubstanceCardState();
}

class _ImprovedSubstanceCardState extends State<ImprovedSubstanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final substanceColor = _getSubstanceColor(widget.substance.name);
    final dangerLevel = _getDangerLevel(widget.substance.name);
    
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Transform.translate(
              offset: Offset(0, -5 * _hoverAnimation.value),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: widget.isCompact ? 160 : 220,
                  maxHeight: widget.isCompact ? 180 : 280,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // Neon glow effect based on substance type
                    BoxShadow(
                      color: substanceColor.withOpacity(0.3 + (0.2 * _hoverAnimation.value)),
                      blurRadius: 20 + (20 * _hoverAnimation.value),
                      offset: const Offset(0, 10),
                    ),
                    // Additional shadow for depth
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        // Glassmorphism background
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ]
                              : [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        // Substance-specific colored border
                        border: Border.all(
                          color: substanceColor.withOpacity(0.3 + (0.2 * _hoverAnimation.value)),
                          width: 1.2,
                        ),
                      ),
                      child: _buildCardContent(context, substanceColor, dangerLevel, isDark),
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

  Widget _buildCardContent(BuildContext context, Color substanceColor, DangerLevel dangerLevel, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and danger badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Substance icon
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: substanceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: substanceColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: FittedBox(
                  child: Icon(
                    AppIconGenerator.getSubstanceIcon(widget.substance.name),
                    color: substanceColor,
                  ),
                ),
              ),
              // Danger badge
              _buildDangerBadge(dangerLevel),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Substance name
          Flexible(
            child: Text(
              widget.substance.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: substanceColor,
                fontSize: 20,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Administration route and duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                Icons.compare_arrows_rounded,
                widget.substance.administrationRouteDisplayName,
                isDark,
              ),
              const SizedBox(height: 2),
              _buildDetailRow(
                Icons.schedule_rounded,
                widget.substance.duration,
                isDark,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Dosage information
          Flexible(
            child: _buildDosageIndicator(context, substanceColor, isDark),
          ),
          
          const SizedBox(height: 12),
          
          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: substanceColor.withOpacity(0.1),
                foregroundColor: substanceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: substanceColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: FittedBox(
                child: Text(
                  'Berechnen',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: substanceColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.white70 : Colors.grey[600],
          size: 15,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDangerBadge(DangerLevel dangerLevel) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;
    
    switch (dangerLevel) {
      case DangerLevel.high:
        badgeColor = Colors.red;
        badgeIcon = Icons.warning;
        badgeText = 'Hoch';
        break;
      case DangerLevel.medium:
        badgeColor = Colors.orange;
        badgeIcon = Icons.warning;
        badgeText = 'Mittel';
        break;
      case DangerLevel.low:
        badgeColor = Colors.green;
        badgeIcon = Icons.check_circle;
        badgeText = 'Niedrig';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageIndicator(BuildContext context, Color substanceColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isDark ? 0.05 : 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended dose (normal dose)
          if (widget.user != null) ...[
            Text(
              'Empfohlene Dosis',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.substance.getFormattedDosage(widget.user!.weightKg, DosageIntensity.normal),
              style: TextStyle(
                fontSize: 16,
                color: Colors.amber[600],
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            // Optional dose (80% of normal)
            Text(
              'Optionale Dosis (80%)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber[300],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(widget.substance.calculateDosage(widget.user!.weightKg, DosageIntensity.normal) * 0.8).toStringAsFixed(1)} mg',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[300],
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Dosage range
          Row(
            children: [
              _buildDosageValue(
                widget.substance.lightDosePerKg.toStringAsFixed(1),
                'mg',
                Colors.green,
              ),
              const SizedBox(width: 2),
              _buildDosageValue(
                widget.substance.normalDosePerKg.toStringAsFixed(1),
                'mg',
                Colors.amber,
              ),
              const SizedBox(width: 2),
              _buildDosageValue(
                widget.substance.strongDosePerKg.toStringAsFixed(1),
                'mg',
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Labels
          Row(
            children: [
              Expanded(
                child: Text(
                  'Leicht',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Normal',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Stark',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDosageValue(String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: FittedBox(
          child: Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Color _getSubstanceColor(String substanceName) {
    final lowerName = substanceName.toLowerCase();
    
    if (lowerName.contains('mdma')) {
      return const Color(0xFFFF10F0); // Pink/Magenta
    } else if (lowerName.contains('lsd')) {
      return const Color(0xFF9D4EDD); // Purple
    } else if (lowerName.contains('ketamin')) {
      return const Color(0xFF0080FF); // Blue
    } else if (lowerName.contains('kokain')) {
      return const Color(0xFFFFA500); // Orange
    } else if (lowerName.contains('cannabis')) {
      return const Color(0xFF22C55E); // Green
    } else if (lowerName.contains('psilocybin')) {
      return const Color(0xFF8B5CF6); // Violet
    } else if (lowerName.contains('amphetamine')) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFF06B6D4); // Cyan (default)
    }
  }

  DangerLevel _getDangerLevel(String substanceName) {
    final lowerName = substanceName.toLowerCase();
    
    if (lowerName.contains('mdma') || 
        lowerName.contains('lsd') || 
        lowerName.contains('kokain') ||
        lowerName.contains('amphetamine')) {
      return DangerLevel.high;
    } else if (lowerName.contains('ketamin') || 
               lowerName.contains('2c-b') ||
               lowerName.contains('mescaline')) {
      return DangerLevel.medium;
    } else {
      return DangerLevel.low;
    }
  }
}

enum DangerLevel { high, medium, low }

/// Responsive container for substance cards
/// Shows 2 cards side by side on wide screens, 1 per row on small devices
class ResponsiveSubstanceCardGrid extends StatelessWidget {
  final List<DosageCalculatorSubstance> substances;
  final DosageCalculatorUser? user;
  final Function(DosageCalculatorSubstance)? onCardTap;

  const ResponsiveSubstanceCardGrid({
    super.key,
    required this.substances,
    this.user,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 600;
        final crossAxisCount = isWideScreen ? 2 : 1;
        final cardWidth = isWideScreen
            ? (constraints.maxWidth - 16) / 2 // 16 for spacing
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: substances.map((substance) {
            return SizedBox(
              width: cardWidth,
              child: ImprovedSubstanceCard(
                substance: substance,
                user: user,
                onTap: onCardTap != null ? () => onCardTap!(substance) : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}