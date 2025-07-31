import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom color picker widget that shows a square preview
/// and opens a circular color palette when tapped
class XTCColorPicker extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final String? label;

  const XTCColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    this.label,
  });

  @override
  State<XTCColorPicker> createState() => _XTCColorPickerState();
}

class _XTCColorPickerState extends State<XTCColorPicker> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  Color _previewColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _previewColor = widget.selectedColor;
  }

  void _showColorPalette(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = _createOverlayEntry(context, position);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideColorPalette() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(BuildContext context, Offset position) {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _hideColorPalette,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Stack(
            children: [
              Positioned(
                left: math.max(20, position.dx - 100),
                top: math.max(100, position.dy - 200),
                child: Material(
                  color: Colors.transparent,
                  child: CircularColorPalette(
                    selectedColor: _previewColor,
                    onColorChanged: (color) {
                      setState(() {
                        _previewColor = color;
                      });
                    },
                    onColorSelected: (color) {
                      widget.onColorChanged(color);
                      _hideColorPalette();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              // Square color preview
              GestureDetector(
                onTap: () => _showColorPalette(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: widget.selectedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: widget.selectedColor.computeLuminance() > 0.5
                      ? Icon(
                          Icons.palette_outlined,
                          color: Colors.black54,
                          size: 20,
                        )
                      : Icon(
                          Icons.palette_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farbe auswählen',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      _getColorName(widget.selectedColor),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  String _getColorName(Color color) {
    if (color == Colors.red || (color.red > 200 && color.green < 100 && color.blue < 100)) return 'Rot';
    if (color == Colors.blue || (color.blue > 200 && color.red < 100 && color.green < 100)) return 'Blau';
    if (color == Colors.green || (color.green > 200 && color.red < 100 && color.blue < 100)) return 'Grün';
    if (color == Colors.yellow || (color.red > 200 && color.green > 200 && color.blue < 100)) return 'Gelb';
    if (color == Colors.orange || (color.red > 200 && color.green > 150 && color.blue < 100)) return 'Orange';
    if (color == Colors.purple || (color.red > 150 && color.blue > 150 && color.green < 100)) return 'Lila';
    if (color == Colors.pink || (color.red > 200 && color.blue > 150 && color.green > 100)) return 'Rosa';
    if (color == Colors.brown || (color.red > 100 && color.green > 60 && color.blue < 60)) return 'Braun';
    if (color == Colors.grey || (color.red > 100 && color.red < 150 && (color.red - color.green).abs() < 20)) return 'Grau';
    if (color == Colors.black || (color.red < 50 && color.green < 50 && color.blue < 50)) return 'Schwarz';
    if (color == Colors.white || (color.red > 200 && color.green > 200 && color.blue > 200)) return 'Weiß';
    return 'Benutzerdefiniert';
  }

  @override
  void dispose() {
    _hideColorPalette();
    super.dispose();
  }
}

/// Circular color palette widget
class CircularColorPalette extends StatefulWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onColorSelected;

  const CircularColorPalette({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onColorSelected,
  });

  @override
  State<CircularColorPalette> createState() => _CircularColorPaletteState();
}

class _CircularColorPaletteState extends State<CircularColorPalette> {
  static const double _paletteSize = 200.0;
  static const double _centerSize = 40.0;
  
  final List<Color> _predefinedColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _paletteSize,
      height: _paletteSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Color wheel segments
            ..._buildColorSegments(),
            
            // Center preview
            Center(
              child: Container(
                width: _centerSize,
                height: _centerSize,
                decoration: BoxDecoration(
                  color: widget.selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildColorSegments() {
    final segments = <Widget>[];
    final segmentCount = _predefinedColors.length;
    final anglePerSegment = 2 * math.pi / segmentCount;

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = i * anglePerSegment;
      final sweepAngle = anglePerSegment;
      final color = _predefinedColors[i];

      segments.add(
        CustomPaint(
          size: const Size(_paletteSize, _paletteSize),
          painter: ColorSegmentPainter(
            color: color,
            startAngle: startAngle,
            sweepAngle: sweepAngle,
            onTap: () {
              widget.onColorChanged(color);
              widget.onColorSelected(color);
            },
          ),
        ),
      );
    }

    return segments;
  }
}

/// Painter for individual color segments in the circular palette
class ColorSegmentPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final VoidCallback onTap;

  ColorSegmentPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.onTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = size.width / 6; // Creates ring shape

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Outer arc
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
    );
    
    // Inner arc (reverse direction)
    final endAngle = startAngle + sweepAngle;
    final innerStartX = center.dx + innerRadius * math.cos(endAngle);
    final innerStartY = center.dy + innerRadius * math.sin(endAngle);
    path.lineTo(innerStartX, innerStartY);
    
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle,
      -sweepAngle,
      false,
    );
    
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ColorSegmentPainter oldDelegate) {
    return oldDelegate.color != color ||
           oldDelegate.startAngle != startAngle ||
           oldDelegate.sweepAngle != sweepAngle;
  }

  @override
  bool hitTest(Offset position) {
    final center = const Offset(100, 100); // _paletteSize / 2
    final distance = (position - center).distance;
    
    if (distance < 33 || distance > 100) return false; // innerRadius to radius
    
    final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    final normalizedAngle = angle < 0 ? angle + 2 * math.pi : angle;
    
    return normalizedAngle >= startAngle && normalizedAngle <= startAngle + sweepAngle;
  }
}

/// Gesture detector that handles taps on the circular palette
class CircularPaletteGestureDetector extends StatelessWidget {
  final Widget child;
  final List<ColorSegmentPainter> segments;

  const CircularPaletteGestureDetector({
    super.key,
    required this.child,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        final localPosition = details.localPosition;
        
        for (final segment in segments) {
          if (segment.hitTest(localPosition)) {
            segment.onTap();
            break;
          }
        }
      },
      child: child,
    );
  }
}