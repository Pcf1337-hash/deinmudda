import 'package:flutter/material.dart';
import '../models/xtc_entry.dart';

/// A widget for selecting XTC pill sizes with geometric shape representations.
class XtcSizeSelector extends StatelessWidget {
  final XtcSize selectedSize;
  final ValueChanged<XtcSize> onSizeChanged;
  final Color? color;

  const XtcSizeSelector({
    super.key,
    required this.selectedSize,
    required this.onSizeChanged,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Größe',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: XtcSize.values.map((size) {
            final isSelected = size == selectedSize;
            return GestureDetector(
              onTap: () => onSizeChanged(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? primaryColor
                        : Colors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Geometric representation
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: _buildGeometricShape(size, primaryColor, isSelected),
                    ),
                    const SizedBox(height: 8),
                    // Size label
                    Text(
                      size.displaySymbol,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? primaryColor : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGeometricShape(XtcSize size, Color color, bool isSelected) {
    final shapeColor = isSelected ? color : color.withOpacity(0.5);
    final strokeWidth = isSelected ? 3.0 : 2.0;
    
    switch (size) {
      case XtcSize.full:
        // Full circle
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: shapeColor.withOpacity(0.2),
            border: Border.all(color: shapeColor, width: strokeWidth),
          ),
        );
        
      case XtcSize.half:
        // Half circle - represents half of a whole pill
        return CustomPaint(
          size: const Size(40, 40),
          painter: _HalfCirclePainter(shapeColor, strokeWidth),
        );
        
      case XtcSize.quarter:
        // Quarter circle (pie slice)
        return CustomPaint(
          size: const Size(40, 40),
          painter: _QuarterCirclePainter(shapeColor, strokeWidth),
        );
        
      case XtcSize.eighth:
        // Eighth circle (smaller pie slice)
        return CustomPaint(
          size: const Size(40, 40),
          painter: _EighthCirclePainter(shapeColor, strokeWidth),
        );
    }
  }
}

/// Custom painter for half circle shape
class _HalfCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HalfCirclePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start angle (-π/2 radians = top)
      3.14159, // Sweep angle (π radians = 180 degrees = semicircle)
      true,
      fillPaint,
    );

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      3.14159,
      true,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for quarter circle shape
class _QuarterCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _QuarterCirclePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // Start angle (0 radians = right side)
      1.5708, // Sweep angle (π/2 radians = 90 degrees)
      true,
      fillPaint,
    );

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      1.5708,
      true,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for eighth circle shape
class _EighthCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _EighthCirclePainter(this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Fill
    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // Start angle (0 radians = right side)
      0.7854, // Sweep angle (π/4 radians = 45 degrees)
      true,
      fillPaint,
    );

    // Stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      0.7854,
      true,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}