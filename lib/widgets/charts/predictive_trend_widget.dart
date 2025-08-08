import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../glass_card.dart';

class PredictiveTrendWidget extends StatelessWidget {
  final List<Map<String, dynamic>> historicalData;
  final String title;
  final String metric;
  final int forecastDays;
  final Color trendColor;

  const PredictiveTrendWidget({
    super.key,
    required this.historicalData,
    required this.title,
    this.metric = 'Einträge',
    this.forecastDays = 7,
    this.trendColor = DesignTokens.primaryIndigo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prediction = _calculatePrediction();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                color: trendColor,
                size: 24,
              ),
              const SizedBox(width: 12),
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
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPredictionColor(prediction['confidence']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prediction['confidence'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPredictionColor(prediction['confidence']),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Prediction metrics
          Row(
            children: [
              Expanded(
                child: _buildPredictionMetric(
                  context,
                  'Prognose ($forecastDays Tage)',
                  '${prediction['forecast'].toStringAsFixed(1)} $metric',
                  prediction['trend'],
                  trendColor,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: theme.dividerColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildPredictionMetric(
                  context,
                  'Durchschnitt (7T)',
                  '${prediction['recentAverage'].toStringAsFixed(1)} $metric',
                  'baseline',
                  DesignTokens.neutral500,
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Trend visualization
          _buildTrendVisualization(context, prediction),
          
          Spacing.verticalSpaceMd,
          
          // Insights
          _buildPredictionInsights(context, prediction),
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

  Widget _buildPredictionMetric(
    BuildContext context,
    String label,
    String value,
    String trend,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (trend != 'baseline') ...[
              Icon(
                _getTrendIcon(trend),
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendVisualization(BuildContext context, Map<String, dynamic> prediction) {
    final theme = Theme.of(context);
    final trendStrength = prediction['trendStrength'] as double;
    
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: trendColor.withOpacity(0.2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: trendStrength.abs().clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: trendStrength > 0 
                  ? [DesignTokens.errorRed.withOpacity(0.6), DesignTokens.errorRed]
                  : [DesignTokens.successGreen.withOpacity(0.6), DesignTokens.successGreen],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionInsights(BuildContext context, Map<String, dynamic> prediction) {
    final theme = Theme.of(context);
    final insights = _generateInsights(prediction);
    
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: trendColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: trendColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Vorhersage-Einblicke',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: Text(
                    insight,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculatePrediction() {
    if (historicalData.length < 3) {
      return {
        'forecast': 0.0,
        'recentAverage': 0.0,
        'trend': 'stable',
        'trendStrength': 0.0,
        'confidence': 'Niedrig',
      };
    }

    // Get recent values
    final recentData = historicalData.take(7).toList();
    final values = recentData.map((d) => (d['value'] as num).toDouble()).toList();
    
    // Calculate moving average
    final recentAverage = values.reduce((a, b) => a + b) / values.length;
    
    // Simple linear trend calculation
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < values.length; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }
    
    final n = values.length;
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;
    
    // Forecast
    final forecast = slope * (n + forecastDays) + intercept;
    
    // Determine trend
    String trend;
    double trendStrength = slope.abs() / (recentAverage + 1); // Avoid division by zero
    
    if (slope > 0.1) {
      trend = 'increasing';
    } else if (slope < -0.1) {
      trend = 'decreasing';
    } else {
      trend = 'stable';
    }
    
    // Confidence based on data consistency
    String confidence;
    if (historicalData.length >= 14) {
      confidence = 'Hoch';
    } else if (historicalData.length >= 7) {
      confidence = 'Mittel';
    } else {
      confidence = 'Niedrig';
    }
    
    return {
      'forecast': forecast.clamp(0.0, double.infinity),
      'recentAverage': recentAverage,
      'trend': trend,
      'trendStrength': trendStrength.clamp(0.0, 1.0),
      'confidence': confidence,
    };
  }

  List<String> _generateInsights(Map<String, dynamic> prediction) {
    final insights = <String>[];
    final trend = prediction['trend'] as String;
    final forecast = prediction['forecast'] as double;
    final recentAverage = prediction['recentAverage'] as double;
    final confidence = prediction['confidence'] as String;
    
    if (trend == 'increasing') {
      insights.add('Steigender Trend erkannt - möglicherweise erhöhter Konsum in den nächsten Tagen');
      if (forecast > recentAverage * 1.2) {
        insights.add('Deutliche Zunahme prognostiziert - achten Sie auf Ihre Gewohnheiten');
      }
    } else if (trend == 'decreasing') {
      insights.add('Sinkender Trend erkannt - positive Entwicklung Ihres Konsumverhaltens');
      insights.add('Ihre Bemühungen zeigen Wirkung - halten Sie den Kurs');
    } else {
      insights.add('Stabiles Konsummuster - keine signifikanten Änderungen erwartet');
    }
    
    insights.add('Vertrauen der Vorhersage: $confidence (basierend auf ${historicalData.length} Datenpunkten)');
    
    return insights;
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'increasing':
        return Icons.trending_up_rounded;
      case 'decreasing':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  Color _getPredictionColor(String confidence) {
    switch (confidence) {
      case 'Hoch':
        return DesignTokens.successGreen;
      case 'Mittel':
        return DesignTokens.warningYellow;
      default:
        return DesignTokens.errorRed;
    }
  }
}