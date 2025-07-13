import 'package:flutter/material.dart';
import 'dart:ui';
import '../../models/dosage_calculator_substance.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import 'danger_badge.dart';

/// Enhanced substance card with glassmorphism design based on demo_ui.html
/// Features:
/// - Responsive layout (2 cards side by side on wide screens, 1 per row on mobile)
/// - Glassmorphism background with substance-specific neon glow
/// - Recommended and optional dose (80% of normal) display
/// - Ripple effects and tap animations
/// - Overflow prevention with responsive text sizing
class EnhancedSubstanceCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final double? userWeight;
  final VoidCallback? onTap;
  final bool showOptionalDose;
  final bool isCompact;

  const EnhancedSubstanceCard({
    super.key,
    required this.substance,
    this.userWeight,
    this.onTap,
    this.showOptionalDose = true,
    this.isCompact = false,
  });

  @override
  State<EnhancedSubstanceCard> createState() => _EnhancedSubstanceCardState();
}

class _EnhancedSubstanceCardState extends State<EnhancedSubstanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _borderAnimation;
  
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveDefault,
    ));

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveDefault,
    ));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: DesignTokens.curveDefault,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final substanceColor = _getSubstanceColor(widget.substance.name);
    
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // Neon glow effect based on substance color
                  BoxShadow(
                    color: substanceColor.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: substanceColor.withOpacity(0.1 * _glowAnimation.value),
                    blurRadius: 40 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark ? [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ] : [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: substanceColor.withOpacity(0.3 * _borderAnimation.value),
                        width: 1.5 * _borderAnimation.value,
                      ),
                    ),
                    child: _buildCardContent(context, theme, substanceColor),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme, Color substanceColor) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and danger badge
            _buildHeader(theme, substanceColor),
            
            const SizedBox(height: 12),
            
            // Substance name
            _buildSubstanceName(theme, substanceColor),
            
            const SizedBox(height: 8),
            
            // Details (administration route and duration)
            _buildSubstanceDetails(theme),
            
            const SizedBox(height: 12),
            
            // Dosage indicator
            _buildDosageIndicator(theme, substanceColor),
            
            const SizedBox(height: 16),
            
            // Calculate button
            _buildCalculateButton(theme, substanceColor),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, Color substanceColor) {
    return Row(
      children: [
        // Substance icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: substanceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: substanceColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            _getSubstanceIcon(widget.substance.name),
            color: substanceColor,
            size: 24,
          ),
        ),
        
        const Spacer(),
        
        // Danger badge
        DangerBadge.fromSubstance(widget.substance.name),
      ],
    );
  }

  Widget _buildSubstanceName(ThemeData theme, Color substanceColor) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        widget.substance.name,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: substanceColor,
          fontSize: 20,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubstanceDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Administration route
        Row(
          children: [
            Icon(
              Icons.route_rounded,
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                widget.substance.administrationRouteDisplayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        
        // Duration
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                widget.substance.duration,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDosageIndicator(ThemeData theme, Color substanceColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended dose
          if (widget.userWeight != null) ...[
            _buildRecommendedDose(theme),
            const SizedBox(height: 8),
          ],
          
          // Optional dose (80% of normal)
          if (widget.showOptionalDose && widget.userWeight != null) ...[
            _buildOptionalDose(theme, substanceColor),
            const SizedBox(height: 8),
          ],
          
          // Dosage range
          _buildDosageRange(theme),
        ],
      ),
    );
  }

  Widget _buildRecommendedDose(ThemeData theme) {
    final recommendedDose = widget.substance.calculateDosage(widget.userWeight!, DosageIntensity.normal);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Empfohlene Dosis',
          style: theme.textTheme.bodySmall?.copyWith(
            color: DesignTokens.warningYellow,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${recommendedDose.toStringAsFixed(1)} mg',
            style: theme.textTheme.titleMedium?.copyWith(
              color: DesignTokens.warningYellow,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionalDose(ThemeData theme, Color substanceColor) {
    final normalDose = widget.substance.calculateDosage(widget.userWeight!, DosageIntensity.normal);
    final optionalDose = normalDose * 0.8; // 80% of normal dose
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optionale Dosis (80%)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: DesignTokens.successGreen,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${optionalDose.toStringAsFixed(1)} mg',
            style: theme.textTheme.titleMedium?.copyWith(
              color: DesignTokens.successGreen,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDosageRange(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildDosageRangeItem(
              theme,
              widget.userWeight != null 
                ? widget.substance.calculateDosage(widget.userWeight!, DosageIntensity.light)
                : widget.substance.lightDosePerKg,
              DesignTokens.successGreen,
            ),
            const SizedBox(width: 2),
            _buildDosageRangeItem(
              theme,
              widget.userWeight != null 
                ? widget.substance.calculateDosage(widget.userWeight!, DosageIntensity.normal)
                : widget.substance.normalDosePerKg,
              DesignTokens.warningYellow,
            ),
            const SizedBox(width: 2),
            _buildDosageRangeItem(
              theme,
              widget.userWeight != null 
                ? widget.substance.calculateDosage(widget.userWeight!, DosageIntensity.strong)
                : widget.substance.strongDosePerKg,
              DesignTokens.errorRed,
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Normal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Stark',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDosageRangeItem(ThemeData theme, double value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${value.toStringAsFixed(1)}mg',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton(ThemeData theme, Color substanceColor) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: Material(
        color: substanceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: substanceColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Berechnen',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: substanceColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubstanceColor(String substanceName) {
    final substanceColorMap = DesignTokens.getSubstanceColor(substanceName);
    return substanceColorMap['primary'] ?? DesignTokens.primaryIndigo;
  }

  IconData _getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma') || name.contains('ecstasy')) {
      return Icons.favorite_rounded; // 💖
    } else if (name.contains('lsd') || name.contains('acid')) {
      return Icons.psychology_rounded; // 🧠
    } else if (name.contains('ketamin') || name.contains('ketamine')) {
      return Icons.medical_services_rounded; // 🏥
    } else if (name.contains('kokain') || name.contains('cocaine')) {
      return Icons.bolt_rounded; // ⚡
    } else if (name.contains('alkohol') || name.contains('alcohol')) {
      return Icons.local_bar_rounded;
    } else if (name.contains('cannabis') || name.contains('thc')) {
      return Icons.local_florist_rounded;
    } else if (name.contains('psilocybin') || name.contains('mushroom')) {
      return Icons.forest_rounded;
    } else if (name.contains('2c-b')) {
      return Icons.auto_awesome_rounded;
    } else if (name.contains('amphetamin') || name.contains('speed')) {
      return Icons.flash_on_rounded;
    } else {
      return Icons.science_rounded;
    }
  }
}

/// Responsive grid layout for enhanced substance cards
class ResponsiveSubstanceGrid extends StatelessWidget {
  final List<DosageCalculatorSubstance> substances;
  final double? userWeight;
  final Function(DosageCalculatorSubstance) onCardTap;

  const ResponsiveSubstanceGrid({
    super.key,
    required this.substances,
    this.userWeight,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine if we should show 2 cards per row or 1
        final screenWidth = constraints.maxWidth;
        final showTwoColumns = screenWidth > 600; // Breakpoint for responsive layout
        
        if (showTwoColumns) {
          return _buildTwoColumnLayout(context, constraints);
        } else {
          return _buildSingleColumnLayout(context);
        }
      },
    );
  }

  Widget _buildTwoColumnLayout(BuildContext context, BoxConstraints constraints) {
    final itemWidth = (constraints.maxWidth - 16) / 2; // Account for spacing
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: substances.map((substance) {
        return SizedBox(
          width: itemWidth,
          child: EnhancedSubstanceCard(
            substance: substance,
            userWeight: userWeight,
            onTap: () => onCardTap(substance),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleColumnLayout(BuildContext context) {
    return Column(
      children: substances.map((substance) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: EnhancedSubstanceCard(
            substance: substance,
            userWeight: userWeight,
            onTap: () => onCardTap(substance),
          ),
        );
      }).toList(),
    );
  }
}