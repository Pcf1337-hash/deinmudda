import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import '../../theme/design_tokens.dart';
import '../../theme/spacing.dart';
import '../../utils/performance_helper.dart';

class LineChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final Color lineColor;
  final bool showDots;
  final bool showGrid;
  final double height;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.xAxisLabel = '',
    this.yAxisLabel = '',
    this.lineColor = DesignTokens.primaryIndigo,
    this.showDots = true,
    this.showGrid = true,
    this.height = 200,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
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
      height: widget.height + 60, // Extra space for labels
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
                  painter: LineChartPainter(
                    data: widget.data,
                    lineColor: widget.lineColor,
                    showDots: widget.showDots,
                    showGrid: widget.showGrid,
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
              Icons.show_chart_rounded,
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

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color lineColor;
  final bool showDots;
  final bool showGrid;
  final double animationValue;
  final TextStyle textStyle;

  LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.showDots,
    required this.showGrid,
    required this.animationValue,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;
      
    // Optimize for low-end devices
    final isLowEndDevice = kReleaseMode && PerformanceHelper.isLowEndDevice();

    // Calculate bounds
    final padding = 40.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);

    // Find min/max values
    final values = data.map((d) => (d['value'] as num).toDouble()).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final valueRange = maxValue - minValue;

    // Draw grid
    if (showGrid && !isLowEndDevice) {
      _drawGrid(canvas, size, padding, chartWidth, chartHeight, gridPaint);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final normalizedValue = valueRange > 0 ? (values[i] - minValue) / valueRange : 0.5;
      final y = padding + chartHeight - (normalizedValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Draw animated line
    if (points.length > 1) {
      final animatedPoints = points.take((points.length * animationValue).ceil()).toList();
      if (animatedPoints.length > 1) {
        final path = Path();
        path.moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
        
        for (int i = 1; i < animatedPoints.length; i++) {
          path.lineTo(animatedPoints[i].dx, animatedPoints[i].dy);
        }
        
        canvas.drawPath(path, paint);
      }
    }

    // Draw dots
    if (showDots && animationValue > 0.5 && !isLowEndDevice) {
      final visibleDots = (points.length * (animationValue - 0.5) * 2).ceil();
      for (int i = 0; i < visibleDots && i < points.length; i++) {
        canvas.drawCircle(points[i], 4.0, dotPaint);
        canvas.drawCircle(points[i], 4.0, Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
        canvas.drawCircle(points[i], 2.0, dotPaint);
      }
    }

    // Draw labels
    if (!isLowEndDevice) {
      _drawLabels(canvas, size, padding, chartWidth, chartHeight, minValue, maxValue);
    }
  }

  void _drawGrid(Canvas canvas, Size size, double padding, double chartWidth, double chartHeight, Paint gridPaint) {
    // Vertical grid lines
    for (int i = 0; i <= 4; i++) {
      final x = padding + (i / 4) * chartWidth;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, padding + chartHeight),
        gridPaint,
      );
    }

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = padding + (i / 4) * chartHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(padding + chartWidth, y),
        gridPaint,
      );
    }
  }

  void _drawLabels(Canvas canvas, Size size, double padding, double chartWidth, double chartHeight, double minValue, double maxValue) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Y-axis labels (values)
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (maxValue - minValue) * (1 - i / 4);
      final y = padding + (i / 4) * chartHeight;
      
      textPainter.text = TextSpan(
        text: value.toStringAsFixed(0),
        style: textStyle.copyWith(fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // X-axis labels (simplified)
    final labelCount = data.length > 6 ? 6 : data.length;
    for (int i = 0; i < labelCount; i++) {
      final dataIndex = (i * (data.length - 1) / (labelCount - 1)).round();
      if (dataIndex < data.length) {
        final x = padding + (dataIndex / (data.length - 1)) * chartWidth;
        final label = data[dataIndex]['label']?.toString() ?? '';
        
        textPainter.text = TextSpan(
          text: label.length > 8 ? '${label.substring(0, 8)}...' : label,
          style: textStyle.copyWith(fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(
          canvas, 
          Offset(x - textPainter.width / 2, padding + chartHeight + 5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}