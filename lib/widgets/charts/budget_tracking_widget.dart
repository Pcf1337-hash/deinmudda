import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../glass_card.dart';

class BudgetTrackingWidget extends StatelessWidget {
  final double monthlyBudget;
  final double currentSpending;
  final int daysInMonth;
  final int daysElapsed;
  final List<Map<String, dynamic>> dailySpending;
  final String title;

  const BudgetTrackingWidget({
    super.key,
    required this.monthlyBudget,
    required this.currentSpending,
    required this.daysInMonth,
    required this.daysElapsed,
    required this.dailySpending,
    this.title = 'Budget-Tracking',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetAnalysis = _analyzeBudget();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: budgetAnalysis['statusColor'],
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
                  color: budgetAnalysis['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  budgetAnalysis['status'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: budgetAnalysis['statusColor'],
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Budget progress bar
          _buildBudgetProgress(context, budgetAnalysis),
          
          Spacing.verticalSpaceMd,
          
          // Budget metrics
          Row(
            children: [
              Expanded(
                child: _buildBudgetMetric(
                  context,
                  'Ausgegeben',
                  '${currentSpending.toStringAsFixed(2)}€',
                  '${budgetAnalysis['spentPercentage'].toStringAsFixed(1)}%',
                  budgetAnalysis['statusColor'],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: theme.dividerColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: _buildBudgetMetric(
                  context,
                  'Verbleibend',
                  '${budgetAnalysis['remaining'].toStringAsFixed(2)}€',
                  '${budgetAnalysis['remainingDays']} Tage',
                  budgetAnalysis['remaining'] > 0 
                      ? DesignTokens.successGreen 
                      : DesignTokens.errorRed,
                ),
              ),
            ],
          ),
          
          Spacing.verticalSpaceMd,
          
          // Daily budget insights
          _buildDailyBudgetInsights(context, budgetAnalysis),
          
          Spacing.verticalSpaceMd,
          
          // Budget recommendations
          _buildBudgetRecommendations(context, budgetAnalysis),
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

  Widget _buildBudgetProgress(BuildContext context, Map<String, dynamic> analysis) {
    final spentPercentage = analysis['spentPercentage'] as double;
    final expectedPercentage = analysis['expectedPercentage'] as double;
    final statusColor = analysis['statusColor'] as Color;
    
    return Column(
      children: [
        // Main progress bar
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: DesignTokens.neutral200,
          ),
          child: Stack(
            children: [
              // Expected spending indicator
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (expectedPercentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: DesignTokens.neutral400.withOpacity(0.5),
                  ),
                ),
              ),
              // Actual spending
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (spentPercentage / 100).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.7), statusColor],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Progress labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0€',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
            Text(
              'Erwartet: ${expectedPercentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
            Text(
              '${monthlyBudget.toStringAsFixed(0)}€',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DesignTokens.neutral500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetMetric(
    BuildContext context,
    String label,
    String primaryValue,
    String secondaryValue,
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
        Text(
          primaryValue,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          secondaryValue,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyBudgetInsights(BuildContext context, Map<String, dynamic> analysis) {
    final theme = Theme.of(context);
    final dailyBudget = analysis['dailyBudget'] as double;
    final averageDailySpending = analysis['averageDailySpending'] as double;
    final statusColor = analysis['statusColor'] as Color;
    
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: statusColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Tägliche Budget-Analyse',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget/Tag',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${dailyBudget.toStringAsFixed(2)}€',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ø Ausgaben/Tag',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${averageDailySpending.toStringAsFixed(2)}€',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: averageDailySpending > dailyBudget 
                            ? DesignTokens.errorRed 
                            : DesignTokens.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetRecommendations(BuildContext context, Map<String, dynamic> analysis) {
    final theme = Theme.of(context);
    final recommendations = analysis['recommendations'] as List<String>;
    
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_rounded,
              size: 16,
              color: DesignTokens.warningYellow,
            ),
            const SizedBox(width: 8),
            Text(
              'Empfehlungen',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: DesignTokens.warningYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recommendations.map((recommendation) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: DesignTokens.warningYellow,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Text(
                  recommendation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Map<String, dynamic> _analyzeBudget() {
    final spentPercentage = monthlyBudget > 0 ? (currentSpending / monthlyBudget) * 100 : 0.0;
    final expectedPercentage = daysInMonth > 0 ? (daysElapsed / daysInMonth) * 100 : 0.0;
    final remaining = monthlyBudget - currentSpending;
    final remainingDays = daysInMonth - daysElapsed;
    final dailyBudget = monthlyBudget / daysInMonth;
    
    // Calculate average daily spending
    double averageDailySpending = 0.0;
    if (daysElapsed > 0) {
      averageDailySpending = currentSpending / daysElapsed;
    }
    
    // Determine status
    String status;
    Color statusColor;
    
    if (spentPercentage > expectedPercentage + 20) {
      status = 'Über Budget';
      statusColor = DesignTokens.errorRed;
    } else if (spentPercentage > expectedPercentage + 10) {
      status = 'Kritisch';
      statusColor = DesignTokens.warningOrange;
    } else if (spentPercentage > expectedPercentage) {
      status = 'Über Plan';
      statusColor = DesignTokens.warningYellow;
    } else {
      status = 'Im Plan';
      statusColor = DesignTokens.successGreen;
    }
    
    // Generate recommendations
    final recommendations = <String>[];
    
    if (spentPercentage > expectedPercentage + 15) {
      recommendations.add('Ihre Ausgaben liegen deutlich über dem geplanten Budget.');
      recommendations.add('Reduzieren Sie die täglichen Ausgaben auf ${(remaining / remainingDays).toStringAsFixed(2)}€.');
    } else if (spentPercentage > expectedPercentage + 5) {
      recommendations.add('Sie liegen etwas über dem Budget-Plan.');
      recommendations.add('Achten Sie in den kommenden Tagen auf Ihre Ausgaben.');
    } else if (spentPercentage < expectedPercentage - 10) {
      recommendations.add('Sie sind deutlich unter Budget - gute Arbeit!');
    }
    
    if (averageDailySpending > dailyBudget * 1.5) {
      recommendations.add('Ihre durchschnittlichen Tagesausgaben sind sehr hoch.');
    }
    
    return {
      'spentPercentage': spentPercentage,
      'expectedPercentage': expectedPercentage,
      'remaining': remaining,
      'remainingDays': remainingDays,
      'dailyBudget': dailyBudget,
      'averageDailySpending': averageDailySpending,
      'status': status,
      'statusColor': statusColor,
      'recommendations': recommendations,
    };
  }
}