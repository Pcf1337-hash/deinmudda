import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../glass_card.dart';

class TrendComparisonWidget extends StatelessWidget {
  final List<Map<String, dynamic>> currentPeriodData;
  final List<Map<String, dynamic>> previousPeriodData;
  final String title;
  final String currentPeriodLabel;
  final String previousPeriodLabel;
  final Color primaryColor;
  final Color secondaryColor;

  const TrendComparisonWidget({
    super.key,
    required this.currentPeriodData,
    required this.previousPeriodData,
    required this.title,
    this.currentPeriodLabel = 'Aktuell',
    this.previousPeriodLabel = 'Vorher',
    this.primaryColor = DesignTokens.primaryIndigo,
    this.secondaryColor = DesignTokens.neutral400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate trend insights
    final currentTotal = _calculateTotal(currentPeriodData);
    final previousTotal = _calculateTotal(previousPeriodData);
    final changePercentage = _calculatePercentageChange(previousTotal, currentTotal);
    final trendDirection = _getTrendDirection(changePercentage);
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with trend indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: trendDirection['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: trendDirection['color'].withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendDirection['icon'],
                      size: 16,
                      color: trendDirection['color'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${changePercentage.abs().toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: trendDirection['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Comparison metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                  context,
                  currentPeriodLabel,
                  currentTotal.toString(),
                  primaryColor,
                  true,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildMetricColumn(
                  context,
                  previousPeriodLabel,
                  previousTotal.toString(),
                  secondaryColor,
                  false,
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Trend description
          Container(
            padding: Spacing.paddingMd,
            decoration: BoxDecoration(
              color: trendDirection['color'].withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: trendDirection['color'].withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  trendDirection['icon'],
                  size: 20,
                  color: trendDirection['color'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTrendDescription(changePercentage),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
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

  Widget _buildMetricColumn(
    BuildContext context,
    String label,
    String value,
    Color color,
    bool isMain,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: isMain ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  double _calculateTotal(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    return data.fold(0.0, (sum, item) => sum + (item['value'] as num? ?? 0).toDouble());
  }

  double _calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return newValue > 0 ? 100.0 : 0.0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  Map<String, dynamic> _getTrendDirection(double changePercentage) {
    if (changePercentage > 5) {
      return {
        'icon': Icons.trending_up_rounded,
        'color': DesignTokens.errorRed,
        'direction': 'up',
      };
    } else if (changePercentage < -5) {
      return {
        'icon': Icons.trending_down_rounded,
        'color': DesignTokens.successGreen,
        'direction': 'down',
      };
    } else {
      return {
        'icon': Icons.trending_flat_rounded,
        'color': DesignTokens.neutral500,
        'direction': 'stable',
      };
    }
  }

  String _getTrendDescription(double changePercentage) {
    if (changePercentage > 20) {
      return 'Deutlicher Anstieg des Konsums. Überprüfen Sie Ihre Gewohnheiten und überlegen Sie, ob dies Ihren Zielen entspricht.';
    } else if (changePercentage > 5) {
      return 'Leichter Anstieg des Konsums im Vergleich zum vorherigen Zeitraum.';
    } else if (changePercentage < -20) {
      return 'Deutliche Reduzierung des Konsums. Glückwunsch zu dieser positiven Entwicklung!';
    } else if (changePercentage < -5) {
      return 'Leichte Reduzierung des Konsums im Vergleich zum vorherigen Zeitraum.';
    } else {
      return 'Ihr Konsumverhalten ist relativ stabil geblieben.';
    }
  }
}