import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// removed unused import: package:flutter/foundation.dart // cleaned by BereinigungsAgent
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/performance_helper.dart';

class BarChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<Color> barColors;
  final bool showValues;
  final double height;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.barColors = const [DesignTokens.primaryIndigo],
    this.showValues = true,
    this.height = 200,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Adjust animation duration based on device capabilities
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
    
    if (widget.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      height: widget.height + 80, // Extra space for labels
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
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: BarChartPainter(
                    data: widget.data,
                    barColors: widget.barColors,
                    showValues: widget.showValues,
                    animationValue: _animation.value,
                    textStyle: theme.textTheme.bodySmall!,
                  ),
                );
              },
            ),
          ),
          if (widget.xAxisLabel.isNotEmpty) ...[
            Spacing.verticalSpaceSm,
            Center(
              child: Text(
                widget.xAxisLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ),
          ],
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

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: widget.height,
      padding: Spacing.paddingMd,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: Spacing.iconXl,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
            Spacing.verticalSpaceMd,
            Text(
              'Keine Daten verfügbar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final List<Color> barColors;
  final bool showValues;
  final double animationValue;
  final TextStyle textStyle;

  BarChartPainter({
    required this.data,
    required this.barColors,
    required this.showValues,
    required this.animationValue,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 40.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    // Find max value
    final values = data.map((d) => (d['value'] as num).toDouble()).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    if (maxValue <= 0) return;

    // Calculate bar dimensions
    final barWidth = chartWidth / data.length * 0.8;
    final barSpacing = chartWidth / data.length * 0.2;

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final value = values[i];
      final normalizedHeight = (value / maxValue) * chartHeight * animationValue;
      
      final barRect = Rect.fromLTWH(
        padding + (i * (barWidth + barSpacing)) + barSpacing / 2,
        padding + chartHeight - normalizedHeight,
        barWidth,
        normalizedHeight,
      );

      final color = barColors[i % barColors.length];
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Draw bar with rounded corners
      final borderRadius = BorderRadius.circular(4.0);
      final rrect = RRect.fromRectAndCorners(
        barRect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      );
      
      canvas.drawRRect(rrect, paint);

      // Draw value on top of bar
      if (showValues && animationValue > 0.7) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: value.toStringAsFixed(0),
            style: textStyle.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textX = barRect.center.dx - textPainter.width / 2;
        final textY = barRect.top - textPainter.height - 4;
        
        textPainter.paint(canvas, Offset(textX, textY));
      }

      // Draw label below bar
      final label = data[i]['label']?.toString() ?? '';
      if (label.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: label.length > 10 ? '${label.substring(0, 10)}...' : label,
            style: textStyle.copyWith(fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        
        final textX = barRect.center.dx - textPainter.width / 2;
        final textY = padding + chartHeight + 5;
        
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // Only draw Y-axis labels if not on a low-end device in release mode
    if (!kReleaseMode || !PerformanceHelper.isLowEndDevice()) {
      _drawYAxisLabels(canvas, padding, chartHeight, maxValue);
    }
  }

  void _drawYAxisLabels(Canvas canvas, double padding, double chartHeight, double maxValue) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int i = 0; i <= 4; i++) {
      final value = (maxValue / 4) * i;
      final y = padding + chartHeight - (i / 4) * chartHeight;
      
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: textStyle.copyWith(fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}