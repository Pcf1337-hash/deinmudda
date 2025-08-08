import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/performance_helper.dart';

class HeatmapWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<Color> heatColors;
  final double height;

  const HeatmapWidget({
    super.key,
    required this.data,
    required this.title,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.heatColors = const [
      Color(0xFF3B82F6), // Blue
      Color(0xFF06B6D4), // Cyan
      Color(0xFF10B981), // Emerald
      Color(0xFFEAB308), // Yellow
      Color(0xFFF97316), // Orange
      Color(0xFFEF4444), // Red
    ],
    this.height = 200,
  });

  @override
  State<HeatmapWidget> createState() => _HeatmapWidgetState();
}

class _HeatmapWidgetState extends State<HeatmapWidget>
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
    
    if (widget.data.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      height: widget.height + 80,
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
                  painter: HeatmapPainter(
                    data: widget.data,
                    heatColors: widget.heatColors,
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
              Icons.grid_view_rounded,
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

class HeatmapPainter extends CustomPainter {
  final Map<String, dynamic> data;
  final List<Color> heatColors;
  final double animationValue;
  final TextStyle textStyle;

  HeatmapPainter({
    required this.data,
    required this.heatColors,
    required this.animationValue,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 60.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    // For time of day heatmap: hours (x-axis) vs weekdays (y-axis)
    final hours = 24;
    final weekdays = 7;
    final cellWidth = chartWidth / hours;
    final cellHeight = chartHeight / weekdays;

    // Get the hourly distribution data
    final hourlyDistribution = data['hourlyDistribution'] as Map<String, int>? ?? {};
    final weekdayDistribution = data['weekdayDistribution'] as Map<String, int>? ?? {};

    // Find max value for normalization
    double maxValue = 0;
    hourlyDistribution.forEach((hour, count) {
      if (count > maxValue) maxValue = count.toDouble();
    });

    if (maxValue == 0) return;

    // Draw weekday labels (y-axis)
    final weekdayNames = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    for (int day = 0; day < weekdays; day++) {
      final y = padding + (day * cellHeight) + (cellHeight / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: weekdayNames[day],
          style: textStyle.copyWith(fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(padding - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // Draw hour labels (x-axis) - show every 4 hours
    for (int hour = 0; hour < hours; hour += 4) {
      final x = padding + (hour * cellWidth) + (cellWidth / 2);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${hour.toString().padLeft(2, '0')}h',
          style: textStyle.copyWith(fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(x - textPainter.width / 2, size.height - padding + 5),
      );
    }

    // Draw heatmap cells
    for (int hour = 0; hour < hours; hour++) {
      for (int day = 0; day < weekdays; day++) {
        final value = hourlyDistribution[hour.toString().padLeft(2, '0')] ?? 0;
        final normalizedValue = maxValue > 0 ? value / maxValue : 0.0;
        
        // Animate the opacity
        final animatedOpacity = normalizedValue * animationValue;
        
        // Get color based on intensity
        final colorIndex = (animatedOpacity * (heatColors.length - 1)).round();
        final color = heatColors[colorIndex.clamp(0, heatColors.length - 1)]
            .withOpacity(animatedOpacity.clamp(0.1, 1.0));

        final rect = Rect.fromLTWH(
          padding + (hour * cellWidth),
          padding + (day * cellHeight),
          cellWidth - 1, // Small gap between cells
          cellHeight - 1,
        );

        final paint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          paint,
        );

        // Draw value text if cell is large enough and value is significant
        if (cellWidth > 20 && cellHeight > 20 && normalizedValue > 0.1 && animationValue > 0.7) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: value.toString(),
              style: textStyle.copyWith(
                fontSize: 8,
                color: normalizedValue > 0.5 ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          
          if (textPainter.width < cellWidth - 4 && textPainter.height < cellHeight - 4) {
            textPainter.paint(
              canvas,
              Offset(
                rect.center.dx - textPainter.width / 2,
                rect.center.dy - textPainter.height / 2,
              ),
            );
          }
        }
      }
    }

    // Draw color legend
    if (!kReleaseMode || !PerformanceHelper.isLowEndDevice()) {
      _drawColorLegend(canvas, size, padding);
    }
  }

  void _drawColorLegend(Canvas canvas, Size size, double padding) {
    final legendWidth = 100.0;
    final legendHeight = 15.0;
    final legendX = size.width - padding - legendWidth;
    final legendY = padding;

    // Draw legend gradient
    for (int i = 0; i < legendWidth; i++) {
      final normalizedPosition = i / legendWidth;
      final colorIndex = (normalizedPosition * (heatColors.length - 1));
      final color = Color.lerp(
        heatColors[colorIndex.floor()],
        heatColors[colorIndex.ceil().clamp(0, heatColors.length - 1)],
        colorIndex - colorIndex.floor(),
      ) ?? heatColors.first;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(legendX + i, legendY, 1, legendHeight),
        paint,
      );
    }

    // Draw legend labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // "Niedrig" label
    textPainter.text = TextSpan(
      text: 'Niedrig',
      style: textStyle.copyWith(fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(legendX, legendY + legendHeight + 2));

    // "Hoch" label
    textPainter.text = TextSpan(
      text: 'Hoch',
      style: textStyle.copyWith(fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(legendX + legendWidth - textPainter.width, legendY + legendHeight + 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}