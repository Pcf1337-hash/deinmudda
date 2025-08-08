import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/performance_helper.dart';

class CorrelationMatrixWidget extends StatefulWidget {
  final List<Map<String, dynamic>> correlationData;
  final String title;
  final double height;

  const CorrelationMatrixWidget({
    super.key,
    required this.correlationData,
    required this.title,
    this.height = 250,
  });

  @override
  State<CorrelationMatrixWidget> createState() => _CorrelationMatrixWidgetState();
}

class _CorrelationMatrixWidgetState extends State<CorrelationMatrixWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    final animationDuration = PerformanceHelper.getAnimationDuration(DesignTokens.animationSlow);
    
    _animationController = AnimationController(
      duration: animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: DesignTokens.curveEaseOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.correlationData.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      padding: Spacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceMd,
          
          // Top correlations list
          _buildTopCorrelationsList(theme),
          
          Spacing.verticalSpaceLg,
          
          // Correlation strength legend
          _buildCorrelationLegend(theme),
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

  Widget _buildTopCorrelationsList(ThemeData theme) {
    // Show top 5 correlations
    final topCorrelations = widget.correlationData.take(5).toList();
    
    return Column(
      children: topCorrelations.asMap().entries.map((entry) {
        final index = entry.key;
        final correlation = entry.value;
        final substance1 = correlation['substance1'] as String;
        final substance2 = correlation['substance2'] as String;
        final correlationValue = correlation['correlation'] as double;
        final strength = correlation['strength'] as String;
        final coOccurrences = correlation['coOccurrences'] as int;
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 20),
                child: Container(
                  margin: const EdgeInsets.only(bottom: Spacing.sm),
                  padding: Spacing.paddingMd,
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(Spacing.md),
                    border: Border.all(
                      color: _getStrengthColor(strength).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getStrengthColor(strength),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      
                      Spacing.horizontalSpaceMd,
                      
                      // Substance names and details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: substance1,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const TextSpan(text: ' + '),
                                  TextSpan(
                                    text: substance2,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  _getStrengthDisplayName(strength),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _getStrengthColor(strength),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(' • '),
                                Text(
                                  '$coOccurrences gemeinsame Tage',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Correlation percentage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStrengthColor(strength).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(Spacing.sm),
                        ),
                        child: Text(
                          '${(correlationValue * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStrengthColor(strength),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildCorrelationLegend(ThemeData theme) {
    return Container(
      padding: Spacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Spacing.md),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Korrelationsstärke',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalSpaceSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(theme, 'Stark', DesignTokens.errorRed, '70-100%'),
              _buildLegendItem(theme, 'Mittel', DesignTokens.warningYellow, '40-69%'),
              _buildLegendItem(theme, 'Schwach', DesignTokens.successGreen, '0-39%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          range,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: widget.height,
      padding: Spacing.paddingMd,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.scatter_plot_rounded,
              size: Spacing.iconXl,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
            Spacing.verticalSpaceMd,
            Text(
              'Keine Korrelationen gefunden',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mindestens 2 Substanzen benötigt',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Stark':
        return DesignTokens.errorRed;
      case 'Mittel':
        return DesignTokens.warningYellow;
      case 'Schwach':
        return DesignTokens.successGreen;
      default:
        return DesignTokens.neutral500;
    }
  }

  String _getStrengthDisplayName(String strength) {
    switch (strength) {
      case 'Stark':
        return 'Starke Korrelation';
      case 'Mittel':
        return 'Mittlere Korrelation';
      case 'Schwach':
        return 'Schwache Korrelation';
      default:
        return strength;
    }
  }
}