import 'package:flutter/material.dart';
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

    return Container(
      constraints: const BoxConstraints(
        minHeight: 220,
        maxHeight: 280,
      ),
      padding: Spacing.paddingMd,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and risk level
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: substanceColor.withOpacity(0.1),
                    borderRadius: Spacing.borderRadiusMd,
                  ),
                  child: Icon(
                    AppIconGenerator.getSubstanceIcon(widget.substance.name),
                    color: substanceColor,
                    size: Spacing.iconLg,
                  ),
                ),
                
                if (widget.showRiskLevel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: Spacing.borderRadiusSm,
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
                          size: Spacing.iconSm,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRiskLevel(widget.substance.name),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: riskColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            Spacing.verticalSpaceMd,
            
            // Substance name
            Flexible(
              child: Text(
                widget.substance.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: substanceColor,
                  fontSize: 22,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            Spacing.verticalSpaceXs,
            
            // Konsumform und Dauer UNTEREINANDER (mit kleinerer Schrift!)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: theme.iconTheme.color?.withOpacity(0.7),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.substance.administrationRouteDisplayName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 12.5,
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
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.substance.duration,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Abstand zum Warnhinweis verringern (statt Spacing.verticalSpaceMd benutzt: SizedBox(height: 10))
            if (widget.showDosagePreview) ...[
              const SizedBox(height: 10),
              _buildDosagePreview(context, substanceColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDosagePreview(BuildContext context, Color substanceColor) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add recommended dose display if user weight is available
          if (widget.userWeight != null) ...[
            Flexible(
              child: Text(
                'Empfohlene Dosis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: substanceColor,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.substance.getFormattedDosage(widget.userWeight!, DosageIntensity.normal),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.amberAccent,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Flexible(
            child: Text(
              'Dosierungsbereich (pro kg)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: substanceColor,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.substance.lightDosePerKg.toStringAsFixed(1)}mg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.greenAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.substance.normalDosePerKg.toStringAsFixed(1)}mg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.amberAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.substance.strongDosePerKg.toStringAsFixed(1)}mg',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Expanded(child: Text('Leicht', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
              Expanded(child: Text('Norm', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
              Expanded(child: Text('Stark', style: TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
            ],
          ),
        ],
      ),
    );
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
