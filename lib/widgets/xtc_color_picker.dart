import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A custom color picker widget with a square preview and circular color palette.
/// 
/// Shows a square color preview that opens a circular color palette when tapped.
/// The palette stays open while the user is touching and selecting colors.
class XtcColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final double size;

  const XtcColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    this.size = 60,
  });

  @override
  State<XtcColorPicker> createState() => _XtcColorPickerState();
}

class _XtcColorPickerState extends State<XtcColorPicker> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _showColorOverlay(context);
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _selectedColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              child: const Center(
                child: Icon(
                  Icons.palette,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ColorPalette(
              onColorSelected: _selectColor,
              onDismiss: () => Navigator.of(context).pop(),
              previewColor: _selectedColor,
            ),
          ),
        );
      },
    );
  }
}

/// Circular color palette widget with common XTC colors.
class ColorPalette extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;
  final VoidCallback onDismiss;
  final Color previewColor;

  const ColorPalette({
    super.key,
    required this.onColorSelected,
    required this.onDismiss,
    required this.previewColor,
  });

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  Color _currentPreview = Colors.transparent;

  // Common XTC/pill colors
  static const List<Color> _colors = [
    // Bright/neon colors
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.yellow,
    Colors.cyan,
    
    // Pastel colors
    Color(0xFFFFB6C1), // Light pink
    Color(0xFFADD8E6), // Light blue
    Color(0xFF90EE90), // Light green
    Color(0xFFFFE4B5), // Moccasin
    Color(0xFFFFA07A), // Light salmon
    Color(0xFFDDA0DD), // Plum
    Color(0xFFFFFF99), // Light yellow
    Color(0xFFAFEEEE), // Pale turquoise
    
    // Darker colors
    Color(0xFF8B0000), // Dark red
    Color(0xFF00008B), // Dark blue
    Color(0xFF006400), // Dark green
    Color(0xFF8B4513), // Saddle brown
    Color(0xFF4B0082), // Indigo
    Color(0xFF800080), // Purple
    Color(0xFF2F4F4F), // Dark slate gray
    Color(0xFF000000), // Black
  ];

  @override
  void initState() {
    super.initState();
    _currentPreview = widget.previewColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Don't dismiss on tap, only on outside tap
      onTap: () {},
      child: Container(
        width: 240,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Farbe wählen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Preview section
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _currentPreview,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Vorschau',
                  style: TextStyle(
                    color: _currentPreview.computeLuminance() > 0.5 
                        ? Colors.black 
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Color grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final color = _colors[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentPreview = color;
                        });
                        widget.onColorSelected(color);
                        widget.onDismiss();
                      },
                      onTapDown: (_) {
                        setState(() {
                          _currentPreview = color;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
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
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}