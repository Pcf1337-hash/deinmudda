import 'package:flutter/material.dart';
import '../../models/dosage_calculator_substance.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';

class DosageLevelIndicator extends StatelessWidget {
  final DosageCalculatorSubstance substance;
  final double? userWeight;
  final bool isCompact;
  final bool showLabels;

  const DosageLevelIndicator({
    super.key,
    required this.substance,
    this.userWeight,
    this.isCompact = false,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 6 : 8,
        horizontal: isCompact ? 8 : 12,
      ),
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
          if (userWeight != null) ...[
            _buildRecommendedDose(context, theme),
            SizedBox(height: isCompact ? 4 : 6),
          ],
          _buildDosageRange(context, theme),
          if (showLabels) ...[
            SizedBox(height: isCompact ? 2 : 4),
            _buildDosageLabels(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendedDose(BuildContext context, ThemeData theme) {
    final recommendedDose = substance.calculateDosage(userWeight!, DosageIntensity.normal);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimale Dosis',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.amberAccent,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 10 : 12,
          ),
        ),
        SizedBox(height: isCompact ? 1 : 2),
        Text(
          '${recommendedDose.toStringAsFixed(1)} mg',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.amberAccent,
            fontWeight: FontWeight.w800,
            fontSize: isCompact ? 14 : 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDosageRange(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dosierungsbereich ${userWeight != null ? '(für ${userWeight!.toStringAsFixed(0)} kg)' : '(pro kg)'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 10 : 12,
          ),
        ),
        SizedBox(height: isCompact ? 2 : 4),
        Row(
          children: [
            _buildDosageValue(
              context,
              theme,
              userWeight != null 
                ? substance.calculateDosage(userWeight!, DosageIntensity.light)
                : substance.lightDosePerKg,
              DesignTokens.successGreen,
              flex: 1,
            ),
            SizedBox(width: isCompact ? 1 : 2),
            _buildDosageValue(
              context,
              theme,
              userWeight != null 
                ? substance.calculateDosage(userWeight!, DosageIntensity.normal)
                : substance.normalDosePerKg,
              DesignTokens.warningYellow,
              flex: 1,
            ),
            SizedBox(width: isCompact ? 1 : 2),
            _buildDosageValue(
              context,
              theme,
              userWeight != null 
                ? substance.calculateDosage(userWeight!, DosageIntensity.strong)
                : substance.strongDosePerKg,
              DesignTokens.errorRed,
              flex: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDosageValue(BuildContext context, ThemeData theme, double value, Color color, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isCompact ? 4 : 6,
          horizontal: isCompact ? 4 : 8,
        ),
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
                fontSize: isCompact ? 11 : 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDosageLabels(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Leicht',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              fontSize: isCompact ? 9 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Normal',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              fontSize: isCompact ? 9 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'Stark',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
              fontSize: isCompact ? 9 : 11,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}