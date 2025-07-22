import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/dosage_calculator_substance.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/app_icon_generator.dart';

class SubstanceCard extends StatefulWidget {
  final DosageCalculatorSubstance substance;
  final VoidCallback? onTap;
  final bool showDosagePreview;
  final bool isCompact;
  final bool showRiskLevel;
  final double? userWeight; // Add user weight parameter

  const SubstanceCard({
    super.key,
    required this.substance,
    this.onTap,
    this.showDosagePreview = true,
    this.isCompact = false,
    this.showRiskLevel = true,
    this.userWeight, // Add user weight parameter
  });

  @override
  State<SubstanceCard> createState() => _SubstanceCardState();
}

class _SubstanceCardState extends State<SubstanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

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
      curve: DesignTokens.curveEaseOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
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
    if (widget.onTap != null) {
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
    final isDark = theme.brightness == Brightness.dark;
    final substanceColor = _getSubstanceColor(widget.substance.name);
    final riskColor = _getRiskColor(widget.substance.name);

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
                gradient: isDark
                    ? DesignTokens.glassGradientDark
                    : DesignTokens.glassGradientLight,
                borderRadius: Spacing.borderRadiusLg,
                border: Border.all(
                  color: substanceColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: substanceColor.withOpacity(0.1),
                    blurRadius: 10 + _elevationAnimation.value,
                    offset: Offset(0, 4 + _elevationAnimation.value / 2),
                  ),
                  BoxShadow(
                    color: isDark
                        ? DesignTokens.shadowDark.withOpacity(0.2)
                        : DesignTokens.shadowLight.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: widget.isCompact
                  ? _buildCompactContent(context, substanceColor, riskColor)
                  : _buildFullContent(context, substanceColor, riskColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactContent(BuildContext context, Color substanceColor, Color riskColor) {
    final theme = Theme.of(context);

    return Padding(
      padding: Spacing.paddingMd,
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: substanceColor.withOpacity(0.1),
              borderRadius: Spacing.borderRadiusMd,
            ),
            child: Icon(
              AppIconGenerator.getSubstanceIcon(widget.substance.name),
              color: substanceColor,
              size: Spacing.iconMd,
            ),
          ),
          
          Spacing.horizontalSpaceMd,
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.substance.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacing.verticalSpaceXs,
                Text(
                  widget.substance.administrationRouteDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Risk indicator
          if (widget.showRiskLevel)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.1),
                borderRadius: Spacing.borderRadiusSm,
              ),
              child: Icon(
                _getRiskIcon(widget.substance.name),
                color: riskColor,
                size: Spacing.iconSm,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, Color substanceColor, Color riskColor) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive dimensions based on available space
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        
        // Use flexible constraints instead of fixed heights
        final minHeight = math.max(220.0, availableHeight * 0.8);
        final maxHeight = math.min(320.0, availableHeight * 1.2);
        
        return Container(
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
            maxWidth: availableWidth,
          ),
          padding: EdgeInsets.all(math.max(12.0, availableWidth * 0.05)),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon and risk level
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(math.max(8.0, availableWidth * 0.04)),
                        decoration: BoxDecoration(
                          color: substanceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(math.max(8.0, availableWidth * 0.04)),
                        ),
                        child: Icon(
                          AppIconGenerator.getSubstanceIcon(widget.substance.name),
                          color: substanceColor,
                          size: math.min(Spacing.iconLg, availableWidth * 0.15),
                        ),
                      ),
                      
                      if (widget.showRiskLevel)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: math.max(8.0, availableWidth * 0.03),
                              vertical: math.max(4.0, availableWidth * 0.02),
                            ),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(math.max(6.0, availableWidth * 0.02)),
                              border: Border.all(
                                color: riskColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getRiskIcon(widget.substance.name),
                                  color: riskColor,
                                  size: math.min(Spacing.iconSm, availableWidth * 0.08),
                                ),
                                SizedBox(width: math.max(2.0, availableWidth * 0.01)),
                                Flexible(
                                  child: Text(
                                    _getRiskLevel(widget.substance.name),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: riskColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: math.min(14.0, availableWidth * 0.045),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: math.max(12.0, availableHeight * 0.04)),
                  
                  // Substance name with flexible sizing
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(35.0, availableHeight * 0.15),
                        maxHeight: math.max(60.0, availableHeight * 0.25),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.substance.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: substanceColor,
                            fontSize: math.min(22.0, availableWidth * 0.08),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: math.max(6.0, availableHeight * 0.02)),
                  
                  // Responsive administration route and duration info
                  _buildResponsiveInfoRows(context, theme, availableWidth),
                  
                  // Flexible dosage preview section
                  if (widget.showDosagePreview) ...[
                    SizedBox(height: math.max(8.0, availableHeight * 0.03)),
                    Flexible(
                      child: _buildResponsiveDosagePreview(context, substanceColor, availableWidth, availableHeight),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsiveInfoRows(BuildContext context, ThemeData theme, double availableWidth) {
    final iconSize = math.min(15.0, availableWidth * 0.05);
    final fontSize = math.min(12.5, availableWidth * 0.04);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.compare_arrows_rounded,
              color: theme.iconTheme.color?.withOpacity(0.7),
              size: iconSize,
            ),
            SizedBox(width: math.max(4.0, availableWidth * 0.01)),
            Flexible(
              child: Text(
                widget.substance.administrationRouteDisplayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: theme.iconTheme.color?.withOpacity(0.7),
              size: iconSize,
            ),
            SizedBox(width: math.max(4.0, availableWidth * 0.01)),
            Flexible(
              child: Text(
                widget.substance.durationWithIcon,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: math.max(13.0, fontSize), // Increased font size
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveDosagePreview(BuildContext context, Color substanceColor, double availableWidth, double availableHeight) {
    final theme = Theme.of(context);
    final padding = math.max(8.0, availableWidth * 0.03);
    final fontSize = math.min(13.0, availableWidth * 0.045);
    final titleFontSize = math.min(16.0, availableWidth * 0.055);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: math.max(70.0, availableHeight * 0.25),
        maxHeight: math.max(120.0, availableHeight * 0.4),
      ),
      padding: EdgeInsets.symmetric(
        vertical: padding,
        horizontal: math.max(10.0, availableWidth * 0.035),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(math.max(12.0, availableWidth * 0.04)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add recommended dose display if user weight is available
            if (widget.userWeight != null) ...[
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Optimale Dosis',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: substanceColor,
                      fontSize: fontSize,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(height: math.max(4.0, availableHeight * 0.01)),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.substance.getFormattedDosage(widget.userWeight!, DosageIntensity.normal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.amberAccent,
                      fontSize: titleFontSize,
                    ),
                  ),
                ),
              ),
              SizedBox(height: math.max(8.0, availableHeight * 0.02)),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Dosierungsbereich (pro kg)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: substanceColor,
                    fontSize: fontSize,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: math.max(2.0, availableHeight * 0.005)),
            // Use Flexible layout for dosage values
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${widget.substance.lightDosePerKg.toStringAsFixed(1)}mg',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.greenAccent,
                              fontSize: math.min(13.0, constraints.maxWidth * 0.08),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: math.max(2.0, constraints.maxWidth * 0.01)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${widget.substance.normalDosePerKg.toStringAsFixed(1)}mg',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.amberAccent,
                              fontSize: math.min(13.0, constraints.maxWidth * 0.08),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: math.max(2.0, constraints.maxWidth * 0.01)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${widget.substance.strongDosePerKg.toStringAsFixed(1)}mg',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.redAccent,
                              fontSize: math.min(13.0, constraints.maxWidth * 0.08),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Labels with responsive sizing
            Flexible(
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Leicht',
                        style: TextStyle(
                          fontSize: math.min(11.0, availableWidth * 0.035),
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Norm',
                        style: TextStyle(
                          fontSize: math.min(11.0, availableWidth * 0.035),
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Stark',
                        style: TextStyle(
                          fontSize: math.min(11.0, availableWidth * 0.035),
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosagePreview(BuildContext context, Color substanceColor) {
    // Keep existing method for backward compatibility
    return _buildResponsiveDosagePreview(context, substanceColor, 200.0, 200.0);
  }

  Color _getSubstanceColor(String substanceName) {
    final hash = substanceName.hashCode;
    final colors = [
      DesignTokens.primaryIndigo,
      DesignTokens.accentCyan,
      DesignTokens.accentEmerald,
      DesignTokens.accentPurple,
      DesignTokens.warningYellow,
      DesignTokens.primaryPurple,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getRiskColor(String substanceName) {
    final name = substanceName.toLowerCase();

    if (name.contains('mdma') || name.contains('lsd') || name.contains('kokain')) {
      return DesignTokens.errorRed; // High risk
    } else if (name.contains('ketamin') || name.contains('2c-b')) {
      return DesignTokens.warningYellow; // Medium risk
    } else if (name.contains('alkohol') || name.contains('psilocybin')) {
      return DesignTokens.warningOrange; // Medium-low risk
    } else {
      return DesignTokens.successGreen; // Low risk
    }
  }

  IconData _getRiskIcon(String substanceName) {
    final color = _getRiskColor(substanceName);

    if (color == DesignTokens.errorRed) {
      return Icons.dangerous_rounded;
    } else if (color == DesignTokens.warningYellow || color == DesignTokens.warningOrange) {
      return Icons.warning_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  String _getRiskLevel(String substanceName) {
    final color = _getRiskColor(substanceName);

    if (color == DesignTokens.errorRed) {
      return 'Hoch';
    } else if (color == DesignTokens.warningYellow || color == DesignTokens.warningOrange) {
      return 'Mittel';
    } else {
      return 'Niedrig';
    }
  }
}

class PopularSubstanceCard extends StatelessWidget {
  final DosageCalculatorSubstance substance;
  final VoidCallback? onTap;
  final bool showPopularBadge;
  final double? userWeight;

  const PopularSubstanceCard({
    super.key,
    required this.substance,
    this.onTap,
    this.showPopularBadge = true,
    this.userWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SubstanceCard(
          substance: substance,
          onTap: onTap,
          showDosagePreview: true,
          isCompact: false,
          showRiskLevel: true,
          userWeight: userWeight,
        ),
        if (showPopularBadge)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: 2,
              ),
              decoration: const BoxDecoration(
                color: DesignTokens.accentEmerald,
                borderRadius: Spacing.borderRadiusSm,
              ),
              child: Text(
                'Beliebt',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CompactSubstanceCard extends StatelessWidget {
  final DosageCalculatorSubstance substance;
  final VoidCallback? onTap;
  final double? userWeight;

  const CompactSubstanceCard({
    super.key,
    required this.substance,
    this.onTap,
    this.userWeight,
  });

  @override
  Widget build(BuildContext context) {
    return SubstanceCard(
      substance: substance,
      onTap: onTap,
      showDosagePreview: false,
      isCompact: true,
      showRiskLevel: true,
      userWeight: userWeight,
    );
  }
}
