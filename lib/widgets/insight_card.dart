import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'glass_card.dart';
import '../theme/design_tokens.dart';
import '../theme/spacing.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String insight;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final Widget? actionWidget;

  const InsightCard({
    super.key,
    required this.title,
    required this.insight,
    required this.icon,
    this.iconColor = DesignTokens.primaryIndigo,
    this.backgroundColor,
    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
              if (actionWidget != null) actionWidget!,
            ],
          ),
          Spacing.verticalSpaceMd,
          Text(
            insight,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }
}

class PatternInsightCard extends StatelessWidget {
  final String patternType;
  final String primaryMetric;
  final String secondaryMetric;
  final String description;
  final IconData icon;
  final Color color;
  final double progress;

  const PatternInsightCard({
    super.key,
    required this.patternType,
    required this.primaryMetric,
    required this.secondaryMetric,
    required this.description,
    required this.icon,
    required this.color,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and pattern type
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patternType,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      primaryMetric,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Secondary metric
          if (secondaryMetric.isNotEmpty) ...[
            Text(
              secondaryMetric,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacing.verticalSpaceSm,
          ],
          
          // Progress bar if applicable
          if (progress > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            Spacing.verticalSpaceSm,
          ],
          
          // Description
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }
}

class ComparisonInsightCard extends StatelessWidget {
  final String title;
  final String currentValue;
  final String previousValue;
  final double changePercentage;
  final String changeDescription;
  final IconData icon;

  const ComparisonInsightCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.changePercentage,
    required this.changeDescription,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = changePercentage > 0;
    final isNegative = changePercentage < 0;
    final changeColor = isPositive 
        ? DesignTokens.errorRed 
        : isNegative 
            ? DesignTokens.successGreen 
            : DesignTokens.neutral500;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                icon,
                color: DesignTokens.primaryIndigo,
                size: 24,
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Change indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive 
                          ? Icons.trending_up_rounded
                          : isNegative 
                              ? Icons.trending_down_rounded
                              : Icons.trending_flat_rounded,
                      color: changeColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercentage.abs().toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Current vs Previous values
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktuell',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      currentValue,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor.withOpacity(0.3),
              ),
              Spacing.horizontalSpaceMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vorher',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      previousValue,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.titleLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Change description
          Container(
            padding: Spacing.paddingMd,
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: changeColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              changeDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: DesignTokens.animationMedium,
    ).slideY(
      begin: 0.3,
      end: 0,
      duration: DesignTokens.animationMedium,
      curve: DesignTokens.curveEaseOut,
    );
  }
}