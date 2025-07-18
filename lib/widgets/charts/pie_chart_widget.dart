import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/performance_helper.dart';

class PieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final List<Color> colors;
  final bool showLegend;
  final bool showPercentages;
  final double size;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.colors = const [
      DesignTokens.primaryIndigo,
      DesignTokens.accentCyan,
      DesignTokens.accentEmerald,
      DesignTokens.warningYellow,
      DesignTokens.errorRed,
      DesignTokens.accentPurple,
    ],
    this.showLegend = true,
    this.showPercentages = true,
    this.size = 200,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget>
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
          Row(
            children: [
              // Pie Chart
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: PieChartPainter(
                      data: widget.data,
                      colors: widget.colors,
                      showPercentages: widget.showPercentages,
                      animationValue: _animation.value,
                      textStyle: theme.textTheme.bodySmall!,
                    ),
                  );
                },
              ),
              
              // Legend
              if (widget.showLegend) ...[
                Spacing.horizontalSpaceLg,
                Expanded(
                  child: _buildLegend(theme),
                ),
              ],
            ],
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

  Widget _buildLegend(ThemeData theme) {
    final total = widget.data.fold<double>(
      0, 
      (sum, item) => sum + (item['value'] as num).toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final value = (item['value'] as num).toDouble();
        final percentage = total > 0 ? (value / total * 100) : 0.0;
        final color = widget.colors[index % widget.colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: Spacing.sm),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Spacing.horizontalSpaceSm,
              Expanded(
                child: Text(
                  item['label']?.toString() ?? '',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: widget.size,
      padding: Spacing.paddingMd,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_rounded,
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

class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final List<Color> colors;
  final bool showPercentages;
  final double animationValue;
  final TextStyle textStyle;

  PieChartPainter({
    required this.data,
    required this.colors,
    required this.showPercentages,
    required this.animationValue,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Optimize for low-end devices
    final isLowEndDevice = kReleaseMode && PerformanceHelper.isLowEndDevice();
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    
    // Calculate total value
    final total = data.fold<double>(
      0, 
      (sum, item) => sum + (item['value'] as num).toDouble(),
    );
    
    if (total <= 0) return;

    double startAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < data.length; i++) {
      final value = (data[i]['value'] as num).toDouble();
      final sweepAngle = (value / total) * 2 * math.pi * animationValue;
      
      if (sweepAngle > 0) {
        final paint = Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.fill;

        // Draw pie slice
        final rect = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

        // Draw percentage text
        if (showPercentages && animationValue > 0.7 && !isLowEndDevice) {
          final percentage = (value / total * 100);
          if (percentage >= 5) { // Only show percentage if slice is large enough
            final textAngle = startAngle + sweepAngle / 2;
            final textRadius = radius * 0.7;
            final textCenter = Offset(
              center.dx + math.cos(textAngle) * textRadius,
              center.dy + math.sin(textAngle) * textRadius,
            );

            final textPainter = TextPainter(
              text: TextSpan(
                text: '${percentage.toStringAsFixed(0)}%',
                style: textStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            
            textPainter.paint(
              canvas,
              Offset(
                textCenter.dx - textPainter.width / 2,
                textCenter.dy - textPainter.height / 2,
              ),
            );
          }
        }

        startAngle += sweepAngle;
      }
    }

    // Draw center circle for donut effect
    if (!isLowEndDevice) {
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.4, centerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}