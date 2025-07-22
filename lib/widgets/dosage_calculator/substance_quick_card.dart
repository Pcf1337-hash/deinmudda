import 'package:flutter/material.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/app_icon_generator.dart';
import 'danger_badge.dart';
import 'dosage_level_indicator.dart';
import 'substance_glass_card.dart';

class SubstanceQuickCard extends StatelessWidget {
  final DosageCalculatorSubstance substance;
  final double? userWeight;
  final VoidCallback? onTap;
  final bool showDosagePreview;
  final bool isCompact;

  const SubstanceQuickCard({
    super.key,
    required this.substance,
    this.userWeight,
    this.onTap,
    this.showDosagePreview = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final substanceColor = _getSubstanceColor(substance.name);
    
    return AnimatedSubstanceGlassCard(
      substanceColor: substanceColor,
      onTap: onTap,
      child: isCompact 
        ? _buildCompactLayout(context, substanceColor)
        : _buildFullLayout(context, substanceColor),
    );
  }

  Widget _buildCompactLayout(BuildContext context, Color substanceColor) {
    final theme = Theme.of(context);
    
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // Icon
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
              _getSubstanceIcon(substance.name),
              color: substanceColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  substance.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: substanceColor,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  substance.administrationRouteDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Danger badge
          DangerBadge.fromSubstance(substance.name),
        ],
      ),
    );
  }

  Widget _buildFullLayout(BuildContext context, Color substanceColor) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height for content
        final availableHeight = constraints.maxHeight - 32; // Account for padding
        
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 200,
            maxHeight: double.infinity,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and danger badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
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
                        _getSubstanceIcon(substance.name),
                        color: substanceColor,
                        size: 24,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Danger badge
                    DangerBadge.fromSubstance(substance.name),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Substance name
                Text(
                  substance.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: substanceColor,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Administration route and duration
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.route_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            substance.administrationRouteDisplayName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
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
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            substance.durationWithIcon,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 13,
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
                ),
                
                const SizedBox(height: 12),
                
                // Dosage indicator (flexible height)
                if (showDosagePreview) ...[
                  Flexible(
                    child: DosageLevelIndicator(
                      substance: substance,
                      userWeight: userWeight,
                      isCompact: true,
                      showLabels: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Calculate button - always at bottom
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: substanceColor.withOpacity(0.1),
                      foregroundColor: substanceColor,
                      side: BorderSide(
                        color: substanceColor.withOpacity(0.3),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Berechnen',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSubstanceColor(String substanceName) {
    final substanceColorMap = DesignTokens.getSubstanceColor(substanceName);
    return substanceColorMap['primary'] ?? DesignTokens.primaryIndigo;
  }

  IconData _getSubstanceIcon(String substanceName) {
    final name = substanceName.toLowerCase();
    
    if (name.contains('mdma') || name.contains('ecstasy')) {
      return Icons.favorite_rounded;
    } else if (name.contains('lsd') || name.contains('acid')) {
      return Icons.psychology_rounded;
    } else if (name.contains('ketamin') || name.contains('ketamine')) {
      return Icons.medical_services_rounded;
    } else if (name.contains('kokain') || name.contains('cocaine')) {
      return Icons.bolt_rounded;
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

// Alternative implementation for grid layouts
class SubstanceGridCard extends StatelessWidget {
  final DosageCalculatorSubstance substance;
  final double? userWeight;
  final VoidCallback? onTap;

  const SubstanceGridCard({
    super.key,
    required this.substance,
    this.userWeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: SubstanceQuickCard(
        substance: substance,
        userWeight: userWeight,
        onTap: onTap,
        showDosagePreview: true,
        isCompact: false,
      ),
    );
  }
}